import 'package:hive/hive.dart';

part 'downloaded_video_model.g.dart';

@HiveType(typeId: 1)
class DownloadedVideoModel extends HiveObject {
  @HiveField(0)
  final int lessonId;

  @HiveField(1)
  final String lessonName;

  @HiveField(2)
  final String videoUrl;

  @HiveField(3)
  final String localPath;

  @HiveField(4)
  final int fileSize;

  @HiveField(5)
  final DateTime downloadDate;

  @HiveField(6)
  final String? thumbnailPath; // Optional: for downloads page

  DownloadedVideoModel({
    required this.lessonId,
    required this.lessonName,
    required this.videoUrl,
    required this.localPath,
    required this.fileSize,
    required this.downloadDate,
    this.thumbnailPath,
  });

  // Convert file size to readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonName': lessonName,
      'videoUrl': videoUrl,
      'localPath': localPath,
      'fileSize': fileSize,
      'downloadDate': downloadDate.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }

  // Create from JSON
  factory DownloadedVideoModel.fromJson(Map<String, dynamic> json) {
    return DownloadedVideoModel(
      lessonId: json['lessonId'] as int,
      lessonName: json['lessonName'] as String,
      videoUrl: json['videoUrl'] as String,
      localPath: json['localPath'] as String,
      fileSize: json['fileSize'] as int,
      downloadDate: DateTime.parse(json['downloadDate'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }
}
