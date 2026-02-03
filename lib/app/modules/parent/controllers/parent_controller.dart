import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../challenges/views/challenges_view.dart';
import '../../challenges/bindings/challenges_binding.dart';
import '../../subjects/controllers/subjects_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_pages.dart';

class ParentController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Guest mode check
  bool get isGuest {
    return !_storageService.isLoggedIn || _storageService.authToken == null;
  }

  // Subscription status check
  bool get hasActiveSubscription {
    final user = _storageService.currentUser;
    return user != null && user.planStatus == 'active';
  }
  // Current page index - dynamically set based on language
  late final RxInt currentIndex;

  // List of page titles
  late final List<String> pageTitles;

  // Hide FAB when search is focused
  final RxBool hideFAB = false.obs;

  // Check if current language is Arabic
  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();

    // Use same page order for all languages: 0=Home, 1=Subjects, 2=Favorite, 3=Profile
    currentIndex = 0.obs;

    // Page titles in same order for all languages
    pageTitles = [
      'home'.tr,
      'subjects'.tr,
      'favorites'.tr,
      'profile'.tr,
    ];
  }

  // Change current page
  void changePage(int index) {
    // Refresh profile data when switching to Home tab (index 0)
    if (index == 0) {
      currentIndex.value = index;
      try {
        final homeController = Get.find<HomeController>();
        // Refresh user data to get fresh profile image URL
        homeController.refreshUserDataFromApi();
      } catch (e) {
        // Controller might not be initialized yet
      }
      return;
    }

    // Refresh profile data when switching to Profile tab (index 3)
    if (index == 3) {
      currentIndex.value = index;
      try {
        final profileController = Get.find<ProfileController>();
        // Refresh profile data to get fresh profile image URL
        profileController.refreshProfileData();
      } catch (e) {
        // Controller might not be initialized yet
      }
      return;
    }

    // Load subjects when subjects tab is selected (index 1)
    if (index == 1) {
      currentIndex.value = index;
      try {
        final subjectsController = Get.find<SubjectsController>();
        // Only load if not already loaded or loading
        if (subjectsController.subjects.isEmpty && !subjectsController.isLoading.value) {
          subjectsController.loadSubjects();
        }
      } catch (e) {
        // Controller might not be initialized yet
      }
      return;
    }

    // Check for favorites tab selection (index 2)
    if (index == 2) {
      // Show login dialog if user is in guest mode
      if (isGuest) {
        _showLoginDialog();
        return; // Don't change the page
      }

      currentIndex.value = index;
      try {
        final favoriteController = Get.find<FavoriteController>();
        // Always reload favorites and downloaded videos to get latest data
        favoriteController.loadFavorites();
        favoriteController.loadDownloadedVideos();
      } catch (e) {
        // Controller might not be initialized yet
      }
      return;
    }

    // For other tabs, just change the page
    currentIndex.value = index;
  }

  // Show login dialog for guest users trying to access favorites
  void _showLoginDialog() {
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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'login_required'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'login_to_access_favorites'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderPrimary, width: 1.5),
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
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Login button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        await _storageService.clearGuestData();
                        Get.offAllNamed(Routes.AUTHENTICATION);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'login'.tr,
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
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Navigate to challenges page
  void navigateToPremium() {
    // Check if user is guest
    if (isGuest) {
      _showLoginDialog();
      return;
    }

    // Check if user has active subscription
    if (!hasActiveSubscription) {
      _showSubscriptionDialog();
      return;
    }

    // User is logged in and has subscription, navigate to challenges
    Get.to(
      () => const ChallengesView(),
      binding: ChallengesBinding(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Show subscription dialog for users without active subscription
  void _showSubscriptionDialog() {
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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'subscription_required'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'subscribe_to_access_challenges'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderPrimary, width: 1.5),
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
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Subscribe button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.toNamed(Routes.SUBSCRIPTION);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'subscribe_now'.tr,
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
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Get current page title
  String get currentPageTitle => pageTitles[currentIndex.value];

  // Set FAB visibility
  void setFABVisibility(bool hide) {
    hideFAB.value = hide;
  }
}
