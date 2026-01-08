class SubjectsContentRequestModel {
  final List<int> subjectIds;
  final String type;

  SubjectsContentRequestModel({
    required this.subjectIds,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject_ids': subjectIds,
      'type': type,
    };
  }
}
