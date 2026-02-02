class ComplaintTypesResponseModel {
  final List<ComplaintType> complaintTypes;

  ComplaintTypesResponseModel({required this.complaintTypes});

  factory ComplaintTypesResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> typesJson = json['complaint_types'] ?? [];
    return ComplaintTypesResponseModel(
      complaintTypes: typesJson.map((e) => ComplaintType.fromJson(e)).toList(),
    );
  }
}

class ComplaintType {
  final int id;
  final String name;

  ComplaintType({required this.id, required this.name});

  factory ComplaintType.fromJson(Map<String, dynamic> json) {
    return ComplaintType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
