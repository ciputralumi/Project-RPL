import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/saving_goal_provider.dart';
import '../../providers/saving_log_provider.dart';
import '../../data/models/saving_goal_model.dart';
import '../../data/models/saving_log_model.dart';

class AddSavingModal extends StatefulWidget {
  final SavingGoalModel goal;

  const AddSavingModal({super.key, required this.goal});

  @override
  State<AddSavingModal> createState() => _AddSavingModalState();
}

class _AddSavingModalState extends State<AddSavingModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tambah Tabungan",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal (Rp)"),
              validator: (v) =>
                  v == null || double.tryParse(v) == null
                      ? "Masukkan angka valid"
                      : null,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final amount = double.parse(_amountCtrl.text);
                final key = widget.goal.key as int;

                // Tambah nominal tabungan
                await context
                    .read<SavingGoalProvider>()
                    .addSaving(key, amount);

                // Tambah log tabungan
                await context.read<SavingLogProvider>().addLog(
                      SavingLogModel(
                        goalKey: key,
                        amount: amount,
                        date: DateTime.now(),
                      ),
                    );

                Navigator.pop(context);
              },
              child: const Text("Tambah"),
            )
          ],
        ),
      ),
    );
  }
}