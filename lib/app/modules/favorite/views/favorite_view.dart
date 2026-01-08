import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
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
      onRefresh: () => controller.loadFavorites(),
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
                'المفضلة',
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
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
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
                      'الفيديوهات المحفوظة',
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
                      'الدروس المفضلة',
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
                    'اشتراك مميز مطلوب',
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Message
                  Text(
                    'يجب الاشتراك للوصول إلى الفيديوهات المحفوظة وجميع المميزات',
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
                      child: const Text(
                        'عرض خطط الاشتراك',
                        style: TextStyle(
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
                  'لا توجد فيديوهات محفوظة',
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

            if (controller.isVideoPlaying.value && controller.chewieController != null) {
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
                    'اشتراك مميز مطلوب',
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Message
                  Text(
                    'يجب الاشتراك للوصول إلى المفضلة وجميع المميزات',
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
                      child: const Text(
                        'عرض خطط الاشتراك',
                        style: TextStyle(
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
                  'لا توجد دروس مفضلة',
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
    final subtitle = lesson?.order ?? 'درس';

    return Slidable(
      key: ValueKey(lesson?.id ?? 0),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) {
              if (lesson?.id != null) {
                controller.toggleFavorite(
                  id: lesson!.id!,
                  type: 'lesson',
                );
              }
            },
            backgroundColor: const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'حذف',
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (lesson?.id != null) {
            controller.playLessonVideo(lesson!.id!);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Status icon (right side in RTL)
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
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.lessonTitle(context),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      subtitle,
                      style: AppTextStyles.lessonSubtitle(context),
                      textAlign: TextAlign.right,
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
                      onTap: () {
                        if (lesson?.id != null) {
                          controller.openLessonTest(lesson!.id!);
                        }
                      },
                      child: Container(
                        width: 78,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4D9F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'اختبار الدرس',
                          style: AppTextStyles.lessonButtonActive(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Summary button
                    GestureDetector(
                      onTap: () {
                        if (lesson?.id != null) {
                          controller.openLessonSummary(lesson!.id!);
                        }
                      },
                      child: Container(
                        width: 78,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4D9F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ملخص الدرس',
                          style: AppTextStyles.lessonButtonActive(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            label: 'حذف',
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
              child: Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: controller.videoLoadProgress.value,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                  Text(
                    '${(controller.videoLoadProgress.value * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
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
            // Video player
            if (controller.chewieController != null)
              Chewie(controller: controller.chewieController!),

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
