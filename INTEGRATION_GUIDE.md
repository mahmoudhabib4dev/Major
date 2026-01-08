# Authentication Integration Guide

This guide shows how to integrate the Hive storage service and API provider into your authentication controller.

## 1. Add Dependencies to Controller

Add these to the top of `authentication_controller.dart`:

```dart
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../models/api_error_model.dart';
import '../../../core/api_client.dart';
```

## 2. Initialize Services in Controller

Add these properties to the `AuthenticationController` class:

```dart
class AuthenticationController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final AuthProvider authProvider = Get.find<AuthProvider>();

  // ... rest of your existing code
}
```

## 3. Update the `continueAsGuest` Method

Replace the existing method with:

```dart
void continueAsGuest() {
  // Mark onboarding as completed
  storageService.setOnboardingCompleted();
  Get.offAllNamed('/parent');
}
```

## 4. Update the `login` Method

Replace the TODO implementation with:

```dart
Future<void> login() async {
  // Clear previous errors
  phoneError.value = '';
  passwordError.value = '';

  // Validate all fields
  final isPhoneValid = validatePhone();
  final isPasswordValid = validatePassword();

  if (!isPhoneValid || !isPasswordValid) {
    return;
  }

  // Start loading
  isLoading.value = true;

  try {
    // Call login API
    final response = await authProvider.login(
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      countryCode: selectedCountryCode.value,
    );

    // Save auth token
    if (response.token != null) {
      await storageService.saveAuthToken(response.token!);
      ApiClient().setToken(response.token!);
    }

    // Save user data
    if (response.user != null) {
      final userModel = UserModel.fromJson(response.user!.toJson());
      await storageService.saveUser(userModel);
    }

    // Mark onboarding as completed
    await storageService.setOnboardingCompleted();

    // Show success dialog
    AppDialog.showSuccess(
      message: response.message ?? 'تم تسجيل الدخول بنجاح',
      buttonText: 'متابعة',
      onButtonPressed: () {
        Get.back();
        Get.offAllNamed('/parent');
      },
    );
  } on ApiErrorModel catch (error) {
    // Handle API errors (HTML or JSON)
    AppDialog.showError(message: error.displayMessage);
  } catch (e) {
    AppDialog.showError(message: 'حدث خطأ غير متوقع');
  } finally {
    isLoading.value = false;
  }
}
```

## 5. Update the `saveNewPassword` Method

For the sign-up flow, update the method to register the user:

```dart
Future<void> saveNewPassword() async {
  if (!isNewPasswordValid) return;

  isLoading.value = true;

  try {
    if (isSignUpMode.value) {
      // Sign up flow - call register API
      final response = await authProvider.register(
        name: usernameController.text.trim(),
        email: signUpEmailController.text.trim(),
        phone: signUpPhoneController.text.trim(),
        password: newPasswordController.text.trim(),
        countryCode: selectedCountryCode.value,
        birthDate: selectedBirthDate.value?.toIso8601String(),
        educationalStage: selectedEducationalStage.value,
        branch: selectedBranch.value,
      );

      // Save auth token
      if (response.token != null) {
        await storageService.saveAuthToken(response.token!);
        ApiClient().setToken(response.token!);
      }

      // Save user data
      if (response.user != null) {
        final userModel = UserModel.fromJson(response.user!.toJson());
        await storageService.saveUser(userModel);
      }

      // Mark onboarding as completed
      await storageService.setOnboardingCompleted();

      // Show success and navigate to subscription
      AppDialog.showSuccess(
        message: response.message ?? 'تم إنشاء الحساب بنجاح',
        buttonText: 'متابعة',
        onButtonPressed: () {
          Get.back();
          navigateToSubscriptionPage();
        },
      );
    } else {
      // Password reset flow - call reset password API
      final response = await authProvider.resetPassword(
        email: userEmail.value,
        password: newPasswordController.text.trim(),
        passwordConfirmation: confirmNewPasswordController.text.trim(),
        resetToken: resetToken.value,
      );

      AppDialog.showSuccess(
        message: response.message ?? 'تم تغيير كلمة المرور بنجاح',
        buttonText: 'تسجيل الدخول',
        onButtonPressed: () {
          Get.back();
          _resetNewPasswordState();
          showNewPasswordPage.value = false;
          showLoginPage.value = true;
        },
      );
    }
  } on ApiErrorModel catch (error) {
    AppDialog.showError(message: error.displayMessage);
  } catch (e) {
    AppDialog.showError(message: 'حدث خطأ أثناء حفظ كلمة المرور');
  } finally {
    isLoading.value = false;
  }
}
```

