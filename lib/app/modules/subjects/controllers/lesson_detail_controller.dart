import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  YoutubePlayerController? youtubePlayerController;

  // Download state (for current playing video)
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isVideoDownloaded = false.obs;
  String _currentVideoUrl = '';

  // Download state for lesson list - use global service state for persistence
  // These getters delegate to VideoDownloadService singleton for cross-page persistence
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
  final RxBool hasLiveLesson = false.obs; // Track if any lesson is currently live

  // Track favorite lessons
  final RxSet<int> favoriteLessons = <int>{}.obs;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  // Load lessons for a unit
  Future<void> loadLessons(int unitId) async {
    try {
      isLoadingLessons.value = true;

      developer.log('📚 Loading lessons for unit: $unitId', name: 'LessonDetailController');

      // Get storage service to check subscription status
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

        // Check if any lesson is currently live
        hasLiveLesson.value = lessons.any((lesson) => lesson.isAlive == 1);

        // Populate favorite lessons from API data
        favoriteLessons.clear();
        for (final lesson in lessons) {
          if (lesson.isFavorite == true) {
            favoriteLessons.add(lesson.id);
          }
        }

        // Check which lessons are already downloaded
        await _checkDownloadedLessons();

        developer.log('✅ Lessons loaded: ${lessons.length} lessons', name: 'LessonDetailController');
        developer.log('   Has live lesson: ${hasLiveLesson.value}', name: 'LessonDetailController');
        developer.log('   Favorite lessons: ${favoriteLessons.length}', name: 'LessonDetailController');
        developer.log('   Downloaded lessons: ${downloadedLessons.length}', name: 'LessonDetailController');
      } else {
        developer.log('❌ Failed to load lessons', name: 'LessonDetailController');
      }
    } catch (e) {
      developer.log('❌ Error loading lessons: $e', name: 'LessonDetailController');

      // Show error message to user
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

      // Create a temporary lesson object for the search result
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

      // Automatically play the lesson video
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
              // Icon
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
              // Title
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
              // Message
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
              // Buttons
              Row(
                children: [
                  // Cancel button
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
                  // Action button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
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

  // Check if a URL is a YouTube URL
  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  // Extract YouTube video ID from URL
  String? _extractYouTubeId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  // Load and play video for a lesson
  Future<void> playLessonVideo(int lessonId) async {
    try {
      isLoadingVideo.value = true;
      currentLessonId.value = lessonId;
      developer.log('🎥 Loading video for lesson: $lessonId', name: 'LessonDetailController');

      // Check if lesson is favorite
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
          isVideoPlaying.value = true;
          _initializeYouTubePlayer(videoId);
          return;
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
        // Play from local storage
        developer.log('✅ Playing video from local storage: $localPath', name: 'LessonDetailController');
        isVideoDownloaded.value = true;
        isVideoPlaying.value = true;
        await _initializeVideoPlayerFromFile(localPath);
      } else if (lesson != null && lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
        // Use video URL from lesson data
        _currentVideoUrl = lesson.videoUrl!;
        developer.log('✅ Using video URL from lesson: ${lesson.videoUrl}', name: 'LessonDetailController');
        isVideoDownloaded.value = false;
        isVideoPlaying.value = true;
        await _initializeVideoPlayer(lesson.videoUrl!);
      } else {
        // Check if user is a guest (not logged in or using guest mode)
        final storageService = Get.find<StorageService>();
        final isGuestMode = !storageService.isLoggedIn || storageService.currentUser == null;

        if (isGuestMode) {
          // Guest user - video URL is missing, show login dialog
          developer.log('❌ Video not available for guest, showing login dialog', name: 'LessonDetailController');
          _showSubscriptionDialog(true);
          return;
        }

        // Authenticated user - try to load from API
        final response = await subjectsProvider.getLessonVideo(lessonId);

        if (response.status && response.data.videoUrl.isNotEmpty) {
          _currentVideoUrl = response.data.videoUrl;
          developer.log('✅ Video URL loaded from API: ${response.data.videoUrl}', name: 'LessonDetailController');
          isVideoDownloaded.value = false;
          isVideoPlaying.value = true;
          await _initializeVideoPlayer(response.data.videoUrl);
        } else {
          developer.log('❌ No video URL available', name: 'LessonDetailController');
          AppDialog.showError(message: 'video_not_available'.tr);
        }
      }
    } catch (e) {
      developer.log('❌ Error loading video: $e', name: 'LessonDetailController');

      // Check if user is guest and show login dialog instead of error
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

  void showVideo() {
    isVideoPlaying.value = true;
  }

  void hideVideo() {
    isVideoPlaying.value = false;
    _disposeVideoPlayer();
  }

  Future<void> toggleFavorite(int lessonId) async {
    // Check subscription access first
    if (!_checkSubscriptionAccess()) {
      return;
    }
    try {
      developer.log('🔄 Toggling favorite for lesson: $lessonId', name: 'LessonDetailController');
      final response = await _favoriteProvider.toggleFavorite(id: lessonId, type: 'lesson');
      isFavorite.value = response.isFavorite ?? !isFavorite.value;

      // Update favoriteLessons set
      if (response.isFavorite == true) {
        favoriteLessons.add(lessonId);
      } else {
        favoriteLessons.remove(lessonId);
      }

      // Update FavoriteController to refresh the favorites list
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

  // Check if lesson is favorite
  Future<void> checkIfFavorite(int lessonId) async {
    try {
      // This would require an API endpoint to check if a lesson is favorite
      // For now, we'll assume it's not favorite by default
      // You can implement this based on your API
      isFavorite.value = false;
    } catch (e) {
      developer.log('❌ Error checking favorite status: $e', name: 'LessonDetailController');
    }
  }

  // Load and navigate to test
  Future<void> openLessonTest(int lessonId) async {
    // Check subscription access first
    if (!_checkSubscriptionAccess()) {
      return;
    }

    try {
      isLoadingTest.value = true;
      developer.log('📝 Loading test for lesson: $lessonId', name: 'LessonDetailController');

      // Find the lesson to check if it has a test_id
      final lesson = lessons.firstWhereOrNull((l) => l.id == lessonId);

      // NEW FLOW: If lesson has a test_id, use the new test start API
      if (lesson != null && lesson.testId != null) {
        developer.log('✅ Lesson has test_id: ${lesson.testId}, using new test API', name: 'LessonDetailController');

        // Delete any existing quiz controller to ensure fresh start
        Get.delete<QuizController>();

        // Navigate to quiz screen with testId to start the test via API
        Get.to(
          () => const QuizView(),
          binding: BindingsBuilder(() {
            Get.put(QuizController(
              lessonTitle: lesson.name,
              testId: lesson.testId, // Use the new test API
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

      // No test_id means no test available for this lesson
      developer.log('ℹ️ No test_id for lesson, showing info message', name: 'LessonDetailController');
      AppDialog.showInfo(
        message: 'no_test_available'.tr,
      );
    } on ApiErrorModel catch (e) {
      // Handle 404 as "no test available"
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
    // Check subscription access first
    if (!_checkSubscriptionAccess()) {
      return;
    }
    try {
      isLoadingSummary.value = true;
      developer.log('📄 Loading summary for lesson: $lessonId', name: 'LessonDetailController');

      final response = await subjectsProvider.getLessonSummary(lessonId);

      if (response.status && response.data.fileUrl.isNotEmpty) {
        developer.log('✅ Summary loaded: ${response.data.fileUrl}', name: 'LessonDetailController');

        // Navigate to PDF viewer
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

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    // Initialize with timeout to prevent indefinite waiting
    try {
      await videoPlayerController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log('⚠️ Video initialization timeout', name: 'LessonDetailController');
        },
      );

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        showOptions: false,
        // Start playing immediately, don't wait for buffering
        autoInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFB2B3A),
          handleColor: const Color(0xFFFB2B3A),
          backgroundColor: const Color(0xFF666666),
          bufferedColor: const Color(0xFF999999),
        ),
        placeholder: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFB2B3A),
          ),
        ),
      );
      update();
    } catch (e) {
      developer.log('❌ Error initializing video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'video_not_available'.tr);
      isVideoPlaying.value = false;
    }
  }

  Future<void> _initializeVideoPlayerFromFile(String filePath) async {
    videoPlayerController = VideoPlayerController.file(File(filePath));

    try {
      await videoPlayerController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        showOptions: false,
        autoInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFB2B3A),
          handleColor: const Color(0xFFFB2B3A),
          backgroundColor: const Color(0xFF666666),
          bufferedColor: const Color(0xFF999999),
        ),
      );
      update();
    } catch (e) {
      developer.log('❌ Error initializing local video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'video_not_available'.tr);
      isVideoPlaying.value = false;
    }
  }

  void _initializeYouTubePlayer(String videoId) {
    youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    );
    update();
  }

  // Download current video
  Future<void> downloadCurrentVideo() async {
    // Check subscription access first
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

      // Reload downloaded videos in FavoriteController if it exists
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

      // Show confirmation dialog
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

                // Reload downloaded videos in FavoriteController if it exists
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

    // Check subscription access first
    if (!_checkSubscriptionAccess()) {
      developer.log('❌ Subscription check failed', name: 'LessonDetailController');
      return;
    }

    // If already downloading this lesson, do nothing (check global state)
    if (_downloadService.isDownloading(lessonId)) {
      developer.log('⚠️ Already downloading lesson: $lessonId', name: 'LessonDetailController');
      return;
    }

    // If already downloaded, show delete confirmation
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

    developer.log('📋 Lesson data:', name: 'LessonDetailController');
    developer.log('   - id: ${lesson.id}', name: 'LessonDetailController');
    developer.log('   - name: ${lesson.name}', name: 'LessonDetailController');
    developer.log('   - videoUrl: ${lesson.videoUrl}', name: 'LessonDetailController');
    developer.log('   - liveUrl: ${lesson.liveUrl}', name: 'LessonDetailController');
    developer.log('   - pdfFile: ${lesson.pdfFile}', name: 'LessonDetailController');
    developer.log('   - isAlive: ${lesson.isAlive}', name: 'LessonDetailController');

    // Get video URL from lesson model or fetch from API
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

      // Download using service (global state is managed by service)
      await _downloadService.downloadVideo(
        lessonId: lessonId,
        videoUrl: videoUrl,
        lessonName: lesson.name,
      );

      // Download completed successfully - add to downloaded list
      downloadedLessons.add(lessonId);

      developer.log('✅ Lesson video downloaded successfully', name: 'LessonDetailController');
      AppDialog.showSuccess(message: 'تم تنزيل الفيديو بنجاح');

      // Reload downloaded videos in FavoriteController if it exists
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

  // Cancel a download in progress (delegates to service)
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
              // Icon
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
              // Title
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
              // Subtitle
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
              // Buttons
              Row(
                children: [
                  // Cancel button
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
                  // Delete button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();

                        await _downloadService.deleteDownload(lessonId);
                        downloadedLessons.remove(lessonId);

                        developer.log('✅ Lesson video deleted successfully', name: 'LessonDetailController');
                        AppDialog.showSuccess(message: 'تم حذف الفيديو بنجاح');

                        // Reload downloaded videos in FavoriteController if it exists
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

  void _disposeVideoPlayer() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
    youtubePlayerController?.dispose();
    chewieController = null;
    videoPlayerController = null;
    youtubePlayerController = null;
    isYouTubeVideo.value = false;
  }

  @override
  void onClose() {
    _disposeVideoPlayer();
    super.onClose();
  }
}
