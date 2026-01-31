class VerifyOtpResponseModel {
  final String? message;
  final bool? success;
  final String? resetToken;
  final String? token; // Token returned for signup flow

  VerifyOtpResponseModel({
    this.message,
    this.success,
    this.resetToken,
    this.token,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      resetToken: json['reset_token'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'reset_token': resetToken,
      'token': token,
    };
  }
}
