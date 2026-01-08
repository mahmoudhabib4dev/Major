import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../parent/controllers/parent_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChallengesView extends StatelessWidget {
  const ChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final parentController = Get.find<ParentController>();
    final profileController = Get.find<ProfileController>();
    final notchRadius = screenSize.width * 0.08;

    // Load leaderboard data when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.loadLeaderboard();
    });

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.image5),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  // Title
                  FadeIn(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'student_challenges'.tr,
                      style: AppTextStyles.notificationPageTitle(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.025),
                  // Ranking container
                  Obx(() {
                    // Show loading indicator while data is being fetched
                    if (profileController.isLoadingLeaderboard.value) {
                      return const SizedBox.shrink();
                    }

                    final leaderboard = profileController.leaderboard.value;
                    final student = leaderboard?.student;
                    final participants = leaderboard?.participants ?? 0;

                    // Only hide if data is loaded AND (student is null OR hidden)
                    if (leaderboard != null && (student == null || student.hidden)) {
                      return const SizedBox.shrink();
                    }

                    // If no data yet, don't show anything
                    if (student == null) {
                      return const SizedBox.shrink();
                    }

                    return FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                        child: Container(
                          width: double.infinity,
                          height: 88,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7DDFA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Rank badge
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000D47),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${student.rank}',
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text content
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'congratulations_close'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000D47),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'your_rank_among'.tr.replaceAll('@rank', '${student.rank}').replaceAll('@total', '$participants'),
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF000D47),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: screenSize.height * 0.02),
                  // Podium with avatars
                  Expanded(
                    child: Obx(() {
                      // Show loading while data is being fetched
                      if (profileController.isLoadingLeaderboard.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      final topPlayers = profileController.leaderboard.value?.top ?? [];

                      return FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Podium image at bottom
                            Positioned(
                              bottom: screenSize.height * 0.05,
                              left: 0,
                              right: 0,
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 400),
                                child: Image.asset(
                                  AppImages.image6,
                                  width: screenSize.width,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                              // 1st place - center
                            if (topPlayers.isNotEmpty)
                              Positioned(
                                top: screenSize.height * 0.06,
                                child: ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  delay: const Duration(milliseconds: 500),
                                  child: Column(
                                    children: [
                                      // Crown icon
                                      Pulse(
                                        infinite: true,
                                        duration: const Duration(milliseconds: 2000),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF7B8FD4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            AppImages.icon13,
                                            width: 16,
                                            height: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Avatar
                                      BounceInDown(
                                        duration: const Duration(milliseconds: 800),
                                        delay: const Duration(milliseconds: 600),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF7B8FD4),
                                              width: 3,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: topPlayers[0].pictureUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: topPlayers[0].pictureUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Image.asset(
                                                      AppImages.icon56,
                                                      width: 70,
                                                      height: 70,
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      AppImages.icon56,
                                                      width: 70,
                                                      height: 70,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.icon56,
                                                    width: 70,
                                                    height: 70,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Name
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 800),
                                        child: Text(
                                          topPlayers[0].name,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Points badge
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 900),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7B8FD4),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${topPlayers[0].score} ${'points'.tr}',
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // 2nd place - left
                            if (topPlayers.length > 1)
                              Positioned(
                                top: screenSize.height * 0.19,
                                left: screenSize.width * 0.08,
                                child: FadeInLeft(
                                  duration: const Duration(milliseconds: 700),
                                  delay: const Duration(milliseconds: 700),
                                  child: Column(
                                    children: [
                                      // Avatar
                                      BounceInDown(
                                        duration: const Duration(milliseconds: 800),
                                        delay: const Duration(milliseconds: 800),
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF7B8FD4),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: topPlayers[1].pictureUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: topPlayers[1].pictureUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Image.asset(
                                                      AppImages.icon57,
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      AppImages.icon57,
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.icon57,
                                                    width: 60,
                                                    height: 60,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Name
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 1000),
                                        child: Text(
                                          topPlayers[1].name,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Points badge
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 1100),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7B8FD4),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${topPlayers[1].score} ${'points'.tr}',
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // 3rd place - right
                            if (topPlayers.length > 2)
                              Positioned(
                                top: screenSize.height * 0.21,
                                right: screenSize.width * 0.08,
                                child: FadeInRight(
                                  duration: const Duration(milliseconds: 700),
                                  delay: const Duration(milliseconds: 700),
                                  child: Column(
                                    children: [
                                      // Avatar
                                      BounceInDown(
                                        duration: const Duration(milliseconds: 800),
                                        delay: const Duration(milliseconds: 900),
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF7B8FD4),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: topPlayers[2].pictureUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: topPlayers[2].pictureUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Image.asset(
                                                      AppImages.icon58,
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      AppImages.icon58,
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.icon58,
                                                    width: 60,
                                                    height: 60,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Name
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 1100),
                                        child: Text(
                                          topPlayers[2].name,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Points badge
                                      FadeInUp(
                                        delay: const Duration(milliseconds: 1200),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7B8FD4),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${topPlayers[2].score} ${'points'.tr}',
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Draggable bottom sheet for ranking
            DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.22,
              maxChildSize: 0.5,
              builder: (context, scrollController) {
                return FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 600),
                  child: ClipPath(
                    clipper: _TopCurveClipper(notchRadius: notchRadius),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -notchRadius * 0.8),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: notchRadius * 0.8),
                            color: Colors.white,
                            child: ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.06,
                                vertical: 20,
                              ),
                              itemCount: profileController.leaderboard.value?.top.length.clamp(0, 10) ?? 0,
                              itemBuilder: (context, index) {
                                final topPlayers = profileController.leaderboard.value?.top ?? [];
                                if (index >= topPlayers.length) return const SizedBox.shrink();

                                final player = topPlayers[index];
                                final colors = [0xFF9B59B6, 0xFF3498DB, 0xFFE91E63, 0xFF4CAF50, 0xFFFF9800, 0xFF00BCD4, 0xFF673AB7, 0xFFE91E63, 0xFF2196F3, 0xFF4CAF50];
                                final playerColor = colors[index % colors.length];

                                return FadeInRight(
                                  duration: Duration(milliseconds: 400 + (index * 100)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        const Spacer(),
                                        // Name and points
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              player.name,
                                              style: const TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF000D47),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${player.score} ${'points'.tr}',
                                              style: const TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        // Avatar with rank number overlay
                                        SizedBox(
                                          width: 55,
                                          height: 55,
                                          child: Stack(
                                            children: [
                                              // Avatar
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Color(playerColor),
                                                      width: 3,
                                                    ),
                                                  ),
                                                  child: ClipOval(
                                                    child: player.pictureUrl != null
                                                        ? CachedNetworkImage(
                                                            imageUrl: player.pictureUrl!,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context, url) => Container(
                                                              color: Colors.grey.shade200,
                                                            ),
                                                            errorWidget: (context, url, error) => Icon(
                                                              Icons.person,
                                                              color: Colors.grey.shade400,
                                                              size: 30,
                                                            ),
                                                          )
                                                        : Icon(
                                                            Icons.person,
                                                            color: Colors.grey.shade400,
                                                            size: 30,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              // Rank number badge (bottom-left of avatar)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Colors.grey.shade400,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${player.rank}',
                                                      style: TextStyle(
                                                        fontFamily: 'Tajawal',
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Small dot at top center where curve peaks
                        Positioned(
                          top: -screenSize.width * 0.025 + 5,
                          left: screenSize.width / 2 - screenSize.width * 0.0125,
                          child: Container(
                            width: screenSize.width * 0.025,
                            height: screenSize.width * 0.025,
                            decoration: const BoxDecoration(
                              color: Color(0xFF000D47),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () => profileController.loadLeaderboard(),
          backgroundColor: AppColors.primary,
          elevation: 8,
          shape: const CircleBorder(),
          child: Obx(() => profileController.isLoadingLeaderboard.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Image.asset(
                  AppImages.icon13,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedBottomNavigationBar.builder(
            itemCount: 4,
            tabBuilder: (int index, bool isActive) {
              return _buildNavItem(context, index: index, isActive: isActive);
            },
            activeIndex: parentController.currentIndex.value,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 12,
            rightCornerRadius: 12,
            onTap: (index) {
              parentController.changePage(index);
              Get.back();
            },
            backgroundColor: AppColors.white,
            height: 55,
            splashColor: AppColors.primary.withValues(alpha: 0.1),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required bool isActive,
  }) {
    final icons = [
      {'unselected': AppImages.icon5, 'selected': AppImages.icon6},
      {'unselected': AppImages.icon11, 'selected': AppImages.icon12},
      {'unselected': AppImages.icon7, 'selected': AppImages.icon8},
      {'unselected': AppImages.icon9, 'selected': AppImages.icon10},
    ];

    final iconPath = isActive ? icons[index]['selected']! : icons[index]['unselected']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }
}

// Custom clipper for the wavy top edge (same as language bottom sheet)
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
