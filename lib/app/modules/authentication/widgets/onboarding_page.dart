import 'package:flutter/material.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  final String icon;
  final String title;
  final String emoji;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.emoji,
    required this.description,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),

        // Animated Image
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              widget.icon,
              width: AppDimensions.onboardingImageSize,
              height: AppDimensions.onboardingImageSize,
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

        // Animated Title
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Text(
              '${widget.emoji} ${widget.title}',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingTitle(context),
            ),
          ),
        ),

        SizedBox(height: AppDimensions.screenHeight(context) * 0.012),

        // Animated Description
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: AppDimensions.paddingHorizontal(context, 0.08),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.onboardingDescription(context),
                    maxLines: 8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
