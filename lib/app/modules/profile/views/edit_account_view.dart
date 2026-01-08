import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/network_avatar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_country_code_bottom_sheet.dart';
import '../widgets/profile_page_header_widget.dart';

class EditAccountView extends GetView<ProfileController> {
  const EditAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load profile data when page opens
    controller.loadProfileData();

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      onRefresh: () => controller.loadProfileData(),
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'edit_profile'.tr,
            onBack: () => Get.back(),
          ),
        ),
      ],
      sliverChildren: [
        SliverPadding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile Picture Section with Orbit
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: _buildProfilePictureSection(context, screenSize),
              ),
              SizedBox(height: screenSize.height * 0.03),
              // Username Field
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: _buildNameField(context),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Phone Number Field (Disabled)
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 150),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 150),
                  child: _buildPhoneField(context, enabled: false),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Email Field (Disabled)
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: _buildEmailField(context, enabled: false),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Birthday Field (Disabled)
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 250),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 250),
                  child: _buildDateField(context, enabled: false),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Educational Stage Dropdown (Disabled)
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildDropdownField(
                    context: context,
                    label: 'educational_stage'.tr,
                    hintText: 'select_educational_stage'.tr,
                    value: controller.selectedEducationalStage,
                    items: controller.educationalStages,
                    onChanged: controller.selectEducationalStage,
                    enabled: false,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Division Dropdown (Disabled)
              SlideInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 350),
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 350),
                  child: _buildDropdownField(
                    context: context,
                    label: 'division'.tr,
                    hintText: 'select_division'.tr,
                    value: controller.selectedDivision,
                    items: controller.divisions,
                    onChanged: controller.selectDivision,
                    enabled: false,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
              // Save Button
              ElasticIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 450),
                child: _buildSaveButton(context, screenSize),
              ),
              SizedBox(height: screenSize.height * 0.05),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(BuildContext context, Size screenSize) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Spinning Orbit
            Positioned(
              top: 0,
              child: SpinPerfect(
                duration: const Duration(seconds: 20),
                infinite: true,
                child: FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF000D47),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      AppImages.icon30,
                      width: 116,
                      height: 113,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Avatar (centered in orbit)
            Positioned(
              top: 16.5, // Vertically center in the 113px tall orbit: (113-80)/2 = 16.5
              child: ZoomIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Obx(
                  () {
                    // Get gender-based avatar
                    final user = controller.storageService.currentUser;
                    final gender = user?.gender;
                    final genderAvatar = (gender == 'male' || gender == 'ذكر')
                        ? AppImages.icon58
                        : AppImages.icon57;

                    return SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipOval(
                        child: controller.selectedProfileImage.value != null
                            ? Image.file(
                                controller.selectedProfileImage.value!,
                                fit: BoxFit.cover,
                              )
                            : controller.userImageUrl.value.isNotEmpty
                                ? NetworkAvatar(
                                    imageUrl: controller.userImageUrl.value,
                                    size: 80,
                                    fallbackAsset: genderAvatar,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    genderAvatar,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Edit Icon at bottom right
            Positioned(
              bottom: 48,
              right: 25,
              child: ZoomIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: GestureDetector(
                  onTap: controller.changeProfilePicture,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.icon40,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '* ',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                TextSpan(
                  text: 'username'.tr,
                  style: AppTextStyles.inputLabel(context),
                ),
              ],
            ),
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
              border: controller.nameError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: TextField(
              controller: controller.nameController,
              keyboardType: TextInputType.name,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyText(context),
              onChanged: (value) {
                if (controller.nameError.value.isNotEmpty) {
                  controller.nameError.value = '';
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
          () => controller.nameError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacing(context, 0.01),
                  ),
                  child: Text(
                    controller.nameError.value,
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

  Widget _buildPhoneField(BuildContext context, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '* ',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                TextSpan(
                  text: 'phone_number'.tr,
                  style: AppTextStyles.inputLabel(context),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: enabled ? AppColors.grey100 : AppColors.grey200,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
              border: controller.phoneError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Country code selector (on the right in RTL)
                GestureDetector(
                  onTap: enabled ? () => ProfileCountryCodeBottomSheet.show(context) : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.03),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Flag icon
                        Obx(
                          () => Text(
                            controller.getCountryFlag(controller.selectedCountryCode.value),
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
                ),
                // Phone input (on the left in RTL)
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    enabled: enabled,
                    readOnly: !enabled,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: enabled ? null : AppColors.grey500,
                    ),
                    onChanged: enabled
                        ? (value) {
                            if (controller.phoneError.value.isNotEmpty) {
                              controller.phoneError.value = '';
                            }
                          }
                        : null,
                    decoration: InputDecoration(
                      hintText: 'phone_number'.tr,
                      hintStyle: AppTextStyles.inputHint(context).copyWith(
                        color: enabled ? null : AppColors.grey400,
                      ),
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

  Widget _buildEmailField(BuildContext context, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '* ',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                TextSpan(
                  text: 'email'.tr,
                  style: AppTextStyles.inputLabel(context),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: enabled ? AppColors.grey100 : AppColors.grey200,
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
              enabled: enabled,
              readOnly: !enabled,
              style: AppTextStyles.bodyText(context).copyWith(
                color: enabled ? null : AppColors.grey500,
              ),
              onChanged: enabled
                  ? (value) {
                      if (controller.emailError.value.isNotEmpty) {
                        controller.emailError.value = '';
                      }
                    }
                  : null,
              decoration: InputDecoration(
                hintText: 'email'.tr,
                hintStyle: AppTextStyles.inputHint(context).copyWith(
                  color: enabled ? null : AppColors.grey400,
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

  Widget _buildDateField(BuildContext context, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'birth_date'.tr,
            style: AppTextStyles.inputLabel(context),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Obx(
          () => InkWell(
            onTap: enabled ? () => controller.selectBirthday(context) : null,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
              decoration: BoxDecoration(
                color: enabled ? AppColors.grey100 : AppColors.grey200,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadius(context, 0.03),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.icon24,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: enabled ? null : AppColors.grey400,
                  ),
                  SizedBox(width: AppDimensions.spacing(context, 0.02)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        controller.selectedBirthday.value != null
                            ? controller.formatBirthday(controller.selectedBirthday.value!)
                            : 'birth_date'.tr,
                        style: controller.selectedBirthday.value != null
                            ? AppTextStyles.bodyText(context).copyWith(
                                color: enabled ? null : AppColors.grey500,
                              )
                            : AppTextStyles.inputHint(context).copyWith(
                                color: enabled ? null : AppColors.grey400,
                              ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String hintText,
    required Rxn<String> value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: AppTextStyles.inputLabel(context),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Obx(
          () => InkWell(
            onTap: enabled
                ? () => _showSelectionBottomSheet(
                      context: context,
                      title: label,
                      items: items,
                      selectedValue: value.value,
                      onSelected: onChanged,
                    )
                : null,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
              decoration: BoxDecoration(
                color: enabled ? AppColors.grey100 : AppColors.grey200,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadius(context, 0.03),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: enabled ? AppColors.grey500 : AppColors.grey400,
                  ),
                  SizedBox(width: AppDimensions.spacing(context, 0.02)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        value.value ?? hintText,
                        style: value.value != null
                            ? AppTextStyles.bodyText(context).copyWith(
                                color: enabled ? null : AppColors.grey500,
                              )
                            : AppTextStyles.inputHint(context).copyWith(
                                color: enabled ? null : AppColors.grey400,
                              ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.borderRadius(context, 0.05)),
            topRight: Radius.circular(AppDimensions.borderRadius(context, 0.05)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(
                vertical: AppDimensions.spacing(context, 0.02),
              ),
              width: AppDimensions.screenWidth(context) * 0.12,
              height: AppDimensions.spacing(context, 0.01),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadius(context, 0.01),
                ),
              ),
            ),
            // Title
            Padding(
              padding: AppDimensions.paddingAll(context, 0.04),
              child: Text(
                title,
                style: AppTextStyles.sectionTitle(context),
              ),
            ),
            // Items list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.grey200,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedValue == item;
                return ListTile(
                  contentPadding: AppDimensions.paddingHorizontal(context, 0.04),
                  title: Text(
                    item,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: isSelected ? AppColors.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  selected: isSelected,
                  selectedTileColor: AppColors.grey100,
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, Size screenSize) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.saveAccountChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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
