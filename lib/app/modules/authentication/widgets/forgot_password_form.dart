import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/authentication_controller.dart';
import 'forgot_password_header.dart';
import 'email_input_field.dart';
import 'login_footer.dart';

class ForgotPasswordForm extends GetView<AuthenticationController> {
  const ForgotPasswordForm({super.key});

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
            child: const ForgotPasswordHeader(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.04),

          // Email input with staggered animation
          _AnimatedWidget(
            delay: 100,
            child: const EmailInputField(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.25),

          // Send code button with staggered animation at bottom
          _AnimatedWidget(
            delay: 200,
            child: Obx(
              () => AppButton(
                text: 'send_code'.tr,
                onPressed: controller.sendOtpCode,
                isLoading: controller.isLoading.value,
                backgroundColor: AppColors.primary,
                width: AppDimensions.screenWidth(context) * 0.9,
              ),
            ),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

          // Footer with staggered animation
          _AnimatedWidget(
            delay: 300,
            child: const LoginFooter(),
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
