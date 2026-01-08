class SetPasswordRequestModel {
  final String password;
  final String passwordConfirmation;

  SetPasswordRequestModel({
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  factory SetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordRequestModel(
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );
  }
}
