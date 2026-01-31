import 'dart:developer' as developer;
import 'package:get/get.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';
import 'home_controller.dart';

class NotificationsController extends GetxController {
  final NotificationsProvider _provider = NotificationsProvider();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  bool get hasMorePages => _currentPage < _lastPage;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications from API
  Future<void> loadNotifications() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      _currentPage = 1;

      final response = await _provider.getNotifications(page: 1);

      notifications.value = response.data;
      _currentPage = response.pagination.currentPage;
      _lastPage = response.pagination.lastPage;

      _updateUnreadCount();

      developer.log(
        '✅ Notifications loaded: ${notifications.length} items, page $_currentPage/$_lastPage',
        name: 'NotificationsController',
      );
    } on ApiErrorModel catch (error) {
      developer.log(
        '❌ Failed to load notifications: ${error.displayMessage}',
        name: 'NotificationsController',
      );
      hasError.value = true;
      if (error.statusCode != 401) {
        AppDialog.showError(message: error.displayMessage);
      }
    } catch (e) {
      developer.log(
        '❌ Unexpected error loading notifications: $e',
        name: 'NotificationsController',
      );
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !hasMorePages) return;

    try {
      isLoadingMore.value = true;

      final nextPage = _currentPage + 1;
      final response = await _provider.getNotifications(page: nextPage);

      notifications.addAll(response.data);
      _currentPage = response.pagination.currentPage;
      _lastPage = response.pagination.lastPage;

      _updateUnreadCount();

      developer.log(
        '✅ More notifications loaded: ${response.data.length} items, page $_currentPage/$_lastPage',
        name: 'NotificationsController',
      );
    } on ApiErrorModel catch (error) {
      developer.log(
        '❌ Failed to load more notifications: ${error.displayMessage}',
        name: 'NotificationsController',
      );
    } catch (e) {
      developer.log(
        '❌ Unexpected error loading more notifications: $e',
        name: 'NotificationsController',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;

    // Also update the home controller's badge
    _updateHomeControllerBadge();
  }

  /// Update the badge in HomeController
  void _updateHomeControllerBadge() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.unreadNotificationsCount.value = unreadCount.value;
      }
    } catch (e) {
      developer.log('⚠️ Could not update home badge: $e', name: 'NotificationsController');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    // Optimistically update UI
    final notification = notifications[index];
    if (notification.isRead) return; // Already read

    notifications[index] = notification.copyWith(isRead: true);
    notifications.refresh();
    _updateUnreadCount();

    // Call API
    final success = await _provider.markAsRead(notificationId);

    if (!success) {
      // Revert if API call failed
      notifications[index] = notification;
      notifications.refresh();
      _updateUnreadCount();
      developer.log(
        '❌ Failed to mark notification as read: $notificationId',
        name: 'NotificationsController',
      );
    } else {
      developer.log(
        '✅ Notification marked as read: $notificationId',
        name: 'NotificationsController',
      );
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();

    // Optimistically update UI
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _updateUnreadCount();

    // Call API for each unread notification
    for (final notification in unreadNotifications) {
      await _provider.markAsRead(notification.id);
    }

    developer.log(
      '✅ All notifications marked as read',
      name: 'NotificationsController',
    );
  }

  /// Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    // Mark as read
    markAsRead(notification.id);

    // Navigate based on notification type
    if (notification.data != null) {
      final data = notification.data!;

      if (data.type == 'lesson_updated' && data.lessonId != null) {
        // TODO: Navigate to lesson detail
        developer.log(
          '📱 Navigate to lesson: ${data.lessonId}',
          name: 'NotificationsController',
        );
      } else if (data.subjectId != null) {
        // TODO: Navigate to subject detail
        developer.log(
          '📱 Navigate to subject: ${data.subjectId}',
          name: 'NotificationsController',
        );
      }
    }
  }

  /// Clear all notifications (local only)
  void clearAll() {
    notifications.clear();
    _updateUnreadCount();
  }
}
