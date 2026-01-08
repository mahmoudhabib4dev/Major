import 'lesson_model.dart';

class LessonsResponseModel {
  final bool status;
  final LessonsData data;

  LessonsResponseModel({
    required this.status,
    required this.data,
  });

  factory LessonsResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonsResponseModel(
      status: (json['status'] ?? json['success']) as bool? ?? false,
      data: LessonsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class LessonsData {
  final String unitName;
  final String teacherName;
  final String liveAt;
  final int lessonsCount;
  final List<LessonModel> lessons;

  LessonsData({
    required this.unitName,
    required this.teacherName,
    required this.liveAt,
    required this.lessonsCount,
    required this.lessons,
  });

  factory LessonsData.fromJson(Map<String, dynamic> json) {
    return LessonsData(
      unitName: json['unit_name'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      liveAt: json['live_at'] as String? ?? '',
      lessonsCount: json['lessons_count'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lesson) => LessonModel.fromJson(lesson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_name': unitName,
      'teacher_name': teacherName,
      'live_at': liveAt,
      'lessons_count': lessonsCount,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
