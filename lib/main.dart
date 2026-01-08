import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:get/get.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/core/api_client.dart';
import 'app/core/services/hive_service.dart';
import 'app/core/services/storage_service.dart';
import 'app/core/services/firebase_notification_service.dart';
import 'app/core/translations/app_translations.dart';

void main() async {
  // Set global status bar style to white icons
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Notification Service
  await FirebaseNotificationService().initialize();

  // Initialize Hive
  await HiveService.init();

  // Initialize storage service in GetX
  final storageService = Get.put(StorageService());

  // Initialize ApiClient with stored token if available
  final apiClient = ApiClient();
  final storedToken = storageService.authToken;
  if (storedToken != null) {
    apiClient.setToken(storedToken);
  }

  // Get saved locale or default to Arabic
  final savedLocale = storageService.locale ?? 'ar';

  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(fontFamily: 'Tajawal'),
      locale: Locale(savedLocale),
      fallbackLocale: const Locale('ar'),
      translations: AppTranslations(),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}


