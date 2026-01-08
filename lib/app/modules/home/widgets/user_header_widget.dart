import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/network_avatar.dart';
import '../controllers/home_controller.dart';

class UserHeaderWidget extends GetView<HomeController> {
  const UserHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification icon
          FadeInLeft(
            duration: const Duration(milliseconds: 600),
            child: IconButton(
              onPressed: controller.onNotificationTap,
              icon: Image.asset(
                AppImages.icon14,
                width: 40,
                height: 40,
              ),
            ),
          ),
          // User info
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: InkWell(
              onTap: controller.onProfileTap,
              child: Row(
                children: [
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.greetingText.value,
                          style: AppTextStyles.homeTitle(context),
                        ),
                        Text(
                          controller.userName.value,
                          style: AppTextStyles.homeSubtitle(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  // User avatar
                  Obx(
                    () {
                      developer.log('🖼️ Rendering avatar - URL: "${controller.userAvatarUrl.value}"', name: 'UserHeaderWidget');

                      // Get fallback avatar based on gender
                      final fallbackAsset = controller.userAvatarAsset.value.isNotEmpty
                          ? controller.userAvatarAsset.value
                          : AppImages.icon58;

                      // If we have a network image URL, try to load it
                      if (controller.userAvatarUrl.value.isNotEmpty) {
                        developer.log('   Attempting to load network image', name: 'UserHeaderWidget');
                        return ClipOval(
                          child: NetworkAvatar(
                            imageUrl: controller.userAvatarUrl.value,
                            size: 50,
                            fallbackAsset: fallbackAsset,
                            fit: BoxFit.cover,
                          ),
                        );
                      }

                      developer.log('   Using default avatar', name: 'UserHeaderWidget');
                      // Show gender-based or default avatar
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipOval(
                          child: Image.asset(
                            fallbackAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
