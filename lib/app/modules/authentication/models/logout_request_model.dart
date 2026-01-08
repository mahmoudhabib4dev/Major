class LogoutRequestModel {
  final String phone;
  final String password;

  LogoutRequestModel({
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) {
    return LogoutRequestModel(
      phone: json['phone'] as String,
      password: json['password'] as String,
    );
  }
}
