class ForgotPasswordResponseModel {
  final String? message;
  final bool? success;
  final String? email;

  ForgotPasswordResponseModel({
    this.message,
    this.success,
    this.email,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'email': email,
    };
  }
}
