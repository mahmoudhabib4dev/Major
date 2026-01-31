import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationCardWidget extends GetView<NotificationsController> {
  final NotificationModel notification;

  const NotificationCardWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.onNotificationTap(notification);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFEFEEFC),
            width: 1,
          ),
          boxShadow: !notification.isRead
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and unread dot on the left with animations
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    notification.formattedTime,
                    style: AppTextStyles.notificationTime(context),
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(height: 4),
                  Pulse(
                    duration: const Duration(milliseconds: 1500),
                    infinite: true,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            // Notification content with fade animation
            Expanded(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.notificationCardText(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.notificationCardText(context),
                      textAlign: TextAlign.right,
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
