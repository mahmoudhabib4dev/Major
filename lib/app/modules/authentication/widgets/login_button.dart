import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/authentication_controller.dart';

class LoginButton extends GetView<AuthenticationController> {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isFormValid = controller.isLoginFormValid;

        if (controller.isLoading.value) {
          return const Center(child: AppLoader(size: 50));
        }

        return AppButton(
          text: 'login'.tr,
          onPressed: isFormValid ? controller.login : null,
          backgroundColor: isFormValid ? AppColors.primary : AppColors.grey300,
          textColor: AppColors.white,
          borderColor: isFormValid ? AppColors.primary : AppColors.grey300,
          width: double.infinity,
        );
      },
    );
  }
}
