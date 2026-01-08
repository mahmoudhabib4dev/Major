import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../parent/controllers/parent_controller.dart';
import '../../subjects/models/subject_model.dart';
import '../../subjects/providers/subjects_provider.dart';
import '../../subjects/controllers/subjects_controller.dart';
import '../../subjects/controllers/lesson_detail_controller.dart';
import '../../subjects/views/subject_detail_view.dart';
import '../../subjects/views/lesson_detail_view.dart';
import '../../authentication/models/api_error_model.dart';
import '../models/offer_model.dart';
import '../models/lesson_search_response_model.dart';
import '../providers/home_provider.dart';

class HomeController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final SubjectsProvider subjectsProvider = SubjectsProvider();
  final HomeProvider homeProvider = HomeProvider();

  // Carousel/Offers state
  final currentCarouselIndex = 0.obs;
  final RxList<OfferModel> offers = <OfferModel>[].obs;
  final RxBool isLoadingOffers = false.obs;
  int get carouselItemCount => offers.length;

  // User data
  final userName = ''.obs;
  final greetingText = 'مرحبا بك .. !'.obs;
  final userAvatarUrl = ''.obs;
  final userAvatarAsset = ''.obs;

  // Subjects list
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubscriptionExpired = false.obs;

  // Search state
  final RxList<LessonSearchItem> searchResults = <LessonSearchItem>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadOffers();
    loadSubjects();
  }

  // Load user data
  void loadUserData() {
    final user = storageService.currentUser;
    developer.log('👤 Loading user data in HomeController', name: 'HomeController');
    developer.log('   User: ${user?.toJson()}', name: 'HomeController');

    if (user != null) {
      userName.value = user.name ?? 'مستخدم';

      // Set avatar based on profile image or gender
      if (user.profileImage != null && user.profileImage!.isNotEmpty) {
        developer.log('   ✅ Profile image found: ${user.profileImage}', name: 'HomeController');
        userAvatarUrl.value = user.profileImage!;
        userAvatarAsset.value = '';
      } else {
        developer.log('   ⚠️ No profile image, using default avatar', name: 'HomeController');
        // Use default avatar based on gender
        if (user.gender == 'male' || user.gender == 'ذكر') {
          userAvatarAsset.value = AppImages.icon58;
        } else {
          userAvatarAsset.value = AppImages.icon57;
        }
        userAvatarUrl.value = '';
      }
    } else {
      developer.log('   ❌ No user found in storage', name: 'HomeController');
      userName.value = 'مستخدم';
      userAvatarAsset.value = AppImages.icon58; // Default to male avatar
      userAvatarUrl.value = '';
    }
  }

  // Load offers/carousel data from API
  Future<void> loadOffers() async {
    try {
      isLoadingOffers.value = true;

      // Get division ID from logged in user or guest
      final divisionId = storageService.currentUser?.divisionId ?? storageService.guestDivisionId;

      if (divisionId == null) {
        developer.log('❌ No division ID found for user', name: 'HomeController');
        isLoadingOffers.value = false;
        return;
      }

      developer.log('🎠 Loading offers for division: $divisionId', name: 'HomeController');

      final response = await homeProvider.getOffers(divisionId);

      if (response.success) {
        offers.value = response.data;
        developer.log('✅ Offers loaded: ${offers.length} offers', name: 'HomeController');
      } else {
        developer.log('❌ Failed to load offers', name: 'HomeController');
      }
    } catch (e) {
      developer.log('❌ Error loading offers: $e', name: 'HomeController');
      // Don't show error to user, just log it - offers are not critical
    } finally {
      isLoadingOffers.value = false;
    }
  }

  // Handle offer tap
  Future<void> onOfferTap(OfferModel offer) async {
    developer.log('🎯 Offer tapped: ${offer.title} (type: ${offer.linkType})', name: 'HomeController');

    if (offer.linkType == 'external' && offer.link != null) {
      // Open external link
      try {
        final url = Uri.parse(offer.link!);
        await launchUrl(url, mode: LaunchMode.externalApplication);
        developer.log('✅ Opened external link: ${offer.link}', name: 'HomeController');
      } catch (e) {
        developer.log('❌ Error launching URL: $e', name: 'HomeController');
        AppDialog.showError(message: 'تعذر فتح الرابط');
      }
    } else if (offer.linkType == 'internal' && offer.lessonId != null) {
      // Navigate to lesson by ID
      developer.log('📱 Navigating to lesson: ${offer.lessonId}', name: 'HomeController');
      await navigateToLesson(offer.lessonId ?? 0);
    }
  }

  // Navigate to a specific lesson by ID
  Future<void> navigateToLesson(int lessonId) async {
    // Show loading dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      developer.log('🔍 Searching for lesson $lessonId...', name: 'HomeController');

      // Get division ID
      final divisionId = storageService.currentUser?.divisionId ?? storageService.guestDivisionId;
      if (divisionId == null) {
        developer.log('❌ No division ID found', name: 'HomeController');
        Get.back(); // Close loading dialog
        AppDialog.showError(message: 'حدث خطأ، يرجى تسجيل الدخول مرة أخرى');
        return;
      }

      // Get all subjects for this division
      final subjectsResponse = await subjectsProvider.getSubjectsByDivision(divisionId);
      if (!subjectsResponse.success || subjectsResponse.data.isEmpty) {
        developer.log('❌ No subjects found', name: 'HomeController');
        Get.back(); // Close loading dialog
        AppDialog.showError(message: 'لم يتم العثور على المواد');
        return;
      }

      // Search through subjects and units to find the lesson
      for (final subject in subjectsResponse.data) {
        try {
          final unitsResponse = await subjectsProvider.getSubjectUnits(subject.id);
          if (unitsResponse.success && unitsResponse.data.isNotEmpty) {
            for (final unit in unitsResponse.data) {
              try {
                final lessonsResponse = await subjectsProvider.getUnitLessons(unit.id);
                if (lessonsResponse.status && lessonsResponse.data.lessons.isNotEmpty) {
                  // Check if this unit contains our lesson
                  final lesson = lessonsResponse.data.lessons.firstWhereOrNull(
                    (l) => l.id == lessonId,
                  );

                  if (lesson != null) {
                    developer.log('✅ Found lesson in unit: ${unit.name}', name: 'HomeController');

                    // Close loading dialog
                    Get.back();

                    // Create and register the LessonDetailController
                    Get.put(LessonDetailController());

                    // Navigate to LessonDetailView
                    await Get.to(
                      () => LessonDetailView(unit: unit),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );

                    // Auto-play the specific lesson video after navigation
                    Future.delayed(const Duration(milliseconds: 800), () {
                      try {
                        final controller = Get.find<LessonDetailController>();
                        controller.playLessonVideo(lessonId);
                      } catch (e) {
                        developer.log('⚠️ Error auto-playing lesson: $e', name: 'HomeController');
                      }
                    });

                    return;
                  }
                }
              } catch (e) {
                developer.log('⚠️ Error checking unit ${unit.id}: $e', name: 'HomeController');
                continue;
              }
            }
          }
        } catch (e) {
          developer.log('⚠️ Error checking subject ${subject.id}: $e', name: 'HomeController');
          continue;
        }
      }

      // If we get here, lesson was not found
      developer.log('❌ Lesson $lessonId not found', name: 'HomeController');
      Get.back(); // Close loading dialog
      AppDialog.showError(message: 'الدرس غير متاح حالياً');

    } catch (e) {
      developer.log('❌ Error navigating to lesson: $e', name: 'HomeController');
      Get.back(); // Close loading dialog
      AppDialog.showError(message: 'حدث خطأ أثناء فتح الدرس');
    }
  }

  // Load subjects data from API
  Future<void> loadSubjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSubscriptionExpired.value = false;

      // Get division ID from logged in user or guest
      final divisionId = storageService.currentUser?.divisionId ?? storageService.guestDivisionId;

      if (divisionId == null) {
        developer.log('❌ No division ID found for user', name: 'HomeController');
        isLoading.value = false;
        return;
      }

      developer.log('📚 Loading subjects for division: $divisionId', name: 'HomeController');

      final response = await subjectsProvider.getSubjectsByDivision(divisionId);

      if (response.success) {
        subjects.value = response.data;
        developer.log('✅ Subjects loaded: ${subjects.length} subjects', name: 'HomeController');
      } else {
        developer.log('❌ Failed to load subjects', name: 'HomeController');
      }
    } catch (e) {
      developer.log('❌ Error loading subjects: $e', name: 'HomeController');

      // Handle subscription expired error
      if (e.toString().contains('Subscription expired') ||
          (e is ApiErrorModel && e.message?.contains('Subscription expired') == true)) {
        isSubscriptionExpired.value = true;
        errorMessage.value = 'انتهت صلاحية الاشتراك';
      } else if (e is ApiErrorModel) {
        errorMessage.value = e.displayMessage;
      } else {
        errorMessage.value = 'حدث خطأ أثناء تحميل المواد';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Update carousel index
  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  // Handle notification tap
  void onNotificationTap() {
    Get.toNamed('/notifications');
  }

  // Handle subject tap
  void onSubjectTap(SubjectModel subject) {
    // Load data for this subject
    try {
      final subjectsController = Get.find<SubjectsController>();
      final isGuestMode = !storageService.isLoggedIn;

      // Always load units
      subjectsController.loadUnits(subject.id);

      // Only load these for authenticated users
      if (!isGuestMode) {
        subjectsController.loadReferences(subject.id);
        subjectsController.loadSolvedExercises(subject.id);
        subjectsController.loadQuizzes(subject.id);
      }
    } catch (e) {
      developer.log('❌ Error getting SubjectsController: $e', name: 'HomeController');
    }

    // Navigate to subject details page
    Get.to(
      () => SubjectDetailView(subject: subject),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Handle view all subjects tap
  void onViewAllSubjectsTap() {
    // Navigate to subjects tab in bottom navigation
    final parentController = Get.find<ParentController>();
    // Subjects tab is at index 1 for Arabic, index 2 for non-Arabic
    final subjectsIndex = parentController.isArabic ? 1 : 2;
    parentController.changePage(subjectsIndex);
  }

  // Handle profile tap
  void onProfileTap() {
    Get.toNamed(Routes.PROFILE);
  }

  // Search for lessons
  Future<void> searchLessons(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      searchQuery.value = '';
      return;
    }

    try {
      isSearching.value = true;
      searchQuery.value = query;

      developer.log('🔍 Searching for lessons: $query', name: 'HomeController');

      final response = await homeProvider.searchLessons(query: query);
      searchResults.value = response.items;

      developer.log('✅ Search results: ${searchResults.length} lessons found', name: 'HomeController');
    } catch (e) {
      developer.log('❌ Error searching lessons: $e', name: 'HomeController');
      if (e is ApiErrorModel) {
        AppDialog.showError(message: e.displayMessage);
      } else {
        AppDialog.showError(message: 'حدث خطأ أثناء البحث');
      }
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
  }

  // Navigate to lesson from search result
  void onSearchResultTap(LessonSearchItem lesson) {
    developer.log('🎯 Opening lesson from search: ${lesson.id} - ${lesson.name}', name: 'HomeController');

    // Navigate to lesson detail view and load the single lesson
    Get.delete<LessonDetailController>(); // Clean up any existing controller

    Get.to(
      () => const LessonDetailView(),
      binding: BindingsBuilder(() {
        final controller = Get.put(LessonDetailController());
        // Load and play the lesson directly
        controller.loadSingleLessonAndPlay(lesson.id, lesson.name);
      }),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
