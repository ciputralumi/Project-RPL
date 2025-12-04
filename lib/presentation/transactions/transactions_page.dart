import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../themes/category_colors.dart';
import 'add_transaction_modal.dart';
import 'edit_transaction_modal.dart';
import '../../providers/account_provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String search = "";
  String filterType = "All"; // All, Income, Expense
  String sort = "Terbaru"; // Terbaru, Terlama, Terbesar, Terkecil
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color get primary => const Color(0xFF6C4EFF); // soft purple main

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    List<TransactionModel> list = txProvider.allTransactions;

    // FILTER
    if (filterType == "Income") {
      list = list.where((t) => t.isIncome).toList();
    } else if (filterType == "Expense") {
      list = list.where((t) => !t.isIncome).toList();
    }

    // SEARCH
    if (search.isNotEmpty) {
      list = list
          .where((t) =>
              t.note.toLowerCase().contains(search.toLowerCase()) ||
              t.category.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }

    // SORT
    list.sort((a, b) {
      switch (sort) {
        case "Terlama":
          return a.date.compareTo(b.date);
        case "Terbesar":
          return b.amount.compareTo(a.amount);
        case "Terkecil":
          return a.amount.compareTo(b.amount);
        default:
          return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Semua Transaksi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () => _openAddModal(),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [primary, primary.withOpacity(0.9)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: primary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 26),
                    ),
                  )
                ],
              ),
            ),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => search = v),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    hintText: "Cari transaksi atau kategori...",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixIcon: search.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => search = "");
                            },
                            child:
                                Icon(Icons.close, color: Colors.grey.shade500),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // FILTERS + SORT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _chip("All", filterType == "All",
                      () => setState(() => filterType = "All")),
                  const SizedBox(width: 8),
                  _chip("Income", filterType == "Income",
                      () => setState(() => filterType = "Income")),
                  const SizedBox(width: 8),
                  _chip("Expense", filterType == "Expense",
                      () => setState(() => filterType = "Expense")),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (v) => setState(() => sort = v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "Terbaru", child: Text("Terbaru")),
                      PopupMenuItem(value: "Terlama", child: Text("Terlama")),
                      PopupMenuItem(
                          value: "Terbesar", child: Text("Nominal Terbesar")),
                      PopupMenuItem(
                          value: "Terkecil", child: Text("Nominal Terkecil")),
                    ],
                    child: Row(
                      children: [
                        Text(sort,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down,
                            color: Colors.grey.shade700),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // LIST / EMPTY
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: list.isEmpty
                    ? _emptyIllustration()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        itemCount: list.length,
                        itemBuilder: (_, i) =>
                            _dismissibleTile(list[i], settings),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    final color = CategoryColors.getColor(
      label == "Income"
          ? "Gaji"
          : label == "Expense"
              ? "Belanja"
              : "Lainnya",
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _emptyIllustration() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.receipt_long,
                  size: 68, color: primary.withOpacity(0.9)),
            ),
            const SizedBox(height: 18),
            Text("Belum ada transaksi",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
                "Tambahkan transaksi pertama kamu untuk mulai mencatat pengeluaran & pemasukan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => _openAddModal(),
              child: const Text("Tambah Transaksi"),
            )
          ],
        ),
      ),
    );
  }

  Widget _dismissibleTile(TransactionModel tx, SettingsProvider s) {
    return Dismissible(
      key: ValueKey(tx.key), // FIX
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        final accProvider = context.read<AccountProvider>();

        await context.read<TransactionProvider>().deleteTransaction(
              tx.key as int,
              accountProvider: accProvider,
            );
      },

      child: GestureDetector(
        onTap: () => _openEditModal(tx),
        child: _buildTransactionTile(tx, s),
      ),
    );
  }

  void _openEditModal(TransactionModel tx) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => EditTransactionModal(tx: tx));
  }

  void _openAddModal() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const AddTransactionModal());
  }

  Widget _buildTransactionTile(TransactionModel tx, SettingsProvider s) {
    final catColor = CategoryColors.getColor(tx.category);
    final amountText = "${s.currencySymbol}${_format(tx.amount)}";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: catColor.withOpacity(0.14),
              child: Icon(
                  tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: catColor)),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tx.note,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(tx.category,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54))),
                const SizedBox(width: 6),
                Text(_niceDate(tx.date),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black45)),
              ])
            ]),
          ),
          const SizedBox(width: 12),
          Text(amountText,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: tx.isIncome ? Colors.green : Colors.red,
                  fontSize: 14)),
        ],
      ),
    );
  }

  String _format(double x) {
    final s = x.round().toString().split('').reversed.join();
    final parts = <String>[];
    for (var i = 0; i < s.length; i += 3)
      parts.add(s.substring(i, (i + 3 > s.length) ? s.length : i + 3));
    return parts
        .map((e) => e.split('').reversed.join())
        .toList()
        .reversed
        .join('.');
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
