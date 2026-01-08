class RegisterRequestModel {
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String stage;
  final String division;
  final String gender;
  final bool terms;
  final String? picture;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.stage,
    required this.division,
    required this.gender,
    required this.terms,
    this.picture,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': birthDate,
      'stage_id': int.parse(stage),
      'division_id': int.parse(division),
      'terms': terms,
      'gender': gender,
    };

    // Add optional picture field
    if (picture != null && picture!.isNotEmpty) {
      json['picture'] = picture!;
    }

    return json;
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: json['birth_date'] as String,
      stage: json['stage'] as String,
      division: json['division'] as String,
      gender: json['gender'] as String,
      terms: json['terms'] as bool,
      picture: json['picture'] as String?,
    );
  }
}
