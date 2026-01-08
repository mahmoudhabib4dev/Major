import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import 'animated_dots_loader.dart';

class SplashProgressLoader extends StatelessWidget {
  const SplashProgressLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final bottomOffset = screenHeight * 0.12;

    return Positioned(
      bottom: bottomOffset,
      left: horizontalPadding,
      right: horizontalPadding,
      child: FadeInUp(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar with Animation
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Obx(
                  () => LinearProgressIndicator(
                    value: controller.progress.value / 100,
                    minHeight: screenHeight * 0.008,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            // Percentage Text and Animated Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => FadeIn(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '${controller.progress.value.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AnimatedDotsLoader(fontSize: screenHeight * 0.014),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
