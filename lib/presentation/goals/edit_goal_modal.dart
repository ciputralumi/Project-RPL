import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saving_goal_provider.dart';
import '../../data/models/saving_goal_model.dart';

class EditGoalModal extends StatefulWidget {
  final SavingGoalModel goal;

  const EditGoalModal({super.key, required this.goal});

  @override
  State<EditGoalModal> createState() => _EditGoalModalState();
}

class _EditGoalModalState extends State<EditGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _addSavingCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.goal.title;
    _targetCtrl.text = widget.goal.target.toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SavingGoalProvider>();
    final key = widget.goal.key; // Hive key

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Edit Target: ${widget.goal.title}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),

          // Edit title
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: "Nama Target"),
          ),

          const SizedBox(height: 10),

          // Edit target amount
          TextFormField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: "Total Target (Rp)"),
          ),

          const SizedBox(height: 16),

          // Add saving
          TextFormField(
            controller: _addSavingCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Tambah Tabungan",
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              /// DELETE BUTTON
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    await provider.deleteGoal(key);
                    Navigator.pop(context);
                  },
                  child: const Text("Hapus"),
                ),
              ),

              const SizedBox(width: 10),

              /// SAVE BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = SavingGoalModel(
                      title: _titleCtrl.text,
                      target: double.tryParse(_targetCtrl.text) ?? widget.goal.target,
                      saved: widget.goal.saved,
                      deadline: widget.goal.deadline,
                    );

                    await provider.updateGoal(key, updated);

                    if (_addSavingCtrl.text.isNotEmpty) {
                      final amount = double.tryParse(_addSavingCtrl.text);
                      if (amount != null) {
                        await provider.addSaving(key, amount);
                      }
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
