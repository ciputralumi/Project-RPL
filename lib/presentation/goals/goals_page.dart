import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/saving_goal_provider.dart';
import '../../data/models/saving_goal_model.dart';
import 'goal_detail_page.dart';
import 'add_goal_modal.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<SavingGoalProvider>().goals;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Target Tabungan"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddGoalModal(),
        ),
        child: const Icon(Icons.add),
      ),

      body: goals.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (_, i) {
                final goal = goals[i];
                final keyId = goal.key as int;

                return _goalCard(context, goal, keyId);
              },
            ),
    );
  }

  // ---------------------------------------------------------------------
  // GOAL CARD
  // ---------------------------------------------------------------------
  Widget _goalCard(
    BuildContext context,
    SavingGoalModel goal,
    int keyId,
  ) {
    final double percent = (goal.saved / goal.target).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalDetailPage(
              goal: goal,
              keyId: keyId,      // ← PARAMETER YANG BENAR
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey.shade300,
              color: Colors.blueAccent,
            ),

            const SizedBox(height: 6),

            Text(
              "Rp ${goal.saved.toInt()} / Rp ${goal.target.toInt()}",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "Belum ada target tabungan",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tambahkan target dan mulai menabung.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
