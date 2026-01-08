class ResendOtpRequestModel {
  final String email;

  ResendOtpRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory ResendOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpRequestModel(
      email: json['email'] as String,
    );
  }
}
