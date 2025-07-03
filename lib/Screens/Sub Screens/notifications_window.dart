import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsWindow extends StatelessWidget {
  const NotificationsWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Hardcoded example notifications
    final notifications = [
      {
        'title': 'Garbage Collection Alert',
        'message': 'Garbage truck will arrive in your area within 10 minutes',
        'time': now.subtract(const Duration(minutes: 15)),
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Today\'s Collection',
        'message': 'Today we collect: Organic waste',
        'time': now.subtract(const Duration(hours: 2)),
        'icon': Icons.recycling,
        'color': Colors.green,
      },
      {
        'title': 'Recycling Confirmation',
        'message':
            'You\'ve given plastic waste to Green Earth Recycling Center',
        'time': now.subtract(const Duration(days: 1)),
        'icon': Icons.check_circle,
        'color': Colors.teal,
      },
      {
        'title': 'App Update',
        'message': 'New version 2.1.0 available with improved waste tracking',
        'time': now.subtract(const Duration(days: 3)),
        'icon': Icons.system_update,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', textAlign: TextAlign.center),
        centerTitle: true, // This centers the title
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            elevation: 2,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: Colors.white,
                ),
              ),
              title: Text(
                notification['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['message'] as String),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(notification['time'] as DateTime)} • ${timeFormat.format(notification['time'] as DateTime)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Handle notification tap
              },
            ),
          );
        },
      ),
    );
  }
}
