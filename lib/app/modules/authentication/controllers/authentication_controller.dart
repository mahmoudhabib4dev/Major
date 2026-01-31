import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/guest_selection_dialog.dart';
import '../../../core/widgets/camera_view.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/device_registration_service.dart';
import '../../../core/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../models/api_error_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/stage_model.dart';
import '../models/division_model.dart';
import '../models/subscription_plans_response_model.dart';
import '../models/bank_accounts_response_model.dart';
import '../models/subscription_store_models.dart';
import '../models/resend_otp_request_model.dart';
import '../models/verify_otp_forget_password_request_model.dart';
import '../models/set_password_request_model.dart';
import '../models/forget_password_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../views/payment_view.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/models/subscription_details_model.dart';

class AuthenticationController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  AuthProvider get authProvider => Get.find<AuthProvider>();
  final ApiClient apiClient = ApiClient();
  final ProfileProvider profileProvider = ProfileProvider();

  // Page controller for onboarding
  late PageController pageController;

  // Current page index
  final RxInt currentPage = 0.obs;

  // Total number of onboarding pages
  final int totalPages = 3;

  // Onboarding data
  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      icon: AppImages.icon1,
      title: 'تعلم بذكاء، لا بجهد',
      emoji: '🎓',
      description:
          'ابدأ رحلتك مع ماجور كلاس، المنصة التي تبني معرفتك خطوة بخطوة باستخدام أدوات ذكية وتجربة تعلم مصممة خصيصاً لك.',
    ),
    OnboardingData(
      icon: AppImages.icon2,
      title: 'تعليم تفاعلي يشبهك',
      emoji: '⚡',
      description:
          'تعلم بالطريقة التي تفضلها – فيديوهات، اختبارات، أو مهارات تفاعلية – ماجور كلاس يجعل كل درس تجربة ممتعة وسهلة الفهم.',
    ),
    OnboardingData(
      icon: AppImages.icon3,
      title: 'نمو مع مجتمع ماجور كلاس',
      emoji: '🌍',
      description:
          'انضم إلى مجتمع من المتعلمين والمعلمين حول العالم، تبادل الخبرات، وشارك إنجازاتك وخذ خطوة نحو مستقبلك المهني.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    // If onboarding is already completed, skip to login page
    developer.log('🎬 AuthenticationController onInit', name: 'AuthController');

    // Check for pending registration first
    if (storageService.hasPendingRegistration) {
      _resumePendingRegistration();
    } else if (storageService.isOnboardingCompleted) {
      developer.log('✅ Onboarding completed - showing login page', name: 'AuthController');
      showLoginPage.value = true;
    } else {
      developer.log('📖 First time - showing onboarding', name: 'AuthController');
    }
  }

  // Resume pending registration if user closed app during signup
  void _resumePendingRegistration() {
    final step = storageService.registrationStep;
    developer.log('🔄 Resuming pending registration at step: $step', name: 'AuthController');

    if (step == 'otp') {
      // User was at OTP verification step
      userEmail.value = storageService.registrationEmail ?? '';
      isSignUpMode.value = true;
      showRestorePasswordPage.value = true;
      startResendCountdown();
      developer.log('📱 Resumed at OTP step - email: ${userEmail.value}', name: 'AuthController');
    } else if (step == 'password') {
      // User was at password creation step - token should already be in storage
      userEmail.value = storageService.registrationEmail ?? '';
      isSignUpMode.value = true;
      showNewPasswordPage.value = true;
      developer.log('🔐 Resumed at password step', name: 'AuthController');
    } else {
      // Unknown step, clear and show login
      storageService.clearRegistrationData();
      showLoginPage.value = true;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    usernameController.dispose();
    signUpPhoneController.dispose();
    signUpEmailController.dispose();
    couponCodeController.dispose();
    referenceNumberController.dispose();

    super.onClose();
  }

  // Navigate to next page
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Update current page
  void updatePage(int index) {
    currentPage.value = index;
    // If user reached last page, mark onboarding as viewed
    if (index == totalPages - 1) {
      storageService.setOnboardingCompleted();
      storageService.setFirstLaunchComplete();
      developer.log('✅ Onboarding marked complete on last page view', name: 'AuthController');
    }
  }

  // Check if current page is last
  bool get isLastPage => currentPage.value == totalPages - 1;

  // Handle continue as guest
  Future<void> continueAsGuest() async {
    developer.log('👤 Continue as guest clicked', name: 'AuthController');

    // Show loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Load stages if not loaded
      if (stages.isEmpty) {
        await loadStages();
      }

      // Close loading dialog
      Get.back();

      // Show guest selection dialog
      Get.dialog(
        GuestSelectionDialog(
          stages: stages,
          loadDivisions: (stageId) async {
            // Load divisions from API using a new provider instance
            final provider = AuthProvider();
            return await provider.getDivisions(stageId);
          },
          onConfirm: (stageId, stageName, divisionId, divisionName) async {
            // Save guest preferences
            await storageService.saveGuestStage(stageId, stageName);
            await storageService.saveGuestDivision(divisionId, divisionName);

            // Mark onboarding as completed and first launch complete
            await storageService.setOnboardingCompleted();
            await storageService.setFirstLaunchComplete();

            developer.log(
              '✅ Guest preferences saved: Stage=$stageName, Division=$divisionName',
              name: 'AuthController',
            );

            // Navigate to home
            Get.offAllNamed('/parent');
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      // Close loading dialog if error occurs
      Get.back();
      developer.log('❌ Error loading stages: $e', name: 'AuthController');
      AppDialog.showError(message: 'فشل تحميل البيانات. يرجى المحاولة مرة أخرى.');
    }
  }

  // Handle navigation to login page
  Future<void> navigateToLogin() async {
    developer.log('🔐 Navigate to login clicked', name: 'AuthController');
    // Mark onboarding as completed and first launch complete
    await storageService.setOnboardingCompleted();
    await storageService.setFirstLaunchComplete();
    showLoginPage.value = true;
  }

  // Check subscription status and navigate accordingly
  void _checkSubscriptionAndNavigate() {
    final user = storageService.currentUser;
    final planStatus = user?.planStatus;

    developer.log('🔍 Checking subscription status: $planStatus', name: 'AuthController');

    // If user has active subscription, go to home
    if (planStatus == 'active') {
      developer.log('✅ User has active subscription - navigating to home', name: 'AuthController');
      Get.offAllNamed('/parent');
      return;
    }

    // User doesn't have active subscription - show dialog and navigate to subscription page
    developer.log('⚠️ User has no active subscription - showing subscription prompt', name: 'AuthController');

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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.golden.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.golden,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'مرحباً بك في ماجور كلاس!',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                'للاستفادة الكاملة من جميع المحتويات التعليمية والميزات الحصرية، يرجى اختيار خطة الاشتراك المناسبة لك.',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    // Show subscription page
                    showSubscriptionPage.value = true;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.golden,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'عرض خطط الاشتراك',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Login page state
  final RxBool showLoginPage = false.obs;
  final RxBool showSignUpPage = false.obs;

  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Focus nodes
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();

  // Sign up form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController signUpPhoneController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();

  // Sign up form state
  final Rx<DateTime?> selectedBirthDate = Rx<DateTime?>(null);
  final RxString selectedEducationalStage = ''.obs;
  final RxString selectedEducationalStageValue = ''.obs; // Stores the value (e.g., "primary")
  final RxString selectedBranch = ''.obs;
  final RxString selectedBranchValue = ''.obs; // Stores the value (e.g., "scientific")
  final RxString selectedGender = ''.obs; // 'male' or 'female'
  final RxString selectedWilaya = ''.obs; // Selected wilaya name
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool agreedToTerms = false.obs;

  // Stages and divisions from API
  final RxList<StageModel> stages = <StageModel>[].obs;
  final RxList<DivisionModel> divisions = <DivisionModel>[].obs;
  final RxBool isLoadingOptions = false.obs;
  final RxBool isLoadingDivisions = false.obs;
  final RxInt selectedStageId = 0.obs;

  // Educational stages list (computed from API)
  List<String> get educationalStages {
    return stages.map((stage) => stage.name).toList();
  }

  // Branches list (computed from API)
  List<String> get branches {
    return divisions.map((division) => division.name).toList();
  }

  // Mauritanian Wilayas list (static)
  List<String> get wilayas {
    return [
      'hodh_ech_chargui'.tr,
      'hodh_el_gharbi'.tr,
      'assaba'.tr,
      'gorgol'.tr,
      'brakna'.tr,
      'trarza'.tr,
      'adrar'.tr,
      'dakhlet_nouadhibou'.tr,
      'tagant'.tr,
      'guidimagha'.tr,
      'tiris_zemmour'.tr,
      'inchiri'.tr,
      'nouakchott_north'.tr,
      'nouakchott_west'.tr,
      'nouakchott_south'.tr,
    ];
  }

  // Form state
  final RxString selectedCountryCode = '+222'.obs; // Mauritania
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  // Validation errors
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString otpError = ''.obs;
  final RxString usernameError = ''.obs;
  final RxString birthDateError = ''.obs;
  final RxString educationalStageError = ''.obs;
  final RxString branchError = ''.obs;

  // Forgot password state
  final RxBool showForgotPasswordPage = false.obs;
  final RxBool showRestorePasswordPage = false.obs;
  final RxBool showNewPasswordPage = false.obs;
  final RxBool showSubscriptionPage = false.obs;
  final RxBool isSignUpMode = false.obs; // true for sign up, false for password reset

  // Subscription state
  final RxString selectedPlan = 'yearly'.obs;
  final RxString selectedPaymentMethod = ''.obs;
  final RxBool showPaymentPage = false.obs;
  final List<String> paymentMethods = [
    'دفع محلي',
  ];

  // Subscription plans from API
  final Rx<SubscriptionPlansResponseModel?> subscriptionPlansResponse = Rx<SubscriptionPlansResponseModel?>(null);
  final RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;
  final Rx<SubscriptionPlan?> selectedSubscriptionPlan = Rx<SubscriptionPlan?>(null);
  final RxBool isLoadingPlans = false.obs;

  // Current subscription details
  final Rx<SubscriptionDetailsModel?> currentSubscription = Rx<SubscriptionDetailsModel?>(null);
  final RxBool isLoadingSubscription = false.obs;

  // Subscription status (from refresh API)
  final RxString subscriptionStatus = ''.obs; // "pending", "accepted", "cancelled"
  final RxString planStatus = ''.obs; // "active", "expired", "none"
  final RxBool hasPendingSubscription = false.obs;

  // Bank accounts from API
  final Rx<BankAccountsResponseModel?> bankAccountsResponse = Rx<BankAccountsResponseModel?>(null);
  final RxList<BankAccount> bankAccounts = <BankAccount>[].obs;
  final Rx<BankAccount?> selectedBankAccount = Rx<BankAccount?>(null);
  final RxBool isLoadingBankAccounts = false.obs;

  // Payment state
  final RxString selectedPaymentAccount = ''.obs;
  final List<Map<String, String>> paymentAccounts = [
    {'name': 'بنكيلي', 'number': '12345678', 'logo': 'assets/icons/43.png'},
    {'name': 'كليك بنك', 'number': '12345678', 'logo': 'assets/icons/44.png'},
    {'name': 'بيغ بنك', 'number': '12345678', 'logo': 'assets/icons/45.png'},
    {'name': 'السداد بنك', 'number': '12345678', 'logo': 'assets/icons/46.png'},
    {'name': 'مصرفي', 'number': '12345678', 'logo': 'assets/icons/47.png'},
    {'name': 'أماني', 'number': '12345678', 'logo': 'assets/icons/48.png'},
  ];
  final RxString userEmail = ''.obs;
  final RxInt resendCountdown = 0.obs;
  final RxBool canResend = true.obs;
  final RxString resetToken = ''.obs;
  final RxString verifiedOtp = ''.obs; // Store OTP after verification for registration

  // New password controllers and state
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmNewPassword = true.obs;

  // Payment controllers and state
  final TextEditingController couponCodeController = TextEditingController();
  final TextEditingController referenceNumberController = TextEditingController();
  final Rx<File?> transferReceiptFile = Rx<File?>(null);
  final RxString transferReceiptFileName = ''.obs;

  // Coupon and discount state
  final RxDouble originalAmount = 0.0.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool isCouponApplied = false.obs;

  // Password strength indicators
  final RxBool hasMinLength = false.obs;
  final RxBool hasUpperAndLower = false.obs;
  final RxBool hasSpecialChar = false.obs;
  final RxBool hasNumber = false.obs;
  final RxBool passwordsMatch = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Update country code
  void updateCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  // Validate phone number
  bool validatePhone() {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = 'من فضلك أدخل رقم الجوال';
      return false;
    }

    if (phone.length < 8) {
      phoneError.value = 'رقم الجوال يجب أن يكون 8 أرقام على الأقل';
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError.value = 'رقم الجوال يجب أن يحتوي على أرقام فقط';
      return false;
    }

    phoneError.value = '';
    return true;
  }

  // Validate password
  bool validatePassword() {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      passwordError.value = 'من فضلك أدخل كلمة المرور';
      return false;
    }

    if (password.length < 6) {
      passwordError.value = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      return false;
    }

    passwordError.value = '';
    return true;
  }

  // Validate and login
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
      developer.log('🔐 Attempting login...', name: 'AuthController');

      // Create login request
      final loginRequest = LoginRequestModel(
        phone: '${selectedCountryCode.value}${phoneController.text.trim()}',
        password: passwordController.text.trim(),
      );

      // Call login API
      final response = await authProvider.login(
        request: loginRequest,
      );

      developer.log('✅ Login successful', name: 'AuthController');

      // Save auth token
      if (response.token != null) {
        await storageService.saveAuthToken(response.token!);
        apiClient.setToken(response.token!);
        developer.log('💾 Token saved', name: 'AuthController');
      }

      // Save password for logout purposes
      await storageService.savePassword(passwordController.text.trim());
      developer.log('💾 Password saved', name: 'AuthController');

      // Save user data
      if (response.student != null) {
        final student = response.student!;
        final userModel = UserModel(
          id: student.id,
          name: student.name,
          email: student.email,
          phone: student.phone,
          birthDate: student.birthDate,
          educationalStage: student.stage?.name,
          branch: student.division?.name,
          divisionId: student.division?.id,
          createdAt: student.createdAt,
          gender: student.gender,
          profileImage: student.picture,
          status: student.status,
          planStatus: student.planStatus,
        );
        await storageService.saveUser(userModel);
        developer.log('💾 User data saved: ${userModel.toJson()}', name: 'AuthController');
      }

      // Mark onboarding as completed
      await storageService.setOnboardingCompleted();

      // Register device for push notifications
      developer.log('📱 Registering device for push notifications...', name: 'AuthController');
      try {
        await DeviceRegistrationService().registerDevice();
        developer.log('✅ Device registration completed', name: 'AuthController');
      } catch (e) {
        developer.log('⚠️ Device registration failed (non-critical): $e', name: 'AuthController');
        // Don't block login if device registration fails
      }

      // Show success dialog
      AppDialog.showSuccess(
        message: response.message ?? 'تم تسجيل الدخول بنجاح',
        buttonText: 'متابعة',
        onButtonPressed: () {
          Get.back();
          // Navigate directly to home without checking subscription
          Get.offAllNamed('/parent');
        },
      );
    } on ApiErrorModel catch (error) {
      developer.log('❌ Login error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to forgot password
  void forgotPassword() {
    showForgotPasswordPage.value = true;
    showLoginPage.value = false;
  }

  // Navigate back to login from forgot password or signup OTP/password pages
  void backToLogin() {
    showForgotPasswordPage.value = false;
    showRestorePasswordPage.value = false;
    showNewPasswordPage.value = false;
    showLoginPage.value = true;
    emailError.value = '';
    otpError.value = '';
    emailController.clear();
    otp1Controller.clear();
    otp2Controller.clear();
    otp3Controller.clear();
    otp4Controller.clear();

    // Clear registration data if user cancels signup
    if (isSignUpMode.value) {
      storageService.clearRegistrationData();
      _resetSignUpState();
      _resetNewPasswordState();
      developer.log('🗑️ Registration cancelled - data cleared', name: 'AuthController');
    }
    isSignUpMode.value = false;
  }

  // Navigate to create account (sign up page)
  void createAccount() async {
    showLoginPage.value = false;
    showSignUpPage.value = true;

    // Load stages if not already loaded
    if (stages.isEmpty) {
      await loadStages();
    }
  }

  // Load educational stages from API
  Future<void> loadStages() async {
    isLoadingOptions.value = true;

    try {
      developer.log('📋 Loading educational stages...', name: 'AuthController');

      final stagesList = await authProvider.getStages();
      stages.value = stagesList;

      developer.log('✅ Stages loaded successfully: ${stages.length} stages', name: 'AuthController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load stages: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: 'فشل تحميل المراحل الدراسية');
    } catch (e) {
      developer.log('❌ Unexpected error loading stages: $e', name: 'AuthController');
      AppDialog.showError(message: 'فشل تحميل المراحل الدراسية');
    } finally {
      isLoadingOptions.value = false;
    }
  }

  // Load divisions for a specific stage
  Future<void> loadDivisions(int stageId) async {
    isLoadingDivisions.value = true;

    try {
      developer.log('📋 Loading divisions for stage $stageId...', name: 'AuthController');

      final divisionsList = await authProvider.getDivisions(stageId);
      divisions.value = divisionsList;

      developer.log('✅ Divisions loaded successfully: ${divisions.length} divisions', name: 'AuthController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load divisions: ${error.displayMessage}', name: 'AuthController');
      divisions.clear();
    } catch (e) {
      developer.log('❌ Unexpected error loading divisions: $e', name: 'AuthController');
      divisions.clear();
    } finally {
      isLoadingDivisions.value = false;
    }
  }

  // Navigate back to login from sign up
  void backToLoginFromSignUp() {
    showSignUpPage.value = false;
    showLoginPage.value = true;
    _resetSignUpState();
    // Clear any pending registration data
    storageService.clearRegistrationData();
  }

  // Reset sign up state
  void _resetSignUpState() {
    usernameController.clear();
    signUpPhoneController.clear();
    signUpEmailController.clear();
    selectedBirthDate.value = null;
    selectedEducationalStage.value = '';
    selectedBranch.value = '';
    selectedGender.value = '';
    selectedWilaya.value = '';
    agreedToTerms.value = false;
    usernameError.value = '';
    birthDateError.value = '';
    educationalStageError.value = '';
    branchError.value = '';
  }

  // Validate username
  bool validateUsername() {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      usernameError.value = 'من فضلك أدخل اسم المستخدم';
      return false;
    }
    if (username.length < 3) {
      usernameError.value = 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
      return false;
    }
    usernameError.value = '';
    return true;
  }

  // Validate sign up phone
  bool validateSignUpPhone() {
    final phone = signUpPhoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = 'من فضلك أدخل رقم الجوال';
      return false;
    }
    if (phone.length < 8) {
      phoneError.value = 'رقم الجوال يجب أن يكون 8 أرقام على الأقل';
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError.value = 'رقم الجوال يجب أن يحتوي على أرقام فقط';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  // Validate sign up email
  bool validateSignUpEmail() {
    final email = signUpEmailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'من فضلك أدخل البريد الالكتروني';
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      emailError.value = 'البريد الالكتروني غير صحيح';
      return false;
    }
    emailError.value = '';
    return true;
  }

  // Toggle terms agreement
  void toggleTermsAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  // Select birth date
  void selectBirthDate(DateTime date) {
    selectedBirthDate.value = date;
    birthDateError.value = '';
  }

  // Select educational stage
  void selectEducationalStage(String stageName) async {
    selectedEducationalStage.value = stageName;

    // Find the stage by name and load its divisions
    final stage = stages.firstWhere(
      (s) => s.name == stageName,
      orElse: () => StageModel(id: 0, name: ''),
    );

    if (stage.id > 0) {
      selectedStageId.value = stage.id;
      selectedEducationalStageValue.value = stage.id.toString();

      // Clear previous division selection
      selectedBranch.value = '';
      selectedBranchValue.value = '';
      divisions.clear();

      // Load divisions for the selected stage
      await loadDivisions(stage.id);
    }

    educationalStageError.value = '';
  }

  // Select branch
  void selectBranch(String branchName) {
    selectedBranch.value = branchName;

    // Find the division by name
    final division = divisions.firstWhere(
      (d) => d.name == branchName,
      orElse: () => DivisionModel(id: 0, name: ''),
    );

    if (division.id > 0) {
      selectedBranchValue.value = division.id.toString();
    }

    branchError.value = '';
  }

  // Select gender
  void selectGender(String gender) {
    selectedGender.value = gender; // 'male' or 'female'
  }

  // Select wilaya
  void selectWilaya(String wilaya) {
    selectedWilaya.value = wilaya;
  }

  // Get default avatar based on gender
  String get defaultAvatar {
    if (selectedGender.value == 'male') {
      return AppImages.icon58; // Boy avatar
    } else if (selectedGender.value == 'female') {
      return AppImages.icon57; // Girl avatar
    }
    return AppImages.icon31; // Default avatar
  }

  // Pick profile image from gallery or camera
  Future<void> pickProfileImage() async {
    try {
      // Show bottom sheet to choose camera or gallery
      final source = await Get.bottomSheet<String>(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'choose_image_source'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('camera'.tr),
                  onTap: () => Get.back(result: 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text('gallery'.tr),
                  onTap: () => Get.back(result: 'gallery'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      File? imageFile;

      if (source == 'camera') {
        // Use camera package for camera capture
        imageFile = await Get.to<File>(() => const CameraView());
      } else {
        // Use image_picker for gallery
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (image != null) {
          imageFile = File(image.path);
        }
      }

      if (imageFile != null) {
        profileImage.value = imageFile;
        developer.log('✅ Profile image selected: ${imageFile.path}', name: 'AuthController');
      }
    } catch (e) {
      developer.log('❌ Error picking image: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء اختيار الصورة');
    }
  }

  // Remove profile image
  void removeProfileImage() {
    profileImage.value = null;
  }

  // Get formatted birth date
  String get formattedBirthDate {
    if (selectedBirthDate.value == null) return '';
    final date = selectedBirthDate.value!;
    return '${date.day}/${date.month}/${date.year}';
  }

  // Complete sign up (directly register without password)
  Future<void> completeSignUp() async {
    // Validate all fields
    final isUsernameValid = validateUsername();
    final isPhoneValid = validateSignUpPhone();
    final isEmailValid = validateSignUpEmail();

    if (!isUsernameValid || !isPhoneValid || !isEmailValid) {
      return;
    }

    if (selectedGender.value.isEmpty) {
      AppDialog.showError(message: 'من فضلك اختر الجنس');
      return;
    }

    if (!agreedToTerms.value) {
      AppDialog.showError(message: 'يجب الموافقة على الشروط والأحكام');
      return;
    }

    // Start loading
    isLoading.value = true;

    try {
      developer.log('📝 Registering new user...', name: 'AuthController');

      // Format birthdate to yyyy-MM-dd
      String formattedBirthdate = '';
      if (selectedBirthDate.value != null) {
        final date = selectedBirthDate.value!;
        formattedBirthdate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      // Create register request with country code + phone
      final fullPhoneNumber = '${selectedCountryCode.value}${signUpPhoneController.text.trim()}';

      final registerRequest = RegisterRequestModel(
        name: usernameController.text.trim(),
        email: signUpEmailController.text.trim(),
        phone: fullPhoneNumber,
        birthDate: formattedBirthdate,
        stage: selectedEducationalStageValue.value, // Use value, not label
        division: selectedBranchValue.value, // Use value, not label
        gender: selectedGender.value,
        terms: agreedToTerms.value,
        picture: profileImage.value?.path,
      );

      developer.log('📱 Full phone number: $fullPhoneNumber', name: 'AuthController');

      final response = await authProvider.register(
        request: registerRequest,
      );

      developer.log('✅ Registration successful - OTP sent', name: 'AuthController');

      // Save email for OTP verification
      userEmail.value = signUpEmailController.text.trim();

      // Navigate to OTP verification page (restore password page)
      isSignUpMode.value = true;
      showSignUpPage.value = false;
      showRestorePasswordPage.value = true;

      // Save registration step for persistence (in case user closes app)
      await storageService.saveRegistrationOtpStep(
        phone: fullPhoneNumber,
        email: signUpEmailController.text.trim(),
      );

      // Start resend countdown timer
      startResendCountdown();

      AppDialog.showSuccess(
        message: response.message ?? 'otp_sent_success'.tr,
      );
    } on ApiErrorModel catch (error) {
      developer.log('❌ Registration error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء إنشاء الحساب');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate email
  bool validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      emailError.value = 'من فضلك أدخل البريد الالكتروني';
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      emailError.value = 'البريد الالكتروني غير صحيح';
      return false;
    }

    emailError.value = '';
    return true;
  }

  // Send OTP code
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
      developer.log('📧 Sending OTP to email...', name: 'AuthController');

      // Call forget password API
      final forgetPasswordRequest = ForgetPasswordRequestModel(
        email: emailController.text.trim(),
      );
      await authProvider.forgetPasswordNew(
        request: forgetPasswordRequest,
      );

      developer.log('✅ OTP sent successfully', name: 'AuthController');

      // Save email for display in restore password page
      userEmail.value = emailController.text.trim();

      // Navigate to restore password page
      showForgotPasswordPage.value = false;
      showRestorePasswordPage.value = true;

      // Start countdown timer
      startResendCountdown();

    } on ApiErrorModel catch (error) {
      developer.log('❌ Send OTP error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء إرسال الرمز');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate OTP
  bool validateOtp() {
    final otp1 = otp1Controller.text.trim();
    final otp2 = otp2Controller.text.trim();
    final otp3 = otp3Controller.text.trim();
    final otp4 = otp4Controller.text.trim();

    if (otp1.isEmpty || otp2.isEmpty || otp3.isEmpty || otp4.isEmpty) {
      otpError.value = 'من فضلك أدخل الرمز كاملاً';
      return false;
    }

    otpError.value = '';
    return true;
  }

  // Verify OTP and restore password
  Future<void> verifyOtp() async {
    // Clear previous errors
    otpError.value = '';

    // Validate OTP
    if (!validateOtp()) {
      return;
    }

    final otp = '${otp1Controller.text}${otp2Controller.text}${otp3Controller.text}${otp4Controller.text}';

    isLoading.value = true;

    try {
      if (isSignUpMode.value) {
        // Registration flow - verify OTP with API
        developer.log('🔢 Verifying OTP for registration...', name: 'AuthController');

        final verifyRequest = VerifyOtpForgetPasswordRequestModel(
          email: userEmail.value,
          otp: otp,
        );

        final response = await authProvider.verifyOtpForgetPassword(
          request: verifyRequest,
        );

        developer.log('✅ OTP verified successfully', name: 'AuthController');

        // Store verified OTP for password creation
        verifiedOtp.value = otp;

        // Save token from OTP verification
        if (response.token != null) {
          await storageService.saveAuthToken(response.token!);
          apiClient.setToken(response.token!);
          developer.log('💾 Verification token saved: ${response.token!.substring(0, 10)}...', name: 'AuthController');

          // Update registration step to password (for persistence)
          await storageService.saveRegistrationPasswordStep(token: response.token!);
        } else {
          developer.log('⚠️ No token received from OTP verification!', name: 'AuthController');
        }

        AppDialog.showSuccess(
          message: response.message ?? 'تم التحقق من الرمز بنجاح',
          buttonText: 'متابعة',
          onButtonPressed: () {
            Get.back();
            // Navigate to password creation page
            showRestorePasswordPage.value = false;
            showNewPasswordPage.value = true;
          },
        );
        return;
      }

      // Password reset flow - verify OTP with API
      developer.log('🔢 Verifying OTP for password reset...', name: 'AuthController');

      // Call verify OTP forget password API
      final verifyRequest = VerifyOtpForgetPasswordRequestModel(
        email: userEmail.value,
        otp: otp,
      );

      final response = await authProvider.verifyOtpForgetPassword(
        request: verifyRequest,
      );

      developer.log('✅ OTP verified successfully', name: 'AuthController');

      // Save token from OTP verification for password reset
      if (response.token != null) {
        await storageService.saveAuthToken(response.token!);
        apiClient.setToken(response.token!);
        developer.log('💾 Reset token saved: ${response.token!.substring(0, 10)}...', name: 'AuthController');
      } else {
        developer.log('⚠️ No token received from OTP verification!', name: 'AuthController');
      }

      AppDialog.showSuccess(
        message: response.message ?? 'تم التحقق من الرمز بنجاح',
        buttonText: 'متابعة',
        onButtonPressed: () {
          Get.back();
          // Navigate to new password page
          navigateToNewPasswordPage();
        },
      );

    } on ApiErrorModel catch (error) {
      developer.log('❌ Verify OTP error: ${error.displayMessage}', name: 'AuthController');
      otpError.value = error.displayMessage;
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      otpError.value = 'الرمز غير صحيح';
      AppDialog.showError(message: 'الرمز غير صحيح');
    } finally {
      isLoading.value = false;
    }
  }

  // Start countdown timer for resend
  void startResendCountdown() {
    canResend.value = false;
    resendCountdown.value = 120; // 2 minutes

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  // Resend OTP code
  Future<void> resendOtpCode() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      developer.log('🔄 Resending OTP...', name: 'AuthController');

      if (isSignUpMode.value) {
        // Registration flow - use resend OTP API
        final resendRequest = ResendOtpRequestModel(email: userEmail.value);
        await authProvider.resendOtp(request: resendRequest);
      } else {
        // Password reset flow - use forget password API
        final forgetPasswordRequest = ForgetPasswordRequestModel(email: userEmail.value);
        await authProvider.forgetPasswordNew(request: forgetPasswordRequest);
      }

      developer.log('✅ OTP resent successfully', name: 'AuthController');

      AppDialog.showSuccess(message: 'otp_resent_success'.tr);

      // Restart countdown
      startResendCountdown();

    } on ApiErrorModel catch (error) {
      developer.log('❌ Resend OTP error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'otp_resend_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Get formatted countdown time
  String get countdownText {
    final minutes = resendCountdown.value ~/ 60;
    final seconds = resendCountdown.value % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Toggle new password visibility
  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  // Toggle confirm new password visibility
  void toggleConfirmNewPasswordVisibility() {
    obscureConfirmNewPassword.value = !obscureConfirmNewPassword.value;
  }

  // Validate new password strength
  void validateNewPasswordStrength() {
    final password = newPasswordController.text;

    // Check minimum length (8-20 characters)
    hasMinLength.value = password.length >= 8 && password.length <= 20;

    // Check for uppercase and lowercase
    hasUpperAndLower.value =
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'));

    // Check for special character
    hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Check for number
    hasNumber.value = password.contains(RegExp(r'[0-9]'));

    // Also validate passwords match if confirm field has value
    if (confirmNewPasswordController.text.isNotEmpty) {
      validatePasswordsMatch();
    }
  }

  // Validate passwords match
  void validatePasswordsMatch() {
    passwordsMatch.value =
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmNewPasswordController.text;
  }

  // Check if new password is valid
  bool get isNewPasswordValid {
    return hasMinLength.value &&
        hasUpperAndLower.value &&
        hasSpecialChar.value &&
        hasNumber.value &&
        passwordsMatch.value;
  }

  // Save new password and verify OTP (handles both registration and password reset)
  Future<void> saveNewPassword() async {
    if (!isNewPasswordValid) return;

    isLoading.value = true;

    try {
      if (isSignUpMode.value) {
        // Registration flow - set password using set-password API
        developer.log('📝 Setting password...', name: 'AuthController');

        // Ensure token from OTP verification is set (in case of hot reload)
        final token = storageService.authToken;
        if (token != null) {
          apiClient.setToken(token);
          developer.log('🔑 Token loaded and set for authentication: ${token.substring(0, 10)}...', name: 'AuthController');
        } else {
          developer.log('❌ No token found in storage!', name: 'AuthController');
          AppDialog.showError(message: 'حدث خطأ في التحقق، الرجاء المحاولة مرة أخرى');
          isLoading.value = false;
          return;
        }

        final setPasswordRequest = SetPasswordRequestModel(
          password: newPasswordController.text.trim(),
          passwordConfirmation: confirmNewPasswordController.text.trim(),
        );

        developer.log('📤 Calling setPassword API with token...', name: 'AuthController');
        final response = await authProvider.setPassword(
          request: setPasswordRequest,
        );

        developer.log('✅ Password set successfully', name: 'AuthController');

        // Now login to get permanent token and full user data
        developer.log('🔐 Auto-login after registration...', name: 'AuthController');

        final loginRequest = LoginRequestModel(
          phone: '${selectedCountryCode.value}${signUpPhoneController.text.trim()}',
          password: newPasswordController.text.trim(),
        );

        final loginResponse = await authProvider.login(request: loginRequest);
        developer.log('✅ Auto-login successful', name: 'AuthController');

        // Save permanent auth token
        if (loginResponse.token != null) {
          await storageService.saveAuthToken(loginResponse.token!);
          apiClient.setToken(loginResponse.token!);
          developer.log('💾 Permanent token saved', name: 'AuthController');
        }

        // Save password for logout purposes
        await storageService.savePassword(newPasswordController.text.trim());
        developer.log('💾 Password saved', name: 'AuthController');

        // Save complete user data from login response
        if (loginResponse.student != null) {
          final student = loginResponse.student!;
          final userModel = UserModel(
            id: student.id,
            name: student.name,
            email: student.email,
            phone: student.phone,
            birthDate: student.birthDate,
            educationalStage: student.stage?.name,
            branch: student.division?.name,
            divisionId: student.division?.id,
            createdAt: student.createdAt,
            countryCode: selectedCountryCode.value,
            gender: student.gender,
            profileImage: student.picture,
            status: student.status,
            planStatus: student.planStatus,
          );
          await storageService.saveUser(userModel);
          developer.log('💾 Complete user data saved: ${userModel.toJson()}', name: 'AuthController');
        }

        // Mark onboarding as completed
        await storageService.setOnboardingCompleted();

        // Register device for push notifications
        developer.log('📱 Registering device for push notifications...', name: 'AuthController');
        try {
          await DeviceRegistrationService().registerDevice();
          developer.log('✅ Device registration completed', name: 'AuthController');
        } catch (e) {
          developer.log('⚠️ Device registration failed (non-critical): $e', name: 'AuthController');
          // Don't block signup if device registration fails
        }

        // Clear registration persistence data (signup completed successfully)
        await storageService.clearRegistrationData();
        developer.log('🗑️ Registration data cleared after successful signup', name: 'AuthController');

        AppDialog.showSuccess(
          message: response.message ?? 'تم إنشاء كلمة المرور بنجاح',
          buttonText: 'متابعة',
          onButtonPressed: () {
            Get.back();
            _resetNewPasswordState();
            _resetSignUpState();
            // Navigate directly to home without checking subscription
            showNewPasswordPage.value = false;
            Get.offAllNamed('/parent');
          },
        );
      } else {
        // Password reset flow - reset password using reset-password API
        developer.log('🔐 Resetting password...', name: 'AuthController');

        // Ensure token from OTP verification is set (in case of hot reload)
        final token = storageService.authToken;
        if (token != null) {
          apiClient.setToken(token);
          developer.log('🔑 Token loaded and set for authentication', name: 'AuthController');
        } else {
          AppDialog.showError(message: 'حدث خطأ في التحقق، الرجاء المحاولة مرة أخرى');
          isLoading.value = false;
          return;
        }

        final resetPasswordRequest = ResetPasswordRequestModel(
          password: newPasswordController.text.trim(),
          passwordConfirmation: confirmNewPasswordController.text.trim(),
        );

        final response = await authProvider.resetPasswordNew(
          request: resetPasswordRequest,
        );

        developer.log('✅ Password reset successful', name: 'AuthController');

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
      developer.log('❌ Error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: isSignUpMode.value
          ? 'حدث خطأ أثناء التحقق من الحساب'
          : 'حدث خطأ أثناء تغيير كلمة المرور');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset new password state
  void _resetNewPasswordState() {
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    obscureNewPassword.value = true;
    obscureConfirmNewPassword.value = true;
    hasMinLength.value = false;
    hasUpperAndLower.value = false;
    hasSpecialChar.value = false;
    hasNumber.value = false;
    passwordsMatch.value = false;
    isSignUpMode.value = false;
  }

  // Navigate to new password page (from password reset flow)
  void navigateToNewPasswordPage() {
    isSignUpMode.value = false;
    showRestorePasswordPage.value = false;
    showNewPasswordPage.value = true;
  }

  // Select subscription plan
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  // Select payment method
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // Navigate to subscription page
  void navigateToSubscriptionPage() {
    showNewPasswordPage.value = false;
    showSubscriptionPage.value = true;
    // Note: Subscription plans are loaded in the bottom sheet when user taps on the plans field
  }

  // Complete subscription - navigate to payment page
  void completeSubscription() async {
    // Validate that a plan and payment method are selected
    if (selectedSubscriptionPlan.value == null) {
      AppDialog.showError(message: 'please_select_subscription_plan'.tr);
      return;
    }

    if (selectedPaymentMethod.value.isEmpty) {
      AppDialog.showError(message: 'please_select_payment_method'.tr);
      return;
    }

    // Load user data from Hive into text controllers for payment page
    await _loadUserDataForPayment();

    // Navigate to PaymentView
    Get.to(() => const PaymentView());
  }

  // Load user data from Hive storage into text fields for payment page
  Future<void> _loadUserDataForPayment() async {
    try {
      final userBox = await Hive.openBox<UserModel>('user');
      final user = userBox.get('currentUser');

      if (user != null) {
        // Populate name and phone from Hive
        usernameController.text = user.name ?? '';
        phoneController.text = user.phone ?? '';
        developer.log('✅ Loaded user data: ${user.name}, ${user.phone}', name: 'AuthController');
      }
    } catch (e) {
      developer.log('❌ Error loading user data: $e', name: 'AuthController');
    }
  }

  // Reset subscription state
  void _resetSubscriptionState() {
    selectedPlan.value = 'yearly';
    selectedPaymentMethod.value = '';
    showSubscriptionPage.value = false;
    showPaymentPage.value = false;
    selectedPaymentAccount.value = '';
    _resetSignUpState();
    _resetNewPasswordState();
  }

  // Navigate to payment page
  void navigateToPaymentPage() {
    showSubscriptionPage.value = false;
    showPaymentPage.value = true;
  }

  // Select payment account
  void selectPaymentAccount(String account) {
    selectedPaymentAccount.value = account;
  }

  // Upload payment receipt
  Future<void> uploadPaymentReceipt() async {
    try {
      developer.log('📸 Opening image picker...', name: 'AuthController');

      // Show source selection bottom sheet
      final source = await _showImageSourceBottomSheet();

      if (source == null) return;

      File? imageFile;

      if (source == ImageSource.camera) {
        // Use camera package for camera capture
        imageFile = await Get.to<File>(() => const CameraView());
      } else {
        // Use image_picker for gallery
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          imageFile = File(image.path);
        }
      }

      if (imageFile == null) {
        developer.log('❌ No image selected', name: 'AuthController');
        return;
      }

      developer.log('✅ Image selected: ${imageFile.path}', name: 'AuthController');

      // Use the image directly without cropping
      transferReceiptFile.value = imageFile;
      transferReceiptFileName.value = imageFile.path.split('/').last;
      developer.log('✅ Image saved: ${imageFile.path}', name: 'AuthController');
      AppDialog.showSuccess(message: 'تم اختيار الصورة بنجاح');
    } catch (e) {
      developer.log('❌ Error picking image: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء اختيار الصورة');
    }
  }

  // Apply coupon code
  Future<void> applyCoupon() async {
    if (couponCodeController.text.trim().isEmpty) {
      AppDialog.showError(message: 'من فضلك أدخل كود الخصم');
      return;
    }

    isLoading.value = true;

    try {
      developer.log('🎫 Applying coupon code...', name: 'AuthController');

      final planId = selectedSubscriptionPlan.value?.id;
      if (planId == null) {
        throw ApiErrorModel(message: 'يرجى اختيار خطة الاشتراك أولاً');
      }

      final response = await authProvider.applyCoupon(
        planId: planId,
        couponCode: couponCodeController.text.trim(),
      );

      developer.log('✅ Coupon applied successfully', name: 'AuthController');

      // Update amounts from nested data object
      originalAmount.value = response.data?.originalPrice ?? 0.0;
      discountAmount.value = response.data?.discount ?? 0.0;
      totalAmount.value = response.data?.finalPrice ?? 0.0;
      isCouponApplied.value = true;

      AppDialog.showSuccess(
        message: response.message ?? 'تم تطبيق كود الخصم بنجاح',
      );
    } on ApiErrorModel catch (error) {
      developer.log('❌ Apply coupon error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
      isCouponApplied.value = false;
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء تطبيق كود الخصم');
      isCouponApplied.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Complete payment
  Future<void> completePayment() async {
    // Validate bank account selection
    if (selectedBankAccount.value == null) {
      AppDialog.showError(message: 'من فضلك اختر حساب الدفع');
      return;
    }

    // Validate transfer receipt
    if (transferReceiptFile.value == null) {
      AppDialog.showError(message: 'من فضلك قم بإرفاق صورة الحوالة');
      return;
    }

    // Validate reference number
    if (referenceNumberController.text.trim().isEmpty) {
      AppDialog.showError(message: 'من فضلك أدخل رقم المرجع');
      return;
    }

    isLoading.value = true;

    try {
      developer.log('💳 Submitting payment...', name: 'AuthController');

      final request = SubscriptionStoreRequest(
        planId: selectedSubscriptionPlan.value?.id,
        bankAccountId: selectedBankAccount.value?.id,
        transferReceipt: transferReceiptFile.value,
        couponCode: isCouponApplied.value ? couponCodeController.text.trim() : null,
        referenceNumber: referenceNumberController.text.trim(),
        paymentMethod: 'bank_transfer',
      );

      final response = await authProvider.storeSubscription(request: request);

      developer.log('✅ Payment submitted successfully', name: 'AuthController');

      AppDialog.showSuccess(
        message: response.message ?? 'تم إرسال طلبك بنجاح\nعليك الانتظار حتى يتم قبول حسابك',
        buttonText: 'الذهاب للصفحة الرئيسية',
        onButtonPressed: () {
          Get.back();
          _resetSubscriptionState();
          Get.offAllNamed('/parent');
        },
      );
    } on ApiErrorModel catch (error) {
      developer.log('❌ Payment error: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء إتمام الدفع');
    } finally {
      isLoading.value = false;
    }
  }

  // Load subscription plans from API
  Future<void> loadSubscriptionPlans() async {
    isLoadingPlans.value = true;

    try {
      developer.log('📋 Loading subscription plans...', name: 'AuthController');

      final response = await authProvider.getSubscriptionPlans();
      subscriptionPlansResponse.value = response;
      subscriptionPlans.value = response.data ?? [];

      // Auto-select the first plan if available
      if (subscriptionPlans.isNotEmpty) {
        selectedSubscriptionPlan.value = subscriptionPlans.first;
      }

      developer.log('✅ Subscription plans loaded: ${subscriptionPlans.length} plans', name: 'AuthController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load subscription plans: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading subscription plans: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل خطط الاشتراك');
    } finally {
      isLoadingPlans.value = false;
    }
  }

  // Select a subscription plan
  void selectSubscriptionPlan(SubscriptionPlan plan) {
    selectedSubscriptionPlan.value = plan;
    developer.log('📦 Selected plan: ${plan.id} - ${plan.formattedPrice} for ${plan.durationLabel}', name: 'AuthController');
  }

  // Load current subscription details
  Future<void> loadCurrentSubscription() async {
    isLoadingSubscription.value = true;

    try {
      developer.log('📅 Loading current subscription...', name: 'AuthController');

      final subscription = await profileProvider.getSubscriptionDetails();
      currentSubscription.value = subscription;

      if (subscription.hasSubscription) {
        developer.log('✅ Current subscription: ${subscription.planName} (${subscription.startDate} - ${subscription.endDate})', name: 'AuthController');
      } else {
        developer.log('ℹ️ No active subscription found', name: 'AuthController');
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load subscription: ${error.displayMessage}', name: 'AuthController');
      // Don't show error to user - subscription details are optional
    } catch (e) {
      developer.log('❌ Unexpected error loading subscription: $e', name: 'AuthController');
      // Don't show error to user - subscription details are optional
    } finally {
      isLoadingSubscription.value = false;
    }
  }

  // Refresh subscription status (check if pending, active, or can subscribe)
  Future<void> refreshSubscriptionStatus() async {
    isLoadingSubscription.value = true;
    try {
      developer.log('🔄 Refreshing subscription status...', name: 'AuthController');

      final response = await authProvider.refreshSubscription();

      if (response.success && response.data != null) {
        subscriptionStatus.value = response.data!.subscriptionStatus ?? '';
        planStatus.value = response.data!.planStatus ?? '';

        // Check if user has a pending subscription request
        hasPendingSubscription.value = response.data!.isPending;

        developer.log('✅ Subscription status refreshed - Status: ${subscriptionStatus.value}, Plan: ${planStatus.value}', name: 'AuthController');

        // Also refresh current subscription details to get latest data
        await loadCurrentSubscription();
      }
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to refresh subscription status: ${error.displayMessage}', name: 'AuthController');
      // Don't show error to user - just log it
    } catch (e) {
      developer.log('❌ Unexpected error refreshing subscription status: $e', name: 'AuthController');
      // Don't show error to user - just log it
    } finally {
      isLoadingSubscription.value = false;
    }
  }

  // Load bank accounts from API
  Future<void> loadBankAccounts() async {
    isLoadingBankAccounts.value = true;

    try {
      developer.log('🏦 Loading bank accounts...', name: 'AuthController');

      final response = await authProvider.getBankAccounts();
      bankAccountsResponse.value = response;
      bankAccounts.value = response.data ?? [];

      // Auto-select the first bank account if available
      if (bankAccounts.isNotEmpty) {
        selectedBankAccount.value = bankAccounts.first;
      }

      developer.log('✅ Bank accounts loaded: ${bankAccounts.length} accounts', name: 'AuthController');
    } on ApiErrorModel catch (error) {
      developer.log('❌ Failed to load bank accounts: ${error.displayMessage}', name: 'AuthController');
      AppDialog.showError(message: error.displayMessage);
    } catch (e) {
      developer.log('❌ Unexpected error loading bank accounts: $e', name: 'AuthController');
      AppDialog.showError(message: 'حدث خطأ أثناء تحميل حسابات البنوك');
    } finally {
      isLoadingBankAccounts.value = false;
    }
  }

  // Select a bank account
  void selectBankAccount(BankAccount account) {
    selectedBankAccount.value = account;
    developer.log('🏦 Selected bank account: ${account.bankName} - ${account.accountNumber}', name: 'AuthController');
  }

  // Show image source bottom sheet
  Future<ImageSource?> _showImageSourceBottomSheet() async {
    return await Get.bottomSheet<ImageSource>(
      _ImageSourceBottomSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

}

// Image Source Bottom Sheet Widget
class _ImageSourceBottomSheet extends StatelessWidget {
  const _ImageSourceBottomSheet();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    final sources = [
      {'name': 'الكاميرا', 'source': ImageSource.camera},
      {'name': 'المعرض', 'source': ImageSource.gallery},
    ];

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Space for wave
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Title
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: AppDimensions.paddingAll(context, 0.04),
                      child: Text(
                        'اختر مصدر الصورة',
                        style: AppTextStyles.sectionTitle(context),
                      ),
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  // Sources list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sources.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.grey200,
                      height: 1,
                      indent: AppDimensions.spacing(context, 0.04),
                      endIndent: AppDimensions.spacing(context, 0.04),
                    ),
                    itemBuilder: (context, index) {
                      final source = sources[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 50 * index),
                        child: ListTile(
                          contentPadding: AppDimensions.paddingHorizontal(context, 0.04),
                          title: Text(
                            source['name'] as String,
                            style: AppTextStyles.bodyText(context),
                            textAlign: TextAlign.right,
                          ),
                          onTap: () {
                            Get.back(result: source['source'] as ImageSource);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.04)),
                ],
              ),
            ),
          ),
          // Small dot at top center where curve peaks
          Positioned(
            top: -screenSize.width * 0.025 + 5,
            left: screenSize.width / 2 - screenSize.width * 0.0125,
            child: Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// Top Curve Clipper for bottom sheet
class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    // Start from top left
    path.lineTo(0, notchRadius);

    // Left side going down
    path.lineTo(0, size.height);

    // Bottom
    path.lineTo(size.width, size.height);

    // Right side going up
    path.lineTo(size.width, notchRadius);

    // Top right corner curve
    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Line to notch start (right side)
    path.lineTo(notchCenterX + notchWidth / 2, 0);

    // Create ONE wavy curve in the middle
    path.quadraticBezierTo(
      notchCenterX, // control point x (center)
      -notchRadius * 0.5, // control point y (depth of wave)
      notchCenterX - notchWidth / 2, // end point x
      0, // end point y
    );

    // Line to top left corner
    path.lineTo(notchRadius, 0);

    // Top left corner curve
    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// Onboarding data model
class OnboardingData {
  final String icon;
  final String title;
  final String emoji;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.emoji,
    required this.description,
  });
}
