import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chewie/chewie.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/storage_service.dart';
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
      child: Scaffold(
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
            // Back button (right side in RTL)
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
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
            // Spacer (left side in RTL)
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // Build video player
  Widget _buildVideoPlayer(BuildContext context, Size screenSize) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
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
                  child: ctrl.chewieController != null &&
                          ctrl.chewieController!.videoPlayerController.value.isInitialized
                      ? Chewie(controller: ctrl.chewieController!)
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFB2B3A),
                          ),
                        ),
                ),
              ),
              // Top controls (download, favorite and back) - with status bar padding
              Positioned(
                top: statusBarHeight + 8,
                left: 8,
                right: 8,
                child: SizedBox(
                  width: screenSize.width - 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (right side in RTL)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: controller.hideVideo,
                      ),
                      const Spacer(),
                      // Download button
                      Obx(() {
                        if (controller.isDownloading.value) {
                          return SizedBox(
                            width: 32,
                            height: 32,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: controller.downloadProgress.value,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                                Text(
                                  '${(controller.downloadProgress.value * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return IconButton(
                          icon: Icon(
                            controller.isVideoDownloaded.value
                                ? Icons.download_done
                                : Icons.download,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            if (controller.isVideoDownloaded.value) {
                              controller.deleteCurrentVideo();
                            } else {
                              controller.downloadCurrentVideo();
                            }
                          },
                        );
                      }),
                      // Favorite button (left side in RTL)
                      Obx(() => IconButton(
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

  // Build teacher info section
  Widget _buildTeacherInfoSection(BuildContext context, Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildInfoItem(
              context,
              'live_time'.tr,
              Obx(() => Text(
                _formatTime(controller.liveAt.value.isNotEmpty ? controller.liveAt.value : '08:00'),
                style: AppTextStyles.statisticsValue(context),
                textAlign: TextAlign.center,
              )),
              AppImages.icon24,
            ),
          ),
          SizedBox(
            width: 1,
            height: 50,
            child: ColoredBox(color: Colors.grey[300]!),
          ),
          Expanded(
            child: _buildInfoItem(
              context,
              'number_of_lessons'.tr,
              Obx(() => Text(
                'lessons_count'.tr.replaceAll('@count', '${controller.lessonsCount.value}'),
                style: AppTextStyles.statisticsValue(context),
                textAlign: TextAlign.center,
              )),
              AppImages.icon25,
            ),
          ),
          SizedBox(
            width: 1,
            height: 50,
            child: ColoredBox(color: Colors.grey[300]!),
          ),
          Expanded(
            child: _buildInfoItem(
              context,
              'teacher'.tr,
              Obx(() => Text(
                controller.teacherName.value.isNotEmpty ? controller.teacherName.value : 'صابرين الأحمد',
                style: AppTextStyles.statisticsValue(context),
                textAlign: TextAlign.center,
              )),
              AppImages.icon26,
            ),
          ),
        ],
      ),
    );
  }

  // Build individual info item
  Widget _buildInfoItem(BuildContext context, String label, Widget value, String iconPath) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 28,
          height: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.statisticsLabel(context),
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

      return Column(
        children: controller.lessons.map((lesson) {
          // Get storage service to check subscription status
          final storageService = Get.find<StorageService>();
          final isGuestMode = !storageService.isLoggedIn;
          final currentUser = storageService.currentUser;
          final hasActiveSubscription = currentUser?.planStatus == 'active';

          // For guests and users without active subscription, show all lessons as available
          // They'll see subscription/registration dialogs when accessing content
          final status = (isGuestMode || !hasActiveSubscription)
              ? 'available'
              : (lesson.isAlive == 1 ? 'available' : 'locked');

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
    return GestureDetector(
      onTap: status != 'locked'
          ? () {
              // Play video for the lesson
              controller.playLessonVideo(lesson.id);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Status icon (right side in RTL)
            _buildStatusIcon(status),
            const SizedBox(width: 16),
            // Center text
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title
                  Text(
                    lesson.name,
                    style: AppTextStyles.lessonTitle(context),
                  ),
                  const SizedBox(height: 4),
                  // Show order if available, otherwise show PDF/Video indicator
                  if (lesson.order != null && lesson.order!.isNotEmpty)
                    Text(
                      lesson.order!,
                      style: AppTextStyles.lessonSubtitle(context),
                    )
                  else if (lesson.pdfFile != null || lesson.videoUrl != null)
                    Text(
                      lesson.pdfFile != null ? 'PDF متاح' : 'فيديو متاح',
                      style: AppTextStyles.lessonSubtitle(context),
                    )
                  else
                    Text(
                      'لا يوجد محتوى',
                      style: AppTextStyles.lessonSubtitle(context),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Buttons (left side in RTL)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test button
                  GestureDetector(
                    onTap: status != 'locked'
                        ? () => controller.openLessonTest(lesson.id)
                        : null,
                    child: Container(
                      width: 78,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: status == 'locked'
                            ? Colors.grey[300]
                            : const Color(0xFFD4D9F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'lesson_test'.tr,
                        style: status == 'locked'
                            ? AppTextStyles.lessonButtonDisabled(context)
                            : AppTextStyles.lessonButtonActive(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Summary button
                  GestureDetector(
                    onTap: status != 'locked'
                        ? () => controller.openLessonSummary(lesson.id)
                        : null,
                    child: Container(
                      width: 78,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: status == 'locked'
                            ? Colors.grey[300]
                            : const Color(0xFFD4D9F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'lesson_summary'.tr,
                        style: status == 'locked'
                            ? AppTextStyles.lessonButtonDisabled(context)
                            : AppTextStyles.lessonButtonActive(context),
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
  }

  // Build status icon based on lesson status
  Widget _buildStatusIcon(String status) {
    if (status == 'locked') {
      // Locked icon centered in 72x72 space
      return SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Image.asset(
            AppImages.icon29,
            width: 30,
            height: 30,
          ),
        ),
      );
    } else if (status == 'live') {
      return InkWell(
        onTap: controller.showVideo,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0x66FF4F6B), // 60% transparency (40% opacity)
            border: Border.all(
              color: const Color(0xFFFB2B3A),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(36), // 50% radius
          ),
          child: Center(
            child: Image.asset(
              AppImages.icon28,
              width: 30,
              height: 30,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E6F5),
          borderRadius: BorderRadius.circular(36), // 50% radius
        ),
        child: Center(
          child: Image.asset(
            AppImages.icon27,
            width: 30,
            height: 30,
          ),
        ),
      );
    }
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
