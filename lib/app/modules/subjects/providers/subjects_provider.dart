import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/subjects_response_model.dart';
import '../models/units_response_model.dart';
import '../models/pdf_resources_response_model.dart';
import '../models/lessons_response_model.dart';
import '../models/lesson_video_response_model.dart';
import '../models/lesson_test_response_model.dart';
import '../models/lesson_summary_response_model.dart';

class SubjectsProvider {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = Get.find<StorageService>();

  // Check if user is in guest mode (not logged in OR logged in without active subscription)
  // Users without active subscription should use guest endpoints to browse content
  bool get _isGuestMode {
    if (!_storageService.isLoggedIn) {
      return true; // Actual guest
    }
    // Logged-in user without active subscription should also use guest endpoints
    final currentUser = _storageService.currentUser;
    return currentUser?.planStatus != 'active';
  }

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

  // Get subjects by division ID
  Future<SubjectsResponseModel> getSubjectsByDivision(int divisionId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestSubjects(divisionId)
          : ApiConstants.subjectsByDivision(divisionId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => SubjectsResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get units for a specific subject
  Future<UnitsResponseModel> getSubjectUnits(int subjectId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestUnits(subjectId)
          : ApiConstants.subjectUnits(subjectId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => UnitsResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get references for a specific subject
  Future<PDFResourcesResponseModel> getSubjectReferences(int subjectId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestReferences(subjectId)
          : ApiConstants.subjectReferences(subjectId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => PDFResourcesResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get solved exercises for a specific subject
  Future<PDFResourcesResponseModel> getSubjectSolvedExercises(int subjectId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestSolvedExercises(subjectId)
          : ApiConstants.subjectSolvedExercises(subjectId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => PDFResourcesResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get quizzes/exams for a specific subject
  Future<PDFResourcesResponseModel> getSubjectQuizzes(int subjectId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestExams(subjectId)
          : ApiConstants.subjectQuizzes(subjectId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => PDFResourcesResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get lessons for a specific unit
  Future<LessonsResponseModel> getUnitLessons(int unitId, {int? divisionId}) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final String url;
      if (_isGuestMode) {
        // For guest mode, get divisionId from storage if not provided
        // For logged-in users without subscription, use their division from user profile
        final division = divisionId ??
                        _storageService.currentUser?.divisionId ??
                        _storageService.guestDivisionId;
        if (division == null) {
          throw ApiErrorModel(
            message: 'Division ID is required for guest users',
            statusCode: 400,
          );
        }
        url = ApiConstants.guestLessons(unitId, division);
      } else {
        url = ApiConstants.unitLessons(unitId);
      }

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => LessonsResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get video URL for a specific lesson
  Future<LessonVideoResponseModel> getLessonVideo(int lessonId) async {
    try {
      // Use guest endpoint if not logged in or user has no active subscription
      final url = _isGuestMode
          ? ApiConstants.guestVideo(lessonId)
          : ApiConstants.lessonVideo(lessonId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => LessonVideoResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get test questions for a specific lesson
  Future<LessonTestResponseModel> getLessonTest(int lessonId) async {
    try {
      // Use guest endpoint if not logged in, otherwise use authenticated endpoint
      final url = _isGuestMode
          ? ApiConstants.guestTest(lessonId)
          : ApiConstants.lessonTest(lessonId);

      final response = await _apiClient.get(url);

      return _handleResponse(
        response: response,
        fromJson: (json) => LessonTestResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get summary PDF for a specific lesson
  Future<LessonSummaryResponseModel> getLessonSummary(int lessonId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.lessonSummary(lessonId),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => LessonSummaryResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
