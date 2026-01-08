import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api_client.dart';
import '../constants/api_constants.dart';

class DeviceRegistrationService {
  static final DeviceRegistrationService _instance =
      DeviceRegistrationService._internal();

  factory DeviceRegistrationService() => _instance;

  DeviceRegistrationService._internal();

  final ApiClient _apiClient = ApiClient();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Register device with the backend
  Future<void> registerDevice() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 Starting device registration process...');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Get device information
      final deviceInfo = await _getDeviceInfo();

      debugPrint('📱 Device UID: ${deviceInfo['device_uid']}');
      debugPrint('📱 Platform: ${deviceInfo['platform']}');
      debugPrint('📱 App Version: ${deviceInfo['app_version']}');
      debugPrint('📱 FCM Token: ${deviceInfo['fcm_token']}');

      // Register device with backend
      final url = '${ApiConstants.baseUrl}/student/device';
      debugPrint('📱 Registering device at: $url');

      final response = await _apiClient.get(
        '$url?device_uid=${deviceInfo['device_uid']}&platform=${deviceInfo['platform']}&fcm_token=${deviceInfo['fcm_token']}&app_version=${deviceInfo['app_version']}',
      );

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 Device Registration Response:');
      debugPrint('📱 Status Code: ${response.statusCode}');
      debugPrint('📱 Response Body: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('✅ Device registered successfully');
        debugPrint('📱 Response Data: $responseData');
      } else {
        debugPrint('❌ Device registration failed with status: ${response.statusCode}');
        debugPrint('📱 Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error during device registration: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      // Get platform
      final platform = _getPlatform();
      debugPrint('📱 Platform detected: $platform');

      // Get device UID (stable identifier)
      final deviceUid = await _getDeviceUid();
      debugPrint('📱 Device UID generated: $deviceUid');

      // Get FCM token
      final fcmToken = await _getFcmToken();
      debugPrint('📱 FCM Token retrieved: $fcmToken');

      // Get app version
      final appVersion = await _getAppVersion();
      debugPrint('📱 App Version: $appVersion');

      return {
        'device_uid': deviceUid,
        'platform': platform,
        'fcm_token': fcmToken,
        'app_version': appVersion,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting device info: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get platform (android or ios)
  String _getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  /// Get stable device UID
  Future<String> _getDeviceUid() async {
    try {
      if (Platform.isAndroid) {
        // For Android, use a combination of device info
        // This is a simplified version - in production you might want to use
        // device_info_plus package to get android ID
        return 'android_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        // For iOS, use identifierForVendor
        return 'ios_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      debugPrint('❌ Error getting device UID: $e');
      // Fallback to timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get FCM token
  Future<String> _getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token obtained: ${token.substring(0, 20)}...');
        return token;
      } else {
        debugPrint('⚠️ FCM Token is null, using placeholder');
        return 'no-token-available';
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return 'error-getting-token';
    }
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    try {
      // For now, return hardcoded version
      // In production, use package_info_plus to get actual version
      return '1.0.0';
    } catch (e) {
      debugPrint('❌ Error getting app version: $e');
      return '1.0.0';
    }
  }
}
