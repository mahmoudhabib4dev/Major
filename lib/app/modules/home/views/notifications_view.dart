import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notifications_empty_state_widget.dart';
import '../widgets/notifications_list_widget.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.image2),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header with title and close button
             SizedBox(height: screenSize.height *0.01),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenSize.width * 0.05,
                  right: screenSize.width * 0.05,
                  top: screenSize.height * 0.05,
                  bottom: screenSize.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    SlideInLeft(
                      duration: const Duration(milliseconds: 600),
                      child: FadeIn(
                        duration: const Duration(milliseconds: 600),
                        child: IconButton(
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Image.asset(
                            AppImages.icon16,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    // Title with unread badge
                    SlideInRight(
                      duration: const Duration(milliseconds: 600),
                      child: FadeIn(
                        duration: const Duration(milliseconds: 600),
                        child: Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'notifications_title'.tr,
                                style: AppTextStyles.notificationPageTitle(context),
                              ),
                              if (controller.unreadCount.value > 0) ...[
                                const SizedBox(width: 8),
                                ZoomIn(
                                  duration: const Duration(milliseconds: 400),
                                  delay: const Duration(milliseconds: 300),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${controller.unreadCount.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // White container with notifications
            Expanded(
              child: ClipPath(
                clipper: _TopCurveClipper(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -(screenSize.width * 0.08) * 0.8,
                      left: 0,
                      right: 0,
                      bottom: -(screenSize.width * 0.08) * 0.8,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: (screenSize.width * 0.08) * 0.8),
                        color: Colors.white,
                        child: RefreshIndicator(
                          onRefresh: controller.refreshNotifications,
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: FadeIn(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 200),
                                child: Obx(() {
                                  // Loading state
                                  if (controller.isLoading.value) {
                                    return SizedBox(
                                      height: screenSize.height * 0.5,
                                      child: const Center(
                                        child: AppLoader(size: 60),
                                      ),
                                    );
                                  }

                                  // Error state
                                  if (controller.hasError.value && controller.notifications.isEmpty) {
                                    return SizedBox(
                                      height: screenSize.height * 0.5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 64,
                                              color: AppColors.grey400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'error_loading_notifications'.tr,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 16,
                                                color: AppColors.grey500,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextButton(
                                              onPressed: controller.loadNotifications,
                                              child: Text(
                                                'retry'.tr,
                                                style: TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Empty state
                                  if (controller.notifications.isEmpty) {
                                    return const NotificationsEmptyStateWidget();
                                  }

                                  // Notifications list
                                  return const NotificationsListWidget();
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Small dot at top center below the wave
                    Positioned(
                      top: -screenSize.width * 0.025 + 5,
                      left: screenSize.width / 2 - screenSize.width * 0.0125,
                      child: Container(
                        width: screenSize.width * 0.025,
                        height: screenSize.width * 0.025,
                        decoration: const BoxDecoration(
                          color: Color(0xFF000D47),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Custom clipper for the wavy top edge
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    // Start from top left
    path.lineTo(0, notchRadius);

    // Left side going down
    path.lineTo(0, size.height);

    // Bottom
    path.lineTo(size.width, size.height);

    // Right side going up
    path.lineTo(size.width, notchRadius);

    // Top right corner curve
    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Line to notch start (right side)
    path.lineTo(notchCenterX + notchWidth / 2, 0);

    // Create ONE wavy curve in the middle
    path.quadraticBezierTo(
      notchCenterX, // control point x (center)
      -notchRadius * 0.5, // control point y (depth of wave)
      notchCenterX - notchWidth / 2, // end point x
      0, // end point y
    );

    // Line to top left corner
    path.lineTo(notchRadius, 0);

    // Top left corner curve
    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
