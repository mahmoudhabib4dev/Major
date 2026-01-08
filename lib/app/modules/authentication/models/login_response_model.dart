class LoginResponseModel {
  final String? token;
  final Student? student;
  final String? message;

  LoginResponseModel({
    this.token,
    this.student,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String?,
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'student': student?.toJson(),
      'message': message,
    };
  }

  // Helper getters for backward compatibility
  String? get accessToken => token;
  Student? get user => student;
}

class Student {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? gender;
  final String? picture;
  final String? birthDate;
  final StageInfo? stage;
  final DivisionInfo? division;
  final String? status;
  final String? planStatus;
  final String? createdAt;

  Student({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.picture,
    this.birthDate,
    this.stage,
    this.division,
    this.status,
    this.planStatus,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      picture: json['picture'] as String?,
      birthDate: json['birth_date'] as String?,
      stage: json['stage'] != null ? StageInfo.fromJson(json['stage']) : null,
      division: json['division'] != null ? DivisionInfo.fromJson(json['division']) : null,
      status: json['status'] as String?,
      planStatus: json['plan_status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'picture': picture,
      'birth_date': birthDate,
      'stage': stage?.toJson(),
      'division': division?.toJson(),
      'status': status,
      'plan_status': planStatus,
      'created_at': createdAt,
    };
  }
}

class StageInfo {
  final int? id;
  final String? name;

  StageInfo({this.id, this.name});

  factory StageInfo.fromJson(Map<String, dynamic> json) {
    return StageInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DivisionInfo {
  final int? id;
  final String? name;

  DivisionInfo({this.id, this.name});

  factory DivisionInfo.fromJson(Map<String, dynamic> json) {
    return DivisionInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Backward compatibility alias
typedef User = Student;
