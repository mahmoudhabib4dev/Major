import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/services/video_download_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/downloaded_video_model.dart';
import '../../../routes/app_pages.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/favorite_response_model.dart';
import '../providers/favorite_provider.dart';
import '../../subjects/providers/subjects_provider.dart';
import '../../subjects/controllers/quiz_controller.dart';
import '../../subjects/views/quiz_view.dart';
import '../../subjects/views/pdf_viewer_screen.dart';

class FavoriteController extends GetxController {
  final FavoriteProvider _favoriteProvider = FavoriteProvider();
  final SubjectsProvider _subjectsProvider = SubjectsProvider();
  final VideoDownloadService _downloadService = VideoDownloadService();
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool isLoading = false.obs;
  final Rx<FavoriteResponseModel?> favoritesResponse = Rx<FavoriteResponseModel?>(null);
  final RxList<FavoriteItem> favorites = <FavoriteItem>[].obs;
  final RxList<FavoriteItem> lessonFavorites = <FavoriteItem>[].obs;
  final RxList<DownloadedVideoModel> downloadedVideos = <DownloadedVideoModel>[].obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoadingTest = false.obs;
  final RxBool isLoadingSummary = false.obs;
  final RxBool isLoadingVideo = false.obs;

  // Video player
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  final RxBool isVideoPlaying = false.obs;
  final RxInt currentPlayingVideoId = 0.obs;
  final RxDouble videoLoadProgress = 0.0.obs;

