import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';

class NotificationsEmptyStateWidget extends StatelessWidget {
  const NotificationsEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            // Text with fade animation
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 300),
              child: Text(
                'notifications_empty_title'.tr,
                style: AppTextStyles.sectionTitle(context).copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 400),
              child: Text(
                'notifications_empty_description'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
