import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';
import '../../data/models/account_model.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final nameC = TextEditingController();
  final bankC = TextEditingController();
  final balanceC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.90,
      minChildSize: 0.4,
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
            const Text("Tambah Akun",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _input("Nama Akun", nameC),
            const SizedBox(height: 14),

            _input("Bank / Sumber", bankC),
            const SizedBox(height: 14),

            _input("Saldo Awal", balanceC,
                isNumber: true),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Simpan",
                  style: TextStyle(color: Colors.white)),
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

  void _save() async {
    final acc = AccountModel(
      name: nameC.text,
      bank: bankC.text,
      balance: double.tryParse(balanceC.text) ?? 0,
    );

    await context.read<AccountProvider>().addAccount(acc);

    Navigator.pop(context);
  }
}
