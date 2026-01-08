class ProfileDataResponseModel {
  final ProfileData? data;

  ProfileDataResponseModel({
    this.data,
  });

  factory ProfileDataResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataResponseModel(
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

class ProfileData {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? picture;
  final String? stage;
  final String? division;
  final int? cantUpdateStageOrDivision;

  ProfileData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.picture,
    this.stage,
    this.division,
    this.cantUpdateStageOrDivision,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      picture: json['picture'] as String?,
      stage: json['stage'] as String?,
      division: json['division'] as String?,
      cantUpdateStageOrDivision: json['cant_update_stage_or_division'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'picture': picture,
      'stage': stage,
      'division': division,
      'cant_update_stage_or_division': cantUpdateStageOrDivision,
    };
  }
}
