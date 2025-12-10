import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/monthly_budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/monthly_budget_model.dart';
import '../../themes/category_colors.dart';
import 'monthly_budget_editor.dart';

class MonthlyBudgetPage extends StatelessWidget {
  const MonthlyBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MonthlyBudgetProvider, TransactionProvider>(
      builder: (_, prov, txProv, __) {
        final list = prov.budgets; // <-- getter dari provider
        final tx = txProv.allTransactions;

        final now = DateTime.now();
        final month = now.month;
        final year = now.year;

        // Filter hanya bulan ini
        final currentList = list
            .where((b) => b.month == month && b.year == year)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FA),
          appBar: AppBar(
            title: const Text(
              "Anggaran Bulanan",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF2F4CFF),
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const MonthlyBudgetEditor(),
              );
            },
          ),

          body: currentList.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentList.length,
                  itemBuilder: (_, i) {
                    final b = currentList[i];
                    final keyId = b.key;

                    final used = tx
                        .where((t) => t.category == b.category && !t.isIncome)
                        .fold(0.0, (a, t) => a + t.amount);

                    final progress =
                        (used / b.limit).clamp(0.0, 1.0).toDouble();

                    return _item(context, b, used, progress, keyId);
                  },
                ),
        );
      },
    );
  }

  Widget _item(BuildContext context, MonthlyBudgetModel b,
      double used, double progress, int keyId) {
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
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => MonthlyBudgetEditor(existing: b),
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
            "Rp ${_fmt(used)} / Rp ${_fmt(b.limit)}",
            style: const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "Belum ada anggaran bulan ini",
            style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, int keyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Anggaran?"),
        content: const Text("Data anggaran bulanan ini akan dihapus."),
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
          )
        ],
      ),
    );
  }

  String _fmt(double x) {
    return x
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}
