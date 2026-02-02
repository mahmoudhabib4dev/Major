import 'package:get/get.dart';

class NotificationModel {
  final int id;
  final int notificationId;
  final int type;
  final String title;
  final String body;
  final NotificationDataModel? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      notificationId: json['notification_id'] ?? 0,
      type: json['type'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'])
          : null,
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'type': type,
      'title': title,
      'body': body,
      'data': data?.toJson(),
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }

  /// Get formatted time string (e.g., "now", "5 minutes", "1 hour", etc.)
  String get formattedTime {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);

      if (difference.inMinutes < 1) {
        return 'time_now'.tr;
      } else if (difference.inMinutes < 60) {
        return 'time_minutes'.trParams({'count': '${difference.inMinutes}'});
      } else if (difference.inHours < 24) {
        return 'time_hours'.trParams({'count': '${difference.inHours}'});
      } else if (difference.inDays < 7) {
        return 'time_days'.trParams({'count': '${difference.inDays}'});
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'time_weeks'.trParams({'count': '$weeks'});
      } else {
        final months = (difference.inDays / 30).floor();
        return 'time_months'.trParams({'count': '$months'});
      }
    } catch (e) {
      return '';
    }
  }

  /// Create a copy with updated isRead status
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      notificationId: notificationId,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      readAt: readAt,
      createdAt: createdAt,
    );
  }
}

class NotificationDataModel {
  final String? type;
  final String? lessonId;
  final String? subjectId;
  final List<String>? placeholders;

  NotificationDataModel({
    this.type,
    this.lessonId,
    this.subjectId,
    this.placeholders,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      type: json['type'],
      lessonId: json['lesson_id']?.toString(),
      subjectId: json['subject_id']?.toString(),
      placeholders: json['placeholders'] != null
          ? List<String>.from(json['placeholders'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lesson_id': lessonId,
      'subject_id': subjectId,
      'placeholders': placeholders,
    };
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

class NotificationsResponseModel {
  final bool success;
  final List<NotificationModel> data;
  final PaginationModel pagination;

  NotificationsResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
