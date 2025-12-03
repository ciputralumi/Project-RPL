// lib/presentation/budget/budget_editor.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../data/models/budget_model.dart';
import '../../themes/category_colors.dart';

class BudgetEditor extends StatefulWidget {
  final BudgetModel? existing;

  const BudgetEditor({super.key, this.existing});

  @override
  State<BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<BudgetEditor> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _goalCtrl;
  late TextEditingController _maxCtrl;

  String? selectedCategory;

  // Grab categories from your CategoryColors helper
  late final List<String> categories;

  @override
  void initState() {
    super.initState();

    categories = CategoryColors.mapKeys;

    _goalCtrl = TextEditingController(text: widget.existing?.goalName ?? "");
    _maxCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.maxBudget.toStringAsFixed(0)
          : "",
    );

    selectedCategory = widget.existing?.category;
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    _maxCtrl.dispose();
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      isEdit ? "Edit Anggaran" : "Tambah Anggaran",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                // CATEGORY DROPDOWN
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
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
                      v == null || v.isEmpty ? "Pilih kategori" : null,
                ),

                const SizedBox(height: 16),

                // GOAL NAME INPUT
                TextFormField(
                  controller: _goalCtrl,
                  decoration: _input("Tujuan Anggaran (contoh: Beli Laptop)"),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null,
                ),

                const SizedBox(height: 16),

                // MAX BUDGET INPUT
                TextFormField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _input("Batas Anggaran (Rp)"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Wajib diisi";
                    final n = double.tryParse(
                        v.replaceAll('.', '').replaceAll(',', ''));
                    if (n == null) return "Masukkan angka valid";
                    if (n <= 0) return "Harus lebih dari 0";
                    return null;
                  },
                ),

                const SizedBox(height: 26),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4CFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _save(context, isEdit),
                    child: Text(
                      isEdit ? "Simpan Perubahan" : "Tambahkan",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
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
  // SAVE HANDLER
  // ====================================================
  void _save(BuildContext context, bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BudgetProvider>();

    // Normalize and parse number (strip thousand separators if present)
    final maxText =
        _maxCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
    final maxBudget = double.tryParse(maxText) ?? 0;
    if (selectedCategory == null) {
      // Shouldn't happen because validator prevents it, but just in case
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih kategori")));
      return;
    }

    final goalName = _goalCtrl.text.trim();

    if (isEdit) {
      // Use the existing Hive object's key to update store
      final existing = widget.existing!;
      final key = existing.key as int;

      final updated = BudgetModel(
        category: selectedCategory!,
        maxBudget: maxBudget,
        goalName: goalName,
      );

      // provider expects (int key, BudgetModel model)
      provider.updateBudget(key, updated);
    } else {
      final newBudget = BudgetModel(
        category: selectedCategory!,
        maxBudget: maxBudget,
        goalName: goalName,
      );

      provider.addBudget(newBudget);
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );
  }
}
