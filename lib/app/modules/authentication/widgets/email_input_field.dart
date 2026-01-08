import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

class EmailInputField extends GetView<AuthenticationController> {
  const EmailInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'email'.tr,
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
              border: controller.emailError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyText(context),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                if (controller.emailError.value.isNotEmpty) {
                  controller.emailError.value = '';
                }
              },
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'email'.tr,
                hintStyle: AppTextStyles.inputHint(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.04),
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => controller.emailError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacing(context, 0.01),
                  ),
                  child: Text(
                    controller.emailError.value,
                    style: AppTextStyles.smallText(context).copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
