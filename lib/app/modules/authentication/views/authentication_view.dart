import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';
import '../widgets/onboarding_buttons.dart';
import 'login_view.dart';
import 'forgot_password_view.dart';
import 'restore_password_view.dart';
import 'new_password_view.dart';
import 'sign_up_view.dart';
import 'subscription_view.dart';
import 'payment_view.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Obx(
      () {
        // Show payment page
        if (controller.showPaymentPage.value) {
          return const PaymentView();
        }

        // Show subscription page
        if (controller.showSubscriptionPage.value) {
          return const SubscriptionView();
        }

        // Show new password page
        if (controller.showNewPasswordPage.value) {
          return const NewPasswordView();
        }

        // Show sign up page
        if (controller.showSignUpPage.value) {
          return const SignUpView();
        }

        // Show restore password page
        if (controller.showRestorePasswordPage.value) {
          return const RestorePasswordView();
        }

        // Show forgot password page
        if (controller.showForgotPasswordPage.value) {
          return const ForgotPasswordView();
        }

        // Show login page
        if (controller.showLoginPage.value) {
          return const LoginView();
        }

        // Show onboarding pages
        return AppScaffold(
          backgroundImage: AppImages.image2,
          showContentContainer: true,
          children: [
            // Onboarding pages with PageView
            _buildOnboardingPageView(screenSize),

            SizedBox(height: screenSize.height * 0.02),

            // Page indicators
            _buildPageIndicators(),

            SizedBox(height: screenSize.height * 0.03),

            // Action buttons
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  /// Builds the PageView with onboarding pages
  Widget _buildOnboardingPageView(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.55,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.updatePage,
            itemCount: controller.totalPages,
            itemBuilder: (context, index) {
              final data = controller.onboardingPages[index];
              return OnboardingPage(
                key: ValueKey('onboarding_page_$index'),
                icon: data.icon,
                title: data.title,
                emoji: data.emoji,
                description: data.description,
              );
            },
          ),
          // Skip button at top left (shown on pages 1 and 2)
          Positioned(
            top: 0,
            left: 0,
            child: Obx(
              () => controller.currentPage.value < controller.totalPages - 1
                  ? TextButton(
                      onPressed: () {
                        controller.pageController.jumpToPage(controller.totalPages - 1);
                      },
                      child: Text(
                        'skip'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1F71),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Previous button at top right (shown on pages 2 and 3)
          Positioned(
            top: 0,
            right: 0,
            child: Obx(
              () => controller.currentPage.value > 0
                  ? TextButton(
                      onPressed: controller.previousPage,
                      child: Text(
                        'previous'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1F71),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the page indicators (dots)
  Widget _buildPageIndicators() {
    return Obx(
      () => PageIndicator(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
      ),
    );
  }

  /// Builds the action buttons (Next or Login/Guest buttons)
  Widget _buildActionButtons() {
    return Obx(
      () => OnboardingButtons(
        isLastPage: controller.isLastPage,
        onNext: controller.nextPage,
        onContinueAsGuest: controller.continueAsGuest,
        onLogin: controller.navigateToLogin,
      ),
    );
  }
}

