import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import 'hive_service.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final HiveService _hiveService = HiveService();

  // Keys
  static const String _isFirstLaunchKey = 'isFirstLaunch';
  static const String _authTokenKey = 'authToken';
  static const String _userDataKey = 'userData';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _onboardingCompletedKey = 'onboardingCompleted';
  static const String _userPasswordKey = 'userPassword';
  static const String _localeKey = 'appLocale';
  static const String _guestStageIdKey = 'guestStageId';
  static const String _guestStageNameKey = 'guestStageName';
  static const String _guestDivisionIdKey = 'guestDivisionId';
  static const String _guestDivisionNameKey = 'guestDivisionName';

  // Settings Box
  Box get _settingsBox => _hiveService.getSettingsBox();
  Box get _userBox => _hiveService.getUserBox();

  // First Launch
  bool get isFirstLaunch {
    return _settingsBox.get(_isFirstLaunchKey, defaultValue: true);
  }

  Future<void> setFirstLaunchComplete() async {
    await _settingsBox.put(_isFirstLaunchKey, false);
  }

  // Onboarding
  bool get isOnboardingCompleted {
    final value = _settingsBox.get(_onboardingCompletedKey, defaultValue: false);
    developer.log('📖 Reading isOnboardingCompleted: $value', name: 'StorageService');
    return value;
  }

  Future<void> setOnboardingCompleted() async {
    await _settingsBox.put(_onboardingCompletedKey, true);
    developer.log('✅ Saved isOnboardingCompleted: true', name: 'StorageService');
  }

  // Authentication
  bool get isLoggedIn {
    return _settingsBox.get(_isLoggedInKey, defaultValue: false);
  }

  Future<void> setLoggedIn(bool value) async {
    await _settingsBox.put(_isLoggedInKey, value);
  }

  // Auth Token
  String? get authToken {
    return _settingsBox.get(_authTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    await _settingsBox.put(_authTokenKey, token);
    await setLoggedIn(true);
  }

  Future<void> clearAuthToken() async {
    await _settingsBox.delete(_authTokenKey);
    await setLoggedIn(false);
  }

  // User Data
  UserModel? get currentUser {
    final data = _userBox.get(_userDataKey);
    return data as UserModel?;
  }

  Future<void> saveUser(UserModel user) async {
    await _userBox.put(_userDataKey, user);
  }

  Future<void> clearUser() async {
    await _userBox.delete(_userDataKey);
  }

  // Password (stored securely in Hive for logout purposes)
  String? get userPassword {
    return _settingsBox.get(_userPasswordKey);
  }

  Future<void> savePassword(String password) async {
    await _settingsBox.put(_userPasswordKey, password);
  }

  Future<void> clearPassword() async {
    await _settingsBox.delete(_userPasswordKey);
  }

  // Locale
  String? get locale {
    return _settingsBox.get(_localeKey);
  }

  Future<void> saveLocale(String localeCode) async {
    await _settingsBox.put(_localeKey, localeCode);
    developer.log('✅ Saved locale: $localeCode', name: 'StorageService');
  }

  // ==================== Guest User Data ====================

  // Save guest stage
  Future<void> saveGuestStage(int stageId, String stageName) async {
    await _settingsBox.put(_guestStageIdKey, stageId);
    await _settingsBox.put(_guestStageNameKey, stageName);
    developer.log('✅ Saved guest stage: $stageName (ID: $stageId)', name: 'StorageService');
  }

  // Get guest stage ID
  int? get guestStageId {
    return _settingsBox.get(_guestStageIdKey);
  }

  // Get guest stage name
  String? get guestStageName {
    return _settingsBox.get(_guestStageNameKey);
  }

  // Save guest division
  Future<void> saveGuestDivision(int divisionId, String divisionName) async {
    await _settingsBox.put(_guestDivisionIdKey, divisionId);
    await _settingsBox.put(_guestDivisionNameKey, divisionName);
    developer.log('✅ Saved guest division: $divisionName (ID: $divisionId)', name: 'StorageService');
  }

  // Get guest division ID
  int? get guestDivisionId {
    return _settingsBox.get(_guestDivisionIdKey);
  }

  // Get guest division name
  String? get guestDivisionName {
    return _settingsBox.get(_guestDivisionNameKey);
  }

  // Clear guest data
  Future<void> clearGuestData() async {
    await _settingsBox.delete(_guestStageIdKey);
    await _settingsBox.delete(_guestStageNameKey);
    await _settingsBox.delete(_guestDivisionIdKey);
    await _settingsBox.delete(_guestDivisionNameKey);
    developer.log('🗑️  Cleared guest data', name: 'StorageService');
  }

  // Check if guest has selected preferences
  bool get hasGuestPreferences {
    return guestStageId != null && guestDivisionId != null;
  }

  // Logout (clear all user-related data)
  Future<void> logout() async {
    await clearAuthToken();
    await clearUser();
    await clearPassword();
    await clearGuestData(); // Also clear guest data on logout
  }

  // Clear all data
  Future<void> clearAll() async {
    await _hiveService.clearAll();
  }

  // Get initial route based on app state
  String getInitialRoute() {
    developer.log('🔍 Determining initial route...', name: 'StorageService');
    developer.log('  - isFirstLaunch: $isFirstLaunch', name: 'StorageService');
    developer.log('  - isOnboardingCompleted: $isOnboardingCompleted', name: 'StorageService');
    developer.log('  - isLoggedIn: $isLoggedIn', name: 'StorageService');
    developer.log('  - authToken exists: ${authToken != null}', name: 'StorageService');
    developer.log('  - hasGuestPreferences: $hasGuestPreferences', name: 'StorageService');

    // Check login status FIRST - if user is logged in, they should go to main app
    if (isLoggedIn && authToken != null) {
      developer.log('➡️  Route: /parent (logged in)', name: 'StorageService');
      return '/parent'; // User is logged in, go to main app
    } else if (hasGuestPreferences && isOnboardingCompleted) {
      // Guest user with saved preferences
      developer.log('➡️  Route: /parent (guest with preferences)', name: 'StorageService');
      return '/parent'; // Guest can go to main app
    } else if (isFirstLaunch || !isOnboardingCompleted) {
      developer.log('➡️  Route: /authentication (onboarding)', name: 'StorageService');
      return '/authentication'; // Show onboarding
    } else {
      developer.log('➡️  Route: /authentication (login)', name: 'StorageService');
      return '/authentication'; // User needs to login
    }
  }
}
