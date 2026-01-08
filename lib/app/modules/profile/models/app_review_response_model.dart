class AppReviewResponseModel {
  final bool success;
  final ReviewData data;

  AppReviewResponseModel({
    required this.success,
    required this.data,
  });

  factory AppReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return AppReviewResponseModel(
      success: json['success'] as bool,
      data: ReviewData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ReviewData {
  final int id;
  final int rating;
  final String comment;

  ReviewData({
    required this.id,
    required this.rating,
    required this.comment,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }
}
