import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/offer_model.dart';
import '../models/subjects_content_request_model.dart';
import '../models/subjects_content_response_model.dart';
import '../models/lesson_search_response_model.dart';

class HomeProvider {
  final ApiClient _apiClient = ApiClient();

  // Helper method to handle API response and errors
  T _handleResponse<T>({
    required http.Response response,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final statusCode = response.statusCode;

    // Check if response is HTML (error page)
    final contentType = response.headers['content-type'] ?? '';
    final isHtml = contentType.contains('text/html');

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
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
      // Error response
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

  // Get home offers/carousel items
  Future<OffersResponseModel> getOffers(int divisionId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.homeOffers(divisionId),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => OffersResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get subjects content (references, solved exercises, etc.)
  Future<SubjectsContentResponseModel> getSubjectsContent({
    required SubjectsContentRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.homeSubjectsContent,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => SubjectsContentResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Search for lessons
  Future<LessonSearchResponseModel> searchLessons({
    required String query,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.homeLessonsSearch(query),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => LessonSearchResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
