import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/api_image.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/lesson_detail_controller.dart';
import '../models/unit_model.dart';

class LessonDetailView extends GetView<LessonDetailController> {
  final UnitModel? unit;

  const LessonDetailView({
    super.key,
    this.unit,
  });

  // Format time from 24h to 12h with translated AM/PM
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      String period = hour >= 12 ? 'pm'.tr : 'am'.tr;

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
      child: _buildMainScaffold(context, screenSize),
    );
  }

  // Build the main scaffold content
  Widget _buildMainScaffold(BuildContext context, Size screenSize) {
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
                ? _buildVideoPlayer(context, screenSize)
                : SafeArea(child: _buildHeader(context, screenSize))),
            // Loading overlay for video
            Obx(() => controller.isLoadingVideo.value
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black54,
                    child: const Center(
                      child: AppLoader(size: 60),
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

  // Build video player using media_kit
  Widget _buildVideoPlayer(BuildContext context, Size screenSize) {
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
                  child: ctrl.videoController != null
                      ? Video(
                          controller: ctrl.videoController!,
                          controls: MaterialVideoControls,
                          fill: Colors.black,
                        )
                      : const Center(
                          child: AppLoader(size: 60),
                        ),
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
                true,
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
                Directionality(
                  textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    'lessons_count'.tr.replaceAll('@count', '${controller.lessonsCount.value}'),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppImages.icon25,
                true,
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
                true,
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
        // Use SizedBox with fixed height to ensure alignment across all info items
        SizedBox(
          height: 36,
          child: Center(child: value),
        ),
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
            child: AppLoader(size: 60),
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
          if (a.isAlive == 1 && b.isAlive != 1) return -1;
          if (b.isAlive == 1 && a.isAlive != 1) return 1;
          final orderA = int.tryParse(a.order ?? '') ?? 999;
          final orderB = int.tryParse(b.order ?? '') ?? 999;
          return orderA.compareTo(orderB);
        });

      return Column(
        children: sortedLessons.map((lesson) {
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
                          child: AppLoader(size: 30),
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
                            ? const Color(0xFFE8D4D4)
                            : const Color(0xFFD4D8E8),
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
                              controller.cancelDownload(lesson.id);
                            } else {
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
                                ? const Color(0xFFE53935)
                                : isDownloaded
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF000D47),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isDownloading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    progress > 0
                                        ? 'cancel_download_progress'.tr.replaceAll('@progress', '${(progress * 100).toInt()}')
                                        : 'cancel_download'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isLocked
                                      ? Icon(
                                          Icons.download,
                                          color: Colors.grey[500],
                                          size: 16,
                                        )
                                      : isDownloaded
                                          ? const Icon(
                                              Icons.download_done,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Image.asset(
                                              AppImages.icon78,
                                              width: 16,
                                              height: 16,
                                            ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isDownloaded ? 'downloaded'.tr : 'download_lesson'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isLocked ? Colors.grey[500] : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              // Test button (left in RTL)
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
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isLocked
                              ? Icon(
                                  Icons.help_outline,
                                  color: Colors.grey[500],
                                  size: 16,
                                )
                              : Image.asset(
                                  AppImages.icon77,
                                  width: 16,
                                  height: 16,
                                ),
                          const SizedBox(width: 6),
                          Text(
                            'lesson_test'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isLocked ? Colors.grey[500] : Colors.white,
                            ),
                          ),
                        ],
                      ),
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

// Custom clipper for the wavy top edge
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    path.lineTo(0, notchRadius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, notchRadius);

    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(notchCenterX + notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchCenterX,
      -notchRadius * 0.5,
      notchCenterX - notchWidth / 2,
      0,
    );

    path.lineTo(notchRadius, 0);

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
