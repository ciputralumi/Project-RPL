import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/transaction_model.dart';
import '../providers/account_provider.dart';
import '../providers/saving_goal_provider.dart';
import '../providers/saving_log_provider.dart';
import '../data/models/saving_log_model.dart';
import '../data/models/saving_goal_model.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>('transactions');

  int filterIndex = 2; // 0=daily,1=weekly,2=monthly,3=annual

  // -------------------------------------------------------------
  // LIST ALL TRANSACTIONS
  // -------------------------------------------------------------
  List<TransactionModel> get allTransactions {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<TransactionModel> get transactions => allTransactions;

  // -------------------------------------------------------------
  // FILTER SYSTEM
  // -------------------------------------------------------------
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return allTransactions.where((tx) {
      switch (filterIndex) {
        case 0:
          return tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;
        case 1:
          return now.difference(tx.date).inDays <= 7;
        case 2:
          return tx.date.year == now.year && tx.date.month == now.month;
        case 3:
          return tx.date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  void setFilter(int index) {
    filterIndex = index;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // TOTALS
  // -------------------------------------------------------------
  double get totalIncome => filteredTransactions
      .where((e) => e.isIncome)
      .fold(0.0, (a, b) => a + b.amount);

  double get totalExpense => filteredTransactions
      .where((e) => !e.isIncome)
      .fold(0.0, (a, b) => a + b.amount);

  double get totalBalance {
    final bal = totalIncome - totalExpense;
    return bal < 0 ? 0 : bal;
  }

  // -------------------------------------------------------------
  // ADD TRANSACTION + APPLY BALANCE + AUTO-SAVING
  // -------------------------------------------------------------
  Future<void> addTransaction(
    TransactionModel tx, {
    required AccountProvider accountProvider,
    SavingGoalProvider? savingGoalProvider,
    SavingLogProvider? savingLogProvider,
  }) async {
    try {
      await accountProvider.applyTransaction(tx);

      // auto saving — jika kategori == goal.title
      if (!tx.isIncome && savingGoalProvider != null) {
        SavingGoalModel? matched;
        for (final g in savingGoalProvider.goals) {
          if (g.title == tx.category) matched = g;
        }

        if (matched != null) {
          final int goalKey = matched.key as int;

          await savingGoalProvider.addSaving(goalKey, tx.amount);

          if (savingLogProvider != null) {
            await savingLogProvider.addLog(
              SavingLogModel(
                goalKey: goalKey,
                amount: tx.amount,
                date: tx.date,
              ),
            );
          }
        }
      }

      await _box.add(tx);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // DELETE TRANSACTION
  // -------------------------------------------------------------
  Future<void> deleteTransaction(
    int key, {
    required AccountProvider accountProvider,
  }) async {
    final tx = _box.get(key);
    if (tx == null) return;

    await accountProvider.revertTransaction(tx);
    await _box.delete(key);
    notifyListeners();
  }

  // -------------------------------------------------------------
  // UPDATE TRANSACTION
  // -------------------------------------------------------------
  Future<void> updateTransaction(
    int key,
    TransactionModel newTx, {
    required AccountProvider accountProvider,
    required TransactionModel oldTx,
  }) async {
    await accountProvider.revertTransaction(oldTx);

    try {
      await accountProvider.applyTransaction(newTx);
      await _box.put(key, newTx);
      notifyListeners();
    } catch (e) {
      await accountProvider.applyTransaction(oldTx);
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // UNDO TRANSFER (FIXED & CLEAN)
  // -------------------------------------------------------------
  Future<void> undoTransfer({
    required String groupId,
    required AccountProvider accountProvider,
  }) async {
    final matches =
        _box.values.where((tx) => tx.transferGroupId == groupId).toList();

    if (matches.length != 2) return;

    for (final tx in matches) {
      final key = tx.key as int;

      await accountProvider.revertTransaction(tx);
      await _box.delete(key);
    }

    notifyListeners();
  }

  // -------------------------------------------------------------
  // UPDATE TRANSFER GROUP
  // -------------------------------------------------------------
  Future<void> updateTransferGroup({
    required String transferGroupId,
    required TransactionModel oldOutTx,
    required TransactionModel oldInTx,
    required double newAmount,
    required int newFromId,
    required int newToId,
    required String newNote,
    required DateTime newDate,
    required AccountProvider accountProvider,
  }) async {
    await accountProvider.revertTransaction(oldOutTx);
    await accountProvider.revertTransaction(oldInTx);

    final newOutTx = TransactionModel(
      amount: newAmount,
      isIncome: false,
      category: "Transfer Out",
      note: newNote,
      date: newDate,
      accountId: newFromId,
      transferGroupId: transferGroupId,
    );

    final newInTx = TransactionModel(
      amount: newAmount,
      isIncome: true,
      category: "Transfer In",
      note: newNote,
      date: newDate,
      accountId: newToId,
      transferGroupId: transferGroupId,
    );

    try {
      await _box.put(oldOutTx.key, newOutTx);
      await _box.put(oldInTx.key, newInTx);

      await accountProvider.applyTransaction(newOutTx);
      await accountProvider.applyTransaction(newInTx);

      notifyListeners();
    } catch (e) {
      await accountProvider.applyTransaction(oldOutTx);
      await accountProvider.applyTransaction(oldInTx);
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // ANALYTICS
  // -------------------------------------------------------------
  Map<String, double> groupByMonth() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      final key = "${_monthName(tx.date.month)} ${tx.date.year}";
      result.update(key, (prev) => prev + tx.amount, ifAbsent: () => tx.amount);
    }

    return Map.fromEntries(
        result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  Map<String, double> groupByWeek() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      final week = ((tx.date.day - 1) / 7).floor() + 1;
      final key = "Minggu $week";
      result.update(key, (prev) => prev + tx.amount,
          ifAbsent: () => tx.amount);
    }

    return result;
  }

  Map<String, double> groupByCategory() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      result.update(tx.category, (prev) => prev + tx.amount,
          ifAbsent: () => tx.amount);
    }

    return result;
  }

  // -------------------------------------------------------------
  // MONTH NAME HELPER (FIXED)
  // -------------------------------------------------------------
  String _monthName(int month) {
    const names = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return names[month - 1];
  }
}
