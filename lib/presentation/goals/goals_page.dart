import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/saving_goal_provider.dart';
import '../../data/models/saving_goal_model.dart';
import 'edit_goal_modal.dart';
import 'add_goal_modal.dart';
import 'goal_detail_page.dart';   // ❗ Tambahkan ini

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingGoalProvider>();
    final goals = provider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Target Tabungan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddGoalModal(),
              );
            },
          )
        ],
      ),

      body: goals.isEmpty
          ? const Center(child: Text("Belum ada target tabungan."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: goals.length,
              itemBuilder: (context, i) {
                final g = goals[i];
                final progress = (g.saved / g.target).clamp(0, 1.0);
                final percentage = (progress * 100).toStringAsFixed(0);
                final remaining = g.target - g.saved;

                return InkWell(
                  onTap: () {
                    // ❗ Pindah ke GoalDetailPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoalDetailPage(goal: g),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title + Percent
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              g.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "$percentage%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Progress bar
                        LinearProgressIndicator(
                          value: progress.toDouble(),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: progress < 0.3
                              ? Colors.red
                              : progress < 0.7
                                  ? Colors.orange
                                  : Colors.green,
                        ),

                        const SizedBox(height: 12),

                        /// Money info
                        Text("Terkumpul: Rp ${g.saved.toStringAsFixed(0)}"),
                        Text("Target: Rp ${g.target.toStringAsFixed(0)}"),
                        Text("Sisa: Rp ${remaining.toStringAsFixed(0)}"),

                        if (g.deadline != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Deadline: ${g.deadline!.toLocal().toString().split(' ')[0]}",
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
