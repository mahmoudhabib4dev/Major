import 'unit_model.dart';

class UnitsResponseModel {
  final bool success;
  final List<UnitModel> data;

  UnitsResponseModel({
    required this.success,
    required this.data,
  });

  factory UnitsResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both regular and guest API response formats
    // Regular: {"success": true, "data": [...]}
    // Guest: {"success": true, "subject_info": {...}, "units": [...]}
    final unitsList = json['data'] ?? json['units'];

    return UnitsResponseModel(
      success: json['success'] as bool,
      data: (unitsList as List<dynamic>)
          .map((unit) => UnitModel.fromJson(unit as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((unit) => unit.toJson()).toList(),
    };
  }
}
