import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

enum ProfileMenuItemType {
  navigation,
  toggle,
}

class ProfileMenuItemWidget extends GetView<ProfileController> {
  final String title;
  final String iconPath;
  final Color iconBackgroundColor;
  final ProfileMenuItemType type;
  final VoidCallback? onTap;
  final bool isDanger;
  final int animationDelay;

  const ProfileMenuItemWidget({
    super.key,
    required this.title,
    required this.iconPath,
    required this.iconBackgroundColor,
    this.type = ProfileMenuItemType.navigation,
    this.onTap,
    this.isDanger = false,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: animationDelay),
      child: SlideInRight(
        duration: const Duration(milliseconds: 350),
        delay: Duration(milliseconds: animationDelay),
        from: 50,
        child: Column(
          children: [
            InkWell(
              onTap: type == ProfileMenuItemType.navigation ? onTap : null,
              splashColor: iconBackgroundColor.withValues(alpha: 0.1),
              highlightColor: iconBackgroundColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.height * 0.012,
                ),
                child: Row(
                  children: [
                    // Icon with circular background and bounce animation (right side in RTL)
                    ElasticIn(
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: animationDelay + 150),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.03),
                    // Title with fade animation
                    Expanded(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 350),
                        delay: Duration(milliseconds: animationDelay + 50),
                        child: Text(
                          title,
                          style: isDanger
                              ? AppTextStyles.profileMenuItemDanger(context)
                              : AppTextStyles.profileMenuItem(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    // Toggle switch with animation (left side in RTL)
                    if (type == ProfileMenuItemType.toggle)
                      FadeIn(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: animationDelay + 100),
                        child: Obx(
                          () => Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: controller.hideInChallenges.value,
                              onChanged: controller.toggleHideInChallenges,
                              activeColor: AppColors.white,
                              activeTrackColor: AppColors.success,
                              inactiveThumbColor: AppColors.white,
                              inactiveTrackColor: AppColors.grey300,
                            ),
                          ),
                        ),
                      ),
                    // Arrow icon (left side in RTL) with animation
                    if (type == ProfileMenuItemType.navigation)
                      FadeInLeft(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: animationDelay + 100),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF000000),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Divider with fade animation
            FadeIn(
              duration: const Duration(milliseconds: 300),
              delay: Duration(milliseconds: animationDelay + 200),
              child: const Divider(
                color: AppColors.grey200,
                height: 1,
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
