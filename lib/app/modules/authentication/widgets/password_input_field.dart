import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

class PasswordInputField extends GetView<AuthenticationController> {
  const PasswordInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label aligned to start (right for RTL, left for LTR)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'password'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
              border: controller.passwordError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Obx(
              () => TextField(
                controller: controller.passwordController,
                focusNode: controller.passwordFocusNode,
                obscureText: !controller.isPasswordVisible.value,
                textAlign: TextAlign.start,
                style: AppTextStyles.bodyText(context),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  if (controller.passwordError.value.isNotEmpty) {
                    controller.passwordError.value = '';
                  }
                },
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                  controller.login();
                },
                decoration: InputDecoration(
                  hintText: 'password'.tr,
                  hintStyle: AppTextStyles.inputHint(context),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing(context, 0.04),
                    vertical: AppDimensions.spacing(context, 0.04),
                  ),
                  suffixIcon: IconButton(
                    icon: Image.asset(
                      AppImages.icon4,
                      width: AppDimensions.iconSmall(context) * 1.5,
                      height: AppDimensions.iconSmall(context) * 1.5,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => controller.passwordError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacing(context, 0.01),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      controller.passwordError.value,
                      style: AppTextStyles.smallText(context).copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        // Forgot password aligned to end (left for LTR, right for RTL)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: GestureDetector(
            onTap: controller.forgotPassword,
            child: Text(
              'forgot_password'.tr,
              style: AppTextStyles.forgotPasswordLink(context),
            ),
          ),
        ),
      ],
    );
  }
}
