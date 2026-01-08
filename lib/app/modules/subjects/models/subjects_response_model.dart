import 'subject_model.dart';

class SubjectsResponseModel {
  final bool success;
  final List<SubjectModel> data;

  SubjectsResponseModel({
    required this.success,
    required this.data,
  });

  factory SubjectsResponseModel.fromJson(Map<String, dynamic> json) {
    return SubjectsResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((subject) => SubjectModel.fromJson(subject as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((subject) => subject.toJson()).toList(),
    };
  }
}
