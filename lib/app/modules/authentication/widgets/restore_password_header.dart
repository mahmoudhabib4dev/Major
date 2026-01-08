import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

class RestorePasswordHeader extends GetView<AuthenticationController> {
  const RestorePasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title with emoji
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.isSignUpMode.value ? 'activate_account'.tr : 'restore_password'.tr,
                style: AppTextStyles.loginTitle(context),
              ),
              SizedBox(width: AppDimensions.spacing(context, 0.02)),
              Text(
                controller.isSignUpMode.value ? '✅' : '🔒',
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        // Subtitle with email
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing(context, 0.04),
          ),
          child: Obx(
            () => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.loginSubtitle(context),
                children: [
                  TextSpan(
                    text: 'enter_code_sent_to'.tr,
                  ),
                  TextSpan(
                    text: controller.userEmail.value,
                    style: AppTextStyles.loginSubtitle(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: controller.isSignUpMode.value
                        ? 'to_activate_account'.tr
                        : 'to_restore_password'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
