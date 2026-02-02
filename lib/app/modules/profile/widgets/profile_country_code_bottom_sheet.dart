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

class ProfileCountryCodeBottomSheet extends GetView<ProfileController> {
  const ProfileCountryCodeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => const ProfileCountryCodeBottomSheet(),
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
                              'select_country_code'.tr,
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
                    // Countries list (Scrollable)
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenSize.height * 0.5,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.countries.length,
                          itemBuilder: (context, index) => FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: Duration(milliseconds: 50 * index.clamp(0, 5)),
                            child: _buildCountryOption(
                              context: context,
                              country: controller.countries[index],
                              isLast: index == controller.countries.length - 1,
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

  Widget _buildCountryOption({
    required BuildContext context,
    required Map<String, String> country,
    required bool isLast,
  }) {
    return Obx(
      () {
        final isSelected = controller.selectedCountryCode.value == country['code'];
        return Column(
          children: [
            InkWell(
              onTap: () {
                controller.updateCountryCode(country['code']!);
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.03),
                ),
                child: Row(
                  children: [
                    // Flag
                    Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: AppDimensions.spacing(context, 0.03)),
                    // Country name
                    Expanded(
                      child: Text(
                        country['name']!,
                        style: AppTextStyles.bodyText(context).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                    ),
                    // Country code
                    Text(
                      country['code']!,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing(context, 0.03)),
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
