import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title with emoji
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'forgot_password_title'.tr,
              style: AppTextStyles.loginTitle(context),
            ),
            SizedBox(width: AppDimensions.spacing(context, 0.02)),
            const Text(
              '🔑',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        // Subtitle
        Text(
          'forgot_password_subtitle'.tr,
          style: AppTextStyles.loginSubtitle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
