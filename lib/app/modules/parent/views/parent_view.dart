import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_view.dart';
import '../../subjects/views/subjects_view.dart';
import '../../favorite/views/favorite_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/parent_controller.dart';

class ParentView extends GetView<ParentController> {
  const ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Check if current language is Arabic (RTL)
    final isArabic = Get.locale?.languageCode == 'ar';

    // Reorder pages based on language (mirror for Arabic)
    final List<Widget> pages = isArabic
        ? [
            const HomeView(),
            const SubjectsView(),
            const FavoriteView(),
            const ProfileView(),
          ]
        : [
            const ProfileView(),
            const FavoriteView(),
            const SubjectsView(),
            const HomeView(),
          ];

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),
      floatingActionButton: Obx(
        () => controller.hideFAB.value
            ? const SizedBox.shrink()
            : SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: controller.navigateToPremium,
                  backgroundColor: AppColors.primary,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: Image.asset(
                    AppImages.icon13,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedBottomNavigationBar.builder(
            itemCount: 4,
            tabBuilder: (int index, bool isActive) {
              return _buildNavItem(
                context,
                index: index,
                isActive: isActive,
              );
            },
            activeIndex: controller.currentIndex.value,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 12,
            rightCornerRadius: 12,
            onTap: controller.changePage,
            backgroundColor: AppColors.white,
            height: 55,
            splashColor: AppColors.primary.withValues(alpha: 0.1),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required bool isActive,
  }) {
    // Check if current language is Arabic (RTL)
    final isArabic = Get.locale?.languageCode == 'ar';

    // Reorder icons based on language (mirror for Arabic)
    final icons = isArabic
        ? [
            {'unselected': AppImages.icon5, 'selected': AppImages.icon6},   // Home
            {'unselected': AppImages.icon11, 'selected': AppImages.icon12}, // Subjects
            {'unselected': AppImages.icon7, 'selected': AppImages.icon8},   // Favorite
            {'unselected': AppImages.icon9, 'selected': AppImages.icon10},  // Profile
          ]
        : [
            {'unselected': AppImages.icon9, 'selected': AppImages.icon10},  // Profile
            {'unselected': AppImages.icon7, 'selected': AppImages.icon8},   // Favorite
            {'unselected': AppImages.icon11, 'selected': AppImages.icon12}, // Subjects
            {'unselected': AppImages.icon5, 'selected': AppImages.icon6},   // Home
          ];

    final iconPath = isActive ? icons[index]['selected']! : icons[index]['unselected']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }
}
