import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saving_goal_provider.dart';

class AddSavingModal extends StatefulWidget {
  final int keyId;

  const AddSavingModal({super.key, required this.keyId});

  @override
  State<AddSavingModal> createState() => _AddSavingModalState();
}

class _AddSavingModalState extends State<AddSavingModal> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Tambah Tabungan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Jumlah (Rp)"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_ctrl.text) ?? 0;
              context.read<SavingGoalProvider>().addSaving(widget.keyId, amount);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }
}
