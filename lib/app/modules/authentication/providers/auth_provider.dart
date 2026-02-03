import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:maajor/app/modules/authentication/models/subscription_refresh_response_model.dart';
import '../../../core/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/api_error_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_request_model.dart';
import '../models/logout_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/register_options_model.dart';
import '../models/stage_model.dart';
import '../models/division_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/verify_otp_response_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/subscription_plans_response_model.dart';
import '../models/bank_accounts_response_model.dart';
import '../models/subscription_store_models.dart';
import '../models/apply_coupon_response_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/set_password_request_model.dart';
import '../models/set_password_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/verify_otp_forget_password_request_model.dart';
import '../models/verify_otp_forget_password_response_model.dart';
import '../models/forget_password_request_model.dart';
import '../models/forget_password_response_model.dart';

class AuthProvider {
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
          message: 'failed_to_process_response'.tr,
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
          message: 'unexpected_error'.tr,
          statusCode: statusCode,
        );
      }
    }
  }

  // Login
  Future<LoginResponseModel> login({
    required LoginRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => LoginResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<LogoutResponseModel> logout({
    required LogoutRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.logout,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => LogoutResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<RegisterResponseModel> register({
    required RegisterRequestModel request,
  }) async {
    try {
      // Prepare fields as strings
      final fields = <String, String>{
        'name': request.name,
        'email': request.email,
        'phone': request.phone,
        'birth_date': request.birthDate,
        'stage_id': request.stage,
        'division_id': request.division,
        'gender': request.gender,
        'terms': request.terms.toString(),
      };

      // Prepare files if picture exists
      final files = <String, File>{};
      if (request.picture != null && request.picture!.isNotEmpty) {
        files['picture'] = File(request.picture!);
      }

      final response = await _apiClient.postMultipart(
        ApiConstants.register,
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => RegisterResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get educational stages
  Future<List<StageModel>> getStages() async {
    try {
      final response = await _apiClient.get(ApiConstants.stages);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => StageModel.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        final error = ApiErrorModel.fromJson(errorData);
        throw ApiErrorModel(
          message: error.message,
          statusCode: response.statusCode,
          errors: error.errors,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get divisions for a specific stage
  Future<List<DivisionModel>> getDivisions(int stageId) async {
    try {
      final response = await _apiClient.get(ApiConstants.divisions(stageId));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => DivisionModel.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        final error = ApiErrorModel.fromJson(errorData);
        throw ApiErrorModel(
          message: error.message,
          statusCode: response.statusCode,
          errors: error.errors,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Forgot Password
  Future<ForgotPasswordResponseModel> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        body: {
          'email': email,
        },
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => ForgotPasswordResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<VerifyOtpResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => VerifyOtpResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String resetToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        body: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'reset_token': resetToken,
        },
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => ResetPasswordResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Subscription Plans
  Future<SubscriptionPlansResponseModel> getSubscriptionPlans() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscriptionPlans);

      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        // Decode the response body (could be array or object)
        final jsonData = jsonDecode(response.body);
        return SubscriptionPlansResponseModel.fromJson(jsonData);
      } else {
        // Error response
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic>) {
          throw ApiErrorModel.fromJson(jsonData);
        } else {
          throw ApiErrorModel(
            message: 'حدث خطأ غير متوقع',
            statusCode: statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Bank Accounts
  Future<BankAccountsResponseModel> getBankAccounts() async {
    try {
      final response = await _apiClient.get(ApiConstants.bankAccounts);

      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        // Decode the response body (could be array or object)
        final jsonData = jsonDecode(response.body);
        return BankAccountsResponseModel.fromJson(jsonData);
      } else {
        // Error response
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic>) {
          throw ApiErrorModel.fromJson(jsonData);
        } else {
          throw ApiErrorModel(
            message: 'حدث خطأ غير متوقع',
            statusCode: statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Apply Coupon
  Future<ApplyCouponResponse> applyCoupon({
    required int planId,
    required String couponCode,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.applyCoupon,
        body: {
          'plan_id': planId,
          'coupon_code': couponCode,
        },
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => ApplyCouponResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Store Subscription (Complete Payment)
  Future<SubscriptionStoreResponse> storeSubscription({
    required SubscriptionStoreRequest request,
  }) async {
    try {
      final fields = <String, String>{};
      final files = <String, File>{};

      // Add required fields
      if (request.planId != null) {
        fields['plan_id'] = request.planId.toString();
      }

      if (request.bankAccountId != null) {
        fields['bank_account_id'] = request.bankAccountId.toString();
      }

      // Add optional fields
      if (request.couponCode != null && request.couponCode!.isNotEmpty) {
        fields['coupon_code'] = request.couponCode!;
      }

      if (request.referenceNumber != null && request.referenceNumber!.isNotEmpty) {
        fields['reference_number'] = request.referenceNumber!;
      }

      if (request.paymentMethod != null && request.paymentMethod!.isNotEmpty) {
        fields['payment_type'] = request.paymentMethod!;
      }

      if (request.transactionId != null && request.transactionId!.isNotEmpty) {
        fields['transaction_id'] = request.transactionId!;
      }

      // Add calculate_only flag if true
      if (request.calculateOnly) {
        fields['calculate_only'] = 'true';
      }

      // Add file
      if (request.transferReceipt != null) {
        files['transfer_receipt'] = request.transferReceipt!;
      }

      final response = await _apiClient.postMultipart(
        ApiConstants.subscriptionStore,
        fields: fields,
        files: files,
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => SubscriptionStoreResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP (with password) - for registration flow
  Future<VerifyOtpResponseModel> verifyOtpWithPassword({
    required VerifyOtpRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => VerifyOtpResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Set Password (returns HTML on success)
  Future<SetPasswordResponseModel> setPassword({
    required SetPasswordRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.setPassword,
        body: request.toJson(),
      );

      final statusCode = response.statusCode;

      // Check if response is HTML (expected for success)
      final contentType = response.headers['content-type'] ?? '';
      final isHtml = contentType.contains('text/html');

      if (statusCode >= 200 && statusCode < 300) {
        // Success response - API returns HTML
        return SetPasswordResponseModel(
          message: 'password_set_successfully'.tr,
        );
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
            message: 'error_setting_password'.tr,
            statusCode: statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password (new API - returns HTML on success)
  Future<ResetPasswordResponseModel> resetPasswordNew({
    required ResetPasswordRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        body: request.toJson(),
      );

      final statusCode = response.statusCode;

      // Check if response is HTML (expected for success)
      final contentType = response.headers['content-type'] ?? '';
      final isHtml = contentType.contains('text/html');

      if (statusCode >= 200 && statusCode < 300) {
        // Success response - API returns HTML
        return ResetPasswordResponseModel(
          success: true,
          message: 'password_reset_successfully'.tr,
        );
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
            message: 'error_resetting_password'.tr,
            statusCode: statusCode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<ResendOtpResponseModel> resendOtp({
    required ResendOtpRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resendOtp,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => ResendOtpResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP for Forget Password
  Future<VerifyOtpForgetPasswordResponseModel> verifyOtpForgetPassword({
    required VerifyOtpForgetPasswordRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtpForgetPassword,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) =>
            VerifyOtpForgetPasswordResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Forget Password (new API)
  Future<ForgetPasswordResponseModel> forgetPasswordNew({
    required ForgetPasswordRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgetPassword,
        body: request.toJson(),
      );

      return _handleResponse(
        response: response,
        fromJson: (json) => ForgetPasswordResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Refresh Subscription Status
  Future<SubscriptionRefreshResponseModel> refreshSubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscriptionRefresh);

      return _handleResponse(
        response: response,
        fromJson: (json) => SubscriptionRefreshResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
