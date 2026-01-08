class TermsResponseModel {
  final String description;

  TermsResponseModel({
    required this.description,
  });

  factory TermsResponseModel.fromJson(Map<String, dynamic> json) {
    return TermsResponseModel(
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }
}
