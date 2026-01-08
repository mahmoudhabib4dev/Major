import 'pdf_resource_model.dart';

class PDFResourcesResponseModel {
  final bool success;
  final List<PDFResourceModel> data;

  PDFResourcesResponseModel({
    required this.success,
    required this.data,
  });

  factory PDFResourcesResponseModel.fromJson(Map<String, dynamic> json) {
    return PDFResourcesResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => PDFResourceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
