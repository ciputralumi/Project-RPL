import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';

class AccountDetailPage extends StatelessWidget {
  final AccountModel account;
  final int accountKey;

  const AccountDetailPage({
    super.key,
    required this.account,
    required this.accountKey,
  });

  @override
  Widget build(BuildContext context) {
    final txProv = context.watch<TransactionProvider>();
    final s = context.watch<SettingsProvider>();

    // Semua transaksi milik akun ini
    final txList = txProv.allTransactions
        .where((t) => t.accountId == accountKey)
        .toList();

    // Hitung income / expense akun ini
    final income = txList
        .where((x) => x.isIncome)
        .fold(0.0, (a, b) => a + b.amount);

    final expense = txList
        .where((x) => !x.isIncome)
        .fold(0.0, (a, b) => a + b.amount);

    final currentBalance = income - expense;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: Text(account.name),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(currentBalance, s),
            const SizedBox(height: 18),

            _statRow(income, expense, currentBalance, s),
            const SizedBox(height: 24),

            const Text(
              "Transaksi Akun Ini",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            if (txList.isEmpty)
              Center(
                child: Text(
                  "Belum ada transaksi",
                  style: TextStyle(color: Colors.black45),
                ),
              )
            else
              ...txList.map((tx) => _txTile(tx, s)),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // HEADER SALDO
  // =============================================================
  Widget _headerCard(double balance, SettingsProvider s) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saldo Saat Ini",
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            "${s.currencySymbol}${_fmt(s.convert(balance))}",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // STATISTIK
  // =============================================================
  Widget _statRow(double income, double expense, double balance, SettingsProvider s) {
    return Row(
      children: [
        Expanded(
          child: _statCard("Income", s.convert(income), Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Expense", s.convert(expense), Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Balance", s.convert(balance), const Color(0xFF2F4CFF)),
        ),
      ],
    );
  }

  Widget _statCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            _fmt(value),
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TRANSACTION TILE
  // =============================================================
  Widget _txTile(TransactionModel tx, SettingsProvider s) {
    final color = tx.isIncome ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(
            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.note,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  tx.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "${s.currencySymbol}${_fmt(s.convert(tx.amount))}",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }

  // =============================================================
  // FORMATTER
  // =============================================================
  String _fmt(double x) {
    return x
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ".");
  }
}
