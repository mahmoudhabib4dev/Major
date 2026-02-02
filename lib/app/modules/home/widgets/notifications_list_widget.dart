import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../../../core/widgets/app_loader.dart';
import 'notification_card_widget.dart';

class NotificationsListWidget extends GetView<NotificationsController> {
  const NotificationsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
      ),
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.02),
          // Notifications list with staggered animations
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];

                // Calculate animation delay based on index (cap at 5 for performance)
                final animationDelay = Duration(milliseconds: 100 + ((index % 5) * 80));

                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: animationDelay,
                  child: SlideInRight(
                    duration: const Duration(milliseconds: 500),
                    delay: animationDelay,
                    child: NotificationCardWidget(
                      notification: notification,
                    ),
                  ),
                );
              },
            ),
          ),
          // Load more button
          Obx(() {
            // Access observable first to ensure Obx tracks changes
            final isLoading = controller.isLoadingMore.value;
            final notificationsCount = controller.notifications.length;

            // hasMorePages is a getter computed from _currentPage < _lastPage
            if (!controller.hasMorePages || notificationsCount == 0) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isLoading
                  ? const Center(
                      child: const AppLoader(size: 50),
                    )
                  : TextButton(
                      onPressed: controller.loadMoreNotifications,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'load_more'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
            );
          }),
          SizedBox(height: screenSize.height * 0.15), // Bottom spacing
        ],
      ),
    );
  }
}
