import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final positive = amount >= 0;
    return Dismissible(
      key: Key(title + date + amount.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (onDelete != null) onDelete!();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(iconData, color: AppBarTheme().iconTheme?.color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (positive ? '+ ' : '- ') + 'Rp${amount.abs().toStringAsFixed(0)}',
                  style: TextStyle(color: positive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(date, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
