import 'self_test_question_model.dart';

class SelfTestResponseModel {
  final bool success;
  final int count;
  final List<SelfTestQuestionModel> data;

  SelfTestResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SelfTestResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((question) => SelfTestQuestionModel.fromJson(question as Map<String, dynamic>))
        .toList();

    return SelfTestResponseModel(
      success: json['success'] as bool,
      count: json['count'] as int? ?? dataList.length, // Use data length if count not provided
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((question) => question.toJson()).toList(),
    };
  }
}
