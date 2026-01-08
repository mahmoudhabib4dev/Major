import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/api_client.dart';
import '../../../routes/app_pages.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/models/api_error_model.dart';
import '../../authentication/models/logout_request_model.dart';
import '../../authentication/controllers/authentication_controller.dart';
import '../../authentication/views/subscription_view.dart';
import '../../authentication/bindings/authentication_binding.dart';
import '../widgets/language_bottom_sheet.dart';
import '../widgets/ticket_type_bottom_sheet.dart';
import '../providers/profile_provider.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_password_request_model.dart';
import '../models/app_review_request_model.dart';
import '../models/leaderboard_response_model.dart';
import '../models/support_center_response_model.dart';

class ProfileController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  AuthProvider get authProvider => Get.find<AuthProvider>();
  final ProfileProvider profileProvider = ProfileProvider();

  final ApiClient apiClient = ApiClient();

  // About information
  final aboutDescription = ''.obs;
  final isLoadingAbout = false.obs;

  // Terms and Privacy Policy
  final termsDescription = ''.obs;
  final isLoadingTerms = false.obs;
  final privacyPolicyDescription = ''.obs;
  final isLoadingPrivacyPolicy = false.obs;

  // Social Links
  final socialLinks = <dynamic>[].obs;
  final isLoadingSocialLinks = false.obs;

  // Leaderboard
  final Rx<LeaderboardResponseModel?> leaderboard = Rx<LeaderboardResponseModel?>(null);
  final isLoadingLeaderboard = false.obs;
  final hideFromLeaderboard = false.obs;

  // Support Center
  final Rx<SupportCenterResponseModel?> supportCenter = Rx<SupportCenterResponseModel?>(null);
  final isLoadingSupportCenter = false.obs;
  final RxList<Faq> faqs = <Faq>[].obs;
  final mobileNumber = ''.obs;
  final whatsappNumber = ''.obs;

  // Profile data
  final isLoadingProfile = false.obs;
  final canUpdateStageOrDivision = true.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedProfileImage = Rx<File?>(null);

  // ==================== User Data ====================
  final userName = 'صلاح سالم'.obs;
  final userImageUrl = ''.obs;
  final hideInChallenges = false.obs;

  // ==================== Edit Account ====================
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final selectedCountryCode = '+222'.obs;
  final selectedBirthday = Rxn<DateTime>();
  final selectedEducationalStage = Rxn<String>();
  final selectedDivision = Rxn<String>();

  // Error states
  final nameError = ''.obs;
  final emailError = ''.obs;
  final phoneError = ''.obs;

  // Countries list
  final List<Map<String, String>> countries = [
    {'name': 'موريتانيا', 'code': '+222', 'flag': '🇲🇷'},
  ];

  // Educational stages and divisions options
  final List<String> educationalStages = [
    'المرحلة الابتدائية',
    'المرحلة المتوسطة',
    'المرحلة الثانوية',
    'المرحلة الجامعية',
  ];

  final List<String> divisions = [
    'علمي',
    'أدبي',
    'تقني',
  ];

  String getCountryFlag(String code) {
    final country = countries.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'flag': '🇲🇷'},
    );
    return country['flag']!;
  }

  void updateCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  // ==================== Edit Password ====================
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // ==================== Delete Account ====================
  final deleteReasonController = TextEditingController();

  // ==================== Help ====================
  final expandedFaqIndex = (-1).obs;
  final List<Map<String, String>> faqItems = [
    {
      'question': 'كيف يمكنني تغيير كلمة المرور؟',
      'answer': 'يمكنك تغيير كلمة المرور من خلال الذهاب إلى الملف الشخصي ثم الضغط على تعديل كلمة المرور.',
    },
    {
      'question': 'كيف يمكنني التواصل مع الدعم؟',
      'answer': 'يمكنك التواصل معنا عبر البريد الإلكتروني أو الهاتف أو واتساب المتوفرين في أسفل هذه الصفحة.',
    },
    {
      'question': 'كيف يمكنني تحديث بيانات حسابي؟',
      'answer': 'يمكنك تحديث بياناتك من خلال الذهاب إلى الملف الشخصي ثم الضغط على تعديل الحساب.',
    },
    {
      'question': 'هل التطبيق مجاني؟',
      'answer': 'نعم، التطبيق مجاني بالكامل مع إمكانية الاشتراك في الباقات المميزة للحصول على مزايا إضافية.',
    },
    {
      'question': 'كيف يمكنني حذف حسابي؟',
      'answer': 'يمكنك حذف حسابك من خلال الذهاب إلى الملف الشخصي ثم الضغط على حذف الحساب في أسفل الصفحة.',
    },
  ];

  // ==================== Language ====================
  final selectedLanguage = 'ar'.obs;
  final List<Map<String, String>> languages = [
    {'code': 'ar', 'nameKey': 'arabic'},
    {'code': 'en', 'nameKey': 'english'},
    {'code': 'fr', 'nameKey': 'french'},
  ];

  void selectLanguage(String code) {
    selectedLanguage.value = code;
  }

  void confirmLanguageSelection() async {
    // Save locale to storage
    await storageService.saveLocale(selectedLanguage.value);

    // Update app locale
    Get.updateLocale(Locale(selectedLanguage.value));

    // Close bottom sheet
    Get.back();

    // Show success message
    AppDialog.showSuccess(message: 'language_changed_success'.tr);
  }

  // ==================== About ====================
  final appVersion = '1.0.0'.obs;

  Future<void> loadAboutInfo() async {
    try {
      isLoadingAbout.value = true;
      final response = await profileProvider.getAbout();
      aboutDescription.value = response.description ?? '';
      developer.log('✅ About info loaded: ${response.description}', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Error loading about info: $e', name: 'ProfileController');
      AppDialog.showError(message: 'فشل في تحميل معلومات التطبيق');
    } finally {
      isLoadingAbout.value = false;
    }
  }

  Future<void> loadTerms() async {
    try {
      isLoadingTerms.value = true;
      final response = await profileProvider.getTerms();
      termsDescription.value = response.description;
      developer.log('✅ Terms loaded', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Error loading terms: $e', name: 'ProfileController');
      AppDialog.showError(message: 'فشل في تحميل الشروط والأحكام');
    } finally {
      isLoadingTerms.value = false;
    }
  }

  Future<void> loadPrivacyPolicy() async {
    try {
      isLoadingPrivacyPolicy.value = true;
      final response = await profileProvider.getPrivacyPolicy();
      privacyPolicyDescription.value = response.description;
      developer.log('✅ Privacy policy loaded', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Error loading privacy policy: $e', name: 'ProfileController');
      AppDialog.showError(message: 'فشل في تحميل سياسة الخصوصية');
    } finally {
      isLoadingPrivacyPolicy.value = false;
    }
  }

  Future<void> loadSocialLinks() async {
    try {
      isLoadingSocialLinks.value = true;
      final response = await profileProvider.getSocialLinks();
      socialLinks.value = response.socialLinks;
      developer.log('✅ Social links loaded: ${response.socialLinks.length} links', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Error loading social links: $e', name: 'ProfileController');
      // Don't show error dialog for social links, just fail silently
    } finally {
      isLoadingSocialLinks.value = false;
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoadingLeaderboard.value = true;
      final response = await profileProvider.getLeaderboard();
      leaderboard.value = response;
      developer.log('✅ Leaderboard loaded successfully - Week: ${response.weekKey}, Participants: ${response.participants}', name: 'ProfileController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load leaderboard: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading leaderboard: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل لوحة المتصدرين');
    } finally {
      isLoadingLeaderboard.value = false;
    }
  }

  Future<void> loadLeaderboardPrivacy() async {
    try {
      final isHidden = await profileProvider.getLeaderboardPrivacy();
      hideFromLeaderboard.value = isHidden;
      hideInChallenges.value = isHidden;
      developer.log('✅ Leaderboard privacy loaded: ${isHidden ? "Hidden" : "Visible"}', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Error loading leaderboard privacy: $e', name: 'ProfileController');
      // Don't show error dialog, just fail silently
    }
  }

  Future<void> toggleLeaderboardPrivacy() async {
    try {
      final newValue = await profileProvider.toggleLeaderboardPrivacy();
      hideFromLeaderboard.value = newValue;
      developer.log('✅ Leaderboard privacy toggled: ${newValue ? "Hidden" : "Visible"}', name: 'ProfileController');
      AppDialog.showSuccess(
        message: newValue
            ? 'تم إخفاء بياناتك من لوحة المتصدرين'
            : 'تم إظهار بياناتك في لوحة المتصدرين',
      );
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to toggle leaderboard privacy: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error toggling leaderboard privacy: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحديث إعدادات الخصوصية');
    }
  }

  Future<void> loadSupportCenter() async {
    try {
      isLoadingSupportCenter.value = true;
      final response = await profileProvider.getSupportCenter();
      supportCenter.value = response;
      faqs.value = response.faqs;
      mobileNumber.value = response.supportContacts.mobile;
      whatsappNumber.value = response.supportContacts.whatsapp;
      developer.log('✅ Support center loaded: ${response.faqs.length} FAQs', name: 'ProfileController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load support center: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading support center: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل مركز الدعم');
    } finally {
      isLoadingSupportCenter.value = false;
    }
  }

  // Open social media link - tries to open app first, falls back to browser
  Future<void> openSocialLink(String platform, String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try to launch with app if available, otherwise use browser
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Try to open in app
        );
        developer.log('✅ Opened $platform: $url', name: 'ProfileController');
      } else {
        developer.log('❌ Cannot launch $platform URL: $url', name: 'ProfileController');
        AppDialog.showError(message: 'لا يمكن فتح الرابط');
      }
    } catch (e) {
      developer.log('❌ Error opening $platform: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء فتح الرابط');
    }
  }

  // Get icon asset for social platform
  String? getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return AppImages.icon71;
      case 'telegram':
        return AppImages.icon72;
      case 'instagram':
        return AppImages.icon73;
      case 'facebook':
        return AppImages.icon74;
      case 'youtube':
        return AppImages.icon75;
      case 'tiktok':
        return AppImages.icon76;
      case 'snapchat':
        return null; // Icon not available yet
      case 'twitter':
      case 'x':
        return null; // Icon not available yet
      default:
        return null; // Return null for unknown platforms
    }
  }

  Future<void> loadProfileData() async {
    try {
      isLoadingProfile.value = true;
      final response = await profileProvider.getProfileData();

      if (response.data != null) {
        final data = response.data!;

        // Update form fields
        nameController.text = data.name ?? '';
        emailController.text = data.email ?? '';

        // Update phone - remove country code from the beginning
        String phoneValue = data.phone ?? '';
        if (phoneValue.startsWith('+222')) {
          phoneValue = phoneValue.substring(4); // Remove "+222"
        } else if (phoneValue.startsWith('+')) {
          phoneValue = phoneValue.substring(1); // Fallback: remove just "+"
        }
        phoneController.text = phoneValue;

        // Update user image
        userImageUrl.value = data.picture ?? '';

        // Update stage and division
        selectedEducationalStage.value = data.stage;
        selectedDivision.value = data.division;

        // Update restriction flag
        canUpdateStageOrDivision.value = data.cantUpdateStageOrDivision == 0;

        developer.log('✅ Profile data loaded: ${data.toJson()}', name: 'ProfileController');
      }
    } catch (e) {
      developer.log('❌ Error loading profile data: $e', name: 'ProfileController');
      AppDialog.showError(message: 'فشل في تحميل بيانات الملف الشخصي');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // ==================== Loading States ====================
  final isLoading = false.obs;

  // ==================== Guest Mode ====================
  bool get isGuest {
    // User is a guest if not logged in or has no auth token
    return !storageService.isLoggedIn || storageService.authToken == null;
  }

  // Check if user has active subscription
  bool get hasActiveSubscription {
    if (isGuest) return false;
    final currentUser = storageService.currentUser;
    return currentUser?.planStatus == 'active';
  }

  void navigateToLogin() async {
    // Clear guest data before navigating to login
    await storageService.clearGuestData();
    Get.offAllNamed(Routes.AUTHENTICATION);
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadLanguage();
    // Load leaderboard privacy status for logged-in users
    if (!isGuest) {
      loadLeaderboardPrivacy();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    deleteReasonController.dispose();
    super.onClose();
  }

  // ==================== Profile Methods ====================
  void _loadUserData() {
    // Load user data from Hive storage
    final user = storageService.currentUser;
    if (user != null) {
      // Load name
      userName.value = user.name ?? 'User';
      nameController.text = user.name ?? '';

      // Load email
      emailController.text = user.email ?? '';

      // Load country code
      if (user.countryCode != null) {
        selectedCountryCode.value = user.countryCode!;
      }

      // Load phone - remove country code from the value
      if (user.phone != null) {
        String phoneValue = user.phone!;
        // Remove country code from the beginning
        if (phoneValue.startsWith('+222')) {
          phoneValue = phoneValue.substring(4); // Remove "+222"
        } else if (phoneValue.startsWith('+')) {
          phoneValue = phoneValue.substring(1); // Fallback: remove just "+"
        }
        phoneController.text = phoneValue;
      }

      // Load birth date
      if (user.birthDate != null) {
        try {
          selectedBirthday.value = DateTime.parse(user.birthDate!);
        } catch (e) {
          developer.log('Error parsing birth date: $e', name: 'ProfileController');
        }
      }

      // Load educational stage
      selectedEducationalStage.value = user.educationalStage;

      // Load division/branch
      selectedDivision.value = user.branch;

      // Load profile image
      userImageUrl.value = user.profileImage ?? '';

      developer.log('User data loaded from Hive: ${user.toJson()}', name: 'ProfileController');
    } else {
      developer.log('No user data found in Hive', name: 'ProfileController');
    }
  }

  void _loadLanguage() {
    // Load saved language or default to Arabic
    final savedLocale = storageService.locale ?? 'ar';
    selectedLanguage.value = savedLocale;
  }

  void toggleHideInChallenges(bool value) async {
    // Update local value immediately for UI responsiveness
    hideInChallenges.value = value;

    // Call API to persist the change
    try {
      final newValue = await profileProvider.toggleLeaderboardPrivacy();
      hideInChallenges.value = newValue;
      hideFromLeaderboard.value = newValue;
      developer.log('✅ Leaderboard privacy toggled: ${newValue ? "Hidden" : "Visible"}', name: 'ProfileController');
    } on ApiErrorModel catch (error) {
      // Revert on error
      hideInChallenges.value = !value;
      developer.log('❌ Failed to toggle leaderboard privacy: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      // Revert on error
      hideInChallenges.value = !value;
      developer.log('❌ Unexpected error toggling leaderboard privacy: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحديث إعدادات الخصوصية');
    }
  }

  // ==================== Navigation Methods ====================
  void navigateToEditAccount() async {
    await loadProfileData();
    Get.toNamed(Routes.EDIT_ACCOUNT);
  }

  void navigateToEditPassword() {
    Get.toNamed(Routes.EDIT_PASSWORD);
  }

  void navigateToSubscription() {
    // Ensure AuthenticationController is available
    AuthenticationBinding().dependencies();
    Get.to(() => const SubscriptionView());
  }

  void navigateToLanguage() {
    LanguageBottomSheet.show(Get.context!);
  }

  void navigateToHelp() {
    Get.toNamed(Routes.HELP);
  }

  void navigateToAbout() {
    Get.toNamed(Routes.ABOUT);
  }

  // ==================== Edit Account Methods ====================
  void changeProfilePicture() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedProfileImage.value = File(pickedFile.path);
        userImageUrl.value = pickedFile.path;
        developer.log('✅ Image selected: ${pickedFile.path}', name: 'ProfileController');
      }
    } catch (e) {
      developer.log('❌ Error picking image: $e', name: 'ProfileController');
      AppDialog.showError(message: 'فشل في اختيار الصورة');
    }
  }

  void selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthday.value ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      selectedBirthday.value = picked;
    }
  }

  void selectEducationalStage(String? value) {
    selectedEducationalStage.value = value;
  }

  void selectDivision(String? value) {
    selectedDivision.value = value;
  }

  String formatBirthday(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void saveAccountChanges() async {
    if (_validateAccountForm()) {
      try {
        isLoading.value = true;

        final request = UpdateProfileRequestModel(
          name: nameController.text,
          picture: selectedProfileImage.value?.path, // Only send if new local file selected
        );

        final response = await profileProvider.updateProfile(request: request);

        if (response.data != null) {
          final data = response.data!;

          // Update local data
          userName.value = data.name ?? '';
          nameController.text = data.name ?? '';
          userImageUrl.value = data.picture ?? '';

          // Update stored user data in Hive
          final user = storageService.currentUser;
          if (user != null) {
            user.name = data.name;
            user.profileImage = data.picture;
            await storageService.saveUser(user);
          }

          developer.log('✅ Profile updated successfully', name: 'ProfileController');

          // Reload user data to update UI
          _loadUserData();

          Get.back();
          AppDialog.showSuccess(message: 'account_changes_saved'.tr);
        }
      } catch (e) {
        developer.log('❌ Error updating profile: $e', name: 'ProfileController');
        AppDialog.showError(message: 'فشل في حفظ التغييرات');
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool _validateAccountForm() {
    if (nameController.text.isEmpty) {
      AppDialog.showError(message: 'please_enter_name'.tr);
      return false;
    }
    if (emailController.text.isEmpty) {
      AppDialog.showError(message: 'please_enter_email'.tr);
      return false;
    }
    if (phoneController.text.isEmpty) {
      AppDialog.showError(message: 'please_enter_phone'.tr);
      return false;
    }
    return true;
  }

  // ==================== Edit Password Methods ====================
  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.value = !obscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void navigateToForgotPassword() {
    // Navigate to authentication page
    Get.toNamed(Routes.AUTHENTICATION);

    // Get the AuthenticationController and trigger forgot password flow
    try {
      final authController = Get.find<AuthenticationController>();
      authController.forgotPassword();
    } catch (e) {
      developer.log('Could not find AuthenticationController: $e');
    }
  }

  void savePassword() async {
    if (_validatePasswordForm()) {
      try {
        isLoading.value = true;

        final request = UpdatePasswordRequestModel(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
          newPasswordConfirmation: confirmPasswordController.text,
        );

        final response = await profileProvider.updatePassword(request: request);

        // Clear password fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Get.back();
        AppDialog.showSuccess(
          message: response.message ?? 'password_changed_success'.tr,
        );
      } catch (e) {
        developer.log('Error updating password: $e');

        // Show specific error message from API
        String errorMessage = 'failed_to_update_password'.tr;
        if (e is ApiErrorModel) {
          errorMessage = e.message ?? e.displayMessage;
        }

        AppDialog.showError(message: errorMessage);
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool _validatePasswordForm() {
    if (currentPasswordController.text.isEmpty) {
      AppDialog.showError(message: 'please_enter_current_password'.tr);
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      AppDialog.showError(message: 'please_enter_new_password'.tr);
      return false;
    }
    if (newPasswordController.text.length < 6) {
      AppDialog.showError(message: 'password_min_length'.tr);
      return false;
    }
    if (confirmPasswordController.text != newPasswordController.text) {
      AppDialog.showError(message: 'passwords_not_match'.tr);
      return false;
    }
    return true;
  }

  // ==================== Help Methods ====================
  void sendEmail() {
    // TODO: Add url_launcher dependency and implement email launch
  }

  void makeCall() {
    // TODO: Add url_launcher dependency and implement phone call
  }

  void openWhatsApp() {
    // TODO: Add url_launcher dependency and implement WhatsApp
  }

  // ==================== About Methods ====================
  void openFacebook() {
    // TODO: Implement Facebook link
  }

  void openInstagram() {
    // TODO: Implement Instagram link
  }

  void openTwitter() {
    // TODO: Implement Twitter link
  }

  void openTelegram() {
    // TODO: Implement Telegram link
  }

  void openYouTube() {
    // TODO: Implement YouTube link
  }

  void openTikTok() {
    // TODO: Implement TikTok link
  }

  // ==================== App Actions ====================
  void rateApp() {
    showRatingDialog(Get.context!);
  }

  void shareApp() {
    // TODO: Share app link
  }

  void logout() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Icon circle
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.icon61,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'logout_confirm_title'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000D47),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'logout_confirm_message'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF000D47), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000D47),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logout button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await _performLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000D47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'logout'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _performLogout() async {
    isLoading.value = true;

    try {
      developer.log('🚪 Performing logout...', name: 'ProfileController');

      // Get user data from storage
      final user = storageService.currentUser;
      final phone = user?.phone ?? '';
      final password = storageService.userPassword ?? '';

      // Create logout request with saved credentials
      final logoutRequest = LogoutRequestModel(
        phone: phone,
        password: password,
      );

      // Call logout API - auth token is automatically included in headers by ApiClient
      await authProvider.logout(request: logoutRequest);

      developer.log('✅ Logout API call successful', name: 'ProfileController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Logout error: ${error.displayMessage}', name: 'ProfileController');
    } catch (e) {
      developer.log('❌ Unexpected logout error: $e', name: 'ProfileController');
    } finally {
      // Clear local data and log out regardless of API response
      await storageService.logout();
      apiClient.clearToken();

      developer.log('🗑️ Local data cleared', name: 'ProfileController');

      isLoading.value = false;

      // Navigate to authentication screen - GetX will handle controller cleanup
      Get.offAllNamed(Routes.AUTHENTICATION);

      // Show success message after a short delay to ensure navigation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        AppDialog.showSuccess(message: 'logout_success'.tr);
      });
    }
  }

  void deleteAccount() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Icon circle
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.icon60,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'delete_account_confirm_title'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000D47),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'delete_account_confirm_message'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE23535), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE23535),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close confirmation dialog
                          _showDeleteReasonDialog(); // Show reason dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE23535),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'delete_account'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showDeleteReasonDialog() {
    deleteReasonController.clear(); // Clear any previous input

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'delete_reason_title'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000D47),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'delete_reason_subtitle'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Reason text field
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: TextField(
                  controller: deleteReasonController,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'delete_reason_hint'.tr,
                    hintStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          deleteReasonController.clear();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Submit button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _submitDeleteRequest(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE23535),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'submit'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _submitDeleteRequest() async {
    if (deleteReasonController.text.trim().isEmpty) {
      AppDialog.showError(message: 'delete_reason_required'.tr);
      return;
    }

    Get.back(); // Close reason dialog

    // Log the delete reason
    developer.log('Delete account reason: ${deleteReasonController.text}', name: 'ProfileController');

    isLoading.value = true;

    try {
      developer.log('🗑️ Deleting account...', name: 'ProfileController');

      // Call delete account API - auth token is automatically included in headers
      await profileProvider.deleteAccount();

      developer.log('✅ Delete account request submitted successfully', name: 'ProfileController');

      deleteReasonController.clear();

      // Show info message that the request is pending admin approval
      AppDialog.showSuccess(
        message: 'تم إرسال طلب حذف الحساب بنجاح، سيتم مراجعته من قبل الإدارة',
        buttonText: 'confirm'.tr,
        onButtonPressed: () => Get.back(),
      );

    } on ApiErrorModel catch (error) {
      developer.log('❌ Delete account error: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected delete account error: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء حذف الحساب');
    } finally {
      isLoading.value = false;
    }
  }

  // Submit app review/rating
  Future<bool> submitReview({
    required int rating,
    required String comment,
  }) async {
    isLoading.value = true;

    try {
      developer.log('⭐ Submitting review: rating=$rating', name: 'ProfileController');

      final request = AppReviewRequestModel(
        rating: rating,
        comment: comment,
      );

      final response = await profileProvider.submitReview(request: request);

      developer.log('✅ Review submitted successfully: ${response.data.id}', name: 'ProfileController');

      return true;
    } on ApiErrorModel catch (error) {
      developer.log('❌ Review submission error: ${error.displayMessage}', name: 'ProfileController');
      AppDialog.showError(message: error.displayMessage);
      return false;
    } catch (e) {
      developer.log('❌ Unexpected review error: $e', name: 'ProfileController');
      AppDialog.showError(message: 'حدث خطأ أثناء إرسال التقييم');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
