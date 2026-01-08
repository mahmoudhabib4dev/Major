import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/authentication_controller.dart';

class LoginButton extends GetView<AuthenticationController> {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton(
        text: 'login'.tr,
        onPressed: controller.isLoading.value ? null : controller.login,
        backgroundColor: AppColors.primary,
        textColor: AppColors.white,
        borderColor: AppColors.primary,
        width: double.infinity,
        isLoading: controller.isLoading.value,
        loadingColor: AppColors.white,
      ),
    );
  }
}
