import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

class LoginHeader extends GetView<AuthenticationController> {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppDimensions.screenHeight(context) * 0.03),
        Text(
          'login'.tr,
          style: AppTextStyles.loginTitle(context),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Text(
          'login_subtitle'.tr,
          style: AppTextStyles.loginSubtitle(context),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.04),
      ],
    );
  }
}
