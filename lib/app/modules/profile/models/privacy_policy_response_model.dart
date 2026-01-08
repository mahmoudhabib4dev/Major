class PrivacyPolicyResponseModel {
  final String description;

  PrivacyPolicyResponseModel({
    required this.description,
  });

  factory PrivacyPolicyResponseModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyResponseModel(
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }
}
