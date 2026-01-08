import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? role;

  @HiveField(5)
  String? birthDate;

  @HiveField(6)
  String? educationalStage;

  @HiveField(7)
  String? branch;

  @HiveField(8)
  String? countryCode;

  @HiveField(9)
  String? profileImage;

  @HiveField(10)
  String? createdAt;

  @HiveField(11)
  int? divisionId;

  @HiveField(12)
  String? gender;

  @HiveField(13)
  String? status;

  @HiveField(14)
  String? planStatus;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.birthDate,
    this.educationalStage,
    this.branch,
    this.countryCode,
    this.profileImage,
    this.createdAt,
    this.divisionId,
    this.gender,
    this.status,
    this.planStatus,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      birthDate: json['birth_date'] as String?,
      educationalStage: json['educational_stage'] as String?,
      branch: json['branch'] as String?,
      countryCode: json['country_code'] as String?,
      // Support both 'picture' (from API) and 'profile_image' (legacy)
      profileImage: (json['picture'] ?? json['profile_image']) as String?,
      createdAt: json['created_at'] as String?,
      divisionId: json['division_id'] as int?,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      planStatus: json['plan_status'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'birth_date': birthDate,
      'educational_stage': educationalStage,
      'branch': branch,
      'country_code': countryCode,
      'profile_image': profileImage,
      'created_at': createdAt,
      'division_id': divisionId,
      'gender': gender,
      'status': status,
      'plan_status': planStatus,
    };
  }

  // Copy with
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? birthDate,
    String? educationalStage,
    String? branch,
    String? countryCode,
    String? profileImage,
    String? createdAt,
    int? divisionId,
    String? gender,
    String? status,
    String? planStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      birthDate: birthDate ?? this.birthDate,
      educationalStage: educationalStage ?? this.educationalStage,
      branch: branch ?? this.branch,
      countryCode: countryCode ?? this.countryCode,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      divisionId: divisionId ?? this.divisionId,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      planStatus: planStatus ?? this.planStatus,
    );
  }
}
