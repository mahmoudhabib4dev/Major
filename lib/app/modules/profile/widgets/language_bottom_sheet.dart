import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/profile_controller.dart';

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

class LanguageBottomSheet extends GetView<ProfileController> {
  const LanguageBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => const LanguageBottomSheet(),
    );
  }

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
                              'select_language'.tr,
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
                    // Language options
                    ...List.generate(
                      controller.languages.length,
                      (index) => FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildLanguageOption(
                          context: context,
                          language: controller.languages[index],
                          isLast: index == controller.languages.length - 1,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context, 0.04)),
                    // Confirm button
                    ElasticIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing(context, 0.04),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.confirmLanguageSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'confirm'.tr,
                              style: AppTextStyles.buttonText(context).copyWith(
                                color: AppColors.white,
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

  Widget _buildLanguageOption({
    required BuildContext context,
    required Map<String, String> language,
    required bool isLast,
  }) {
    return Obx(
      () {
        final isSelected = controller.selectedLanguage.value == language['code'];
        return Column(
          children: [
            InkWell(
              onTap: () => controller.selectLanguage(language['code']!),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.03),
                ),
                child: Row(
                  children: [
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
                    const Spacer(),
                    // Language name
                    Text(
                      language['nameKey']!.tr,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
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
