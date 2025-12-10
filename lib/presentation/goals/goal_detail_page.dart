import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/saving_goal_model.dart';
import '../../providers/saving_goal_provider.dart';
import '../../providers/saving_log_provider.dart';
import '../../data/models/saving_log_model.dart';

import 'add_saving_modal.dart';
import 'edit_goal_modal.dart';

class GoalDetailPage extends StatelessWidget {
  final SavingGoalModel goal;

  const GoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingGoalProvider>();

    // Cegah error kalau goal sudah dihapus
    final g = provider.goals.firstWhere(
      (x) => x.key == goal.key,
      orElse: () => goal,
    );

    final double safeTarget = g.target == 0 ? 1 : g.target;
    final progress = (g.saved / safeTarget).clamp(0, 1.0);
    final percentage = (progress * 100).toStringAsFixed(0);
    final remaining = g.target - g.saved;

    final logs =
        context.watch<SavingLogProvider>().logsForGoal(g.key as int);

    Color barColor;
    if (progress < 0.3) {
      barColor = Colors.red;
    } else if (progress < 0.7) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreMenu(context, g, provider);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddSavingModal(goal: g),
          );
        },
        label: const Text("Tambah Tabungan"),
        icon: const Icon(Icons.savings),
        backgroundColor: const Color(0xFF2F4CFF),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== CARD PROGRESS ====================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress Tabungan",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$percentage%",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Target: Rp ${g.target.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.toDouble(),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: barColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Terkumpul: Rp ${g.saved.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Sisa: Rp ${remaining.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 13),
                  ),

                  if (g.deadline != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Deadline: ${g.deadline!.toLocal().toString().split(' ')[0]}",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================== RIWAYAT TABUNGAN ====================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Tabungan",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (logs.isEmpty)
                    const Text(
                      "Belum ada riwayat tabungan.",
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    ...logs.map((log) {
                      return ListTile(
                        leading: const Icon(Icons.savings,
                            color: Color(0xFF2F4CFF)),
                        title: Text(
                          "+ Rp ${log.amount.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          log.date.toLocal().toString().split(' ')[0],
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ======================= MORE MENU =========================

  void _showMoreMenu(
      BuildContext context, SavingGoalModel g, SavingGoalProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Target"),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => EditGoalModal(goal: g),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus Target"),
                onTap: () async {
                  Navigator.pop(context);
                  await provider.deleteGoal(g.key as int);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
