class OfferModel {
  final int id;
  final String title;
  final String image;
  final String linkType; // 'external' or 'internal'
  final String? link;
  final int? lessonId;

  OfferModel({
    required this.id,
    required this.title,
    required this.image,
    required this.linkType,
    this.link,
    this.lessonId,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
      linkType: json['link_type'] as String,
      link: json['link'] as String?,
      lessonId: json['lesson_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'link_type': linkType,
      'link': link,
      'lesson_id': lessonId,
    };
  }
}

class OffersResponseModel {
  final bool success;
  final List<OfferModel> data;

  OffersResponseModel({
    required this.success,
    required this.data,
  });

  factory OffersResponseModel.fromJson(Map<String, dynamic> json) {
    return OffersResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((offer) => offer.toJson()).toList(),
    };
  }
}
