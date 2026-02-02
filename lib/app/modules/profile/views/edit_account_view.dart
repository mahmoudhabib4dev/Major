import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_loader.dart';
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
              border: controller.nameError.value.isNotEmpty
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: TextField(
              controller: controller.nameController,
              keyboardType: TextInputType.name,
              textAlign: TextAlign.start,
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
              color: enabled ? AppColors.grey100 : AppColors.grey200,
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
                  onTap: enabled ? () => ProfileCountryCodeBottomSheet.show(context) : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.03),
                      vertical: AppDimensions.spacing(context, 0.01),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                // Phone input
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
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
              textDirection: TextDirection.ltr,
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
        Obx(
          () => InkWell(
            onTap: enabled ? () => controller.selectBirthday(context) : null,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
            child: Container(
              width: double.infinity,
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
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedBirthday.value != null
                          ? controller.formatBirthday(controller.selectedBirthday.value!)
                          : 'birth_date'.tr,
                      textAlign: TextAlign.start,
                      style: controller.selectedBirthday.value != null
                          ? AppTextStyles.bodyText(context).copyWith(
                              color: enabled ? null : AppColors.grey500,
                            )
                          : AppTextStyles.inputHint(context).copyWith(
                              color: enabled ? null : AppColors.grey400,
                            ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.asset(
                    AppImages.icon24,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: enabled ? null : AppColors.grey400,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: AppTextStyles.inputLabel(context),
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
              width: double.infinity,
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
                children: [
                  Expanded(
                    child: Text(
                      value.value ?? hintText,
                      textAlign: TextAlign.start,
                      style: value.value != null
                          ? AppTextStyles.bodyText(context).copyWith(
                              color: enabled ? null : AppColors.grey500,
                            )
                          : AppTextStyles.inputHint(context).copyWith(
                              color: enabled ? null : AppColors.grey400,
                            ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: enabled ? AppColors.grey500 : AppColors.grey400,
                    size: 24,
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
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => Transform.translate(
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
                      // Space for wave
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
                      // Items list
                      ...List.generate(
                        items.length,
                        (index) {
                          final item = items[index];
                          final isSelected = selectedValue == item;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: Duration(milliseconds: 100 * index.clamp(0, 5)),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    onSelected(item);
                                    Navigator.pop(context);
                                  },
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
                                if (index != items.length - 1)
                                  Divider(
                                    color: AppColors.grey200,
                                    height: 1,
                                    indent: AppDimensions.spacing(context, 0.04),
                                    endIndent: AppDimensions.spacing(context, 0.04),
                                  ),
                              ],
                            ),
                          );
                        },
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
      ),
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
                onPressed: controller.saveAccountChanges,
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

// Top curve clipper for wave effect
class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    // Start from top left
    path.lineTo(0, notchRadius);

    // Left side going down
    path.lineTo(0, size.height);

    // Bottom
    path.lineTo(size.width, size.height);

    // Right side going up
    path.lineTo(size.width, notchRadius);

    // Top right corner curve
    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Line to notch start (right side)
    path.lineTo(notchCenterX + notchWidth / 2, 0);

    // Create ONE wavy curve in the middle
    path.quadraticBezierTo(
      notchCenterX, // control point x (center)
      -notchRadius * 0.5, // control point y (depth of wave)
      notchCenterX - notchWidth / 2, // end point x
      0, // end point y
    );

    // Line to top left corner
    path.lineTo(notchRadius, 0);

    // Top left corner curve
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
