import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/downloaded_video_model.dart';

class HiveService {
  // Box names
  static const String _userBox = 'userBox';
  static const String _settingsBox = 'settingsBox';
  static const String _downloadsBox = 'downloadsBox';

  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DownloadedVideoModelAdapter().typeId)) {
      Hive.registerAdapter(DownloadedVideoModelAdapter());
    }

    // Open boxes
    await Hive.openBox(_userBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox<DownloadedVideoModel>(_downloadsBox);
  }

  // Get boxes
  Box getUserBox() => Hive.box(_userBox);
  Box getSettingsBox() => Hive.box(_settingsBox);
  Box<DownloadedVideoModel> getDownloadsBox() => Hive.box<DownloadedVideoModel>(_downloadsBox);

  // Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }

  // Clear all data
  Future<void> clearAll() async {
    await getUserBox().clear();
    await getSettingsBox().clear();
  }
}
