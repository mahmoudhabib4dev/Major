import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/authentication_controller.dart';
import 'login_header.dart';
import 'phone_input_field.dart';
import 'password_input_field.dart';
import 'login_button.dart';
import 'login_footer.dart';

class AnimatedLoginForm extends GetView<AuthenticationController> {
  const AnimatedLoginForm({super.key});

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
            child: const LoginHeader(),
          ),

          // Phone input with staggered animation
          _AnimatedWidget(
            delay: 100,
            child: const PhoneInputField(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

          // Password input with staggered animation
          _AnimatedWidget(
            delay: 200,
            child: const PasswordInputField(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

          // Login button with staggered animation
          _AnimatedWidget(
            delay: 300,
            child: const LoginButton(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

          // Footer with staggered animation
          _AnimatedWidget(
            delay: 400,
            child: const LoginFooter(),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

          // Continue as Guest button with staggered animation
          _AnimatedWidget(
            delay: 500,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenWidth(context) * 0.05,
              ),
              child: AppButton(
                text: 'continue_as_guest'.tr,
                onPressed: controller.continueAsGuest,
                backgroundColor: Colors.transparent,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                width: double.infinity,
              ),
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
