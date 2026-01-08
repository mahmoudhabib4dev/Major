import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppDialog extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? icon;
  final Color? iconBackgroundColor;
  final bool isSuccess;
  final bool isError;

  const AppDialog({
    super.key,
    required this.message,
    required this.buttonText,
    this.onButtonPressed,
    this.icon,
    this.iconBackgroundColor,
    this.isSuccess = false,
    this.isError = false,
  });

  /// Shows a success dialog
  static void showSuccess({
    required String message,
    String buttonText = 'حسناً',
    VoidCallback? onButtonPressed,
  }) {
    Get.dialog(
      AppDialog(
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed ?? () => Get.back(),
        isSuccess: true,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
          size: 40,
        ),
        iconBackgroundColor: AppColors.success,
      ),
      barrierDismissible: false,
    );
  }

  /// Shows an error dialog
  static void showError({
    required String message,
    String buttonText = 'حسناً',
    VoidCallback? onButtonPressed,
  }) {
    Get.dialog(
      AppDialog(
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed ?? () => Get.back(),
        isError: true,
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 40,
        ),
        iconBackgroundColor: AppColors.error,
      ),
      barrierDismissible: false,
    );
  }

  /// Shows an info dialog
  static void showInfo({
    required String message,
    String buttonText = 'حسناً',
    VoidCallback? onButtonPressed,
    Widget? icon,
  }) {
    Get.dialog(
      AppDialog(
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed ?? () => Get.back(),
        icon: icon,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: screenSize.width * 0.85,
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          padding: EdgeInsets.all(screenSize.width * 0.06),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.grey200,
                    shape: BoxShape.circle,
                  ),
                  child: icon != null
                      ? Center(child: icon)
                      : null,
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              // Message
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  message,
                  style: AppTextStyles.sectionTitle(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
              // Button
              ElasticIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: AppTextStyles.buttonText(context).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
