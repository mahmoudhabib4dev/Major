import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../controllers/splash_controller.dart';
import '../widgets/splash_progress_loader.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Zoom Animation
          FadeIn(
            duration: const Duration(milliseconds: 1000),
            child: ZoomIn(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.image1),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Progress Loader at Bottom
          const SplashProgressLoader(),
        ],
      ),
    );
  }
}
