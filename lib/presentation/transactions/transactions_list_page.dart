import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../themes/category_colors.dart';
import 'edit_transaction_modal.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  String searchQuery = "";
  String selectedCategory = "Semua";
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color get primary => const Color(0xFF6C4EFF);

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    final all = tx.allTransactions;

    final categories = ["Semua", ...{for (final t in all) t.category}];

    final filtered = all.where((t) {
      final matchSearch = t.note.toLowerCase().contains(searchQuery.toLowerCase());
      final matchCategory = selectedCategory == "Semua" ? true : t.category == selectedCategory;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: const Text("Semua Transaksi"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // SEARCH + ACTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                        hintText: "Cari catatan atau kategori...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: searchQuery.isNotEmpty
                            ? GestureDetector(onTap: () { _searchController.clear(); setState(() => searchQuery = ""); }, child: Icon(Icons.close, color: Colors.grey.shade600))
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showCategoryPicker(context, categories),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                    child: Row(children: [Icon(Icons.filter_list, color: primary), const SizedBox(width: 6), Text(selectedCategory, style: const TextStyle(fontWeight: FontWeight.w600))]),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 6),

          // CATEGORY LIST HORIZONTAL (quick taps)
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final active = selectedCategory == cat;
                final color = cat == "Semua" ? primary : CategoryColors.getColor(cat);
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? color.withOpacity(0.14) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: active ? color.withOpacity(0.18) : Colors.grey.shade200),
                      boxShadow: active ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))] : null,
                    ),
                    child: Row(
                      children: [
                        if (cat != "Semua") Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                        if (cat != "Semua") const SizedBox(width: 8),
                        Text(cat, style: TextStyle(fontWeight: FontWeight.w600, color: active ? color : Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),

          const SizedBox(height: 12),

          // LIST
          Expanded(
            child: filtered.isEmpty
                ? Center(child: _emptyState())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      return _tile(t, settings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.inbox, size: 64, color: primary.withOpacity(0.9)),
          ),
          const SizedBox(height: 18),
          Text("Belum ada transaksi di sini", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
          const SizedBox(height: 6),
          Text("Gunakan tombol tambah untuk memasukkan transaksi pertama kamu", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _tile(TransactionModel t, SettingsProvider s) {
    final amount = "${s.currencySymbol}${_fmt(t.amount)}";
    final color = CategoryColors.getColor(t.category);

    return GestureDetector(
      onTap: () => _openEditModal(t),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.14), child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.note, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  Text(t.category, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  const SizedBox(width: 8),
                  Text(_niceDate(t.date), style: const TextStyle(fontSize: 12, color: Colors.black38)),
                ]),
              ]),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: TextStyle(fontWeight: FontWeight.w800, color: t.isIncome ? Colors.green : Colors.red)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _confirmDelete(t),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade300),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker(BuildContext context, List<String> categories) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            const Text("Pilih Kategori", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...categories.map((c) => ListTile(title: Text(c), onTap: () => Navigator.pop(context, c))).toList(),
            const SizedBox(height: 12),
          ]),
        );
      },
    );

    if (chosen != null) setState(() => selectedCategory = chosen);
  }

  void _confirmDelete(TransactionModel t) {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text("Hapus transaksi?"),
        content: const Text("Transaksi akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () {
            context.read<TransactionProvider>().deleteTransaction(t.id);
            Navigator.pop(context);
          }, child: const Text("Hapus"))
        ],
      );
    });
  }

  void _openEditModal(TransactionModel tx) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => EditTransactionModal(tx: tx));
  }

  String _fmt(double x) {
    final s = x.abs().round().toString().split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < s.length; i += 3) {
      chunks.add(s.substring(i, min(i + 3, s.length)));
    }
    return chunks.map((e) => e.split('').reversed.join()).toList().reversed.join('.');
  }

  String _niceDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return "Hari ini";
    if (diff == 1) return "Kemarin";
    if (diff < 7) return "${diff} hari lalu";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
