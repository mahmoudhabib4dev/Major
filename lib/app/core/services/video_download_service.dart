import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../../data/models/downloaded_video_model.dart';
import 'hive_service.dart';
import 'storage_service.dart';

class VideoDownloadService {
  final Dio _dio = Dio();
  final HiveService _hiveService = HiveService();
  final StorageService _storageService = StorageService();

  // Singleton pattern
  static final VideoDownloadService _instance = VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  // Global download state (persists across page navigation)
  final RxMap<int, double> downloadProgress = <int, double>{}.obs;
  final RxSet<int> activeDownloads = <int>{}.obs;
  final Map<int, CancelToken> _cancelTokens = {};

  /// Check if a lesson is currently downloading
  bool isDownloading(int lessonId) => activeDownloads.contains(lessonId);

  /// Get download progress for a lesson (0.0 to 1.0)
  double getProgress(int lessonId) => downloadProgress[lessonId] ?? 0.0;

  /// Cancel an active download
  void cancelDownload(int lessonId) {
    developer.log('🔴 Cancel requested for lesson: $lessonId', name: 'VideoDownloadService');
    developer.log('   Active downloads: ${activeDownloads.toList()}', name: 'VideoDownloadService');

    final cancelToken = _cancelTokens[lessonId];
    if (cancelToken == null) {
      developer.log('   ❌ No cancel token found for lesson', name: 'VideoDownloadService');
      return;
    }

    if (cancelToken.isCancelled) {
      developer.log('   ⚠️ Token already cancelled', name: 'VideoDownloadService');
      return;
    }

    developer.log('🚫 Cancelling download for lesson: $lessonId', name: 'VideoDownloadService');
    cancelToken.cancel('User cancelled download');

    // Clean up state
    activeDownloads.remove(lessonId);
    downloadProgress.remove(lessonId);
    _cancelTokens.remove(lessonId);
  }

  /// Get current user ID (returns null for guest users)
  int? get _currentUserId => _storageService.currentUser?.id;

  /// Generate a unique key for storing downloads per user
  /// Format: "userId_lessonId" or "guest_lessonId" for guest users
  String _getDownloadKey(int lessonId) {
    final userId = _currentUserId;
    return userId != null ? '${userId}_$lessonId' : 'guest_$lessonId';
  }

  /// Check if a video is already downloaded for the current user
  Future<bool> isVideoDownloaded(int lessonId) async {
    try {
      final box = _hiveService.getDownloadsBox();
      final key = _getDownloadKey(lessonId);
      final downloadedVideo = box.get(key);

      if (downloadedVideo == null) return false;

      // Check if file still exists
      final file = File(downloadedVideo.localPath);
      if (!await file.exists()) {
        // File was deleted, remove from database
        await box.delete(key);
        return false;
      }

      return true;
    } catch (e) {
      developer.log('❌ Error checking if video is downloaded: $e', name: 'VideoDownloadService');
      return false;
    }
  }

  /// Get local path of downloaded video for the current user
  Future<String?> getLocalVideoPath(int lessonId) async {
    try {
      final box = _hiveService.getDownloadsBox();
      final key = _getDownloadKey(lessonId);
      final downloadedVideo = box.get(key);

      if (downloadedVideo == null) return null;

      // Verify file exists
      final file = File(downloadedVideo.localPath);
      if (!await file.exists()) {
        await box.delete(key);
        return null;
      }

      return downloadedVideo.localPath;
    } catch (e) {
      developer.log('❌ Error getting local video path: $e', name: 'VideoDownloadService');
      return null;
    }
  }

