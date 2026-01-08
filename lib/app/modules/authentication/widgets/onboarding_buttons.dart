import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingButtons extends StatefulWidget {
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onContinueAsGuest;
  final VoidCallback onLogin;

  const OnboardingButtons({
    super.key,
    required this.isLastPage,
    required this.onNext,
    required this.onContinueAsGuest,
    required this.onLogin,
  });

  @override
  State<OnboardingButtons> createState() => _OnboardingButtonsState();
}

class _OnboardingButtonsState extends State<OnboardingButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(OnboardingButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLastPage != widget.isLastPage) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.isLastPage
            ? _buildLastPageButtons(screenSize)
            : _buildNextButton(screenSize),
      ),
    );
  }

  Widget _buildLastPageButtons(Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'continue_as_guest'.tr,
            onPressed: widget.onContinueAsGuest,
            backgroundColor: Colors.transparent,
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
            width: double.infinity,
          ),
        ),
        SizedBox(width: screenSize.width * 0.04),
        Expanded(
          child: AppButton(
            text: 'login'.tr,
            onPressed: widget.onLogin,
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            borderColor: AppColors.primary,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(Size screenSize) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: (screenSize.width - (screenSize.width * 0.1) - (screenSize.width * 0.04)) / 2,
        child: AppButton(
          text: 'next'.tr,
          onPressed: widget.onNext,
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          borderColor: AppColors.primary,
          width: double.infinity,
        ),
      ),
    );
  }
}
