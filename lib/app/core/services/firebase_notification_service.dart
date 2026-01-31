import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../modules/home/controllers/home_controller.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Background message received: ${message.messageId}');
  debugPrint('📱 Title: ${message.notification?.title}');
  debugPrint('📱 Body: ${message.notification?.body}');
  debugPrint('📱 Data: ${message.data}');
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      // Request notification permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('📱 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('📱 User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('📱 User granted provisional permission');
      } else {
        debugPrint('📱 User declined or has not accepted permission');
        return;
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('📱 FCM Token refreshed: $newToken');
        // TODO: Send token to your server
      });

      // Set foreground notification presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📱 App opened from terminated state via notification');
        _handleNotificationTap(initialMessage);
      }

      debugPrint('📱 Firebase Notification Service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Firebase Notification Service: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📱 Foreground message received: ${message.messageId}');
    debugPrint('📱 Title: ${message.notification?.title}');
    debugPrint('📱 Body: ${message.notification?.body}');
    debugPrint('📱 Data: ${message.data}');

    // Refresh unread notifications count in HomeController
    _refreshUnreadCount();

    // Show in-app notification when app is in foreground
    final notification = message.notification;
    if (notification != null) {
      _showInAppNotification(
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  /// Refresh unread notifications count in HomeController
  void _refreshUnreadCount() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.refreshUnreadCount();
        debugPrint('📱 Refreshed unread notifications count');
      }
    } catch (e) {
      debugPrint('📱 Could not refresh unread count: $e');
    }
  }

  /// Show in-app notification using GetX snackbar
  void _showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      icon: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(4),
        child: ClipOval(
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      shouldIconPulse: true,
      onTap: (snack) {
        debugPrint('📱 In-app notification tapped');
        // Navigate to notifications page
        _navigateToNotifications();
      },
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📱 Notification tapped: ${message.messageId}');
    debugPrint('📱 Data: ${message.data}');

    // Navigate to notifications page
    _navigateToNotifications();
  }

  /// Navigate to notifications page
  void _navigateToNotifications() {
    // Small delay to ensure app is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      // Check if we're already on notifications page
      if (Get.currentRoute == Routes.NOTIFICATIONS) {
        debugPrint('📱 Already on notifications page');
        return;
      }

      // Navigate to notifications
      debugPrint('📱 Navigating to notifications page');
      Get.toNamed(Routes.NOTIFICATIONS);
    });
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('📱 Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('📱 Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('📱 FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }
}
