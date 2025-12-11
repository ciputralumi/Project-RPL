import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/account_model.dart';
import '../../providers/account_provider.dart';
import 'dart:math';
import 'account_editor.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (_, prov, __) {
        final acc1 = prov.accounts;
        final accounts = acc1
            .where((acc) => acc.key != null)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FA),

          appBar: AppBar(
            title: const Text(
              "Akun & Dompet",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Color(0xFF448AFF),
            elevation: 0,
            foregroundColor: Colors.black,
          ),

          floatingActionButton: FloatingActionButton(
            heroTag: "add_account",
            backgroundColor: const Color(0xFF2F4CFF),
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const AccountEditor(),
              );
            },
          ),

          body: accounts.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (_, i) {
                    final acc = accounts[i];
                    final keyId = acc.key as int;
                    return _accountCard(context, acc, keyId);
                  },
                ),
        );
      },
    );
  }

  // =============================================================
  // ACCOUNT CARD COMPONENT
  // =============================================================
  Widget _accountCard(BuildContext context, AccountModel acc, int keyId) {
    final s = context.read<SettingsProvider>();
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F0FF),
            child: const Icon(Icons.account_balance_wallet,
                color: Color(0xFF2F4CFF)),
          ),
          const SizedBox(width: 14),

          // TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  acc.type,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // BALANCE
          Text(
            "${s.currencySymbol}${_fmt(s.convert(acc.balance))}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F4CFF),
            ),
          ),

          const SizedBox(width: 6),

          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => AccountEditor(
                  existing: acc,
                  keyId: keyId,
                ),
              );
            },
          ),

          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, keyId),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EMPTY STATE
  // =============================================================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "Belum ada akun",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tambahkan akun dompet atau rekening\nuntuk mulai melacak sumber uang.",
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

  // =============================================================
  // DELETE CONFIRMATION
  // =============================================================
  void _confirmDelete(BuildContext context, int keyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text("""
Akun ini akan dihapus.
Pastikan tidak digunakan di transaksi jika ingin menjaga histori yang rapi.
"""),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AccountProvider>().deleteAccount(keyId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FORMAT NUMBER
  // =============================================================
  String _fmt(double x) {
    if (x.isNaN || x.isInfinite) return "0,00"; 

    // SELALU format ke 2 angka desimal
    String numString = x.abs().toStringAsFixed(2); 
    
    final parts = numString.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00'; 

    // Logika Pemisah Ribuan
    final s = integerPart.split('').reversed.join();
    final separatedParts = <String>[];

    for (int i = 0; i < s.length; i += 3) {
      separatedParts.add(s.substring(i, min(i + 3, s.length)));
    }

    String formattedInteger = separatedParts
        .map((e) => e.split('').reversed.join())
        .toList()
        .reversed
        .join('.'); // Titik (.) sebagai pemisah ribuan
        
    // Gabungkan dengan koma (,) sebagai pemisah desimal
    return "$formattedInteger,$decimalPart"; 
  }
  
}