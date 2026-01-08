import 'login_response_model.dart';

class SetPasswordResponseModel {
  final String? message;
  final Student? student;

  SetPasswordResponseModel({
    this.message,
    this.student,
  });

  factory SetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordResponseModel(
      message: json['message'] as String?,
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'student': student?.toJson(),
    };
  }
}
