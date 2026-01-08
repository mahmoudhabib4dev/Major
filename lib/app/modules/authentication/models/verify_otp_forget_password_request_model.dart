class VerifyOtpForgetPasswordRequestModel {
  final String email;
  final String otp;

  VerifyOtpForgetPasswordRequestModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  factory VerifyOtpForgetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpForgetPasswordRequestModel(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );
  }
}
