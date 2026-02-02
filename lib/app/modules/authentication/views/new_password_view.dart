import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';

class NewPasswordView extends GetView<AuthenticationController> {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        backgroundImage: AppImages.image2,
        showContentContainer: true,
        contentContainerPadding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.width * 0.05,
        ),
        children: [
        SizedBox(height: screenSize.height * 0.02),
        // Title
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Obx(
            () => Text(
              controller.isSignUpMode.value
                  ? 'create_password'.tr
                  : 'enter_new_password'.tr,
              style: AppTextStyles.sectionTitle(context).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        // Subtitle
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'password_requirements'.tr,
            style: AppTextStyles.smallText(context).copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenSize.height * 0.04),
        // New Password Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: _buildPasswordSection(context, screenSize),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Confirm Password Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 250),
          child: _buildConfirmPasswordSection(context, screenSize),
        ),
        SizedBox(height: screenSize.height * 0.04),
        // Save Button
        ElasticIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 400),
          child: _buildSaveButton(context, screenSize),
        ),
        SizedBox(height: screenSize.height * 0.05),
      ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Label
        Text(
          'new_password'.tr,
          style: AppTextStyles.inputLabel(context),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        // Password Field
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: TextField(
              controller: controller.newPasswordController,
              obscureText: controller.obscureNewPassword.value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyText(context),
              onChanged: (_) => controller.validateNewPasswordStrength(),
              decoration: InputDecoration(
                hintText: 'password'.tr,
                hintStyle: AppTextStyles.inputHint(context),
                prefixIcon: IconButton(
                  icon: Image.asset(
                    AppImages.icon4,
                    width: AppDimensions.iconSmall(context) * 1.5,
                    height: AppDimensions.iconSmall(context) * 1.5,
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.04),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        // Password Requirements
        _buildPasswordRequirements(context),
      ],
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _buildRequirementRow(
            context,
            'password_req_length'.tr,
            controller.hasMinLength.value,
          ),
          SizedBox(height: 8),
          _buildRequirementRow(
            context,
            'password_req_case'.tr,
            controller.hasUpperAndLower.value,
          ),
          SizedBox(height: 8),
          _buildRequirementRow(
            context,
            'password_req_special'.tr,
            controller.hasSpecialChar.value,
          ),
          SizedBox(height: 8),
          _buildRequirementRow(
            context,
            'password_req_number'.tr,
            controller.hasNumber.value,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(BuildContext context, String text, bool isValid) {
    final hasInput = controller.newPasswordController.text.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: AppTextStyles.smallText(context).copyWith(
            color: hasInput
                ? (isValid ? AppColors.success : AppColors.error)
                : AppColors.grey500,
          ),
        ),
        SizedBox(width: 8),
        Icon(
          isValid ? Icons.check : Icons.close,
          size: 18,
          color: hasInput
              ? (isValid ? AppColors.success : AppColors.error)
              : AppColors.grey400,
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordSection(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Label
        Text(
          'confirm_password'.tr,
          style: AppTextStyles.inputLabel(context),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        // Confirm Password Field
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: TextField(
              controller: controller.confirmNewPasswordController,
              obscureText: controller.obscureConfirmNewPassword.value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyText(context),
              textInputAction: TextInputAction.done,
              onChanged: (_) => controller.validatePasswordsMatch(),
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'password'.tr,
                hintStyle: AppTextStyles.inputHint(context),
                prefixIcon: IconButton(
                  icon: Image.asset(
                    AppImages.icon4,
                    width: AppDimensions.iconSmall(context) * 1.5,
                    height: AppDimensions.iconSmall(context) * 1.5,
                  ),
                  onPressed: controller.toggleConfirmNewPasswordVisibility,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.04),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        // Passwords Match Indicator
        Obx(
          () {
            final hasInput = controller.confirmNewPasswordController.text.isNotEmpty;
            final isMatch = controller.passwordsMatch.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'passwords_must_match'.tr,
                  style: AppTextStyles.smallText(context).copyWith(
                    color: hasInput
                        ? (isMatch ? AppColors.success : AppColors.error)
                        : AppColors.grey500,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isMatch ? Icons.check : Icons.close,
                  size: 18,
                  color: hasInput
                      ? (isMatch ? AppColors.success : AppColors.error)
                      : AppColors.grey400,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, Size screenSize) {
    return Obx(
      () {
        final isValid = controller.isNewPasswordValid;

        if (controller.isLoading.value) {
          return const Center(child: AppLoader(size: 50));
        }

        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isValid ? controller.saveNewPassword : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppColors.primary : AppColors.grey400,
              disabledBackgroundColor: AppColors.grey300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'save'.tr,
              style: AppTextStyles.buttonText(context).copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
