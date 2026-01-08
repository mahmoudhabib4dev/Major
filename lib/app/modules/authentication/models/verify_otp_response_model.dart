class VerifyOtpResponseModel {
  final String? message;
  final bool? success;
  final String? resetToken;

  VerifyOtpResponseModel({
    this.message,
    this.success,
    this.resetToken,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      resetToken: json['reset_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'reset_token': resetToken,
    };
  }
}
