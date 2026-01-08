class UpdateProfileRequestModel {
  final String name;
  final String? picture; // File path

  UpdateProfileRequestModel({
    required this.name,
    this.picture,
  });

  Map<String, String> toFields() {
    return {
      'name': name,
    };
  }
}
