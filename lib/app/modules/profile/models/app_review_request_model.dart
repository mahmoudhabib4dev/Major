class AppReviewRequestModel {
  final int rating;
  final String comment;

  AppReviewRequestModel({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
