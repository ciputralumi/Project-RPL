import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/account_model.dart';
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

  double get totalBalance {
    final bal = totalIncome - totalExpense;
    return bal < 0 ? 0 : bal;
  }

  double get totalIncomeAll {
    return allTransactions
        .where((e) => e.isIncome)
        .fold(0.0, (a, b) => a + b.amount);
  }

  double get totalExpenseAll {
    return allTransactions
        .where((e) => !e.isIncome)
        .fold(0.0, (a, b) => a + b.amount);
  }

  // -------------------------------------------------------------
  // ADD TRANSACTION ✓ AUTO APPLY BALANCE
  // -------------------------------------------------------------
  Future<void> addTransaction(
    TransactionModel tx, {
    required AccountProvider accountProvider,
  }) async {
    // Simpan ke Hive → dapat hiveKey
    final hiveKey = await _box.add(tx);
    hiveKey;
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

  Future<void> undoTransfer({
    required String groupId,
    required AccountProvider accountProvider,
  }) async {
    // Ambil dua transaksi yang termasuk dalam transfer group
    final matches =
        _box.values.where((t) => t.transferGroupId == groupId).toList();

    // Transfer valid harus ada tepat 2 transaksi
    if (matches.length != 2) return;

    for (final tx in matches) {
      final key = tx.key as int;

      // kembalikan saldo akun
      await accountProvider.revertTransaction(tx);

      // hapus dari Hive
      await _box.delete(key);
    }

    // Tidak ada _transactions → langsung notifyListeners
    notifyListeners();
  }

// =======================================================
// UPDATE TRANSFER GROUP
// =======================================================
  Future<void> updateTransferGroup({
    required String transferGroupId, // <-- ganti int → String
    required TransactionModel oldOutTx,
    required TransactionModel oldInTx,
    required double newAmount,
    required int newFromId,
    required int newToId,
    required String newNote,
    required DateTime newDate,
    required AccountProvider accountProvider,
  }) async {
    // Step 1 — Undo dua transaksi lama
    await accountProvider.revertTransaction(oldOutTx);
    await accountProvider.revertTransaction(oldInTx);

    // Step 2 — Create transaksi baru OUT
    final newOutTx = TransactionModel(
      amount: newAmount,
      isIncome: false,
      category: "Transfer Out",
      note: newNote,
      date: newDate,
      accountId: newFromId,
      transferGroupId: transferGroupId, // now String
    );

    // Step 3 — Create transaksi baru IN
    final newInTx = TransactionModel(
      amount: newAmount,
      isIncome: true,
      category: "Transfer In",
      note: newNote,
      date: newDate,
      accountId: newToId,
      transferGroupId: transferGroupId, // now String
    );

    // Replace OUT
    await _box.put(oldOutTx.key, newOutTx);

    // Replace IN
    await _box.put(oldInTx.key, newInTx);

    // Apply saldo
    await accountProvider.applyTransaction(newOutTx);
    await accountProvider.applyTransaction(newInTx);

    notifyListeners();
  }

  // -------------------------------------------------------------
  // ADD INITIAL BALANCE SAAT AKUN DIBUAT
  // -------------------------------------------------------------
  Future<void> addInitialBalanceTransaction(
    AccountModel acc, // Akun yang baru ditambahkan
    int accountKey, // Hive Key dari akun tersebut
  ) async {
    // Gunakan nilai absolute agar tidak ada masalah dengan minus
    final amount = acc.balance.abs();

    // Hanya buat transaksi jika saldo awal > 0
    if (amount <= 0) return;

    final tx = TransactionModel(
      note: "Saldo Awal - ${acc.name}",
      category: "Lainnya",
      amount: amount,
      isIncome: true, // Saldo Awal = Pemasukan
      date: DateTime.now(),
      accountId: accountKey,
    );

    //    await accountProvider.applyTransaction(newOutTx);
    //await addTransaction(tx, accountProvider: null);
    // Saya akan berasumsi ada method _saveTx(tx) yang menangani penyimpanan & notifikasi.
    await _saveTx(tx);
  }

  // -------------------------------------------------------------
  // REVERT TRANSACTION SAAT AKUN TERHAPUS
  // -------------------------------------------------------------
  /// Mencatat Reversal Saldo Akun sebagai transaksi Expense saat akun dihapus.
  Future<void> revertAccountTransaction(
    AccountModel acc,
    int accountKey,
  ) async {
    final amount = acc.balance.abs();

    // Hanya buat transaksi reversal jika saldo akhir > 0
    if (amount <= 0) return;

    final tx = TransactionModel(
      note: "Penghapusan Akun - ${acc.name}",
      category: "Lainnya",
      amount: amount,
      isIncome: false, // Reversal = Pengeluaran
      date: DateTime.now(),
      accountId: accountKey,
    );

    await _saveTx(tx);
  }

  Future<void> _saveTx(TransactionModel tx) async {
    await _box.add(tx);
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
