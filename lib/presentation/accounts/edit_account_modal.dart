import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';
import '../../data/models/account_model.dart';

class EditAccountModal extends StatefulWidget {
  final int accountKey;
  final AccountModel acc;

  const EditAccountModal({
    super.key,
    required this.accountKey,
    required this.acc,
  });

  @override
  State<EditAccountModal> createState() => _EditAccountModalState();
}

class _EditAccountModalState extends State<EditAccountModal> {
  late TextEditingController nameC;
  late TextEditingController bankC;
  late TextEditingController balanceC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.acc.name);
    bankC = TextEditingController(text: widget.acc.type);
    balanceC = TextEditingController(text: widget.acc.balance.toString());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      maxChildSize: 0.95,
      minChildSize: 0.50,
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
            const Text("Edit Akun",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _input("Nama Akun", nameC),
            const SizedBox(height: 14),

            _input("Bank / Sumber", bankC),
            const SizedBox(height: 14),

            _input("Saldo", balanceC, isNumber: true),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Simpan Perubahan",
                  style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 14),

            TextButton(
              onPressed: _delete,
              child: const Text("Hapus Akun",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _save() async {
    final updated = AccountModel(
      name: nameC.text,
      type: bankC.text,
      balance: double.tryParse(balanceC.text) ?? 0,
    );

    await context
        .read<AccountProvider>()
        .updateAccount(widget.accountKey, updated);

    Navigator.pop(context);
  }

  Future<void> _delete() async {
    await context.read<AccountProvider>().deleteAccount(widget.accountKey);
    Navigator.pop(context);
  }
}
