class LessonSummaryResponseModel {
  final bool status;
  final LessonSummaryData data;

  LessonSummaryResponseModel({
    required this.status,
    required this.data,
  });

  factory LessonSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonSummaryResponseModel(
      status: json['status'] as bool? ?? false,
      data: LessonSummaryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class LessonSummaryData {
  final String lessonName;
  final String fileUrl;

  LessonSummaryData({
    required this.lessonName,
    required this.fileUrl,
  });

  factory LessonSummaryData.fromJson(Map<String, dynamic> json) {
    return LessonSummaryData(
      lessonName: json['lesson_name'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_name': lessonName,
      'file_url': fileUrl,
    };
  }
}
