class SubjectModel {
  final int id;
  final int? testId; // ID of the test associated with this subject
  final String name;
  final String? image;
  final int studentsCounts;
  final int hoursCount;
  final int unitsCount;
  final bool? isFavorite;

  SubjectModel({
    required this.id,
    this.testId,
    required this.name,
    this.image,
    this.studentsCounts = 0,
    this.hoursCount = 0,
    this.unitsCount = 0,
    this.isFavorite,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      testId: json['test_id'] as int?,
      name: json['name'] as String,
      image: json['image'] as String?,
      studentsCounts: json['students_counts'] as int? ?? 0,
      hoursCount: json['hours_count'] as int? ?? 0,
      unitsCount: json['units_count'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'name': name,
      'image': image,
      'students_counts': studentsCounts,
      'hours_count': hoursCount,
      'units_count': unitsCount,
      'is_favorite': isFavorite,
    };
  }

  SubjectModel copyWith({
    int? id,
    int? testId,
    String? name,
    String? image,
    int? studentsCounts,
    int? hoursCount,
    int? unitsCount,
    bool? isFavorite,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      name: name ?? this.name,
      image: image ?? this.image,
      studentsCounts: studentsCounts ?? this.studentsCounts,
      hoursCount: hoursCount ?? this.hoursCount,
      unitsCount: unitsCount ?? this.unitsCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
