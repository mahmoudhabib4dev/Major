class UpdateProfileRequestModel {
  final String name;
  final String? picture; // File path
  final String? email;

  UpdateProfileRequestModel({
    required this.name,
    this.picture,
    this.email,
  });

  Map<String, String> toFields() {
    final fields = {
      'name': name,
    };

    if (email != null && email!.isNotEmpty) {
      fields['email'] = email!;
    }

    return fields;
  }
}
