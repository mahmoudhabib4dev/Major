import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.timestamp,
  });
}

class NotificationsController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  // Load notifications data
  void _loadNotifications() {
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'تذكير',
        message: 'الحصة الخامسة لمادة اللغة الفرنسية ستبدأ بعد 5 دقائق',
        time: 'الآن',
        isRead: false,
        timestamp: DateTime.now(),
      ),
      NotificationModel(
        id: '2',
        title: 'تذكير',
        message: 'أكمل درساً واحداً يومياً للحفاظ على معدل حماستك!',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        title: 'تذكير',
        message: 'لديك 5 دقائق؟ انطلق في درس سريع الآن!',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '4',
        title: 'تذكير',
        message: 'لقد وصلت إلى 5 أيام متتالية! استمر في التعلم لتحافظ على السلسلة.',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '5',
        title: 'تذكير',
        message: 'حان وقت مراجعة بعض الأخطاء في اللغة الإنجليزية لتتقدم بشكل أفضل.',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '6',
        title: 'تذكير',
        message: 'ثبّت لك درس واحد فقط لتحقيق هدف الأسبوع.',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '7',
        title: 'تذكير',
        message: 'لم يتبق سوى 15 دقيقة لإنهاء اليوم! ابدأ درسنا سريعاً الآن.',
        time: '1 ساعة',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
    _updateUnreadCount();
  }

  // Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        message: notifications[index].message,
        time: notifications[index].time,
        isRead: true,
        timestamp: notifications[index].timestamp,
      );
      notifications.refresh();
      _updateUnreadCount();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    notifications.value = notifications
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              time: n.time,
              isRead: true,
              timestamp: n.timestamp,
            ))
        .toList();
    _updateUnreadCount();
  }

  // Clear all notifications
  void clearAll() {
    notifications.clear();
    _updateUnreadCount();
  }

  // Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    markAsRead(notification.id);
    // TODO: Navigate to relevant page based on notification type
  }
}