  // Guest mode check - treat users without active subscription as guests for favorites
  bool get isGuest {
    if (!_storageService.isLoggedIn || _storageService.authToken == null) {
      return true; // Actual guest
    }
    // Logged-in user without active subscription should also be treated as guest
    final currentUser = _storageService.currentUser;
    return currentUser?.planStatus != 'active';
  }

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    loadDownloadedVideos();
  }

  Future<void> loadFavorites() async {
    // Don't load favorites if user is in guest mode
    if (isGuest) {
      developer.log('⏭️  Skipping favorites load - user is in guest mode', name: 'FavoriteController');
      favorites.value = [];
      lessonFavorites.value = [];
      return;
    }

    isLoading.value = true;
    try {
      developer.log('📚 Loading favorites...', name: 'FavoriteController');
      final response = await _favoriteProvider.getFavorites();
      favoritesResponse.value = response;
      favorites.value = response.data ?? [];
      lessonFavorites.value = favorites.where((item) => item.type == 'lesson').toList();
      developer.log('✅ Favorites loaded: ${favorites.length} items', name: 'FavoriteController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load favorites: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading favorites: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل المفضلة');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDownloadedVideos() async {
    try {
      developer.log('📥 Loading downloaded videos...', name: 'FavoriteController');
      final videos = await _downloadService.getAllDownloads();
      downloadedVideos.value = videos;
      developer.log('✅ Downloaded videos loaded: ${videos.length} items', name: 'FavoriteController');
    } catch (e) {
      developer.log('❌ Error loading downloaded videos: $e', name: 'FavoriteController');
    }
  }

  Future<void> deleteDownloadedVideo(int lessonId) async {
    try {
      developer.log('🗑️ Deleting downloaded video: $lessonId', name: 'FavoriteController');
      await _downloadService.deleteDownload(lessonId);
      await loadDownloadedVideos();
      developer.log('✅ Downloaded video deleted', name: 'FavoriteController');
      AppDialog.showSuccess(message: 'تم حذف الفيديو المحفوظ');
    } catch (e) {
      developer.log('❌ Error deleting downloaded video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء حذف الفيديو');
    }
  }

  Future<void> toggleFavorite({
    required int id,
    required String type,
  }) async {
    // Show appropriate dialog if user cannot access favorites
    if (isGuest) {
      // Check if user is actually logged in (but without subscription)
      if (_storageService.isLoggedIn) {
        showSubscriptionDialog();
      } else {
        showLoginDialog();
      }
      return;
    }

    try {
      developer.log('🔄 Toggling favorite: $type #$id', name: 'FavoriteController');
      final response = await _favoriteProvider.toggleFavorite(id: id, type: type);
      await loadFavorites();
      developer.log('✅ Toggle favorite successful: ${response.isFavorite}', name: 'FavoriteController');
      AppDialog.showSuccess(message: response.message ?? (response.isFavorite == true ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'));
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to toggle favorite: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error toggling favorite: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحديث المفضلة');
    }
  }

  // Show subscription dialog for logged-in users without active subscription
  void showSubscriptionDialog() {
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
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'اشتراك مميز مطلوب',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              const Text(
                'يجب الاشتراك للوصول إلى المفضلة وجميع المميزات',
                style: TextStyle(
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
                  // Subscribe button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.toNamed(Routes.SUBSCRIPTION);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'عرض خطط الاشتراك',
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

  // Show login dialog for guest users
  void showLoginDialog() {
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
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              const Text(
                'يجب عليك تسجيل الدخول للوصول إلى المفضلة',
                style: TextStyle(
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
                  // Login button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        await _storageService.clearGuestData();
                        Get.offAllNamed(Routes.AUTHENTICATION);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'تسجيل الدخول',
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

  // Load and navigate to test
  Future<void> openLessonTest(int lessonId) async {
    try {
      isLoadingTest.value = true;
      developer.log('📝 Loading test for lesson: $lessonId', name: 'FavoriteController');

      final response = await _subjectsProvider.getLessonTest(lessonId);

      if (response.status && response.data.questions.isNotEmpty) {
        developer.log('✅ Test loaded: ${response.data.questions.length} questions', name: 'FavoriteController');

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
        developer.log('❌ No test available', name: 'FavoriteController');
        AppDialog.showError(message: 'لا يوجد اختبار متاح لهذا الدرس');
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load test: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading test: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل الاختبار');
    } finally {
      isLoadingTest.value = false;
    }
  }

  // Load and open lesson summary PDF
  Future<void> openLessonSummary(int lessonId) async {
    try {
      isLoadingSummary.value = true;
      developer.log('📄 Loading summary for lesson: $lessonId', name: 'FavoriteController');

      final response = await _subjectsProvider.getLessonSummary(lessonId);

      if (response.status && response.data.fileUrl.isNotEmpty) {
        developer.log('✅ Summary loaded: ${response.data.fileUrl}', name: 'FavoriteController');

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
        developer.log('❌ No summary available', name: 'FavoriteController');
        AppDialog.showError(message: 'لا يوجد ملخص متاح لهذا الدرس');
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load summary: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading summary: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل الملخص');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // Play lesson video
  Future<void> playLessonVideo(int lessonId) async {
    try {
      isLoadingVideo.value = true;
      developer.log('🎥 Loading video for lesson: $lessonId', name: 'FavoriteController');

      final response = await _subjectsProvider.getLessonVideo(lessonId);

      if (response.status && response.data.videoUrl.isNotEmpty) {
        developer.log('✅ Video URL loaded: ${response.data.videoUrl}', name: 'FavoriteController');

        // Navigate to a simple video player or show video
        // For now, just show success message - you can implement video player later
        AppDialog.showSuccess(message: 'جاري تحميل الفيديو...');

        // TODO: Implement video player navigation
        // Get.to(() => VideoPlayerView(videoUrl: response.data.videoUrl));
      } else {
        developer.log('❌ No video URL available', name: 'FavoriteController');
        AppDialog.showError(message: 'لا يوجد فيديو متاح لهذا الدرس');
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load video: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل الفيديو');
    } finally {
      isLoadingVideo.value = false;
    }
  }

  // Play downloaded video inline
  Future<void> playDownloadedVideo(DownloadedVideoModel video) async {
    try {
      isLoadingVideo.value = true;
      videoLoadProgress.value = 0.0;
      currentPlayingVideoId.value = video.lessonId;

      developer.log('🎥 Playing downloaded video: ${video.lessonName}', name: 'FavoriteController');

      // Dispose previous player if exists
      await _disposeVideoPlayer();

      // Check if file exists
      final file = File(video.localPath);
      if (!await file.exists()) {
        developer.log('❌ Video file not found: ${video.localPath}', name: 'FavoriteController');
        AppDialog.showError(message: 'الملف غير موجود. قد يكون تم حذفه.');
        isLoadingVideo.value = false;
        return;
      }

      // Initialize video player from local file
      videoPlayerController = VideoPlayerController.file(file);

      // Listen to buffering progress
      videoPlayerController!.addListener(() {
        if (videoPlayerController!.value.isBuffering) {
          videoLoadProgress.value = 0.5;
        } else if (videoPlayerController!.value.isInitialized) {
          videoLoadProgress.value = 1.0;
          isLoadingVideo.value = false;
        }
      });

      await videoPlayerController!.initialize();

      // Create Chewie controller
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF6B7FFF),
          handleColor: const Color(0xFF6B7FFF),
          backgroundColor: const Color(0xFFE0E0E0),
          bufferedColor: const Color(0xFFB0B0B0),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6B7FFF),
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تشغيل الفيديو',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      isVideoPlaying.value = true;
      videoLoadProgress.value = 1.0;
      developer.log('✅ Video player initialized successfully', name: 'FavoriteController');
    } catch (e) {
      developer.log('❌ Error playing video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'حدث خطأ أثناء تشغيل الفيديو');
      await _disposeVideoPlayer();
    } finally {
      isLoadingVideo.value = false;
    }
  }

  // Stop and dispose video player
  Future<void> stopVideo() async {
    await _disposeVideoPlayer();
    isVideoPlaying.value = false;
    currentPlayingVideoId.value = 0;
    videoLoadProgress.value = 0.0;
  }

  Future<void> _disposeVideoPlayer() async {
    try {
      chewieController?.dispose();
      chewieController = null;
      await videoPlayerController?.dispose();
      videoPlayerController = null;
    } catch (e) {
      developer.log('⚠️ Error disposing video player: $e', name: 'FavoriteController');
    }
  }

  @override
  void onClose() {
    _disposeVideoPlayer();
    super.onClose();
  }
}
