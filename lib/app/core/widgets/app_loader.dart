import 'package:flutter/material.dart';

import '../constants/app_images.dart';
import '../theme/app_colors.dart';

/// A unified loader widget that matches the app's design.
///
/// Features:
/// - App logo in the center with pulse animation
/// - Circular progress indicator around the logo
/// - Customizable size and colors
class AppLoader extends StatefulWidget {
  /// The size of the loader (default: 60)
  final double size;

  /// Whether to show the logo in the center (default: true)
  final bool showLogo;

  /// Primary color for the loader (default: AppColors.primary)
  final Color? primaryColor;

  /// Secondary color for the loader (default: AppColors.accent)
  final Color? secondaryColor;

  /// Stroke width of the circular indicator (default: 3)
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size = 60,
    this.showLogo = true,
    this.primaryColor,
    this.secondaryColor,
    this.strokeWidth = 3,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.primary;
    final secondaryColor = widget.secondaryColor ?? AppColors.accent;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              backgroundColor: secondaryColor.withValues(alpha: 0.2),
            ),
          ),
          // Pulsing logo in center
          if (widget.showLogo)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: widget.size * 0.55,
                height: widget.size * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(widget.size * 0.08),
                child: Image.asset(
                  AppImages.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple loader without logo - animated pulsing dot
class AppLoaderSimple extends StatefulWidget {
  final double size;
  final Color? color;

  const AppLoaderSimple({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  State<AppLoaderSimple> createState() => _AppLoaderSimpleState();
}

class _AppLoaderSimpleState extends State<AppLoaderSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final dotSize = widget.size * 0.3;
    final spacing = widget.size * 0.08;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final animValue = (_controller.value + delay) % 1.0;
              final scale = 0.5 + (0.5 * _getPulseValue(animValue));
              final opacity = 0.4 + (0.6 * _getPulseValue(animValue));

              return Container(
                margin: EdgeInsets.symmetric(horizontal: spacing),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  double _getPulseValue(double t) {
    if (t < 0.5) {
      return t * 2;
    } else {
      return 2 - (t * 2);
    }
  }
}

/// Button loader - a stylish animated dots loader for buttons
class AppLoaderButton extends StatefulWidget {
  final Color? color;
  final double size;

  const AppLoaderButton({
    super.key,
    this.color,
    this.size = 24,
  });

  @override
  State<AppLoaderButton> createState() => _AppLoaderButtonState();
}

class _AppLoaderButtonState extends State<AppLoaderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white;
    final dotSize = widget.size * 0.25;
    final spacing = widget.size * 0.08;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final animValue = (_controller.value + delay) % 1.0;
              final scale = 0.5 + (0.5 * _getPulseValue(animValue));
              final opacity = 0.4 + (0.6 * _getPulseValue(animValue));

              return Container(
                margin: EdgeInsets.symmetric(horizontal: spacing),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  double _getPulseValue(double t) {
    // Creates a smooth pulse: 0 -> 1 -> 0
    if (t < 0.5) {
      return t * 2;
    } else {
      return 2 - (t * 2);
    }
  }
}
