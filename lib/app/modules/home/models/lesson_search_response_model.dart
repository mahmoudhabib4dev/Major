class LessonSearchResponseModel {
  final String query;
  final List<LessonSearchItem> items;

  LessonSearchResponseModel({
    required this.query,
    required this.items,
  });

  factory LessonSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonSearchResponseModel(
      query: json['q'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => LessonSearchItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': query,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class LessonSearchItem {
  final int id;
  final String name;

  LessonSearchItem({
    required this.id,
    required this.name,
  });

  factory LessonSearchItem.fromJson(Map<String, dynamic> json) {
    return LessonSearchItem(
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
