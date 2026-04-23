import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        centerTitle: true,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                for (var n in notifications) {
                  if (!n.isRead) notificationProvider.markAsRead(n.id);
                }
              },
              child: const Text('Прочитать все'),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(notifications, notificationProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Уведомлений пока нет',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Мы сообщим вам о статусе ваших заказов здесь',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List notifications, NotificationProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Theme.of(context).cardTheme.color 
                : (Theme.of(context).cardTheme.color ?? Colors.white).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead 
                ? null 
                : Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildIcon(notification.type, notification.isRead),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(notification.createdAt),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              if (!notification.isRead) {
                provider.markAsRead(notification.id);
              }
              // Можно добавить переход к заказу, если relatedOrderId != null
            },
          ),
        );
      },
    );
  }

  Widget _buildIcon(String type, bool isRead) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'order_update':
        iconData = Icons.local_shipping_rounded;
        color = Colors.blue;
        break;
      case 'promo':
        iconData = Icons.local_offer_rounded;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.info_rounded;
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(isRead ? 0.1 : 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
