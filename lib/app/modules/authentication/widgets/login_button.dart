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
      () => controller.isLoading.value
          ? const Center(child: AppLoader(size: 50))
          : AppButton(
              text: 'login'.tr,
              onPressed: controller.login,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderColor: AppColors.primary,
              width: double.infinity,
            ),
    );
  }
}
