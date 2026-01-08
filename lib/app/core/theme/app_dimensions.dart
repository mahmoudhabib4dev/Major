import 'package:flutter/material.dart';

class AppDimensions {
  // Get screen size
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;

  // Get screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // Get screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Image dimensions
  static double onboardingImageSize = 200; // 200x200 as specified

  // Spacing
  static double spacing(BuildContext context, double factor) {
    return screenWidth(context) * factor;
  }

  // Padding
  static EdgeInsets paddingAll(BuildContext context, double factor) {
    return EdgeInsets.all(screenWidth(context) * factor);
  }

  static EdgeInsets paddingHorizontal(BuildContext context, double factor) {
    return EdgeInsets.symmetric(horizontal: screenWidth(context) * factor);
  }

  static EdgeInsets paddingVertical(BuildContext context, double factor) {
    return EdgeInsets.symmetric(vertical: screenHeight(context) * factor);
  }

  // Border radius
  static double borderRadius(BuildContext context, double factor) {
    return screenWidth(context) * factor;
  }

  // Icon sizes
  static double iconSmall(BuildContext context) => screenWidth(context) * 0.04;
  static double iconMedium(BuildContext context) => screenWidth(context) * 0.06;
  static double iconLarge(BuildContext context) => screenWidth(context) * 0.08;

  // Button dimensions
  static double buttonHeight(BuildContext context) => screenHeight(context) * 0.067;
  static double buttonWidth(BuildContext context) => screenWidth(context) * 0.35;

  // Font sizes
  static double fontSize(BuildContext context, double factor) {
    return screenWidth(context) * factor;
  }
}
