class UpdatePasswordResponseModel {
  final String? message;

  UpdatePasswordResponseModel({
    this.message,
  });

  factory UpdatePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponseModel(
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
