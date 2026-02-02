import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video;
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../providers/subjects_provider.dart';
import '../models/lesson_model.dart';
import 'quiz_controller.dart';
import '../views/quiz_view.dart';
import '../views/pdf_viewer_screen.dart';
import '../../favorite/providers/favorite_provider.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/services/video_download_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/models/api_error_model.dart';

class LessonDetailController extends GetxController {
  final SubjectsProvider subjectsProvider = SubjectsProvider();
  final FavoriteProvider _favoriteProvider = FavoriteProvider();
  final VideoDownloadService _downloadService = VideoDownloadService();

  final RxBool isVideoPlaying = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isLoadingLessons = false.obs;
  final RxBool isLoadingVideo = false.obs;
  final RxBool isLoadingTest = false.obs;
  final RxBool isLoadingSummary = false.obs;
  final RxInt currentLessonId = 0.obs;

  // YouTube video state
  final RxBool isYouTubeVideo = false.obs;

  // Download state (for current playing video)
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isVideoDownloaded = false.obs;
  String _currentVideoUrl = '';

  // Download state for lesson list - use global service state for persistence
  RxMap<int, double> get lessonDownloadProgress => _downloadService.downloadProgress;
  RxSet<int> get downloadingLessons => _downloadService.activeDownloads;

  // Local state for tracking which lessons are downloaded (file exists)
  final RxSet<int> downloadedLessons = <int>{}.obs;

  // Lessons data from API
  final RxList<LessonModel> lessons = <LessonModel>[].obs;
  final RxString unitName = ''.obs;
  final RxString teacherName = ''.obs;
  final RxString liveAt = ''.obs;
  final RxInt lessonsCount = 0.obs;
  final RxBool hasLiveLesson = false.obs;

  // Track favorite lessons
  final RxSet<int> favoriteLessons = <int>{}.obs;

  // Media Kit player and controller
  Player? player;
  VideoController? videoController;

  // YouTube explode for extracting direct URLs
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  void _initializePlayer() {
    player = Player();
    videoController = VideoController(player!);
  }

  // Load lessons for a unit
  Future<void> loadLessons(int unitId) async {
    try {
      isLoadingLessons.value = true;

      developer.log('📚 Loading lessons for unit: $unitId', name: 'LessonDetailController');

      final storageService = Get.find<StorageService>();
      final user = storageService.currentUser;
      developer.log('   User plan_status: ${user?.planStatus}', name: 'LessonDetailController');

      final response = await subjectsProvider.getUnitLessons(unitId);

      if (response.status) {
        lessons.value = response.data.lessons;
        unitName.value = response.data.unitName;
        teacherName.value = response.data.teacherName;
        liveAt.value = response.data.liveAt;
        lessonsCount.value = response.data.lessonsCount;

        hasLiveLesson.value = lessons.any((lesson) => lesson.isAlive == 1);

        favoriteLessons.clear();
        for (final lesson in lessons) {
          if (lesson.isFavorite == true) {
            favoriteLessons.add(lesson.id);
          }
        }

        await _checkDownloadedLessons();

        developer.log('✅ Lessons loaded: ${lessons.length} lessons', name: 'LessonDetailController');
      } else {
        developer.log('❌ Failed to load lessons', name: 'LessonDetailController');
      }
    } catch (e) {
      developer.log('❌ Error loading lessons: $e', name: 'LessonDetailController');

      if (e is ApiErrorModel) {
        AppDialog.showError(message: e.displayMessage);
      } else {
        AppDialog.showError(message: 'حدث خطأ أثناء تحميل الدروس');
      }
    } finally {
      isLoadingLessons.value = false;
    }
  }

  // Load a single lesson directly by ID (for search results)
  Future<void> loadSingleLessonAndPlay(int lessonId, String lessonName) async {
    try {
      isLoadingLessons.value = true;

      developer.log('🔍 Loading single lesson from search: $lessonId', name: 'LessonDetailController');

      final tempLesson = LessonModel(
        id: lessonId,
        name: lessonName,
        order: '1',
      );

      lessons.value = [tempLesson];
      unitName.value = 'نتيجة البحث';
      teacherName.value = '';
      liveAt.value = '';
      lessonsCount.value = 1;

      developer.log('✅ Single lesson loaded, preparing to play video', name: 'LessonDetailController');

      await playLessonVideo(lessonId);
    } catch (e) {
      developer.log('❌ Error loading single lesson: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل الدرس');
    } finally {
      isLoadingLessons.value = false;
    }
  }

  void toggleVideo() {
    isVideoPlaying.value = !isVideoPlaying.value;
  }

