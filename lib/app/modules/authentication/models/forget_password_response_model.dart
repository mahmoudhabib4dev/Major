class ForgetPasswordResponseModel {
  final String? message;

  ForgetPasswordResponseModel({
    this.message,
  });

  factory ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponseModel(
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
