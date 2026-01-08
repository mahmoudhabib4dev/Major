class VerifyOtpForgetPasswordResponseModel {
  final String? message;
  final String? token;

  VerifyOtpForgetPasswordResponseModel({
    this.message,
    this.token,
  });

  factory VerifyOtpForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpForgetPasswordResponseModel(
      message: json['message'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
    };
  }
}
