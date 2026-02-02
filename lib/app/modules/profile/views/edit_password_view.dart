import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_page_header_widget.dart';

class EditPasswordView extends GetView<ProfileController> {
  const EditPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'edit_password'.tr,
            onBack: () => Get.back(),
          ),
        ),
      ],
      sliverChildren: [
        SliverPadding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: screenSize.height * 0.02),
              // Lock Title
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'enter_new_password'.tr,
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              // Subtitle
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'password_requirements'.tr,
                    style: AppTextStyles.smallText(context).copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
              // Current Password
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 150),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 150),
                  child: _buildPasswordField(
                    context: context,
                    label: 'current_password'.tr,
                    hintText: 'current_password'.tr,
                    textController: controller.currentPasswordController,
                    isObscured: controller.obscureCurrentPassword,
                    onToggle: controller.toggleCurrentPasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
              // New Password
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 250),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 250),
                  child: _buildPasswordField(
                    context: context,
                    label: 'new_password'.tr,
                    hintText: 'new_password'.tr,
                    textController: controller.newPasswordController,
                    isObscured: controller.obscureNewPassword,
                    onToggle: controller.toggleNewPasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Confirm Password
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildPasswordField(
                    context: context,
                    label: 'confirm_password'.tr,
                    hintText: 'confirm_password'.tr,
                    textController: controller.confirmPasswordController,
                    isObscured: controller.obscureConfirmPassword,
                    onToggle: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.06),
              // Save Button
              ElasticIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: _buildSaveButton(context, screenSize),
              ),
              SizedBox(height: screenSize.height * 0.05),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController textController,
    required RxBool isObscured,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
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
            ),
            child: TextField(
              controller: textController,
              obscureText: isObscured.value,
              textAlign: TextAlign.start,
              style: AppTextStyles.bodyText(context),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.inputHint(context),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    AppImages.icon4,
                    width: AppDimensions.iconSmall(context) * 1.5,
                    height: AppDimensions.iconSmall(context) * 1.5,
                  ),
                  onPressed: onToggle,
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
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, Size screenSize) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: AppLoader(size: 50))
          : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'save_changes'.tr,
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
