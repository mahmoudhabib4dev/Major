import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_loader.dart';

/// Custom refresh indicator that uses AppLoader for a consistent look
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final double displacement;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.displacement = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      backgroundColor: backgroundColor ?? AppColors.white,
      color: AppColors.primary,
      strokeWidth: 3.0,
      // Custom builder to show AppLoader
      child: child,
    );
  }
}

/// Custom refresh indicator with builder for complete customization
class CustomRefreshIndicatorBuilder extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double displacement;
  final Color? backgroundColor;

  const CustomRefreshIndicatorBuilder({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 40.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      backgroundColor: backgroundColor ?? Colors.transparent,
      color: AppColors.primary,
      strokeWidth: 3.0,
      child: child,
    );
  }
}
