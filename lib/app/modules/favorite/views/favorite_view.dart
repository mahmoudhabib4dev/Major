import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../data/models/downloaded_video_model.dart';
import '../controllers/favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final isArabic = Get.locale?.languageCode == 'ar';

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      onRefresh: controller.onRefresh,
      headerChildren: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.05,
              bottom: screenSize.height * 0.02,
            ),
            child: FadeIn(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'favorite_title'.tr,
                style: AppTextStyles.notificationPageTitle(context),
              ),
            ),
          ),
        ),
      ],
      children: [
        SizedBox(height: screenSize.height * 0.02),
        // Custom tabs
        _buildTabsSection(context, screenSize),
        SizedBox(height: screenSize.height * 0.03),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                child: const AppLoader(size: 60),
              ),
            );
          }

          return _buildTabContent(context, screenSize, isArabic);
        }),
        SizedBox(height: screenSize.height * 0.15),
      ],
    );
  }

  Widget _buildTabsSection(BuildContext context, Size screenSize) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTabIndex.value = 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedTabIndex.value == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'favorite_saved_videos'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonText(context).copyWith(
                        color: controller.selectedTabIndex.value == 0
                            ? Colors.white
                            : AppColors.textGrey,
                        fontSize: AppTextStyles.getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTabIndex.value = 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedTabIndex.value == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'favorite_lessons'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonText(context).copyWith(
                        color: controller.selectedTabIndex.value == 1
                            ? Colors.white
                            : AppColors.textGrey,
                        fontSize: AppTextStyles.getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildTabContent(BuildContext context, Size screenSize, bool isArabic) {
    return Obx(() {
      if (controller.selectedTabIndex.value == 0) {
        // Downloaded videos tab
        return _buildDownloadedVideosList(context, screenSize);
      } else {
        // Favorited lessons tab
        return _buildFavoriteLessonsList(context, screenSize, isArabic);
      }
    });
  }

  Widget _buildDownloadedVideosList(BuildContext context, Size screenSize) {
    return Obx(() {
      final videos = controller.downloadedVideos;

      if (videos.isEmpty) {
        // Check if user needs subscription
        if (controller.isGuest) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.1,
                horizontal: screenSize.width * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  // Title
                  Text(
                    'premium_subscription_required'.tr,
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Message
                  Text(
                    'favorite_subscription_required_videos'.tr,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/subscription');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'view_subscription_plans'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // For users with active subscription who have no downloaded videos
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.icon54,
                  width: 80,
                  height: 80,
                  color: AppColors.grey400,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'favorite_no_saved_videos'.tr,
                  style: AppTextStyles.inputLabel(context).copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // Video player section
          Obx(() {
            if (controller.isLoadingVideo.value) {
              return _buildVideoLoadingIndicator(context, screenSize);
            }

            if (controller.isVideoPlaying.value && controller.videoController != null) {
              return _buildVideoPlayer(context, screenSize);
            }

            return const SizedBox.shrink();
          }),

          // Videos list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            separatorBuilder: (context, index) => SizedBox(height: screenSize.height * 0.015),
            itemBuilder: (context, index) {
              final video = videos[index];

              return FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: 100 * index),
                child: _buildDownloadedVideoCard(
                  context: context,
                  screenSize: screenSize,
                  video: video,
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildFavoriteLessonsList(BuildContext context, Size screenSize, bool isArabic) {
    return Obx(() {
      final lessons = controller.lessonFavorites;

      if (lessons.isEmpty) {
        // Check if user needs subscription
        if (controller.isGuest) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.1,
                horizontal: screenSize.width * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  // Title
                  Text(
                    'premium_subscription_required'.tr,
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Message
                  Text(
                    'favorite_subscription_required_lessons'.tr,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/subscription');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'view_subscription_plans'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // For users with active subscription who have no favorites
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.icon54,
                  width: 80,
                  height: 80,
                  color: AppColors.grey400,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'favorite_no_lessons'.tr,
                  style: AppTextStyles.inputLabel(context).copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lessons.length,
        separatorBuilder: (context, index) => SizedBox(height: screenSize.height * 0.015),
        itemBuilder: (context, index) {
          final favoriteItem = lessons[index];

          return FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: Duration(milliseconds: 100 * index),
            child: _buildFavoriteCard(
              context: context,
              screenSize: screenSize,
              favoriteItem: favoriteItem,
              isArabic: isArabic,
            ),
          );
        },
      );
    });
  }

  Widget _buildFavoriteCard({
    required BuildContext context,
    required Size screenSize,
    required favoriteItem,
    required bool isArabic,
  }) {
    final lesson = favoriteItem.asLesson;
    final title = lesson?.name ?? '';
    final lessonId = lesson?.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFEEFC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Play button, Title, Heart icon
            Row(
              children: [
                // Play button with gradient - tappable to play video
                GestureDetector(
                  onTap: () {
                    if (lessonId != null) {
                      controller.playLessonVideo(lessonId);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6B7FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Lesson title
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.lessonTitle(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Heart icon - tappable to remove from favorites
                GestureDetector(
                  onTap: () {
                    if (lessonId != null) {
                      controller.toggleFavorite(
                        id: lessonId,
                        type: 'lesson',
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFFF6B6B),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row: Action buttons - matching LessonDetailView design
            Obx(() {
              final isDownloading = lessonId != null && controller.downloadingLessons.contains(lessonId);
              final isDownloaded = lessonId != null && controller.downloadedLessons.contains(lessonId);
              final progress = lessonId != null ? (controller.lessonDownloadProgress[lessonId] ?? 0.0) : 0.0;

              return Row(
                children: [
                  // Download Lesson button - matching LessonDetailView style
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (lessonId != null) {
                          if (isDownloading) {
                            controller.cancelDownload(lessonId);
                          } else {
                            controller.downloadLesson(lessonId);
                          }
                        }
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: isDownloading
                              ? const Color(0xFFE53935) // Red when downloading
                              : isDownloaded
                                  ? const Color(0xFF4CAF50) // Green when downloaded
                                  : const Color(0xFF000D47), // Dark blue normal
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isDownloading
                                ? (progress > 0
                                    ? 'cancel_download_progress'.tr.replaceAll('@progress', '${(progress * 100).toInt()}')
                                    : 'cancel_download'.tr)
                                : (isDownloaded ? 'downloaded'.tr : 'download_lesson'.tr),
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lesson Test button - matching LessonDetailView style
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (lessonId != null) {
                          controller.openLessonTest(lessonId, lesson?.testId);
                        }
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF000D47),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'lesson_test'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadedVideoCard({
    required BuildContext context,
    required Size screenSize,
    required DownloadedVideoModel video,
  }) {
    final dateFormatter = DateFormat('dd/MM/yyyy', 'ar');
    final formattedDate = dateFormatter.format(video.downloadDate);

    return Slidable(
      key: ValueKey(video.lessonId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async {
              await controller.deleteDownloadedVideo(video.lessonId);
            },
            backgroundColor: const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'delete'.tr,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // Play video inline
          controller.playDownloadedVideo(video);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Video icon (right side in RTL)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E6F5),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.icon27,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Center text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Lesson name
                    Text(
                      video.lessonName,
                      style: AppTextStyles.lessonTitle(context),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // File size and date
                    Text(
                      '${video.fileSizeFormatted} • $formattedDate',
                      style: AppTextStyles.lessonSubtitle(context),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Play button (left side in RTL)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6B7FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLoadingIndicator(BuildContext context, Size screenSize) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      height: screenSize.height * 0.25,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: const AppLoader(size: 60),
            ),
            const SizedBox(height: 16),
            Text(
              'favorite_loading_video'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, Size screenSize) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      height: screenSize.height * 0.25,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video player using media_kit
            if (controller.videoController != null)
              Video(
                controller: controller.videoController!,
                controls: MaterialVideoControls,
                fill: Colors.black,
              ),

            // Close button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  controller.stopVideo();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
