import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percent;
  final Color color;

  const GoalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            color: color,
            backgroundColor: color.withOpacity(0.18),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            (percent * 100).toStringAsFixed(0) + '%',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
