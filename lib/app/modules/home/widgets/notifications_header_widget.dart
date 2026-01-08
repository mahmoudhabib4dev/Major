import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/notifications_controller.dart';

class NotificationsHeaderWidget extends GetView<NotificationsController> {
  const NotificationsHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: screenSize.width * 0.05,
          right: screenSize.width * 0.05,
          top: screenSize.height * 0.05, // Move down more
          bottom: screenSize.height * 0.01,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button with slide animation
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
            // Title with fade and slide animation
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${controller.unreadCount.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
    );
  }
}
