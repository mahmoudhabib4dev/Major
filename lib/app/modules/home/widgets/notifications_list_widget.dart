import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../controllers/notifications_controller.dart';
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

                // Calculate animation delay based on index
                final animationDelay = Duration(milliseconds: 100 + (index * 80));

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
          SizedBox(height: screenSize.height * 0.15), // Bottom spacing
        ],
      ),
    );
  }
}
