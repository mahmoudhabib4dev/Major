import 'package:flutter/material.dart';

import 'app_loader.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final Color? loadingColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.borderWidth,
    this.padding,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Default dimensions based on the design (130.92px width, 54px height)
    // Converting to percentage of screen width for responsiveness
    final double defaultWidth = screenSize.width * 0.35; // ~130px on standard device
    final double defaultHeight = screenSize.height * 0.067; // ~54px on standard device
    final double defaultBorderRadius = screenSize.width * 0.053; // ~20px
    final double defaultFontSize = screenSize.width * 0.04; // ~16px

    return SizedBox(
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
            side: BorderSide(
              color: borderColor ?? const Color(0xFF000D47),
              width: borderWidth ?? 1,
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? AppLoaderButton(
                size: screenSize.width * 0.06,
                color: loadingColor ?? textColor ?? Colors.white,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: screenSize.width * 0.02),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize ?? defaultFontSize,
                        fontWeight: fontWeight ?? FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: screenSize.width * 0.02),
                    trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}
