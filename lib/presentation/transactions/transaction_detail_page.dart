import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../themes/category_colors.dart';
import 'edit_transaction_modal.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel tx;

  const TransactionDetailPage({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final catColor = CategoryColors.getColor(tx.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EditTransactionModal(tx: tx),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await _confirmDelete(context);
              if (confirm == true) {
                await context
                    .read<TransactionProvider>()
                    .deleteTransaction(tx.id);

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(catColor, settings),
            const SizedBox(height: 24),
            _infoRow("Catatan", tx.note),
            _infoRow("Kategori", tx.category),
            _infoRow("Jenis", tx.isIncome ? "Pemasukan" : "Pengeluaran"),
            _infoRow("Tanggal", _fmtDate(tx.date)),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // HEADER AMOUNT CARD
  // =======================================================
  Widget _header(Color catColor, SettingsProvider s) {
    final amount = "${s.currencySymbol}${_format(tx.amount)}";

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: catColor.withValues(alpha: 0.25),
            child: Icon(
              tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: catColor,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: tx.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // INFO ROW
  // =======================================================
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // DATE FORMAT
  // =======================================================
  String _fmtDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  // =======================================================
  // NUMBER FORMAT
  // =======================================================
  String _format(double x) {
    final s = x.round().toString().split('').reversed.join();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.substring(i, (i + 3 > s.length) ? s.length : i + 3));
    }

    return parts.reversed
        .map((e) => e.split('').reversed.join())
        .join('.');
  }

  // =======================================================
  // CONFIRM DELETE DIALOG
  // =======================================================
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Transaksi?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
