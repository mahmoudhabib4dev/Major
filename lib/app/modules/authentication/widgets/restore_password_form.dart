import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/authentication_controller.dart';
import 'restore_password_header.dart';
import 'otp_input_fields.dart';

class RestorePasswordForm extends GetView<AuthenticationController> {
  const RestorePasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Header with staggered animation
          _AnimatedWidget(
            delay: 0,
            child: const RestorePasswordHeader(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.04),

          // OTP input fields with staggered animation
          _AnimatedWidget(
            delay: 100,
            child: const OtpInputFields(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

          // Error message
          Obx(
            () => controller.otpError.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppDimensions.spacing(context, 0.01),
                    ),
                    child: Text(
                      controller.otpError.value,
                      style: AppTextStyles.smallText(context).copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.04),

          // Verify button with staggered animation
          _AnimatedWidget(
            delay: 200,
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: AppLoader(size: 50))
                  : AppButton(
                      text: 'confirm'.tr,
                      onPressed: controller.verifyOtp,
                      backgroundColor: AppColors.primary,
                      width: double.infinity,
                    ),
            ),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

          // Resend section with staggered animation
          _AnimatedWidget(
            delay: 300,
            child: Column(
              children: [
                Text(
                  'didnt_receive_message'.tr,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.textGrey,
                    fontSize: AppDimensions.fontSize(context, 0.035),
                  ),
                ),
                SizedBox(height: AppDimensions.spacing(context, 0.01)),
                Obx(
                  () => controller.canResend.value
                      ? GestureDetector(
                          onTap: controller.resendOtpCode,
                          child: Text(
                            'resend'.tr,
                            style: AppTextStyles.bodyText(context).copyWith(
                              color: AppColors.accent,
                              fontSize: AppDimensions.fontSize(context, 0.035),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyText(context).copyWith(
                              fontSize: AppDimensions.fontSize(context, 0.035),
                            ),
                            children: [
                              TextSpan(
                                text: 'resend_after'.tr,
                              ),
                              TextSpan(
                                text: '( ${controller.countdownText} )',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedWidget extends StatelessWidget {
  final int delay;
  final Widget child;

  const _AnimatedWidget({
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
