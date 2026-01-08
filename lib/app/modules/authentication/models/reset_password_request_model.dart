class ResetPasswordRequestModel {
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestModel({
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequestModel(
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );
  }
}
