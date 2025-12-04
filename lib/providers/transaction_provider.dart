import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/transaction_model.dart';
import '../providers/account_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>('transactions');

  // Filter: 0 = Daily, 1 = Weekly, 2 = Monthly, 3 = Annual
  int filterIndex = 2;

  // -------------------------------------------------------------
  // LIST ALL TRANSACTIONS (Newest first)
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

  double get totalBalance => totalIncome - totalExpense;

  // -------------------------------------------------------------
  // ADD TRANSACTION ✓ AUTO APPLY BALANCE
  // -------------------------------------------------------------
  Future<void> addTransaction(
  TransactionModel tx, {
  required AccountProvider accountProvider,
}) async {
  // Simpan ke Hive → dapat hiveKey
  final hiveKey = await _box.add(tx);

  // Jangan set tx.key, biarkan Hive yang handle

  await accountProvider.applyTransaction(tx);

  notifyListeners();
}


  // -------------------------------------------------------------
  // DELETE TRANSACTION ✓ AUTO REVERT BALANCE
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
  // UPDATE TRANSACTION ✓ AUTO ADJUST ACCOUNT BALANCE
  // -------------------------------------------------------------
  Future<void> updateTransaction(
  int key,
  TransactionModel newTx, {
  required AccountProvider accountProvider,
  required TransactionModel oldTx,
}) async {

  await accountProvider.updateTransaction(
    oldTx: oldTx,
    newTx: newTx,
  );

  await _box.put(key, newTx);

  notifyListeners();
}


  // -------------------------------------------------------------
  // ANALYTICS (unchanged)
  // -------------------------------------------------------------
  Map<String, double> groupByMonth() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      final key = "${_monthName(tx.date.month)} ${tx.date.year}";
      result.update(key, (prev) => prev + tx.amount, ifAbsent: () => tx.amount);
    }

    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, double> groupByWeek() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      final int week = ((tx.date.day - 1) / 7).floor() + 1;
      final key = "Minggu $week";

      result.update(key, (prev) => prev + tx.amount, ifAbsent: () => tx.amount);
    }

    return Map.fromEntries(
      result.entries.toList()
        ..sort((a, b) {
          final ai = int.parse(a.key.replaceAll("Minggu ", ""));
          final bi = int.parse(b.key.replaceAll("Minggu ", ""));
          return ai.compareTo(bi);
        }),
    );
  }

  Map<String, double> groupByCategory() {
    final Map<String, double> result = {};

    for (final tx in allTransactions) {
      result.update(tx.category, (prev) => prev + tx.amount,
          ifAbsent: () => tx.amount);
    }

    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

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
