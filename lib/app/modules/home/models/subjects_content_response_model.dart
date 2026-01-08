class SubjectsContentResponseModel {
  final String type;
  final List<ContentItem> items;

  SubjectsContentResponseModel({
    required this.type,
    required this.items,
  });

  factory SubjectsContentResponseModel.fromJson(Map<String, dynamic> json) {
    return SubjectsContentResponseModel(
      type: json['type'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ContentItem {
  final int id;
  final int subjectId;
  final String name;

  ContentItem({
    required this.id,
    required this.subjectId,
    required this.name,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
    };
  }
}
