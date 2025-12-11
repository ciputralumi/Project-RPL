import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
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
          // =============================
          // ⟳ UNDO TRANSFER (JIKA ADA)
          // =============================
          if (tx.transferGroupId != null)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () async {
                final confirm = await _confirmUndo(context);
                if (confirm == true) {
                  final txProv = context.read<TransactionProvider>();
                  final accProv = context.read<AccountProvider>();

                  // Undo kedua transaksi
                  await txProv.undoTransfer(
                    groupId: tx.transferGroupId!,
                    accountProvider: accProv,
                  );

                  Navigator.pop(context);
                }
              },
            ),

          // EDIT
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

          // DELETE
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Tidak izinkan delete transaksi transfer secara individual!!!
              if (tx.transferGroupId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Gunakan tombol Undo untuk membatalkan transfer."),
                  ),
                );
                return;
              }

              final confirm = await _confirmDelete(context);
              if (confirm == true) {
                final txProv = context.read<TransactionProvider>();
                final accProv = context.read<AccountProvider>();

                final hiveKey = tx.key as int;

                await txProv.deleteTransaction(
                  hiveKey,
                  accountProvider: accProv,
                );

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(catColor, settings),
            const SizedBox(height: 30),
            _infoRow("Catatan", tx.note),
            _infoRow("Kategori", tx.category),
            _infoRow("Jenis", tx.isIncome ? "Pemasukan" : "Pengeluaran"),
            _infoRow("Tanggal", _fmtDate(tx.date)),
            _infoRow("Akun", "ID: ${tx.accountId}"),
            if (tx.transferGroupId != null)
              _infoRow("Transfer ID", tx.transferGroupId!),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // HEADER (Jumlah)
  // =======================================================
  Widget _header(Color catColor, SettingsProvider s) {
    final amount = "${s.currencySymbol}${_format(tx.amount)}";

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: catColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: catColor.withOpacity(0.25),
            child: Icon(
              tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: catColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: tx.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // ITEM INFO
  // =======================================================
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black54),
              )),
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
  // HELPERS
  // =======================================================
  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  String _format(double x) {
    final s = x.round().toString().split('').reversed.join();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.substring(i, (i + 3 > s.length) ? s.length : i + 3));
    }

    return parts.reversed.map((e) => e.split('').reversed.join()).join('.');
  }

  // =======================================================
  // DIALOG DELETE
  // =======================================================
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Hapus Transaksi?"),
        content: const Text(
            "Transaksi ini akan dihapus dan saldo akun akan dikembalikan."),
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

  // =======================================================
  // DIALOG UNDO TRANSFER
  // =======================================================
  Future<bool?> _confirmUndo(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Batalkan Transfer?"),
        content: const Text(
            "Dua transaksi transfer akan dihapus dan saldo akun akan dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Batalkan"),
          ),
        ],
      ),
    );
  }
}
