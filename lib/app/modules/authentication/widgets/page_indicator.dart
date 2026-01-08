import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          width: currentPage == index
              ? screenWidth * 0.025
              : screenWidth * 0.02,
          height: currentPage == index
              ? screenWidth * 0.025
              : screenWidth * 0.02,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.primary
                : AppColors.grey400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
