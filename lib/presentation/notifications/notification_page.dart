import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sample notifications - in a real app, this would come from a provider
          _notificationItem(
            title: 'Budget Alert',
            message: 'You have exceeded your monthly budget for Food & Drinks.',
            time: '2 hours ago',
            isRead: false,
          ),
          _notificationItem(
            title: 'Transaction Reminder',
            message: 'Don\'t forget to log your transportation expenses.',
            time: '1 day ago',
            isRead: true,
          ),
          _notificationItem(
            title: 'Savings Goal',
            message: 'You\'re 80% towards your vacation savings goal!',
            time: '3 days ago',
            isRead: true,
          ),
          _notificationItem(
            title: 'Account Update',
            message: 'Your account balance has been updated.',
            time: '1 week ago',
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _notificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: isRead ? Colors.transparent : Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isRead ? Colors.black87 : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
