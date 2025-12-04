import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class TransferModal extends StatefulWidget {
  const TransferModal({super.key});

  @override
  State<TransferModal> createState() => _TransferModalState();
}

class _TransferModalState extends State<TransferModal> {
  int? fromId;
  int? toId;
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                "Transfer Antar Akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const SizedBox(height: 18),

          // Dari Akun
          const Text("Dari Akun",
              style: TextStyle(fontWeight: FontWeight.w600)),
          DropdownButtonFormField<int>(
            value: fromId,
            items: accounts
                .map((acc) => DropdownMenuItem<int>(
                      value: acc.key as int,
                      child: Text("${acc.name} — Rp ${_fmt(acc.balance)}"),
                    ))
                .toList(),
            onChanged: (v) => setState(() => fromId = v),
            decoration: _input(),
          ),

          const SizedBox(height: 16),

          // Ke Akun
          const Text("Ke Akun", style: TextStyle(fontWeight: FontWeight.w600)),
          DropdownButtonFormField<int>(
            value: toId,
            items: accounts
                .map((acc) => DropdownMenuItem<int>(
                      value: acc.key as int,
                      child: Text("${acc.name} — Rp ${_fmt(acc.balance)}"),
                    ))
                .toList(),
            onChanged: (v) => setState(() => toId = v),
            decoration: _input(),
          ),

          const SizedBox(height: 16),

          // Nominal
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: _input().copyWith(hintText: "Nominal"),
          ),

          const SizedBox(height: 16),

          // Catatan
          TextField(
            controller: noteCtrl,
            decoration: _input().copyWith(hintText: "Catatan (opsional)"),
          ),

          const SizedBox(height: 24),

          // Tombol Transfer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4CFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _doTransfer(context),
              child: const Text(
                "Transfer",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _input() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF4F4F6),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ================================================================
  // 🔥 FUNGSI TRANSFER
  // ================================================================
  void _doTransfer(BuildContext context) async {
    if (fromId == null || toId == null) return;

    final amount = double.tryParse(amountCtrl.text) ?? 0;
    if (amount <= 0) return;

    final accProv = context.read<AccountProvider>();
    final txProv = context.read<TransactionProvider>();

    // Generate transferGroupId unik (untuk mengikat 2 transaksi transfer)
    final transferGroupId =
        "TRF-${DateTime.now().millisecondsSinceEpoch}-${fromId}-${toId}";

    final now = DateTime.now();

    // 1) Jalankan logic saldo antar akun
    await accProv.transfer(
      fromId: fromId!,
      toId: toId!,
      amount: amount,
    );

    // 2) Buat transaksi "Transfer Out"
    final txOut = TransactionModel(
      amount: amount,
      isIncome: false,
      category: "Transfer Out",
      note: noteCtrl.text,
      date: now,
      accountId: fromId!,
      transferGroupId: transferGroupId, // NEW 🔥
    );

    await txProv.addTransaction(
      txOut,
      accountProvider: accProv,
    );

    // 3) Buat transaksi "Transfer In"
    final txIn = TransactionModel(
      amount: amount,
      isIncome: true,
      category: "Transfer In",
      note: noteCtrl.text,
      date: now,
      accountId: toId!,
      transferGroupId: transferGroupId, // NEW 🔥
    );

    await txProv.addTransaction(
      txIn,
      accountProvider: accProv,
    );

    Navigator.pop(context);
  }

  // ================================================================
  // TOAST / SNACKBAR
  // ================================================================
  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Formatting saldo
  String _fmt(double x) {
    return x
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}
