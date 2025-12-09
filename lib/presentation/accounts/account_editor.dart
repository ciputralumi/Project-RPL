import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';
import '../../data/models/account_model.dart';

class AccountEditor extends StatefulWidget {
  final AccountModel? existing;
  final int? keyId;

  const AccountEditor({super.key, this.existing, this.keyId});

  @override
  State<AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<AccountEditor> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _bankCtrl;
  late TextEditingController _balanceCtrl;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.existing?.name ?? "");
    _bankCtrl = TextEditingController(text: widget.existing?.bank ?? "");
    _balanceCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.balance.toStringAsFixed(0)
          : "",
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bankCtrl.dispose();
    _balanceCtrl.dispose();
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
                Row(
                  children: [
                    Text(
                      isEdit ? "Edit Akun" : "Tambah Akun",
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

                const SizedBox(height: 16),

                // NAME
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _input("Nama Akun (contoh: Rekening Utama)"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                ),

                const SizedBox(height: 16),

                // BANK
                TextFormField(
                  controller: _bankCtrl,
                  decoration: _input("Nama Bank / Tipe (BCA, Cash, Mandiri)"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                ),

                const SizedBox(height: 16),

                // BALANCE
                TextFormField(
                  controller: _balanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _input("Saldo Awal"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Wajib diisi";
                    final n = double.tryParse(v);
                    if (n == null) return "Masukkan angka valid";
                    if (n < 0) return "Tidak boleh negatif";
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

  // ============================================================
  // SAVE HANDLER
  // ============================================================
  void _save(BuildContext context, bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<AccountProvider>();

    final name = _nameCtrl.text.trim();
    final bank = _bankCtrl.text.trim();
    final balance = double.tryParse(_balanceCtrl.text.trim()) ?? 0;

    final model = AccountModel(
      name: name,
      bank: bank,
      balance: balance,
    );

    if (isEdit) {
      prov.updateAccount(widget.keyId!, model);
    } else {
      prov.addAccount(model);
    }

    Navigator.pop(context);
  }

  // ============================================================
  // INPUT STYLE
  // ============================================================
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