## 6. Add a Logout Method

Add this new method to handle logout:

```dart
Future<void> logout() async {
  isLoading.value = true;

  try {
    // Call logout API
    await authProvider.logout();

    // Clear local storage
    await storageService.logout();
    ApiClient().clearToken();

    // Navigate to authentication page
    Get.offAllNamed('/authentication');
  } on ApiErrorModel catch (error) {
    AppDialog.showError(message: error.displayMessage);
  } catch (e) {
    AppDialog.showError(message: 'حدث خطأ أثناء تسجيل الخروج');
  } finally {
    isLoading.value = false;
  }
}
```

## 7. Add Reset Token Variable

Add this variable to store the reset token from OTP verification:

```dart
final RxString resetToken = ''.obs;
```

## 8. Update the `sendOtpCode` Method

Replace the TODO implementation with:

```dart
Future<void> sendOtpCode() async {
  // Clear previous errors
  emailError.value = '';

  // Validate email
  if (!validateEmail()) {
    return;
  }

  // Start loading
  isLoading.value = true;

  try {
    // Call forgot password API
    final response = await authProvider.forgotPassword(
      email: emailController.text.trim(),
    );

    // Save email for display in restore password page
    userEmail.value = emailController.text.trim();

    // Navigate to restore password page
    showForgotPasswordPage.value = false;
    showRestorePasswordPage.value = true;

    // Start countdown timer
    startResendCountdown();

  } on ApiErrorModel catch (error) {
    AppDialog.showError(message: error.displayMessage);
  } catch (e) {
    AppDialog.showError(message: 'حدث خطأ أثناء إرسال الرمز');
  } finally {
    isLoading.value = false;
  }
}
```

## 9. Update the `verifyOtp` Method

Replace the TODO implementation with:

```dart
Future<void> verifyOtp() async {
  // Clear previous errors
  otpError.value = '';

  // Validate OTP
  if (!validateOtp()) {
    return;
  }

  // Start loading
  isLoading.value = true;

  try {
    final otp = '${otp1Controller.text}${otp2Controller.text}${otp3Controller.text}${otp4Controller.text}';

    // Call verify OTP API
    final response = await authProvider.verifyOtp(
      email: userEmail.value,
      otp: otp,
    );

    // Store reset token for password reset
    if (response.resetToken != null) {
      resetToken.value = response.resetToken!;
    }

    AppDialog.showSuccess(
      message: response.message ?? 'تم التحقق من الرمز بنجاح',
      buttonText: 'متابعة',
      onButtonPressed: () {
        Get.back();
        navigateToNewPasswordPage();
      },
    );

  } on ApiErrorModel catch (error) {
    otpError.value = error.displayMessage;
  } catch (e) {
    otpError.value = 'الرمز غير صحيح';
  } finally {
    isLoading.value = false;
  }
}
```

## 10. Update the `resendOtpCode` Method

Replace the TODO implementation with:

```dart
Future<void> resendOtpCode() async {
  if (!canResend.value) return;

  isLoading.value = true;

  try {
    // Call forgot password API again to resend OTP
    await authProvider.forgotPassword(
      email: userEmail.value,
    );

    AppDialog.showSuccess(message: 'تم إرسال الرمز مرة أخرى');

    // Restart countdown
    startResendCountdown();

  } on ApiErrorModel catch (error) {
    AppDialog.showError(message: error.displayMessage);
  } catch (e) {
    AppDialog.showError(message: 'حدث خطأ أثناء إعادة إرسال الرمز');
  } finally {
    isLoading.value = false;
  }
}
```

---

## Summary

The integration provides:

✅ **First-time onboarding detection** - Only shows onboarding once
✅ **Persistent authentication** - User stays logged in across app restarts
✅ **Secure token storage** - Auth tokens stored in Hive
✅ **User data persistence** - User profile stored locally
✅ **Professional error handling** - Handles both HTML and JSON errors
✅ **Clean logout** - Properly clears all user data

The app will now:
- Show onboarding on first launch
- Navigate to main app if user is logged in
- Navigate to authentication if user is not logged in
