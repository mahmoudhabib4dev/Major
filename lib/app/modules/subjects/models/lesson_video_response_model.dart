class LessonVideoResponseModel {
  final bool status;
  final LessonVideoData data;

  LessonVideoResponseModel({
    required this.status,
    required this.data,
  });

  factory LessonVideoResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonVideoResponseModel(
      status: json['status'] as bool? ?? false,
      data: LessonVideoData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class LessonVideoData {
  final String lessonName;
  final String videoUrl;

  LessonVideoData({
    required this.lessonName,
    required this.videoUrl,
  });

  factory LessonVideoData.fromJson(Map<String, dynamic> json) {
    return LessonVideoData(
      lessonName: json['lesson_name'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_name': lessonName,
      'video_url': videoUrl,
    };
  }
}
