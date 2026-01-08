import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/network_avatar.dart';
import '../controllers/profile_controller.dart';

class ProfileHeaderWidget extends GetView<ProfileController> {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: screenSize.height * 0.01),
        // Avatar with circles - animated
        _buildAvatarWithCircles(context, screenSize),
        
        // User name with animation
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: SlideInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 300),
            from: 20,
            child: controller.isGuest
                ? const Text(
                    'مستخدم ضيف',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : Obx(
                    () => Text(
                      controller.userName.value,
                      style: AppTextStyles.profileUserName(context),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithCircles(BuildContext context, Size screenSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Orbiting circles with spin animation
        SpinPerfect(
          duration: const Duration(seconds: 20),
          infinite: true,
          child: FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Image.asset(
              AppImages.icon30,
              width: 116,
              height: 102,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Avatar with zoom animation
        ZoomIn(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Pulse(
            duration: const Duration(seconds: 3),
            infinite: true,
            child: Obx(
              () {
                // Get gender-based avatar
                final user = controller.storageService.currentUser;
                final gender = user?.gender;
                final genderAvatar = (gender == 'male' || gender == 'ذكر')
                    ? AppImages.icon58
                    : AppImages.icon57;

                // If we have a network image URL, try to load it
                if (controller.userImageUrl.value.isNotEmpty) {
                  return ClipOval(
                    child: NetworkAvatar(
                      imageUrl: controller.userImageUrl.value,
                      size: 58,
                      fallbackAsset: genderAvatar,
                      fit: BoxFit.cover,
                    ),
                  );
                }

                // Show gender-based or default avatar
                return ClipOval(
                  child: Image.asset(
                    genderAvatar,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
