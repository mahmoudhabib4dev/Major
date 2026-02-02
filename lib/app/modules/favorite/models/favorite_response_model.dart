class FavoriteResponseModel {
  final bool? success;
  final List<FavoriteItem>? data;
  final String? message;

  FavoriteResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory FavoriteResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.where((e) => e is Map<String, dynamic> && (e as Map).isNotEmpty)
          .map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class FavoriteItem {
  final int? id;
  final String? type;
  final dynamic item;

  FavoriteItem({
    this.id,
    this.type,
    this.item,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as int?,
      type: json['type'] as String?,
      item: json['item'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'item': item,
    };
  }

  LessonItem? get asLesson {
    if (type == 'lesson' && item is Map<String, dynamic>) {
      return LessonItem.fromJson(item as Map<String, dynamic>);
    }
    return null;
  }

  SubjectItem? get asSubject {
    if (type == 'subject' && item is Map<String, dynamic>) {
      return SubjectItem.fromJson(item as Map<String, dynamic>);
    }
    return null;
  }

  bool get isFavorite {
    if (item is Map<String, dynamic>) {
      return (item as Map<String, dynamic>)['is_favorite'] == true;
    }
    return false;
  }
}

class LessonItem {
  final int? id;
  final int? testId;
  final String? name;
  final String? order;
  final bool? isAlive;
  final bool? isFavorite;

  LessonItem({
    this.id,
    this.testId,
    this.name,
    this.order,
    this.isAlive,
    this.isFavorite,
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    // Handle is_alive which can be bool or int from API
    bool? isAliveValue;
    final rawIsAlive = json['is_alive'];
    if (rawIsAlive is bool) {
      isAliveValue = rawIsAlive;
    } else if (rawIsAlive is int) {
      isAliveValue = rawIsAlive == 1;
    }

    return LessonItem(
      id: json['id'] as int?,
      testId: json['test_id'] as int?,
      name: json['name'] as String?,
      order: json['order'] as String?,
      isAlive: isAliveValue,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'name': name,
      'order': order,
      'is_alive': isAlive == true ? 1 : 0,
      'is_favorite': isFavorite,
    };
  }
}

class SubjectItem {
  final int? id;
  final String? name;
  final String? image;
  final bool? isFavorite;

  SubjectItem({
    this.id,
    this.name,
    this.image,
    this.isFavorite,
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: json['id'] as int?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'is_favorite': isFavorite,
    };
  }
}

class ToggleFavoriteResponse {
  final String? message;
  final bool? isFavorite;

  ToggleFavoriteResponse({
    this.message,
    this.isFavorite,
  });

  factory ToggleFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return ToggleFavoriteResponse(
      message: json['message'] as String?,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'is_favorite': isFavorite,
    };
  }
}
