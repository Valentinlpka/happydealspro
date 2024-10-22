import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/notification.dart';
import 'package:happy_deals_pro/services/notification_service.dart';

class NotificationBell extends StatelessWidget {
  final String userId;
  final NotificationService _notificationService = NotificationService();

  NotificationBell({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getNotifications(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.notifications);
        }
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _showNotificationMenu(context, notifications),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationMenu(
      BuildContext context, List<NotificationModel> notifications) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  subtitle: Text(notification.timestamp.toString()),
                  onTap: () {
                    _notificationService.markAsRead(notification.id);
                    _navigateToRelatedPage(context, notification);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToRelatedPage(
      BuildContext context, NotificationModel notification) {
    // Implement navigation based on notification type
    switch (notification.type) {
      case 'referral':
        // Navigate to referral page
        break;
      case 'job_application':
        // Navigate to job applications page
        break;
      case 'new_order':
        // Navigate to orders page
        break;
      case 'deal_express':
        // Navigate to deal express page
        break;
    }
  }
}
