import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../models/subject_model.dart';
import '../controllers/subjects_controller.dart';
import '../controllers/quiz_controller.dart';
import 'section_detail_view.dart';
import 'pdf_list_view.dart';
import 'quiz_view.dart';

class SubjectDetailView extends GetView<SubjectsController> {
  final SubjectModel subject;

  const SubjectDetailView({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final storageService = Get.find<StorageService>();
    final isGuestMode = !storageService.isLoggedIn;
    final isArabic = Get.locale?.languageCode == 'ar';

    // Check subscription status for logged-in users
    final currentUser = storageService.currentUser;
    final hasActiveSubscription = currentUser?.planStatus == 'active';
    final needsSubscription = !isGuestMode && !hasActiveSubscription;

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBody: true,
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.image3),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header with title and back button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.05,
                  bottom: screenSize.height * 0.02,
                  left: screenSize.width * 0.05,
                  right: screenSize.width * 0.05,
                ),
                child: FadeIn(
                  duration: const Duration(milliseconds: 800),
                  // Keep RTL layout for header to maintain arrow position on left
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Spacer to center the title
                        const SizedBox(width: 48),
                        // Title
                        Expanded(
                          child: Text(
                            subject.name,
                            style: AppTextStyles.subjectDetailTitle(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Back button (always on left)
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // White container with content
            Expanded(
              child: ClipPath(
                clipper: _TopCurveClipper(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -(screenSize.width * 0.08) * 0.8,
                      left: 0,
                      right: 0,
                      bottom: -(screenSize.width * 0.08) * 0.8,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: (screenSize.width * 0.08) * 0.8),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: screenSize.height * 0.03),
                                // Test section - Now shown for all users
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildTestSection(context, screenSize, isGuestMode, needsSubscription),
                                ),
                                SizedBox(height: screenSize.height * 0.02),
                                // Educational topics section - Always shown and accessible
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 300),
                                  child: _buildSectionCard(
                                    context,
                                    screenSize,
                                    'educational_topics'.tr,
                                    AppImages.icon17,
                                    isArabic,
                                    () {
                                      // Load units when user taps on educational topics
                                      controller.loadUnits(subject.id);
                                      Get.to(
                                        () => SectionDetailView(
                                          sectionTitle: 'educational_topics'.tr,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
                                  ),
                                ),
                                // Notes section (Exams) - Always shown but requires subscription
                                SizedBox(height: screenSize.height * 0.015),
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 400),
                                  child: _buildSectionCard(
                                    context,
                                    screenSize,
                                    'notes'.tr,
                                    AppImages.icon18,
                                    isArabic,
                                    () {
                                      // Check if user is guest or needs subscription
                                      if (isGuestMode || needsSubscription) {
                                        _showSubscriptionDialog(context, isGuestMode);
                                        return;
                                      }
                                      // Load quizzes when user taps on notes
                                      controller.loadQuizzes(subject.id);
                                      Get.to(
                                        () => PdfListView(
                                          pageTitle: 'notes'.tr,
                                          pdfList: controller.quizzes,
                                          isLoading: controller.isLoadingQuizzes,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.015),
                                // Solved exercises section - Always shown but requires subscription
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 500),
                                  child: _buildSectionCard(
                                    context,
                                    screenSize,
                                    'solved_exercises'.tr,
                                    AppImages.icon19,
                                    isArabic,
                                    () {
                                      // Check if user is guest or needs subscription
                                      if (isGuestMode || needsSubscription) {
                                        _showSubscriptionDialog(context, isGuestMode);
                                        return;
                                      }
                                      // Load solved exercises when user taps on it
                                      controller.loadSolvedExercises(subject.id);
                                      Get.to(
                                        () => PdfListView(
                                          pageTitle: 'solved_exercises'.tr,
                                          pdfList: controller.solvedExercises,
                                          isLoading: controller.isLoadingSolvedExercises,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.015),
                                // PDF references section - Always shown but requires subscription
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 600),
                                  child: _buildSectionCard(
                                    context,
                                    screenSize,
                                    'pdf_references'.tr,
                                    AppImages.icon20,
                                    isArabic,
                                    () {
                                      // Check if user is guest or needs subscription
                                      if (isGuestMode || needsSubscription) {
                                        _showSubscriptionDialog(context, isGuestMode);
                                        return;
                                      }
                                      // Load references when user taps on pdf references
                                      controller.loadReferences(subject.id);
                                      Get.to(
                                        () => PdfListView(
                                          pageTitle: 'pdf_references'.tr,
                                          pdfList: controller.references,
                                          isLoading: controller.isLoadingReferences,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Small dot at top center below the wave
                    Positioned(
                      top: -screenSize.width * 0.025 + 5,
                      left: screenSize.width / 2 - screenSize.width * 0.0125,
                      child: Container(
                        width: screenSize.width * 0.025,
                        height: screenSize.width * 0.025,
                        decoration: const BoxDecoration(
                          color: Color(0xFF000D47),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Build test section with progress
  Widget _buildTestSection(BuildContext context, Size screenSize, bool isGuestMode, bool needsSubscription) {
    return GestureDetector(
      onTap: () {
        // Check if user is in guest mode or needs subscription
        if (isGuestMode || needsSubscription) {
          // Show subscription dialog
          _showSubscriptionDialog(context, isGuestMode);
          return;
        }

        // Delete any existing quiz controller to ensure fresh start
        Get.delete<QuizController>();

        // Initialize the quiz controller with subject ID for self-tests
        // Subject self-tests use the old API (no timer, practice mode)
        Get.put(QuizController(
          lessonTitle: 'اختبار ${subject.name}',
          subjectId: subject.id, // Use subjectId for subject self-tests
        ));
        Get.to(
          () => const QuizView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        )?.then((_) {
          // Delete controller when returning from quiz
          Get.delete<QuizController>();
        });
      },
      child: Container(
        width: 344,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage(AppImages.icon23),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress circle (65%)
          Container(
            margin: EdgeInsets.only(bottom: 40),
            child:   Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle image (22.png)
                  Image.asset(
                    AppImages.icon22,
                    width: 48,
                    height: 48,
                  ),
                  // Percentage text
                  Text(
                    '65%',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),),
            // Text and icon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'subject_test'.tr,
                    style: AppTextStyles.testSectionLabel(context),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Headset icon (21.png) - will appear on right in RTL
                      Image.asset(
                        AppImages.icon21,
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'test_yourself'.tr,
                        style: AppTextStyles.testYourselfLabel(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build section card
  Widget _buildSectionCard(
    BuildContext context,
    Size screenSize,
    String title,
    String iconPath,
    bool isArabic,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 344,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.04,
          vertical: screenSize.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Icon
            Image.asset(
              iconPath,
              width: 88,
              height: 88,
            ),
            SizedBox(width: screenSize.width * 0.03),
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.sectionCardTitle(context),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show registration/subscription dialog
  void _showSubscriptionDialog(BuildContext context, bool isGuestMode) {
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
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGuestMode ? Icons.lock_outline : Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                isGuestMode ? 'login_required'.tr : 'premium_subscription_required'.tr,
                style: TextStyle(
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
                isGuestMode
                    ? 'login_to_access_content'.tr
                    : 'subscribe_to_access_content'.tr,
                style: TextStyle(
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
                        side: BorderSide(color: AppColors.borderPrimary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        if (isGuestMode) {
                          final storage = Get.find<StorageService>();
                          await storage.clearGuestData();
                          Get.offAllNamed('/authentication');
                        } else {
                          Get.toNamed('/subscription');
                        }
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
                        isGuestMode ? 'login'.tr : 'view_subscription_plans'.tr,
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
}

// Custom clipper for the wavy top edge (same as subjects view)
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
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