  // Check if user needs subscription and show dialog
  bool _checkSubscriptionAccess() {
    final storageService = Get.find<StorageService>();
    final isGuestMode = !storageService.isLoggedIn;
    final currentUser = storageService.currentUser;
    final hasActiveSubscription = currentUser?.planStatus == 'active';

    if (isGuestMode || !hasActiveSubscription) {
      _showSubscriptionDialog(isGuestMode);
      return false;
    }
    return true;
  }

  // Show subscription or registration dialog
  void _showSubscriptionDialog(bool isGuestMode) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGuestMode ? Icons.lock_outline : Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isGuestMode ? 'تسجيل الدخول مطلوب' : 'اشتراك مميز مطلوب',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isGuestMode
                    ? 'يجب عليك إنشاء حساب للوصول إلى محتوى الدروس'
                    : 'يجب الاشتراك للوصول إلى محتوى الدروس',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderPrimary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        if (isGuestMode) {
                          final storage = Get.find<StorageService>();
                          await storage.clearGuestData();
                          Get.offAllNamed('/authentication');
                        } else {
                          Get.toNamed('/subscription');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        isGuestMode ? 'تسجيل الدخول' : 'عرض خطط الاشتراك',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Extract YouTube video ID from URL
  String? _extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  // Get direct video URL from YouTube
  Future<String?> _getYouTubeDirectUrl(String videoId) async {
    try {
      developer.log('🔍 Extracting YouTube direct URL for: $videoId', name: 'LessonDetailController');

      final manifest = await _youtubeExplode.videos.streamsClient.getManifest(videoId);

      // Get the best quality muxed stream (video + audio)
      final muxedStreams = manifest.muxed.sortByVideoQuality();
      if (muxedStreams.isNotEmpty) {
        final streamUrl = muxedStreams.last.url.toString();
        developer.log('✅ Got YouTube direct URL (muxed): ${muxedStreams.last.qualityLabel}', name: 'LessonDetailController');
        return streamUrl;
      }

      // Fallback to video-only stream if no muxed available
      final videoStreams = manifest.videoOnly.sortByVideoQuality();
      if (videoStreams.isNotEmpty) {
        final streamUrl = videoStreams.last.url.toString();
        developer.log('✅ Got YouTube direct URL (video-only): ${videoStreams.last.qualityLabel}', name: 'LessonDetailController');
        return streamUrl;
      }

      return null;
    } catch (e) {
      developer.log('❌ Error extracting YouTube URL: $e', name: 'LessonDetailController');
      return null;
    }
  }

  // Load and play video for a lesson
  Future<void> playLessonVideo(int lessonId) async {
    try {
      isLoadingVideo.value = true;
      currentLessonId.value = lessonId;
      developer.log('🎥 Loading video for lesson: $lessonId', name: 'LessonDetailController');

      final lesson = lessons.firstWhereOrNull((l) => l.id == lessonId);
      if (lesson != null) {
        isFavorite.value = lesson.isFavorite ?? false;
      }

      // For live lessons, use liveUrl (YouTube)
      if (lesson != null && lesson.isAlive == 1 && lesson.liveUrl != null && lesson.liveUrl!.isNotEmpty) {
        developer.log('📺 Live lesson detected, using YouTube URL: ${lesson.liveUrl}', name: 'LessonDetailController');

        final videoId = _extractYouTubeId(lesson.liveUrl!);
        if (videoId != null) {
          isYouTubeVideo.value = true;
          isVideoDownloaded.value = false;

          // Get direct URL from YouTube
          final directUrl = await _getYouTubeDirectUrl(videoId);
          if (directUrl != null) {
            await _playVideo(directUrl);
            return;
          } else {
            developer.log('❌ Could not get YouTube direct URL', name: 'LessonDetailController');
            AppDialog.showError(message: 'رابط البث غير صالح');
            return;
          }
        } else {
          developer.log('❌ Could not extract YouTube video ID', name: 'LessonDetailController');
          AppDialog.showError(message: 'رابط البث غير صالح');
          return;
        }
      }

      // Reset YouTube flag for non-live videos
      isYouTubeVideo.value = false;

      // Check if video is downloaded
      final localPath = await _downloadService.getLocalVideoPath(lessonId);

      if (localPath != null) {
        developer.log('✅ Playing video from local storage: $localPath', name: 'LessonDetailController');
        isVideoDownloaded.value = true;
        await _playVideoFromFile(localPath);
      } else if (lesson != null && lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
        _currentVideoUrl = lesson.videoUrl!;
        developer.log('✅ Using video URL from lesson: ${lesson.videoUrl}', name: 'LessonDetailController');
        isVideoDownloaded.value = false;
        await _playVideo(lesson.videoUrl!);
      } else {
        final storageService = Get.find<StorageService>();
        final isGuestMode = !storageService.isLoggedIn || storageService.currentUser == null;

        if (isGuestMode) {
          developer.log('❌ Video not available for guest, showing login dialog', name: 'LessonDetailController');
          _showSubscriptionDialog(true);
          return;
        }

        final response = await subjectsProvider.getLessonVideo(lessonId);

        if (response.status && response.data.videoUrl.isNotEmpty) {
          _currentVideoUrl = response.data.videoUrl;
          developer.log('✅ Video URL loaded from API: ${response.data.videoUrl}', name: 'LessonDetailController');
          isVideoDownloaded.value = false;
          await _playVideo(response.data.videoUrl);
        } else {
          developer.log('❌ No video URL available', name: 'LessonDetailController');
          AppDialog.showError(message: 'video_not_available'.tr);
        }
      }
    } catch (e) {
      developer.log('❌ Error loading video: $e', name: 'LessonDetailController');

      final storageService = Get.find<StorageService>();
      final isGuestMode = !storageService.isLoggedIn || storageService.currentUser == null;

      if (isGuestMode) {
        developer.log('🔐 Guest user, showing login dialog', name: 'LessonDetailController');
        _showSubscriptionDialog(true);
      } else {
        AppDialog.showError(message: 'video_not_available'.tr);
      }
    } finally {
      isLoadingVideo.value = false;
    }
  }

  // Play video from URL using media_kit
  Future<void> _playVideo(String videoUrl) async {
    try {
      developer.log('▶️ Playing video: $videoUrl', name: 'LessonDetailController');

      // Open the media - this starts buffering immediately
      await player?.open(Media(videoUrl));

      // Start playback
      await player?.play();

      isVideoPlaying.value = true;
      update();
    } catch (e) {
      developer.log('❌ Error playing video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'video_not_available'.tr);
      isVideoPlaying.value = false;
    }
  }

  // Play video from local file using media_kit
  Future<void> _playVideoFromFile(String filePath) async {
    try {
      developer.log('▶️ Playing local video: $filePath', name: 'LessonDetailController');

      await player?.open(Media(filePath));
      await player?.play();

      isVideoPlaying.value = true;
      update();
    } catch (e) {
      developer.log('❌ Error playing local video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'video_not_available'.tr);
      isVideoPlaying.value = false;
    }
  }

  void showVideo() {
    isVideoPlaying.value = true;
  }

  void hideVideo() {
    isVideoPlaying.value = false;
    player?.stop();
  }

  Future<void> toggleFavorite(int lessonId) async {
    if (!_checkSubscriptionAccess()) {
      return;
    }
    try {
      developer.log('🔄 Toggling favorite for lesson: $lessonId', name: 'LessonDetailController');
      final response = await _favoriteProvider.toggleFavorite(id: lessonId, type: 'lesson');
      isFavorite.value = response.isFavorite ?? !isFavorite.value;

      if (response.isFavorite == true) {
        favoriteLessons.add(lessonId);
      } else {
        favoriteLessons.remove(lessonId);
      }

      try {
        final favoriteController = Get.find<FavoriteController>();
        favoriteController.loadFavorites();
      } catch (e) {
        developer.log('⚠️ FavoriteController not found', name: 'LessonDetailController');
      }

      developer.log('✅ Toggle favorite successful: ${response.isFavorite}', name: 'LessonDetailController');
      AppDialog.showSuccess(message: isFavorite.value ? 'added_to_favorites'.tr : 'removed_from_favorites'.tr);
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to toggle favorite: ${error.displayMessage}', name: 'LessonDetailController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error toggling favorite: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحديث المفضلة');
    }
  }

  Future<void> checkIfFavorite(int lessonId) async {
    try {
      isFavorite.value = false;
    } catch (e) {
      developer.log('❌ Error checking favorite status: $e', name: 'LessonDetailController');
    }
  }

  // Load and navigate to test
  Future<void> openLessonTest(int lessonId) async {
    if (!_checkSubscriptionAccess()) {
      return;
    }

    try {
      isLoadingTest.value = true;
      developer.log('📝 Loading test for lesson: $lessonId', name: 'LessonDetailController');

      final lesson = lessons.firstWhereOrNull((l) => l.id == lessonId);

      if (lesson != null && lesson.testId != null) {
        developer.log('✅ Lesson has test_id: ${lesson.testId}, using new test API', name: 'LessonDetailController');

        Get.delete<QuizController>();

        Get.to(
          () => const QuizView(),
          binding: BindingsBuilder(() {
            Get.put(QuizController(
              lessonTitle: lesson.name,
              testId: lesson.testId,
            ));
          }),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        )?.then((_) {
          Get.delete<QuizController>();
        });

        isLoadingTest.value = false;
        return;
      }

      developer.log('ℹ️ No test_id for lesson, showing info message', name: 'LessonDetailController');
      AppDialog.showInfo(
        message: 'no_test_available'.tr,
      );
    } on ApiErrorModel catch (e) {
      if (e.statusCode == 404) {
        developer.log('ℹ️ No test found (404)', name: 'LessonDetailController');
        AppDialog.showInfo(
          message: 'no_test_available'.tr,
        );
      } else {
        developer.log('❌ Error loading test: $e', name: 'LessonDetailController');
        AppDialog.showError(
          message: 'error_loading_test'.tr,
        );
      }
    } catch (e) {
      developer.log('❌ Error loading test: $e', name: 'LessonDetailController');
      AppDialog.showError(
        message: 'error_loading_test'.tr,
      );
    } finally {
      isLoadingTest.value = false;
    }
  }

  // Load and open lesson summary PDF
  Future<void> openLessonSummary(int lessonId) async {
    if (!_checkSubscriptionAccess()) {
      return;
    }
    try {
      isLoadingSummary.value = true;
      developer.log('📄 Loading summary for lesson: $lessonId', name: 'LessonDetailController');

      final response = await subjectsProvider.getLessonSummary(lessonId);

      if (response.status && response.data.fileUrl.isNotEmpty) {
        developer.log('✅ Summary loaded: ${response.data.fileUrl}', name: 'LessonDetailController');

        Get.to(
          () => PdfViewerScreen(
            pdfUrl: response.data.fileUrl,
            title: response.data.lessonName,
          ),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        developer.log('❌ No summary available', name: 'LessonDetailController');
        AppDialog.showInfo(
          message: 'لا يوجد ملخص متاح لهذا الدرس',
        );
      }
    } catch (e) {
      developer.log('❌ Error loading summary: $e', name: 'LessonDetailController');
      AppDialog.showError(
        message: 'حدث خطأ أثناء تحميل الملخص',
      );
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // Download current video
  Future<void> downloadCurrentVideo() async {
    if (!_checkSubscriptionAccess()) {
      return;
    }
    try {
      if (isDownloading.value) {
        developer.log('⚠️ Download already in progress', name: 'LessonDetailController');
        return;
      }

      if (_currentVideoUrl.isEmpty) {
        AppDialog.showError(message: 'لا يوجد رابط فيديو متاح');
        return;
      }

      final lesson = lessons.firstWhereOrNull((l) => l.id == currentLessonId.value);
      if (lesson == null) {
        AppDialog.showError(message: 'لم يتم العثور على الدرس');
        return;
      }

      isDownloading.value = true;
      downloadProgress.value = 0.0;

      developer.log('📥 Starting video download for lesson: ${currentLessonId.value}', name: 'LessonDetailController');

      await _downloadService.downloadVideo(
        lessonId: currentLessonId.value,
        videoUrl: _currentVideoUrl,
        lessonName: lesson.name,
        onProgress: (progress) {
          downloadProgress.value = progress;
        },
      );

      isVideoDownloaded.value = true;
      downloadProgress.value = 1.0;

      developer.log('✅ Video downloaded successfully', name: 'LessonDetailController');
      AppDialog.showSuccess(message: 'تم تنزيل الفيديو بنجاح');

      try {
        final favoriteController = Get.find<FavoriteController>();
        favoriteController.loadDownloadedVideos();
      } catch (e) {
        // FavoriteController might not be initialized
      }
    } catch (e) {
      developer.log('❌ Error downloading video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء تنزيل الفيديو');
    } finally {
      isDownloading.value = false;
    }
  }

  // Delete downloaded video
  Future<void> deleteCurrentVideo() async {
    try {
      developer.log('🗑️ Deleting video for lesson: ${currentLessonId.value}', name: 'LessonDetailController');

      Get.dialog(
        AlertDialog(
          title: const Text('حذف الفيديو'),
          content: const Text('هل أنت متأكد من حذف هذا الفيديو المحمل؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();

                await _downloadService.deleteDownload(currentLessonId.value);
                isVideoDownloaded.value = false;

                developer.log('✅ Video deleted successfully', name: 'LessonDetailController');
                AppDialog.showSuccess(message: 'تم حذف الفيديو بنجاح');

                try {
                  final favoriteController = Get.find<FavoriteController>();
                  favoriteController.loadDownloadedVideos();
                } catch (e) {
                  // FavoriteController might not be initialized
                }
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('❌ Error deleting video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء حذف الفيديو');
    }
  }

  // Check which lessons are already downloaded
  Future<void> _checkDownloadedLessons() async {
    downloadedLessons.clear();
    for (final lesson in lessons) {
      final localPath = await _downloadService.getLocalVideoPath(lesson.id);
      if (localPath != null && await File(localPath).exists()) {
        downloadedLessons.add(lesson.id);
      }
    }
  }

  // Download a specific lesson video from the list
  Future<void> downloadLessonVideo(int lessonId) async {
    developer.log('📥 Download requested for lesson: $lessonId', name: 'LessonDetailController');

    if (!_checkSubscriptionAccess()) {
      developer.log('❌ Subscription check failed', name: 'LessonDetailController');
      return;
    }

    if (_downloadService.isDownloading(lessonId)) {
      developer.log('⚠️ Already downloading lesson: $lessonId', name: 'LessonDetailController');
      return;
    }

    if (downloadedLessons.contains(lessonId)) {
      developer.log('📦 Lesson already downloaded, showing delete dialog', name: 'LessonDetailController');
      _showDeleteLessonVideoDialog(lessonId);
      return;
    }

    final lesson = lessons.firstWhereOrNull((l) => l.id == lessonId);
    if (lesson == null) {
      developer.log('❌ Lesson not found in list: $lessonId', name: 'LessonDetailController');
      AppDialog.showError(message: 'لم يتم العثور على الدرس');
      return;
    }

    String? videoUrl = lesson.videoUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      developer.log('⚠️ No video URL in lesson data, fetching from API...', name: 'LessonDetailController');

      try {
        final response = await subjectsProvider.getLessonVideo(lessonId);
        if (response.status && response.data.videoUrl.isNotEmpty) {
          videoUrl = response.data.videoUrl;
          developer.log('✅ Video URL loaded from API: $videoUrl', name: 'LessonDetailController');
        } else {
          developer.log('❌ API returned no video URL', name: 'LessonDetailController');
          AppDialog.showError(message: 'لا يوجد فيديو متاح للتنزيل');
          return;
        }
      } catch (e) {
        developer.log('❌ Failed to fetch video URL from API: $e', name: 'LessonDetailController');
        AppDialog.showError(message: 'لا يوجد فيديو متاح للتنزيل');
        return;
      }
    }

    try {
      developer.log('📥 Starting video download for lesson: $lessonId', name: 'LessonDetailController');

      await _downloadService.downloadVideo(
        lessonId: lessonId,
        videoUrl: videoUrl,
        lessonName: lesson.name,
      );

      downloadedLessons.add(lessonId);

      developer.log('✅ Lesson video downloaded successfully', name: 'LessonDetailController');
      AppDialog.showSuccess(message: 'تم تنزيل الفيديو بنجاح');

      try {
        final favoriteController = Get.find<FavoriteController>();
        favoriteController.loadDownloadedVideos();
      } catch (e) {
        // FavoriteController might not be initialized
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        developer.log('⚠️ Download cancelled for lesson: $lessonId', name: 'LessonDetailController');
        AppDialog.showInfo(message: 'تم إلغاء التنزيل');
      } else {
        developer.log('❌ Error downloading lesson video: $e', name: 'LessonDetailController');
        AppDialog.showError(message: 'حدث خطأ أثناء تنزيل الفيديو');
      }
    } catch (e) {
      developer.log('❌ Error downloading lesson video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء تنزيل الفيديو');
    }
  }

  // Cancel a download in progress
  void cancelDownload(int lessonId) {
    _downloadService.cancelDownload(lessonId);
  }

  // Show delete confirmation dialog for lesson video
  void _showDeleteLessonVideoDialog(int lessonId) {
    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.85,
          margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
          padding: EdgeInsets.all(Get.width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'حذف الفيديو',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000D47),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'هل أنت متأكد من حذف هذا الفيديو المحمل؟\nيمكنك تنزيله مرة أخرى لاحقاً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF000D47), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000D47),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();

                        await _downloadService.deleteDownload(lessonId);
                        downloadedLessons.remove(lessonId);

                        developer.log('✅ Lesson video deleted successfully', name: 'LessonDetailController');
                        AppDialog.showSuccess(message: 'تم حذف الفيديو بنجاح');

                        try {
                          final favoriteController = Get.find<FavoriteController>();
                          favoriteController.loadDownloadedVideos();
                        } catch (e) {
                          // FavoriteController might not be initialized
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'حذف',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  void onClose() {
    player?.dispose();
    _youtubeExplode.close();
    super.onClose();
  }
}
