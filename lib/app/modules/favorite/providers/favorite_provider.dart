import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/favorite_response_model.dart';

class FavoriteProvider {
  final ApiClient _apiClient = ApiClient();

  T _handleResponse<T>({
    required http.Response response,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final statusCode = response.statusCode;
    final contentType = response.headers['content-type'] ?? '';
    final isHtml = contentType.contains('text/html');

    if (statusCode >= 200 && statusCode < 300) {
      if (isHtml) {
        throw ApiErrorModel.fromHtml(response.body, statusCode);
      }
      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return fromJson(jsonData);
      } catch (e) {
        throw ApiErrorModel(
          message: 'فشل في معالجة استجابة الخادم',
          statusCode: statusCode,
        );
      }
    } else {
      if (isHtml) {
        throw ApiErrorModel.fromHtml(response.body, statusCode);
      }
      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiErrorModel.fromJson(jsonData);
      } catch (e) {
        if (e is ApiErrorModel) rethrow;
        throw ApiErrorModel(
          message: 'حدث خطأ غير متوقع',
          statusCode: statusCode,
        );
      }
    }
  }

  Future<FavoriteResponseModel> getFavorites() async {
    try {
      final response = await _apiClient.get(ApiConstants.favorites);
      return _handleResponse(
        response: response,
        fromJson: (json) => FavoriteResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ToggleFavoriteResponse> toggleFavorite({
    required int id,
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.toggleFavorite}?id=$id&type=$type',
        body: {},
      );
      return _handleResponse(
        response: response,
        fromJson: (json) => ToggleFavoriteResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
