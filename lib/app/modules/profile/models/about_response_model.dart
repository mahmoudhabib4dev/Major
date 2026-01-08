class AboutResponseModel {
  final String? description;

  AboutResponseModel({
    this.description,
  });

  factory AboutResponseModel.fromJson(Map<String, dynamic> json) {
    return AboutResponseModel(
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }
}
