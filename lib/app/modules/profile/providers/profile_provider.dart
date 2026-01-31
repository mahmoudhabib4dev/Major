import 'dart:convert';
import 'dart:io';
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/about_response_model.dart';
import '../models/profile_data_response_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_password_request_model.dart';
import '../models/update_password_response_model.dart';
import '../models/subscription_details_model.dart';
import '../models/app_review_request_model.dart';
import '../models/app_review_response_model.dart';
import '../models/terms_response_model.dart';
import '../models/privacy_policy_response_model.dart';
import '../models/social_links_response_model.dart';
import '../models/leaderboard_response_model.dart';
import '../models/support_center_response_model.dart';
import '../models/complaint_response_model.dart';

class ProfileProvider {
  final ApiClient _apiClient = ApiClient();

  // Get About information
  Future<AboutResponseModel> getAbout() async {
    try {
      final response = await _apiClient.get(ApiConstants.about);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AboutResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load about information');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Profile data
  Future<ProfileDataResponseModel> getProfileData() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProfileDataResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  Future<ProfileDataResponseModel> updateProfile({
    required UpdateProfileRequestModel request,
  }) async {
    try {
      final fields = request.toFields();
      final files = <String, File>{};

      // Add picture file if provided
      if (request.picture != null && request.picture!.isNotEmpty) {
        files['picture'] = File(request.picture!);
      }

      final response = await _apiClient.postMultipart(
        ApiConstants.profile,
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProfileDataResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Password
  Future<UpdatePasswordResponseModel> updatePassword({
    required UpdatePasswordRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.updatePassword,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UpdatePasswordResponseModel.fromJson(jsonData);
      } else {
        // Parse error response
        final jsonData = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(jsonData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteAccount,
        body: {},
      );

      if (response.statusCode != 200) {
        // Parse error response if available
        try {
          final jsonData = jsonDecode(response.body);
          throw ApiErrorModel.fromJson(jsonData);
        } catch (e) {
          throw ApiErrorModel(
            message: 'فشل في إرسال طلب حذف الحساب',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Subscription Details
  Future<SubscriptionDetailsModel> getSubscriptionDetails() async {
    try {
      final response = await _apiClient.get(ApiConstants.profileSubscription);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SubscriptionDetailsModel.fromJson(jsonData);
      } else {
        // Parse error response
        try {
          final jsonData = jsonDecode(response.body);
          throw ApiErrorModel.fromJson(jsonData);
        } catch (e) {
          throw ApiErrorModel(
            message: 'فشل في تحميل تفاصيل الاشتراك',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Submit App Review
  Future<AppReviewResponseModel> submitReview({
    required AppReviewRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.appReview,
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return AppReviewResponseModel.fromJson(jsonData);
      } else {
        // Parse error response - handle both success:false and standard error format
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] != null) {
          throw ApiErrorModel(
            message: jsonData['message'] as String,
            statusCode: response.statusCode,
          );
        }
        throw ApiErrorModel.fromJson(jsonData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Submit Student Complaint
  Future<ComplaintResponseModel> submitComplaint({
    required int complaintTypeId,
    required String message,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.studentComplaints,
        body: {
          'complaint_type_id': complaintTypeId,
          'message': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return ComplaintResponseModel.fromJson(jsonData);
      } else {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] != null) {
          throw ApiErrorModel(
            message: jsonData['message'] as String,
            statusCode: response.statusCode,
          );
        }
        throw ApiErrorModel.fromJson(jsonData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Terms and Conditions
  Future<TermsResponseModel> getTerms() async {
    try {
      final response = await _apiClient.get(ApiConstants.terms);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TermsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load terms and conditions');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Privacy Policy
  Future<PrivacyPolicyResponseModel> getPrivacyPolicy() async {
    try {
      final response = await _apiClient.get(ApiConstants.policies);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PrivacyPolicyResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load privacy policy');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Social Links
  Future<SocialLinksResponseModel> getSocialLinks() async {
    try {
      final response = await _apiClient.get(ApiConstants.socialLinks);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SocialLinksResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load social links');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Leaderboard data
  Future<LeaderboardResponseModel> getLeaderboard() async {
    try {
      final response = await _apiClient.get(ApiConstants.leaderboard);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LeaderboardResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Leaderboard Privacy Status
  Future<bool> getLeaderboardPrivacy() async {
    try {
      final response = await _apiClient.get(ApiConstants.leaderboardPrivacy);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['hide_from_leaderboard'] ?? false;
      } else {
        throw Exception('Failed to load leaderboard privacy status');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Toggle Leaderboard Privacy
  Future<bool> toggleLeaderboardPrivacy() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardPrivacyToggle,
        body: {},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['hide_from_leaderboard'] ?? false;
      } else {
        throw Exception('Failed to toggle leaderboard privacy');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Support Center data
  Future<SupportCenterResponseModel> getSupportCenter() async {
    try {
      final response = await _apiClient.get(ApiConstants.supportCenter);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SupportCenterResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load support center');
      }
    } catch (e) {
      rethrow;
    }
  }
}

