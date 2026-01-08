class LessonModel {
  final int id;
  final int? testId; // ID of the test associated with this lesson
  final String name;
  final String? order;
  final int isAlive;
  final String? pdfFile;
  final String? videoUrl;
  final bool? isFavorite;

  LessonModel({
    required this.id,
    this.testId,
    required this.name,
    this.order,
    this.isAlive = 0,
    this.pdfFile,
    this.videoUrl,
    this.isFavorite,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as int,
      testId: json['test_id'] as int?,
      name: json['name'] as String,
      order: json['order'] as String?,
      isAlive: json['is_alive'] as int? ?? 0,
      pdfFile: json['pdf_file'] as String?,
      videoUrl: json['video_url'] as String?,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'name': name,
      'order': order,
      'is_alive': isAlive,
      'pdf_file': pdfFile,
      'video_url': videoUrl,
      'is_favorite': isFavorite,
    };
  }
}
