import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../themes/category_colors.dart';
import '../../data/models/budget_model.dart';
import 'budget_editor.dart';

class BudgetTabGeneral extends StatelessWidget {
  const BudgetTabGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (_, budgetProv, txProv, __) {
        final budgets = budgetProv.budgets;
        final tx = txProv.allTransactions;

        if (budgets.isEmpty) return _emptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: budgets.length,
          itemBuilder: (_, i) {
            final b = budgets[i];
            final keyId = b.key;

            // Hitung pengeluaran kategori
            final used = tx
                .where((t) => t.category == b.category && !t.isIncome)
                .fold(0.0, (a, b) => a + b.amount);

            final progress =
                (used / b.maxBudget).clamp(0.0, 1.0).toDouble();

            return _budgetCard(context, b, used, progress, keyId);
          },
        );
      },
    );
  }

  // ============================================================
  /// CARD ITEM
  // ============================================================
  Widget _budgetCard(
      BuildContext context,
      BudgetModel b,
      double used,
      double progress,
      int keyId,
      ) {
    final color = CategoryColors.getColor(b.category);

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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.category, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b.category,
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
                    builder: (_) => BudgetEditor(existing: b),
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

          Text(
            "Rp ${_fmt(used)} / Rp ${_fmt(b.maxBudget)}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

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
          Icon(Icons.account_balance_wallet,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "Belum ada anggaran",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tambahkan anggaran untuk mulai memantau\npengeluaran tiap kategori.",
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
        title: const Text("Hapus Anggaran?"),
        content: const Text("Anggaran ini akan dihapus secara permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BudgetProvider>().deleteBudget(keyId);
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
  /// NUM FORMATTER
  // ============================================================
  String _fmt(double x) {
    return x
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}
