import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/account_provider.dart';
import '../../themes/category_colors.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedType = "Outcome"; // Income / Outcome
  String? selectedCategory;
  String? selectedAccountId;

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = settings.categories;

    final accProvider = context.watch<AccountProvider>();
    final accounts = accProvider.accounts;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              "Tambah Transaksi",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            /// TYPE PICKER
            Row(
              children: [
                _typeButton("Income"),
                const SizedBox(width: 10),
                _typeButton("Outcome"),
              ],
            ),

            const SizedBox(height: 18),

            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Jumlah Uang (${settings.currencySymbol})",
                prefixIcon: const Icon(Icons.payments_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// CATEGORY
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: CategoryColors.getColor(c),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(c),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
              decoration: InputDecoration(
                labelText: "Kategori",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// ACCOUNT DROPDOWN (WITH BALANCE)
            DropdownButtonFormField<String>(
              value: selectedAccountId,
              items: accounts.map((acc) {
                final balance = _money(acc.balance, settings.currencySymbol);

                return DropdownMenuItem(
                  value: acc.key.toString(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${acc.name} (${acc.bank})"),
                      Text(
                        balance,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedAccountId = v),
              decoration: InputDecoration(
                labelText: "Dari Akun / Dompet",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v == null ? "Pilih akun" : null,
            ),

            const SizedBox(height: 18),

            /// NOTE
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: "Catatan (opsional)",
                prefixIcon: const Icon(Icons.edit_note_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// DATE PICKER
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat("dd MMM yyyy").format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4CFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveTransaction,
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // =============================
  // BUTTON TYPE PICKER
  // =============================
  Widget _typeButton(String type) {
    final bool active = (selectedType == type);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2F4CFF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? Colors.transparent : Colors.grey.shade400,
            ),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================
  // DATE PICKER
  // =============================
  Future<void> _pickDate() async {
    final pick = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pick != null) {
      setState(() => selectedDate = pick);
    }
  }

  // =============================
  // SAVE TRANSACTION
  // =============================
  void _saveTransaction() async {
    if (amountController.text.isEmpty ||
        selectedCategory == null ||
        selectedAccountId == null) {
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;

    final newTx = TransactionModel(
      note:
          noteController.text.isEmpty ? selectedCategory! : noteController.text,
      category: selectedCategory!,
      amount: amount,
      isIncome: (selectedType == "Income"),
      date: selectedDate,
      accountId: int.parse(selectedAccountId!),
    );

    final txProvider = context.read<TransactionProvider>();
    final accProvider = context.read<AccountProvider>();

    await txProvider.addTransaction(
      newTx,
      accountProvider: accProvider,
    );

    Navigator.pop(context);
  }

  // =============================
  // MONEY FORMAT
  // =============================
  String _money(double amount, String symbol) {
    final f = NumberFormat("#,###", "id_ID");
    return "$symbol${f.format(amount)}";
  }
}