  /// Download a video (with global state tracking)
  Future<void> downloadVideo({
    required int lessonId,
    required String videoUrl,
    required String lessonName,
    Function(double)? onProgress,
  }) async {
    // If already downloading, skip
    if (activeDownloads.contains(lessonId)) {
      developer.log('⚠️ Already downloading lesson: $lessonId', name: 'VideoDownloadService');
      return;
    }

    try {
      developer.log('📥 Starting download for lesson: $lessonId', name: 'VideoDownloadService');

      // Track this download globally
      activeDownloads.add(lessonId);
      downloadProgress[lessonId] = 0.0;

      // Create cancel token
      final cancelToken = CancelToken();
      _cancelTokens[lessonId] = cancelToken;

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${appDir.path}/videos');

      // Create videos directory if it doesn't exist
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lesson_${lessonId}_$timestamp.mp4';
      final filePath = '${videosDir.path}/$fileName';

      // Download the video
      await _dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            // Update global state
            downloadProgress[lessonId] = progress;
            // Also call callback if provided
            onProgress?.call(progress);
            developer.log('📥 Download progress: ${(progress * 100).toStringAsFixed(0)}%', name: 'VideoDownloadService');
          }
        },
        cancelToken: cancelToken,
      );

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();

      // Save to Hive with user-specific key
      final downloadedVideo = DownloadedVideoModel(
        lessonId: lessonId,
        lessonName: lessonName,
        videoUrl: videoUrl,
        localPath: filePath,
        fileSize: fileSize,
        downloadDate: DateTime.now(),
        userId: _currentUserId,
      );

      final box = _hiveService.getDownloadsBox();
      final key = _getDownloadKey(lessonId);
      await box.put(key, downloadedVideo);

      developer.log('✅ Video downloaded successfully: $filePath', name: 'VideoDownloadService');
      developer.log('📊 File size: ${downloadedVideo.fileSizeFormatted}', name: 'VideoDownloadService');
    } catch (e) {
      developer.log('❌ Error downloading video: $e', name: 'VideoDownloadService');
      rethrow;
    } finally {
      // Always clean up global state
      activeDownloads.remove(lessonId);
      downloadProgress.remove(lessonId);
      _cancelTokens.remove(lessonId);
    }
  }

  /// Delete a downloaded video for the current user
  Future<void> deleteDownload(int lessonId) async {
    try {
      developer.log('🗑️ Deleting download for lesson: $lessonId', name: 'VideoDownloadService');

      final box = _hiveService.getDownloadsBox();
      final key = _getDownloadKey(lessonId);
      final downloadedVideo = box.get(key);

      if (downloadedVideo != null) {
        // Delete file from storage
        final file = File(downloadedVideo.localPath);
        if (await file.exists()) {
          await file.delete();
          developer.log('✅ File deleted: ${downloadedVideo.localPath}', name: 'VideoDownloadService');
        }

        // Remove from database
        await box.delete(key);
        developer.log('✅ Download record removed from database', name: 'VideoDownloadService');
      }
    } catch (e) {
      developer.log('❌ Error deleting download: $e', name: 'VideoDownloadService');
      rethrow;
    }
  }

  /// Get all downloaded videos for the current user
  Future<List<DownloadedVideoModel>> getAllDownloads() async {
    try {
      final box = _hiveService.getDownloadsBox();
      final downloads = box.values.toList();
      final currentUserId = _currentUserId;

      // Filter by current user and check if files still exist
      final validDownloads = <DownloadedVideoModel>[];
      for (final download in downloads) {
        // Check if this download belongs to the current user
        // For guest users (currentUserId == null), only show downloads with null userId
        final belongsToCurrentUser = (currentUserId == null && download.userId == null) ||
            (currentUserId != null && download.userId == currentUserId);

        if (!belongsToCurrentUser) continue;

        final file = File(download.localPath);
        if (await file.exists()) {
          validDownloads.add(download);
        } else {
          // File was deleted, remove from database
          final key = _getDownloadKey(download.lessonId);
          await box.delete(key);
        }
      }

      // Sort by download date (newest first)
      validDownloads.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

      return validDownloads;
    } catch (e) {
      developer.log('❌ Error getting all downloads: $e', name: 'VideoDownloadService');
      return [];
    }
  }

  /// Get total size of all downloaded videos
  Future<int> getTotalDownloadSize() async {
    try {
      final downloads = await getAllDownloads();
      int totalSize = 0;

      for (final download in downloads) {
        totalSize += download.fileSize;
      }

      return totalSize;
    } catch (e) {
      developer.log('❌ Error getting total download size: $e', name: 'VideoDownloadService');
      return 0;
    }
  }

  /// Format bytes to human-readable size
  String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Delete all downloads
  Future<void> deleteAllDownloads() async {
    try {
      developer.log('🗑️ Deleting all downloads', name: 'VideoDownloadService');

      final downloads = await getAllDownloads();

      for (final download in downloads) {
        await deleteDownload(download.lessonId);
      }

      developer.log('✅ All downloads deleted', name: 'VideoDownloadService');
    } catch (e) {
      developer.log('❌ Error deleting all downloads: $e', name: 'VideoDownloadService');
      rethrow;
    }
  }
}
