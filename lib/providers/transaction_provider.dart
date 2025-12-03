import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>('transactions');

  // Filter: 0 = Daily, 1 = Weekly, 2 = Monthly, 3 = Annual
  int filterIndex = 2;

  // ============================================================
  // GET ALL TRANSACTIONS (SORTED NEWEST FIRST)
  // ============================================================
  List<TransactionModel> get allTransactions {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Alias untuk kompatibilitas
  List<TransactionModel> get transactions => allTransactions;

  // ============================================================
  // FILTERED TRANSACTIONS
  // ============================================================
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return allTransactions.where((tx) {
      switch (filterIndex) {
        case 0: // Daily
          return tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;

        case 1: // Weekly
          return now.difference(tx.date).inDays <= 7;

        case 2: // Monthly
          return tx.date.year == now.year &&
              tx.date.month == now.month;

        case 3: // Annual
          return tx.date.year == now.year;

        default:
          return true;
      }
    }).toList();
  }

  // ============================================================
  // SET FILTER
  // ============================================================
  void setFilter(int index) {
    filterIndex = index;
    notifyListeners();
  }

  // ============================================================
  // TOTALS
  // ============================================================
  double get totalIncome =>
      filteredTransactions.where((e) => e.isIncome).fold(0.0, (a, b) => a + b.amount);

  double get totalExpense =>
      filteredTransactions.where((e) => !e.isIncome).fold(0.0, (a, b) => a + b.amount);

  double get totalBalance => totalIncome - totalExpense;

  // ============================================================
  // ADD TRANSACTION
  // ============================================================
  Future<void> addTransaction(TransactionModel tx) async {
    await _box.put(tx.id, tx);
    notifyListeners();
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // ============================================================
  // UPDATE TRANSACTION (FIX)
  // ============================================================
  Future<void> updateTransaction(TransactionModel updatedTx) async {
    await _box.put(updatedTx.id, updatedTx);
    notifyListeners();
  }

  // =======================================================
  // ANALYTICS FUNCTIONS
  // =======================================================

// 1. Group by Month (Jan 2025 → total pengeluaran)
// -------------------------------------------------------
Map<String, double> groupByMonth() {
  final Map<String, double> result = {};

  for (final tx in allTransactions) {
    final key = "${_monthName(tx.date.month)} ${tx.date.year}";
    result.update(key, (prev) => prev + tx.amount,
        ifAbsent: () => tx.amount);
  }

  return Map.fromEntries(
    result.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)),
  );
}

// 2. Group by Week
// -------------------------------------------------------
// (minggu dihitung berdasar "Week 1", "Week 2", dst) 
Map<String, double> groupByWeek() {
  final Map<String, double> result = {};

  for (final tx in allTransactions) {
    // hitung minggu ke berapa dalam bulan
    final int week = ((tx.date.day - 1) / 7).floor() + 1;
    final key = "Minggu $week";

    result.update(key, (prev) => prev + tx.amount,
        ifAbsent: () => tx.amount);
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

// 3. Group by Category (Food → total)
// -------------------------------------------------------
Map<String, double> groupByCategory() {
  final Map<String, double> result = {};

  for (final tx in allTransactions) {
    result.update(tx.category, (prev) => prev + tx.amount,
        ifAbsent: () => tx.amount);
  }

  // urut paling besar → kecil
  return Map.fromEntries(
    result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)),
  );
}

// Helper bulan
String _monthName(int month) {
  const names = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
    "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
  ];
  return names[month - 1];
}

}
