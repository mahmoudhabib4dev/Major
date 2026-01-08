import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

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

class CountryCodeBottomSheet extends GetView<AuthenticationController> {
  const CountryCodeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CountryCodeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    final countries = [
      {'name': 'موريتانيا', 'code': '+222', 'flag': '🇲🇷'},
    ];

    return ClipPath(
      clipper: _TopCurveClipper(notchRadius: notchRadius),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(0, -notchRadius * 0.8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: notchRadius * 0.8),
              color: AppColors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Space for wave
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Title
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: AppDimensions.paddingAll(context, 0.04),
                      child: Text(
                        'اختر كود الدولة',
                        style: AppTextStyles.sectionTitle(context),
                      ),
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  // Countries list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: countries.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.grey200,
                        height: 1,
                        indent: AppDimensions.spacing(context, 0.04),
                        endIndent: AppDimensions.spacing(context, 0.04),
                      ),
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: 50 * index),
                          child: Obx(
                            () {
                              final isSelected = controller.selectedCountryCode.value == country['code'];
                              return ListTile(
                                contentPadding: AppDimensions.paddingHorizontal(context, 0.04),
                                leading: Text(
                                  country['flag']!,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                title: Text(
                                  country['name']!,
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : null,
                                  ),
                                ),
                                trailing: Text(
                                  country['code']!,
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.grey600,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedTileColor: AppColors.grey100,
                                onTap: () {
                                  controller.updateCountryCode(country['code']!);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
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
    );
  }
}
