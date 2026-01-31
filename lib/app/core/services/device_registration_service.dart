import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive/hive.dart';
import '../api_client.dart';
import '../constants/api_constants.dart';

class DeviceRegistrationService {
  static final DeviceRegistrationService _instance =
      DeviceRegistrationService._internal();

  factory DeviceRegistrationService() => _instance;

  DeviceRegistrationService._internal();

  final ApiClient _apiClient = ApiClient();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static const String _deviceIdKey = 'persistent_device_uid';
  static const String _boxName = 'device_box';

  String? _cachedDeviceId;

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
      debugPrint('📱 FCM Token: ${deviceInfo['fcm_token']?.substring(0, 20) ?? 'null'}...');

      // Check if FCM token is valid
      if (deviceInfo['fcm_token'] == null ||
          deviceInfo['fcm_token']!.isEmpty ||
          deviceInfo['fcm_token'] == 'error-getting-token' ||
          deviceInfo['fcm_token'] == 'no-token-available') {
        debugPrint('⚠️ FCM token not available, skipping device registration');
        return;
      }

      // Register device with backend using POST
      debugPrint('📱 Registering device at: ${ApiConstants.registerDevice}');

      final response = await _apiClient.post(
        ApiConstants.registerDevice,
        body: {
          'device_uid': deviceInfo['device_uid'],
          'platform': deviceInfo['platform'],
          'fcm_token': deviceInfo['fcm_token'],
          'app_version': deviceInfo['app_version'],
        },
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
  Future<Map<String, String?>> _getDeviceInfo() async {
    try {
      // Get platform
      final platform = _getPlatform();
      debugPrint('📱 Platform detected: $platform');

      // Get device UID (stable identifier that persists across reinstalls)
      final deviceUid = await _getDeviceUid();
      debugPrint('📱 Device UID: $deviceUid');

      // Get FCM token
      final fcmToken = await _getFcmToken();
      debugPrint('📱 FCM Token retrieved: ${fcmToken?.substring(0, 20) ?? 'null'}...');

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

  /// Get stable device UID that persists across app reinstalls
  Future<String> _getDeviceUid() async {
    try {
      // Return cached if available
      if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
        return _cachedDeviceId!;
      }

      // Try to get from Hive storage first
      final box = await Hive.openBox(_boxName);
      String? deviceId = box.get(_deviceIdKey);

      if (deviceId != null && deviceId.isNotEmpty) {
        _cachedDeviceId = deviceId;
        debugPrint('📱 Device ID loaded from storage: $deviceId');
        return deviceId;
      }

      // Get hardware-based ID that persists across reinstalls
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        // androidId persists until factory reset on most devices
        deviceId = androidInfo.id;
        debugPrint('📱 Using Android hardware ID: $deviceId');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        // identifierForVendor - persists until all apps from vendor are deleted
        deviceId = iosInfo.identifierForVendor;
        debugPrint('📱 Using iOS vendor ID: $deviceId');
      }

      // Fallback if we still don't have an ID
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('📱 Generated fallback device ID: $deviceId');
      }

      // Save to persistent storage
      await box.put(_deviceIdKey, deviceId);
      _cachedDeviceId = deviceId;

      return deviceId;
    } catch (e) {
      debugPrint('❌ Error getting device UID: $e');
      // Fallback to timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get FCM token
  Future<String?> _getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      } else {
        debugPrint('⚠️ FCM Token is null');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get app version using package_info_plus
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('❌ Error getting app version: $e');
      return '1.0.0';
    }
  }

  /// Update FCM token when it refreshes
  Future<void> updateFcmToken(String newToken) async {
    try {
      final deviceUid = await _getDeviceUid();
      final platform = _getPlatform();
      final appVersion = await _getAppVersion();

      debugPrint('📱 Updating FCM token...');

      final response = await _apiClient.post(
        ApiConstants.registerDevice,
        body: {
          'device_uid': deviceUid,
          'platform': platform,
          'fcm_token': newToken,
          'app_version': appVersion,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ FCM token updated successfully');
      } else {
        debugPrint('❌ FCM token update failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }
}
