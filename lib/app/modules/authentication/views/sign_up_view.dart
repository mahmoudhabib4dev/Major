import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/country_code_bottom_sheet.dart';

class SignUpView extends GetView<AuthenticationController> {
  const SignUpView({super.key});

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
          child: Text(
            'sign_up'.tr,
            style: AppTextStyles.sectionTitle(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        // Subtitle
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'sign_up_subtitle'.tr,
            style: AppTextStyles.smallText(context).copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Profile Picture
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: _buildProfilePictureSection(context),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Username Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 200),
          child: _buildUsernameField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Phone Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 250),
          child: _buildPhoneField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Email Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 300),
          child: _buildEmailField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Gender Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 325),
          child: _buildGenderField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Birth Date Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 350),
          child: _buildBirthDateField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Educational Stage Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 400),
          child: _buildEducationalStageField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Branch Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 450),
          child: Obx(
            () => controller.selectedEducationalStage.value.isNotEmpty
                ? controller.isLoadingDivisions.value
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spacing(context, 0.04),
                        ),
                        child: const Center(
                          child: AppLoader(size: 50),
                        ),
                      )
                    : controller.divisions.isNotEmpty
                        ? Column(
                            children: [
                              _buildBranchField(context),
                              SizedBox(height: screenSize.height * 0.02),
                            ],
                          )
                        : const SizedBox.shrink()
                : const SizedBox.shrink(),
          ),
        ),
        // Wilaya Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 475),
          child: _buildWilayaField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Terms and Conditions
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 500),
          child: _buildTermsCheckbox(context),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Next Button
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 550),
          child: _buildNextButton(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Login Link
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 600),
          child: _buildLoginLink(context),
        ),
        SizedBox(height: screenSize.height * 0.03),
      ],
      ),
    );
  }

  Widget _buildProfilePictureSection(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: controller.pickProfileImage,
        child: Obx(
          () {
            final hasImage = controller.profileImage.value != null;
            final hasGender = controller.selectedGender.value.isNotEmpty;

            return Stack(
              children: [
                // Avatar circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey100,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.file(
                            controller.profileImage.value!,
                            fit: BoxFit.cover,
                          )
                        : hasGender
                            ? Image.asset(
                                controller.defaultAvatar,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.grey400,
                              ),
                  ),
                ),
                // Camera icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'gender'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showGenderBottomSheet(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedGender.value.isEmpty
                          ? 'choose_gender'.tr
                          : controller.selectedGender.value == 'male'
                              ? 'male'.tr
                              : 'female'.tr,
                      textAlign: TextAlign.start,
                      style: controller.selectedGender.value.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.grey500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'username'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
              Text(
                ' *',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
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
              border: controller.usernameError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: TextField(
              controller: controller.usernameController,
              textAlign: TextAlign.start,
              style: AppTextStyles.bodyText(context),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (controller.usernameError.value.isNotEmpty) {
                  controller.usernameError.value = '';
                }
              },
              decoration: InputDecoration(
                hintText: 'username'.tr,
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
          () => controller.usernameError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacing(context, 0.01),
                  ),
                  child: Text(
                    controller.usernameError.value,
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

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'phone_number'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
              Text(
                ' *',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
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
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    CountryCodeBottomSheet.show(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.03),
                      vertical: AppDimensions.spacing(context, 0.01),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => Text(
                            _getCountryFlag(controller.selectedCountryCode.value),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacing(context, 0.015)),
                        Obx(
                          () => Text(
                            controller.selectedCountryCode.value,
                            style: AppTextStyles.bodyText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Phone input
                Expanded(
                  child: TextField(
                    controller: controller.signUpPhoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.bodyText(context),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (controller.phoneError.value.isNotEmpty) {
                        controller.phoneError.value = '';
                      }
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

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'email'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
              Text(
                ' *',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
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
              controller: controller.signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodyText(context),
              textInputAction: TextInputAction.done,
              onChanged: (_) {
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

  Widget _buildBirthDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'birth_date'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showDatePicker(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.formattedBirthDate.isEmpty
                          ? 'birth_date'.tr
                          : controller.formattedBirthDate,
                      textAlign: TextAlign.start,
                      style: controller.formattedBirthDate.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  AppImages.icon24,
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationalStageField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'educational_stage'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showEducationalStageBottomSheet(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedEducationalStage.value.isEmpty
                          ? 'select_educational_stage'.tr
                          : controller.selectedEducationalStage.value,
                      textAlign: TextAlign.start,
                      style: controller.selectedEducationalStage.value.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.grey500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'division'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showBranchBottomSheet(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedBranch.value.isEmpty
                          ? 'select_division'.tr
                          : controller.selectedBranch.value,
                      textAlign: TextAlign.start,
                      style: controller.selectedBranch.value.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.grey500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWilayaField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'wilaya'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showWilayaBottomSheet(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedWilaya.value.isEmpty
                          ? 'select_wilaya'.tr
                          : controller.selectedWilaya.value,
                      textAlign: TextAlign.start,
                      style: controller.selectedWilaya.value.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.grey500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(
          () => GestureDetector(
            onTap: controller.toggleTermsAgreement,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: controller.agreedToTerms.value
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: controller.agreedToTerms.value
                      ? AppColors.primary
                      : AppColors.grey400,
                  width: 1.5,
                ),
              ),
              child: controller.agreedToTerms.value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.smallText(context).copyWith(
                color: AppColors.grey600,
              ),
              children: [
                TextSpan(
                  text: 'i_agree_to'.tr,
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/terms');
                    },
                    child: Text(
                      'terms_and_conditions'.tr,
                      style: AppTextStyles.smallText(context).copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: AppLoader(size: 50))
          : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.completeSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'create_account'.tr,
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'have_account'.tr,
          style: AppTextStyles.bodyText(context).copyWith(
            color: AppColors.grey600,
          ),
        ),
        GestureDetector(
          onTap: controller.backToLoginFromSignUp,
          child: Text(
            'login'.tr,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context) async {
    // Dismiss keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    DateTime? selectedDate = controller.selectedBirthDate.value;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _DatePickerBottomSheet(
        initialDate: controller.selectedBirthDate.value ?? DateTime(2000),
        onDateChanged: (date) {
          selectedDate = date;
        },
        onConfirm: () {
          if (selectedDate != null) {
            controller.selectBirthDate(selectedDate!);
          }
          Get.back();
        },
      ),
    );

    // Forcefully hide keyboard after bottom sheet closes
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showEducationalStageBottomSheet(BuildContext context) async {
    // Dismiss keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _SelectionBottomSheet(
        title: 'choose_educational_stage'.tr,
        items: controller.educationalStages,
        selectedValue: controller.selectedEducationalStage,
        onSelect: (value) {
          controller.selectEducationalStage(value);
          Get.back();
        },
      ),
    );

    // Forcefully hide keyboard after bottom sheet closes
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showBranchBottomSheet(BuildContext context) async {
    // Dismiss keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _SelectionBottomSheet(
        title: 'choose_division'.tr,
        items: controller.branches,
        selectedValue: controller.selectedBranch,
        onSelect: (value) {
          controller.selectBranch(value);
          Get.back();
        },
      ),
    );

    // Forcefully hide keyboard after bottom sheet closes
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showWilayaBottomSheet(BuildContext context) async {
    // Dismiss keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _SelectionBottomSheet(
        title: 'choose_wilaya'.tr,
        items: controller.wilayas,
        selectedValue: controller.selectedWilaya,
        onSelect: (value) {
          controller.selectWilaya(value);
          Get.back();
        },
      ),
    );

    // Forcefully hide keyboard after bottom sheet closes
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showGenderBottomSheet(BuildContext context) async {
    // Dismiss keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _GenderSelectionBottomSheet(
        onSelect: (value) {
          controller.selectGender(value);
          Get.back();
        },
      ),
    );

    // Forcefully hide keyboard after bottom sheet closes
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  String _getCountryFlag(String code) {
    return '🇲🇷';
  }
}

// Top curve clipper for wave effect
class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    path.lineTo(0, notchRadius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, notchRadius);

    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(notchCenterX + notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchCenterX,
      -notchRadius * 0.5,
      notchCenterX - notchWidth / 2,
      0,
    );

    path.lineTo(notchRadius, 0);

    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// Selection bottom sheet widget
class _SelectionBottomSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final RxString selectedValue;
  final Function(String) onSelect;

  const _SelectionBottomSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Header with close button and title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close button
                        FadeInLeft(
                          duration: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.grey600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            title,
                            style: AppTextStyles.sectionTitle(context),
                          ),
                        ),
                        // Empty space for balance
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Options (Scrollable)
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.6,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) => FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: 100 * index),
                          child: _buildOption(
                            context: context,
                            item: items[index],
                            isLast: index == items.length - 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.04)),
                ],
              ),
            ),
          ),
          // Small dot at top center where curve peaks
          Positioned(
            top: -screenSize.width * 0.025 + 5,
            left: screenSize.width / 2 - screenSize.width * 0.0125,
            child: Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String item,
    required bool isLast,
  }) {
    return Obx(
      () {
        final isSelected = selectedValue.value == item;
        return Column(
          children: [
            InkWell(
              onTap: () => onSelect(item),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.03),
                ),
                child: Row(
                  children: [
                    // Item name
                    Text(
                      item,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    const Spacer(),
                    // Radio button
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(
                color: AppColors.grey200,
                height: 1,
                indent: AppDimensions.spacing(context, 0.04),
                endIndent: AppDimensions.spacing(context, 0.04),
              ),
          ],
        );
      },
    );
  }
}

// Gender selection bottom sheet widget
class _GenderSelectionBottomSheet extends StatelessWidget {
  final Function(String) onSelect;

  const _GenderSelectionBottomSheet({
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Header with close button and title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close button
                        FadeInLeft(
                          duration: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.grey600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'choose_gender'.tr,
                            style: AppTextStyles.sectionTitle(context),
                          ),
                        ),
                        // Empty space for balance
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Male option
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _buildGenderOption(
                      context: context,
                      genderKey: 'male',
                      icon: AppImages.icon58,
                    ),
                  ),
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                    indent: AppDimensions.spacing(context, 0.04),
                    endIndent: AppDimensions.spacing(context, 0.04),
                  ),
                  // Female option
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildGenderOption(
                      context: context,
                      genderKey: 'female',
                      icon: AppImages.icon57,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.04)),
                ],
              ),
            ),
          ),
          // Small dot at top center where curve peaks
          Positioned(
            top: -screenSize.width * 0.025 + 5,
            left: screenSize.width / 2 - screenSize.width * 0.0125,
            child: Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildGenderOption({
    required BuildContext context,
    required String genderKey,
    required String icon,
  }) {
    return InkWell(
      onTap: () => onSelect(genderKey),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing(context, 0.04),
          vertical: AppDimensions.spacing(context, 0.03),
        ),
        child: Row(
          children: [
            // Gender name
            Text(
              genderKey.tr,
              style: AppTextStyles.bodyText(context),
            ),
            const Spacer(),
            // Gender icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey100,
              ),
              child: ClipOval(
                child: Image.asset(
                  icon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Date picker bottom sheet widget
class _DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onConfirm;

  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.onDateChanged,
    required this.onConfirm,
  });

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;
    final locale = Get.locale?.languageCode ?? 'ar';

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: AppDimensions.spacing(context, 0.02)),
                    // Header with close button and title
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing(context, 0.04),
                        vertical: AppDimensions.spacing(context, 0.02),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Close button
                          FadeInLeft(
                            duration: const Duration(milliseconds: 400),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.grey600,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          // Title
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              'birth_date'.tr,
                              style: AppTextStyles.sectionTitle(context),
                            ),
                          ),
                          // Empty space for balance
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    // Divider
                    Divider(
                      color: AppColors.grey200,
                      height: 1,
                    ),
                    SizedBox(height: AppDimensions.spacing(context, 0.03)),
                    // Date Picker
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing(context, 0.04),
                        ),
                        child: DatePickerWidget(
                          looping: false,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          initialDate: _selectedDate,
                          dateFormat: 'dd-MMMM-yyyy',
                          locale: locale == 'ar'
                              ? DateTimePickerLocale.ar
                              : locale == 'fr'
                                  ? DateTimePickerLocale.fr
                                  : DateTimePickerLocale.en_us,
                          pickerTheme: DateTimePickerTheme(
                            backgroundColor: AppColors.white,
                            itemTextStyle: AppTextStyles.bodyText(context).copyWith(
                              color: AppColors.textDark,
                              fontSize: 18,
                            ),
                            dividerColor: AppColors.primary,
                            itemHeight: 50,
                          ),
                          onChange: (DateTime newDate, _) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                            widget.onDateChanged(newDate);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context, 0.03)),
                    // Confirm button
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing(context, 0.04),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: widget.onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'confirm'.tr,
                              style: AppTextStyles.buttonText(context).copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context, 0.04)),
                  ],
                ),
              ),
            ),
            // Small dot at top center where curve peaks
            Positioned(
              top: -screenSize.width * 0.025 + 5,
              left: screenSize.width / 2 - screenSize.width * 0.0125,
              child: Container(
                width: screenSize.width * 0.025,
                height: screenSize.width * 0.025,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
