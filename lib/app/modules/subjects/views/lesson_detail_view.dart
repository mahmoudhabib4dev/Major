import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/api_image.dart';
import '../controllers/lesson_detail_controller.dart';
import '../models/unit_model.dart';

class LessonDetailView extends GetView<LessonDetailController> {
  final UnitModel? unit;

  const LessonDetailView({
    super.key,
    this.unit,
  });

  // Format time from 24h to 12h with Arabic AM/PM
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      String period = hour >= 12 ? 'م' : 'ص'; // م for PM (مساءً), ص for AM (صباحاً)

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour = hour - 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load lessons when view is built (only if unit is provided)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (unit != null) {
        controller.loadLessons(unit!.id);
      }
    });

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        // Use YoutubePlayerBuilder when YouTube video is playing for proper fullscreen handling
        if (controller.isYouTubeVideo.value && controller.youtubePlayerController != null) {
          return YoutubePlayerBuilder(
            onExitFullScreen: () {
              // Restore portrait orientation when exiting fullscreen
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              // Reset status bar style
              SystemChrome.setSystemUIOverlayStyle(
                const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              );
            },
            onEnterFullScreen: () {
              // Allow landscape for fullscreen
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            },
            player: YoutubePlayer(
              controller: controller.youtubePlayerController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFFFB2B3A),
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFFFB2B3A),
                handleColor: Color(0xFFFB2B3A),
              ),
            ),
            builder: (context, player) {
              return _buildMainScaffold(context, screenSize, youtubePlayer: player);
            },
          );
        }

        // Normal scaffold without YouTube player builder
        return _buildMainScaffold(context, screenSize);
      }),
    );
  }

  // Build the main scaffold content
  Widget _buildMainScaffold(BuildContext context, Size screenSize, {Widget? youtubePlayer}) {
    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.image3),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Video player or header - behind everything
            Obx(() => controller.isVideoPlaying.value
                ? _buildVideoPlayer(context, screenSize, youtubePlayer: youtubePlayer)
                : SafeArea(child: _buildHeader(context, screenSize))),
            // Loading overlay for video
            Obx(() => controller.isLoadingVideo.value
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFB2B3A),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            // White container with content - on top
            Obx(() => Positioned(
              top: controller.isVideoPlaying.value
                  ? screenSize.height * 0.4
                  : screenSize.height * 0.22,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: _TopCurveClipper(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -(screenSize.width * 0.08) * 0.8,
                      left: 0,
                      right: 0,
                      bottom: -(screenSize.width * 0.08) * 0.8,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: (screenSize.width * 0.08) * 0.8),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: screenSize.height * 0.03),
                                // Teacher info section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildTeacherInfoSection(context, screenSize),
                                ),
                                SizedBox(height: screenSize.height * 0.03),
                                // Lessons list
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 300),
                                  child: _buildLessonsList(context, screenSize),
                                ),
                                SizedBox(height: screenSize.height * 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Small dot at top center below the wave
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
            )),
          ],
        ),
      ),
    );
  }

  // Build header with title and back button
  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05,
        bottom: screenSize.height * 0.02,
        left: screenSize.width * 0.05,
        right: screenSize.width * 0.05,
      ),
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Spacer (right side in RTL)
            const SizedBox(width: 48),
            // Title
            Expanded(
              child: unit != null
                  ? Text(
                      unit?.name ?? "",
                      style: AppTextStyles.subjectDetailTitle(context),
                      textAlign: TextAlign.center,
                    )
                  : Obx(() => Text(
                      controller.unitName.value,
                      style: AppTextStyles.subjectDetailTitle(context),
                      textAlign: TextAlign.center,
                    )),
            ),
            // Back button (left side in RTL)
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build video player
  Widget _buildVideoPlayer(BuildContext context, Size screenSize, {Widget? youtubePlayer}) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return SizedBox(
      width: double.infinity,
      height: screenSize.height * 0.40,
      child: GetBuilder<LessonDetailController>(
        builder: (ctrl) {
          return Stack(
            children: [
              // Video player area (full width, reaches top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Obx(() {
                    // YouTube player for live lessons - use the player from YoutubePlayerBuilder
                    if (ctrl.isYouTubeVideo.value && youtubePlayer != null) {
                      return youtubePlayer;
                    }
                    // Regular video player
                    if (ctrl.chewieController != null &&
                        ctrl.chewieController!.videoPlayerController.value.isInitialized) {
                      return Chewie(controller: ctrl.chewieController!);
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFB2B3A),
                      ),
                    );
                  }),
                ),
              ),
              // Top controls (favorite and back) - with status bar padding
              Positioned(
                top: statusBarHeight + 8,
                left: 8,
                right: 8,
                child: SizedBox(
                  width: screenSize.width - 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Favorite button (right side in RTL) - only show for non-YouTube videos
                      Obx(() => controller.isYouTubeVideo.value
                          ? const SizedBox(width: 48)
                          : IconButton(
                              icon: Icon(
                                controller.isFavorite.value
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: controller.isFavorite.value
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                // Get current lesson ID from the playing lesson
                                final currentLesson = controller.lessons.firstWhereOrNull(
                                  (lesson) => lesson.id == controller.currentLessonId.value
                                );
                                if (currentLesson != null) {
                                  controller.toggleFavorite(currentLesson.id);
                                }
                              },
                            )),
                      const Spacer(),
                      // Back button (left side in RTL)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: controller.hideVideo,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build teacher info section - always dark style with image7 background
  Widget _buildTeacherInfoSection(BuildContext context, Size screenSize) {
    return Obx(() {
      const dividerColor = Colors.white30;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(AppImages.image7),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Live time (left in RTL - appears on the left)
            Expanded(
              child: _buildInfoItem(
                context,
                'live_time'.tr,
                Text(
                  // Show "جاري" (ongoing) if any lesson is live, otherwise show scheduled time
                  controller.hasLiveLesson.value
                      ? 'ongoing'.tr
                      : (controller.liveAt.value.isNotEmpty
                          ? _formatTime(controller.liveAt.value)
                          : '-'),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppImages.icon24,
                true, // Always white mode
              ),
            ),
            const SizedBox(
              width: 1,
              height: 50,
              child: ColoredBox(color: dividerColor),
            ),
            // Number of lessons (middle)
            Expanded(
              child: _buildInfoItem(
                context,
                'number_of_lessons'.tr,
                Text(
                  'lessons_count'.tr.replaceAll('@count', '${controller.lessonsCount.value}'),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppImages.icon25,
                true, // Always white mode
              ),
            ),
            const SizedBox(
              width: 1,
              height: 50,
              child: ColoredBox(color: dividerColor),
            ),
            // Teacher (right in RTL - appears on the right)
            Expanded(
              child: _buildInfoItem(
                context,
                'teacher'.tr,
                Text(
                  controller.teacherName.value.isNotEmpty ? controller.teacherName.value : 'صابرين الأحمد',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppImages.icon26,
                true, // Always white mode
              ),
            ),
          ],
        ),
      );
    });
  }

  // Build individual info item - always white mode
  Widget _buildInfoItem(BuildContext context, String label, Widget value, String iconPath, [bool isWhiteMode = true]) {
    return Column(
      children: [
        // Icon - always white
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.asset(
            iconPath,
            width: 28,
            height: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        value,
      ],
    );
  }

  // Build lessons list
  Widget _buildLessonsList(BuildContext context, Size screenSize) {
    return Obx(() {
      // Show loading indicator
      if (controller.isLoadingLessons.value) {
        return Padding(
          padding: EdgeInsets.only(top: screenSize.height * 0.1),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF000D47),
            ),
          ),
        );
      }

      // Check if controller has lessons
      if (controller.lessons.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: screenSize.height * 0.1),
          child: Text(
            'no_data_available'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      // Sort lessons: live lessons first (isAlive == 1), then by order
      final sortedLessons = controller.lessons.toList()
        ..sort((a, b) {
          // Live lessons come first
          if (a.isAlive == 1 && b.isAlive != 1) return -1;
          if (b.isAlive == 1 && a.isAlive != 1) return 1;
          // Then sort by order if available
          final orderA = int.tryParse(a.order ?? '') ?? 999;
          final orderB = int.tryParse(b.order ?? '') ?? 999;
          return orderA.compareTo(orderB);
        });

      return Column(
        children: sortedLessons.map((lesson) {
          // All lessons are shown as available
          // Access control (subscription/login checks) is handled in playLessonVideo()
          const status = 'available';

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildLessonCard(
              context,
              screenSize,
              lesson,
              status,
            ),
          );
        }).toList(),
      );
    });
  }

  // Build individual lesson card
  Widget _buildLessonCard(
    BuildContext context,
    Size screenSize,
    lesson,
    String status,
  ) {
    final bool isLive = lesson.isAlive == 1;
    final bool isLocked = status == 'locked';

    return Column(
      children: [
        // Main card with thumbnail
        GestureDetector(
          onTap: !isLocked
              ? () => controller.playLessonVideo(lesson.id)
              : null,
          child: Container(
            height: 149,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isLive
                  ? Border.all(color: const Color(0xFFFFB5B5), width: 3)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isLive ? 13 : 16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail - show image if available, otherwise placeholder color
                  if (lesson.videoThumbnail != null && lesson.videoThumbnail!.isNotEmpty)
                    ApiImage(
                      imageUrl: lesson.videoThumbnail!,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: isLive
                            ? const Color(0xFFE8D4D4)
                            : const Color(0xFFD4D8E8),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF000D47),
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        color: isLive
                            ? const Color(0xFFE8D4D4)
                            : const Color(0xFFD4D8E8),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFFE8D4D4) // Light pink/beige for live
                            : const Color(0xFFD4D8E8), // Light blue/gray for regular
                      ),
                    ),
                  // Play button in center (37x37)
                  Center(
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFFFB2B3A)
                            : const Color(0xFF000D47),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  // Favorite button (top-left in RTL = top-right visually) - only for non-live lessons
                  if (!isLive)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => controller.toggleFavorite(lesson.id),
                        child: Obx(() {
                          final isFav = controller.favoriteLessons.contains(lesson.id) ||
                              lesson.isFavorite == true;
                          return Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? const Color(0xFFFF6B6B) : Colors.white,
                            size: 24,
                          );
                        }),
                      ),
                    ),
                  // LIVE icon (top-left in RTL = top-right visually)
                  if (isLive)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Image.asset(
                        AppImages.icon28,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  // Lesson info overlay at bottom (name and order)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Lesson order (left in RTL)
                          if (lesson.order != null && lesson.order!.isNotEmpty)
                            Text(
                              lesson.order!,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          const Spacer(),
                          // Lesson name (right in RTL)
                          Expanded(
                            flex: 3,
                            child: Text(
                              lesson.name,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Locked overlay
                  if (isLocked)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Image.asset(
                          AppImages.icon29,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Action buttons - only show for non-live lessons
        if (!isLive) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              // Download video button (right in RTL)
              Expanded(
                child: Obx(() {
                  final isDownloading = controller.downloadingLessons.contains(lesson.id);
                  final isDownloaded = controller.downloadedLessons.contains(lesson.id);
                  final progress = controller.lessonDownloadProgress[lesson.id] ?? 0.0;

                  return GestureDetector(
                    onTap: !isLocked
                        ? () {
                            if (isDownloading) {
                              // Cancel download
                              controller.cancelDownload(lesson.id);
                            } else {
                              // Start download
                              controller.downloadLessonVideo(lesson.id);
                            }
                          }
                        : null,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey[300]
                            : isDownloading
                                ? const Color(0xFFE53935) // Red for cancel
                                : isDownloaded
                                    ? const Color(0xFF4CAF50) // Green for downloaded
                                    : const Color(0xFF000D47),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isDownloading
                          // Show progress while downloading with cancel option
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  progress > 0 ? 'إلغاء ${(progress * 100).toInt()}%' : 'إلغاء',
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isLocked
                                    ? Icon(
                                        Icons.download,
                                        color: Colors.grey[500],
                                        size: 20,
                                      )
                                    : isDownloaded
                                        ? const Icon(
                                            Icons.download_done,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Image.asset(
                                            AppImages.icon78,
                                            width: 20,
                                            height: 20,
                                          ),
                                const SizedBox(width: 8),
                                Text(
                                  isDownloaded ? 'تم التنزيل' : 'تنزيل الدرس',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isLocked ? Colors.grey[500] : Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              // Test button (left in RTL) - same dark blue background as download button
              Expanded(
                child: GestureDetector(
                  onTap: !isLocked
                      ? () => controller.openLessonTest(lesson.id)
                      : null,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey[300] : const Color(0xFF000D47),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isLocked
                            ? Icon(
                                Icons.help_outline,
                                color: Colors.grey[500],
                                size: 20,
                              )
                            : Image.asset(
                                AppImages.icon77,
                                width: 20,
                                height: 20,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          'اختبار الدرس',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLocked ? Colors.grey[500] : Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Custom clipper for the wavy top edge (same as subjects view)
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
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
