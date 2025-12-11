import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/saving_goal_model.dart';
import '../../providers/saving_goal_provider.dart';

class EditGoalModal extends StatefulWidget {
  final SavingGoalModel goal;
  final int keyId;

  const EditGoalModal({
    super.key,
    required this.goal,
    required this.keyId,
  });

  @override
  State<EditGoalModal> createState() => _EditGoalModalState();
}

class _EditGoalModalState extends State<EditGoalModal> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _addSavingCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.goal.title;
    _targetCtrl.text = widget.goal.target.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edit Target: ${widget.goal.title}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- TITLE ----------------
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: "Nama Target",
            ),
          ),

          const SizedBox(height: 15),

          // ---------------- TARGET ----------------
          TextField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Total Target (Rp)",
            ),
          ),

          const SizedBox(height: 15),

          // ---------------- ADD SAVINGS ----------------
          TextField(
            controller: _addSavingCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Tambah Tabungan",
            ),
          ),

          const SizedBox(height: 25),

          // ---------------- BUTTONS ----------------
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final provider = context.read<SavingGoalProvider>();
                    await provider.deleteGoal(widget.keyId);
                    Navigator.pop(context);
                  },
                  child: const Text("Hapus"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    final provider = context.read<SavingGoalProvider>();

                    final newTitle = _titleCtrl.text.trim();
                    final newTarget = double.tryParse(_targetCtrl.text) ?? widget.goal.target;
                    final addAmount = double.tryParse(_addSavingCtrl.text) ?? 0;

                    final updated = SavingGoalModel(
                      title: newTitle,
                      target: newTarget,
                      saved: widget.goal.saved + addAmount,
                      deadline: widget.goal.deadline,
                    );

                    await provider.updateGoal(widget.keyId, updated);

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
