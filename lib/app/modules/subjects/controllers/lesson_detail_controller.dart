import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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

  // Download state
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isVideoDownloaded = false.obs;
  String _currentVideoUrl = '';

  // Lessons data from API
  final RxList<LessonModel> lessons = <LessonModel>[].obs;
  final RxString unitName = ''.obs;
  final RxString teacherName = ''.obs;
  final RxString liveAt = ''.obs;
  final RxInt lessonsCount = 0.obs;

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

        developer.log('✅ Lessons loaded: ${lessons.length} lessons', name: 'LessonDetailController');
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
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    if (isGuestMode) {
                      Get.toNamed('/authentication');
                    } else {
                      Get.toNamed('/subscription');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGuestMode
                        ? const Color(0xFF00A8A8)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isGuestMode ? 'إنشاء حساب' : 'عرض خطط الاشتراك',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel Button
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
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

      // Check if video is downloaded
      final localPath = await _downloadService.getLocalVideoPath(lessonId);

      if (localPath != null) {
        // Play from local storage
        developer.log('✅ Playing video from local storage: $localPath', name: 'LessonDetailController');
        isVideoDownloaded.value = true;
        isVideoPlaying.value = true;
        _initializeVideoPlayerFromFile(localPath);
      } else if (lesson != null && lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
        // Use video URL from lesson data
        _currentVideoUrl = lesson.videoUrl!;
        developer.log('✅ Using video URL from lesson: ${lesson.videoUrl}', name: 'LessonDetailController');
        isVideoDownloaded.value = false;
        isVideoPlaying.value = true;
        _initializeVideoPlayer(lesson.videoUrl!);
      } else {
        // Check if user is authenticated
        final storageService = Get.find<StorageService>();
        final isAuthenticated = storageService.isLoggedIn && storageService.authToken != null;

        if (!isAuthenticated) {
          // Guest user - video URL is missing, show unavailable message
          developer.log('❌ Video URL not available for guest', name: 'LessonDetailController');
          AppDialog.showError(message: 'الفيديو غير متاح حالياً');
          return;
        }

        // Authenticated user - try to load from API
        final response = await subjectsProvider.getLessonVideo(lessonId);

        if (response.status && response.data.videoUrl.isNotEmpty) {
          _currentVideoUrl = response.data.videoUrl;
          developer.log('✅ Video URL loaded from API: ${response.data.videoUrl}', name: 'LessonDetailController');
          isVideoDownloaded.value = false;
          isVideoPlaying.value = true;
          _initializeVideoPlayer(response.data.videoUrl);
        } else {
          developer.log('❌ No video URL available', name: 'LessonDetailController');
          AppDialog.showError(message: 'الفيديو غير متاح حالياً');
        }
      }
    } catch (e) {
      developer.log('❌ Error loading video: $e', name: 'LessonDetailController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل الفيديو');
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

      // Update FavoriteController to refresh the favorites list
      try {
        final favoriteController = Get.find<FavoriteController>();
        favoriteController.loadFavorites();
      } catch (e) {
        developer.log('⚠️ FavoriteController not found', name: 'LessonDetailController');
      }

      developer.log('✅ Toggle favorite successful: ${response.isFavorite}', name: 'LessonDetailController');
      AppDialog.showSuccess(message: response.message ?? (isFavorite.value ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'));
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

      // OLD FLOW: If no test_id, use the old getLessonTest API
      developer.log('   Using old lesson test API', name: 'LessonDetailController');
      final response = await subjectsProvider.getLessonTest(lessonId);

      if (response.status && response.data.questions.isNotEmpty) {
        developer.log('✅ Test loaded: ${response.data.questions.length} questions', name: 'LessonDetailController');

        // Delete any existing quiz controller to ensure fresh start
        Get.delete<QuizController>();

        // Navigate to quiz screen with lesson test questions
        Get.to(
          () => const QuizView(),
          binding: BindingsBuilder(() {
            Get.put(QuizController(
              lessonTitle: response.data.testName,
              initialQuestions: response.data.questions,
            ));
          }),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        )?.then((_) {
          // Delete controller when returning from quiz
          Get.delete<QuizController>();
        });
      } else {
        developer.log('❌ No test available', name: 'LessonDetailController');
        AppDialog.showInfo(
          message: 'لا يوجد اختبار متاح لهذا الدرس',
        );
      }
    } catch (e) {
      developer.log('❌ Error loading test: $e', name: 'LessonDetailController');
      AppDialog.showError(
        message: 'حدث خطأ أثناء تحميل الاختبار',
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

  void _initializeVideoPlayer(String videoUrl) {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    videoPlayerController!.initialize().then((_) {
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFB2B3A),
          handleColor: const Color(0xFFFB2B3A),
          backgroundColor: const Color(0xFF666666),
          bufferedColor: const Color(0xFF999999),
        ),
      );
      update();
    });
  }

  void _initializeVideoPlayerFromFile(String filePath) {
    videoPlayerController = VideoPlayerController.file(File(filePath));

    videoPlayerController!.initialize().then((_) {
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFB2B3A),
          handleColor: const Color(0xFFFB2B3A),
          backgroundColor: const Color(0xFF666666),
          bufferedColor: const Color(0xFF999999),
        ),
      );
      update();
    });
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

  void _disposeVideoPlayer() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
    chewieController = null;
    videoPlayerController = null;
  }

  @override
  void onClose() {
    _disposeVideoPlayer();
    super.onClose();
  }
}
