import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    // Start from top left
    path.lineTo(0, notchRadius);

    // Left side going down
    path.lineTo(0, size.height);

    // Bottom
    path.lineTo(size.width, size.height);

    // Right side going up
    path.lineTo(size.width, notchRadius);

    // Top right corner curve
    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Line to notch start (right side)
    path.lineTo(notchCenterX + notchWidth / 2, 0);

    // Create ONE wavy curve in the middle
    path.quadraticBezierTo(
      notchCenterX, // control point x (center)
      -notchRadius * 0.5, // control point y (depth of wave)
      notchCenterX - notchWidth / 2, // end point x
      0, // end point y
    );

    // Line to top left corner
    path.lineTo(notchRadius, 0);

    // Top left corner curve
    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class AppScaffold extends StatelessWidget {
  final String? backgroundImage;
  final List<Widget> children;
  final List<Widget>? sliverChildren; // Direct sliver children for better performance
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool showContentContainer;
  final Color? contentContainerColor;
  final double? contentContainerTopRadius;
  final EdgeInsets? contentContainerPadding;
  final double? contentContainerTopMargin;
  final bool showNotch;
  final Color? notchColor;
  final List<Widget>? headerChildren; // Widgets to show above the white container
  final Future<void> Function()? onRefresh; // Pull-to-refresh callback

  const AppScaffold({
    super.key,
    this.backgroundImage,
    this.children = const [],
    this.sliverChildren,
    this.backgroundColor,
    this.padding,
    this.showContentContainer = false,
    this.contentContainerColor,
    this.contentContainerTopRadius,
    this.contentContainerPadding,
    this.contentContainerTopMargin,
    this.showNotch = true,
    this.notchColor,
    this.headerChildren,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      body: Container(
        decoration:
            backgroundImage != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                )
                : null,
        child: showContentContainer
            ? Column(
                children: [
                  if (headerChildren != null)
                    ...headerChildren!
                  else
                    SizedBox(height: contentContainerTopMargin ?? screenSize.height * 0.22),
                  Expanded(
                    child: ClipPath(
                      clipper: _TopCurveClipper(
                        notchRadius: contentContainerTopRadius ?? screenSize.width * 0.08,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -(contentContainerTopRadius ?? screenSize.width * 0.08) * 1.4,
                            left: 0,
                            right: 0,
                            bottom: -(contentContainerTopRadius ?? screenSize.width * 0.08) * 0.8,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: (contentContainerTopRadius ?? screenSize.width * 0.08) * 1.5),
                              color: contentContainerColor ?? Colors.white,
                              child: onRefresh != null
                                  ? RefreshIndicator(
                                      onRefresh: onRefresh!,
                                      color: const Color(0xFF000D47),
                                      child: CustomScrollView(
                                        slivers: sliverChildren ?? [
                                          SliverPadding(
                                            padding: contentContainerPadding ??
                                                EdgeInsets.all(screenSize.width * 0.05),
                                            sliver: SliverList(
                                              delegate: SliverChildListDelegate(children),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : CustomScrollView(
                                      slivers: sliverChildren ?? [
                                        SliverPadding(
                                          padding: contentContainerPadding ??
                                              EdgeInsets.all(screenSize.width * 0.05),
                                          sliver: SliverList(
                                            delegate: SliverChildListDelegate(children),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          // Small dot at top center where curve peaks
                          if (showNotch)
                            Positioned(
                              top: -screenSize.width * 0.025 + 5,
                              left: screenSize.width / 2 - screenSize.width * 0.0125,
                              child: Container(
                                width: screenSize.width * 0.025,
                                height: screenSize.width * 0.028,
                                decoration: BoxDecoration(
                                  color: notchColor ?? const Color(0xFF000D47),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: padding ?? EdgeInsets.zero,
                    sliver: SliverList(delegate: SliverChildListDelegate(children)),
                  ),
                ],
              ),
      ),
    );
  }
}
