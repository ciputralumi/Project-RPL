import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/monthly_budget_provider.dart';
import '../../data/models/monthly_budget_model.dart';
import '../../themes/category_colors.dart';

class MonthlyBudgetEditor extends StatefulWidget {
  final MonthlyBudgetModel? existing;

  const MonthlyBudgetEditor({super.key, this.existing});

  @override
  State<MonthlyBudgetEditor> createState() => _MonthlyBudgetEditorState();
}

class _MonthlyBudgetEditorState extends State<MonthlyBudgetEditor> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountCtrl;
  String? selectedCategory;

  late final List<String> categories;

  @override
  void initState() {
    super.initState();

    categories = CategoryColors.mapKeys;

    _amountCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.limit.toStringAsFixed(0)
          : "",
    );

    selectedCategory = widget.existing?.category;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // HEADER
                Row(
                  children: [
                    Text(
                      isEdit
                          ? "Edit Anggaran Bulanan"
                          : "Tambah Anggaran Bulanan",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),

                const SizedBox(height: 14),

                // CATEGORY SELECT
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  decoration: _input("Kategori"),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Pilih kategori" : null,
                ),

                const SizedBox(height: 14),

                // AMOUNT INPUT
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _input("Total Anggaran Bulanan (Rp)"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Wajib diisi";
                    final n = double.tryParse(v.replaceAll('.', ''));
                    if (n == null || n <= 0) return "Masukkan angka valid";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _save(context, isEdit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4CFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEdit ? "Simpan Perubahan" : "Tambahkan",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================
  // SAVE DATA
  // ====================================================
  void _save(BuildContext context, bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<MonthlyBudgetProvider>();

    final amount = double.parse(
      _amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
    );

    final now = DateTime.now();

    if (isEdit) {
      final existing = widget.existing!;
      final keyId = existing.key as int;

      final updated = MonthlyBudgetModel(
        category: selectedCategory!,
        limit: amount,
        month: existing.month,
        year: existing.year,
      );

      prov.update(keyId, updated);
    } else {
      final newBudget = MonthlyBudgetModel(
        category: selectedCategory!,
        limit: amount,
        month: now.month,
        year: now.year,
      );

      prov.add(newBudget);
    }

    Navigator.pop(context);
  }

  // ====================================================
  // INPUT DECORATION
  // ====================================================
  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
    );
  }
}
