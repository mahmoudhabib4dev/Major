import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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

  // Download state tracking
  final RxSet<int> downloadingLessons = <int>{}.obs;
  final RxSet<int> downloadedLessons = <int>{}.obs;
  final RxMap<int, double> lessonDownloadProgress = <int, double>{}.obs;

  // Video player using media_kit
  Player? player;
  VideoController? videoController;
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
      AppDialog.showError(message: 'favorite_error_loading'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDownloadedVideos() async {
    try {
      developer.log('📥 Loading downloaded videos...', name: 'FavoriteController');
      final videos = await _downloadService.getAllDownloads();
      downloadedVideos.value = videos;

      // Update downloaded lessons set
      downloadedLessons.clear();
      downloadedLessons.addAll(videos.map((v) => v.lessonId).toSet());

      developer.log('✅ Downloaded videos loaded: ${videos.length} items', name: 'FavoriteController');
    } catch (e) {
      developer.log('❌ Error loading downloaded videos: $e', name: 'FavoriteController');
    }
  }

  // Pull-to-refresh handler for favorite page
  Future<void> onRefresh() async {
    try {
      developer.log('🔄 Pull-to-refresh triggered on favorite page', name: 'FavoriteController');

      // Reload favorites and downloaded videos
      await Future.wait([
        loadFavorites(),
        loadDownloadedVideos(),
      ]);

      developer.log('✅ Favorite page refreshed successfully', name: 'FavoriteController');
    } catch (e) {
      developer.log('❌ Error refreshing favorite page: $e', name: 'FavoriteController');
    }
  }

  Future<void> deleteDownloadedVideo(int lessonId) async {
    try {
      developer.log('🗑️ Deleting downloaded video: $lessonId', name: 'FavoriteController');
      await _downloadService.deleteDownload(lessonId);
      await loadDownloadedVideos();
      developer.log('✅ Downloaded video deleted', name: 'FavoriteController');
      AppDialog.showSuccess(message: 'favorite_video_deleted'.tr);
    } catch (e) {
      developer.log('❌ Error deleting downloaded video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_deleting_video'.tr);
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
      AppDialog.showSuccess(message: response.isFavorite == true ? 'added_to_favorites'.tr : 'removed_from_favorites'.tr);
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to toggle favorite: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error toggling favorite: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_updating'.tr);
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
              Text(
                'premium_subscription_required'.tr,
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
                'favorite_subscription_required_lessons'.tr,
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
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
                      child: Text(
                        'view_subscription_plans'.tr,
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
              Text(
                'login_required'.tr,
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
                'login_to_access_content'.tr,
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
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
                      child: Text(
                        'login'.tr,
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

  // Load and navigate to test
  Future<void> openLessonTest(int lessonId, int? testId) async {
    // Check if lesson has a test_id before calling API
    if (testId == null) {
      developer.log('ℹ️ No test_id for lesson $lessonId, showing info message', name: 'FavoriteController');
      AppDialog.showInfo(message: 'no_test_available'.tr);
      return;
    }

    try {
      isLoadingTest.value = true;
      developer.log('📝 Loading test for lesson: $lessonId (testId: $testId)', name: 'FavoriteController');

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
        AppDialog.showInfo(message: 'no_test_available'.tr);
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load test: ${error.displayMessage}', name: 'FavoriteController');
      // Show info message for 404 errors (no test available)
      if (error.statusCode == 404) {
        AppDialog.showInfo(message: 'no_test_available'.tr);
      } else {
        AppDialog.showError(message: error.displayMessage);
      }
    } catch (e) {
      developer.log('❌ Unexpected error loading test: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_loading_test'.tr);
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
        AppDialog.showError(message: 'favorite_no_summary_available'.tr);
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load summary: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading summary: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_loading_summary'.tr);
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
        AppDialog.showSuccess(message: 'favorite_video_loading_msg'.tr);

        // TODO: Implement video player navigation
        // Get.to(() => VideoPlayerView(videoUrl: response.data.videoUrl));
      } else {
        developer.log('❌ No video URL available', name: 'FavoriteController');
        AppDialog.showError(message: 'favorite_no_video_available'.tr);
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load video: ${error.displayMessage}', name: 'FavoriteController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_loading_video'.tr);
    } finally {
      isLoadingVideo.value = false;
    }
  }

  // Download lesson video with progress tracking
  Future<void> downloadLesson(int lessonId) async {
    // Check if already downloading or downloaded
    if (downloadingLessons.contains(lessonId)) {
      developer.log('⚠️ Lesson $lessonId is already downloading', name: 'FavoriteController');
      return;
    }

    if (downloadedLessons.contains(lessonId)) {
      developer.log('✅ Lesson $lessonId is already downloaded', name: 'FavoriteController');
      AppDialog.showSuccess(message: 'favorite_already_downloaded'.tr);
      return;
    }

    try {
      developer.log('📥 Starting download for lesson: $lessonId', name: 'FavoriteController');

      // Mark as downloading
      downloadingLessons.add(lessonId);
      lessonDownloadProgress[lessonId] = 0.0;

      final response = await _subjectsProvider.getLessonVideo(lessonId);

      if (response.status && response.data.videoUrl.isNotEmpty) {
        developer.log('✅ Video URL for download: ${response.data.videoUrl}', name: 'FavoriteController');

        // Start download using download service with progress callback
        await _downloadService.downloadVideo(
          lessonId: lessonId,
          lessonName: response.data.lessonName,
          videoUrl: response.data.videoUrl,
          onProgress: (progress) {
            lessonDownloadProgress[lessonId] = progress;
          },
        );

        // Mark as downloaded
        downloadingLessons.remove(lessonId);
        downloadedLessons.add(lessonId);
        lessonDownloadProgress.remove(lessonId);

        AppDialog.showSuccess(message: 'favorite_download_complete'.tr);

        // Refresh downloaded videos list
        await loadDownloadedVideos();
      } else {
        developer.log('❌ No video URL available for download', name: 'FavoriteController');
        downloadingLessons.remove(lessonId);
        lessonDownloadProgress.remove(lessonId);
        AppDialog.showError(message: 'favorite_no_video_available'.tr);
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to get video for download: ${error.displayMessage}', name: 'FavoriteController');
      downloadingLessons.remove(lessonId);
      lessonDownloadProgress.remove(lessonId);
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error downloading lesson: $e', name: 'FavoriteController');
      downloadingLessons.remove(lessonId);
      lessonDownloadProgress.remove(lessonId);
      AppDialog.showError(message: 'favorite_error_downloading'.tr);
    }
  }

  // Cancel ongoing download
  void cancelDownload(int lessonId) {
    if (downloadingLessons.contains(lessonId)) {
      developer.log('🛑 Cancelling download for lesson: $lessonId', name: 'FavoriteController');
      _downloadService.cancelDownload(lessonId);
      downloadingLessons.remove(lessonId);
      lessonDownloadProgress.remove(lessonId);
      AppDialog.showSuccess(message: 'favorite_download_cancelled'.tr);
    }
  }

  // Play downloaded video inline using media_kit
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
        AppDialog.showError(message: 'favorite_file_not_found'.tr);
        isLoadingVideo.value = false;
        return;
      }

      // Initialize media_kit player
      player = Player();
      videoController = VideoController(player!);

      // Listen for errors
      player!.stream.error.listen((error) {
        developer.log('❌ Video error: $error', name: 'FavoriteController');
      });

      // Listen for playing state
      player!.stream.playing.listen((playing) {
        if (playing) {
          videoLoadProgress.value = 1.0;
          isLoadingVideo.value = false;
        }
      });

      // Open and play video from local file
      await player!.open(Media(file.path));
      await player!.play();

      isVideoPlaying.value = true;
      videoLoadProgress.value = 1.0;
      developer.log('✅ Video player initialized successfully', name: 'FavoriteController');
    } catch (e) {
      developer.log('❌ Error playing video: $e', name: 'FavoriteController');
      AppDialog.showError(message: 'favorite_error_playing_video'.tr);
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
      videoController = null;
      await player?.dispose();
      player = null;
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
