import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saving_goal_provider.dart';
import '../../data/models/saving_goal_model.dart';

class AddGoalModal extends StatefulWidget {
  const AddGoalModal({super.key});

  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tambah Target Tabungan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            const SizedBox(height: 14),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Nama Target"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Wajib diisi" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Target (Rp)"),
              validator: (v) =>
                  v == null || double.tryParse(v) == null ? "Masukkan angka valid" : null,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                final goal = SavingGoalModel(
                  title: _titleCtrl.text,
                  target: double.parse(_targetCtrl.text),
                );

                context.read<SavingGoalProvider>().addGoal(goal);
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}