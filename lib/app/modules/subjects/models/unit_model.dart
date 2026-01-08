import 'lesson_model.dart';

class UnitModel {
  final int id;
  final String name;
  final String? image;
  final List<LessonModel> lessons;

  UnitModel({
    required this.id,
    required this.name,
    this.image,
    this.lessons = const [],
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lesson) => LessonModel.fromJson(lesson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
