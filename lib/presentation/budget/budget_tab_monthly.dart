import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/monthly_budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../themes/category_colors.dart';
import '../../data/models/monthly_budget_model.dart';
import 'monthly_budget_editor.dart';

class BudgetTabMonthly extends StatelessWidget {
  const BudgetTabMonthly({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MonthlyBudgetProvider, TransactionProvider>(
      builder: (_, monthlyProv, txProv, __) {
        final budgets = monthlyProv.budgets;
        final tx = txProv.allTransactions;

        if (budgets.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: budgets.length,
          itemBuilder: (_, i) {
            final b = budgets[i];
            final keyId = b.key;

            // Filter transaksi sesuai bulan & kategori
            final monthTx = tx.where((t) {
              return t.category == b.category &&
                  !t.isIncome &&
                  t.date.month == b.month &&
                  t.date.year == b.year;
            }).toList();

            final spent = monthTx.fold(0.0, (a, t) => a + t.amount);
            final progress = (spent / b.limit).clamp(0.0, 1.0);

            return _budgetCard(
              context: context,
              budget: b,
              spent: spent,
              progress: progress,
              keyId: keyId,
            );
          },
        );
      },
    );
  }

  // ============================================================
  /// BUDGET CARD
  // ============================================================
  Widget _budgetCard({
    required BuildContext context,
    required MonthlyBudgetModel budget,
    required double spent,
    required double progress,
    required int keyId,
  }) {
    final color = CategoryColors.getColor(budget.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE ROW
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.calendar_month, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${budget.category} — ${_monthName(budget.month)} ${budget.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => MonthlyBudgetEditor(existing: budget),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _delete(context, keyId),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // MONEY SPENT
          Text(
            "Rp ${_fmt(spent)} / Rp ${_fmt(budget.limit)}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            progress >= 1
                ? "⚠️ Anggaran habis"
                : "${(progress * 100).toStringAsFixed(0)}% digunakan",
            style: TextStyle(
              color: progress >= 1 ? Colors.red : Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  /// EMPTY STATE
  // ============================================================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "Belum ada anggaran bulanan",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tambahkan anggaran bulanan untuk memulai.",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  /// DELETE CONFIRMATION
  // ============================================================
  void _delete(BuildContext context, int keyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Anggaran Bulanan?"),
        content: const Text("Data ini akan dihapus secara permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MonthlyBudgetProvider>().delete(keyId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  /// HELPERS
  // ============================================================
  String _fmt(double x) {
    return x
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }

  String _monthName(int m) {
    const list = [
      "Jan","Feb","Mar","Apr","Mei","Jun",
      "Jul","Agu","Sep","Okt","Nov","Des"
    ];
    return list[m - 1];
  }
}
