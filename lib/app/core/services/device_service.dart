import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../api_client.dart';
import '../constants/api_constants.dart';
import 'firebase_notification_service.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _deviceIdKey = 'device_uid';
  static const String _boxName = 'device_box';

  final ApiClient _apiClient = ApiClient();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseNotificationService _fcmService = FirebaseNotificationService();

  String? _cachedDeviceId;

  /// Get or create a persistent device ID that survives app reinstalls
  Future<String> getDeviceId() async {
    // Return cached if available
    if (_cachedDeviceId != null) {
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

    // Try to get hardware-based ID that persists across reinstalls
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // androidId persists until factory reset
        deviceId = androidInfo.id;
        debugPrint('📱 Using Android hardware ID: $deviceId');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor changes on reinstall, so we use a combination
        deviceId = iosInfo.identifierForVendor;
        debugPrint('📱 Using iOS vendor ID: $deviceId');
      }
    } catch (e) {
      debugPrint('⚠️ Error getting hardware device ID: $e');
    }

    // If we still don't have an ID, generate a UUID
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      debugPrint('📱 Generated new device UUID: $deviceId');
    }

    // Save to persistent storage
    await box.put(_deviceIdKey, deviceId);
    _cachedDeviceId = deviceId;

    return deviceId;
  }

  /// Get current platform name
  String getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Get app version
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('⚠️ Error getting app version: $e');
      return '1.0.0';
    }
  }

  /// Register device with backend
  Future<bool> registerDevice() async {
    try {
      final deviceId = await getDeviceId();
      final platform = getPlatform();
      final appVersion = await getAppVersion();
      final fcmToken = await _fcmService.getToken();

      if (fcmToken == null) {
        debugPrint('⚠️ FCM token not available, skipping device registration');
        return false;
      }

      final body = {
        'device_uid': deviceId,
        'platform': platform,
        'fcm_token': fcmToken,
        'app_version': appVersion,
      };

      debugPrint('📱 Registering device: $body');

      final response = await _apiClient.post(
        ApiConstants.registerDevice,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Device registered successfully');
        return true;
      } else {
        debugPrint('❌ Device registration failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error registering device: $e');
      return false;
    }
  }

  /// Update FCM token on the server
  Future<bool> updateFcmToken(String newToken) async {
    try {
      final deviceId = await getDeviceId();
      final platform = getPlatform();
      final appVersion = await getAppVersion();

      final body = {
        'device_uid': deviceId,
        'platform': platform,
        'fcm_token': newToken,
        'app_version': appVersion,
      };

      debugPrint('📱 Updating FCM token: $body');

      final response = await _apiClient.post(
        ApiConstants.registerDevice,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ FCM token updated successfully');
        return true;
      } else {
        debugPrint('❌ FCM token update failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
      return false;
    }
  }
}
