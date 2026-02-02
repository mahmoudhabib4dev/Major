import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfilePageHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const ProfilePageHeaderWidget({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.08,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        // Keep RTL direction so back button stays on left for all languages
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Empty space for balance
              const SizedBox(width: 24),
              // Title in center
              Expanded(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    title,
                    style: AppTextStyles.notificationPageTitle(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Back button (always on the left visually)
              FadeInRight(
                duration: const Duration(milliseconds: 400),
                child: GestureDetector(
                  onTap: onBack,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: 24,
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
