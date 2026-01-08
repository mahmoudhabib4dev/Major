import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import '../../data/models/downloaded_video_model.dart';
import 'hive_service.dart';

class VideoDownloadService {
  final Dio _dio = Dio();
  final HiveService _hiveService = HiveService();

  // Singleton pattern
  static final VideoDownloadService _instance = VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  /// Check if a video is already downloaded
  Future<bool> isVideoDownloaded(int lessonId) async {
    try {
      final box = _hiveService.getDownloadsBox();
      final downloadedVideo = box.get(lessonId);

      if (downloadedVideo == null) return false;

      // Check if file still exists
      final file = File(downloadedVideo.localPath);
      if (!await file.exists()) {
        // File was deleted, remove from database
        await box.delete(lessonId);
        return false;
      }

      return true;
    } catch (e) {
      developer.log('❌ Error checking if video is downloaded: $e', name: 'VideoDownloadService');
      return false;
    }
  }

  /// Get local path of downloaded video
  Future<String?> getLocalVideoPath(int lessonId) async {
    try {
      final box = _hiveService.getDownloadsBox();
      final downloadedVideo = box.get(lessonId);

      if (downloadedVideo == null) return null;

      // Verify file exists
      final file = File(downloadedVideo.localPath);
      if (!await file.exists()) {
        await box.delete(lessonId);
        return null;
      }

      return downloadedVideo.localPath;
    } catch (e) {
      developer.log('❌ Error getting local video path: $e', name: 'VideoDownloadService');
      return null;
    }
  }

  /// Download a video
  Future<void> downloadVideo({
    required int lessonId,
    required String videoUrl,
    required String lessonName,
    required Function(double) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      developer.log('📥 Starting download for lesson: $lessonId', name: 'VideoDownloadService');

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
            onProgress(progress);
            developer.log('📥 Download progress: ${(progress * 100).toStringAsFixed(0)}%', name: 'VideoDownloadService');
          }
        },
        cancelToken: cancelToken,
      );

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();

      // Save to Hive
      final downloadedVideo = DownloadedVideoModel(
        lessonId: lessonId,
        lessonName: lessonName,
        videoUrl: videoUrl,
        localPath: filePath,
        fileSize: fileSize,
        downloadDate: DateTime.now(),
      );

      final box = _hiveService.getDownloadsBox();
      await box.put(lessonId, downloadedVideo);

      developer.log('✅ Video downloaded successfully: $filePath', name: 'VideoDownloadService');
      developer.log('📊 File size: ${downloadedVideo.fileSizeFormatted}', name: 'VideoDownloadService');
    } catch (e) {
      developer.log('❌ Error downloading video: $e', name: 'VideoDownloadService');
      rethrow;
    }
  }

  /// Delete a downloaded video
  Future<void> deleteDownload(int lessonId) async {
    try {
      developer.log('🗑️ Deleting download for lesson: $lessonId', name: 'VideoDownloadService');

      final box = _hiveService.getDownloadsBox();
      final downloadedVideo = box.get(lessonId);

      if (downloadedVideo != null) {
        // Delete file from storage
        final file = File(downloadedVideo.localPath);
        if (await file.exists()) {
          await file.delete();
          developer.log('✅ File deleted: ${downloadedVideo.localPath}', name: 'VideoDownloadService');
        }

        // Remove from database
        await box.delete(lessonId);
        developer.log('✅ Download record removed from database', name: 'VideoDownloadService');
      }
    } catch (e) {
      developer.log('❌ Error deleting download: $e', name: 'VideoDownloadService');
      rethrow;
    }
  }

  /// Get all downloaded videos
  Future<List<DownloadedVideoModel>> getAllDownloads() async {
    try {
      final box = _hiveService.getDownloadsBox();
      final downloads = box.values.toList();

      // Filter out videos whose files no longer exist
      final validDownloads = <DownloadedVideoModel>[];
      for (final download in downloads) {
        final file = File(download.localPath);
        if (await file.exists()) {
          validDownloads.add(download);
        } else {
          // File was deleted, remove from database
          await box.delete(download.lessonId);
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
