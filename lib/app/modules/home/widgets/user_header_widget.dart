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
          // User info - First item appears on RIGHT in RTL (Arabic)
          FadeIn(
            duration: const Duration(milliseconds: 600),
            child: InkWell(
              onTap: controller.onProfileTap,
              child: Row(
                children: [
                  // User avatar (appears first, on the right in RTL)
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
                  SizedBox(width: screenSize.width * 0.03),
                  // Title and subtitle (appears second, to the left of avatar in RTL)
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'welcome_greeting'.tr,
                          style: AppTextStyles.homeTitle(context),
                        ),
                        Text(
                          controller.userName.value,
                          style: AppTextStyles.homeSubtitle(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notification icon with badge - Second item appears on LEFT in RTL (Arabic)
          // Hide for guest users
          if (!controller.isGuest)
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: controller.onNotificationTap,
                    icon: Image.asset(
                      AppImages.icon14,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  // Unread badge
                  Obx(() {
                    if (controller.unreadNotificationsCount.value > 0) {
                      return Positioned(
                        right: 6,
                        top: 6,
                        child: ZoomIn(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                controller.unreadNotificationsCount.value > 99
                                    ? '99+'
                                    : '${controller.unreadNotificationsCount.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
