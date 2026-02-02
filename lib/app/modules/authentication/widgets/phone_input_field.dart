import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';
import 'country_code_bottom_sheet.dart';

class PhoneInputField extends GetView<AuthenticationController> {
  const PhoneInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'phone_number'.tr,
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
              border: controller.phoneError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Country code selector
                _buildCountryCodeSelector(context),

                // Phone input
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.bodyText(context),
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      if (controller.phoneError.value.isNotEmpty) {
                        controller.phoneError.value = '';
                      }
                    },
                    onSubmitted: (_) {
                      controller.passwordFocusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'phone_number'.tr,
                      hintStyle: AppTextStyles.inputHint(context),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing(context, 0.04),
                        vertical: AppDimensions.spacing(context, 0.04),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => controller.phoneError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacing(context, 0.01),
                  ),
                  child: Text(
                    controller.phoneError.value,
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

  Widget _buildCountryCodeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => CountryCodeBottomSheet.show(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing(context, 0.03),
          vertical: AppDimensions.spacing(context, 0.01),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flag icon on the right
            Obx(
              () => Text(
                _getCountryFlag(controller.selectedCountryCode.value),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(width: AppDimensions.spacing(context, 0.015)),
            // Code
            Obx(
              () => Text(
                controller.selectedCountryCode.value,
                style: AppTextStyles.bodyText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryFlag(String code) {
    return '🇲🇷';
  }
}
