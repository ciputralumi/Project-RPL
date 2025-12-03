import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../themes/category_colors.dart';

class EditTransactionModal extends StatefulWidget {
  final TransactionModel tx;

  const EditTransactionModal({super.key, required this.tx});

  @override
  State<EditTransactionModal> createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  late TextEditingController noteC;
  late TextEditingController amountC;

  late DateTime selectedDate;
  late bool isIncome;
  late String category;

  @override
  void initState() {
    super.initState();
    noteC = TextEditingController(text: widget.tx.note);
    amountC = TextEditingController(text: widget.tx.amount.toString());
    selectedDate = widget.tx.date;
    isIncome = widget.tx.isIncome;
    category = widget.tx.category;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = settings.categories;
    final catColor = CategoryColors.getColor(category);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Edit Transaksi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // NOTE
            TextField(
              controller: noteC,
              decoration: InputDecoration(
                labelText: "Catatan",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),

            // AMOUNT
            TextField(
              controller: amountC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Jumlah (${settings.currencySymbol})",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),

            // DATE PICKER
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat("dd MMM yyyy").format(selectedDate)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
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
                  onChanged: (v) {
                    if (v != null) setState(() => category = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // INCOME / EXPENSE
            Row(
              children: [
                _typeChip("Income", true),
                const SizedBox(width: 8),
                _typeChip("Outcome", false),
              ],
            ),

            const SizedBox(height: 28),

            // SAVE BTN
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: catColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String label, bool incomeValue) {
    final selected = (incomeValue == isIncome);
    final color = incomeValue
        ? CategoryColors.getColor("Gaji")
        : CategoryColors.getColor("Belanja");

    return GestureDetector(
      onTap: () => setState(() => isIncome = incomeValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> _save() async {
    final provider = context.read<TransactionProvider>();

    final updated = TransactionModel(
      id: widget.tx.id,
      note: noteC.text.isEmpty ? category : noteC.text,
      amount: double.tryParse(amountC.text) ?? widget.tx.amount,
      category: category,
      isIncome: isIncome,
      date: selectedDate,
    );

    await provider.updateTransaction(updated);

    Navigator.pop(context);
  }
}
