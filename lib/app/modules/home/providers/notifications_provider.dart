import 'dart:convert';
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/notification_model.dart';

class NotificationsProvider {
  final ApiClient _apiClient = ApiClient();

  /// Get user notifications with pagination
  Future<NotificationsResponseModel> getNotifications({int page = 1}) async {
    try {
      final url = '${ApiConstants.notifications}?page=$page';
      final response = await _apiClient.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return NotificationsResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw ApiErrorModel(
          message: 'غير مصرح',
          statusCode: 401,
        );
      } else {
        final jsonData = jsonDecode(response.body);
        throw ApiErrorModel(
          message: jsonData['message'] ?? 'فشل في تحميل الإشعارات',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(
        message: 'حدث خطأ أثناء تحميل الإشعارات',
        statusCode: 0,
      );
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final url = ApiConstants.markNotificationRead(notificationId);
      final response = await _apiClient.post(url, body: {});

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw ApiErrorModel(
          message: 'غير مصرح',
          statusCode: 401,
        );
      } else {
        return false;
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      return false;
    }
  }
}
