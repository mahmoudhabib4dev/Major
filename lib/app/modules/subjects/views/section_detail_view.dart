import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/api_image.dart';
import '../controllers/lesson_detail_controller.dart';
import '../controllers/subjects_controller.dart';
import 'lesson_detail_view.dart';

class SectionDetailView extends GetView<SubjectsController> {
  final String sectionTitle;

  const SectionDetailView({
    super.key,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (right side in RTL)
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          sectionTitle,
                          style: AppTextStyles.subjectDetailTitle(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Spacer (left side in RTL)
                      const SizedBox(width: 48),
                    ],
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
                        child: Obx(() {
                          if (controller.isLoadingUnits.value) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: screenSize.height * 0.2),
                                child: const CircularProgressIndicator(
                                  color: Color(0xFF000D47),
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.05,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: screenSize.height * 0.03),
                                  // Statistics section
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 800),
                                    delay: const Duration(milliseconds: 200),
                                    child: _buildStatisticsSection(context, screenSize),
                                  ),
                                  SizedBox(height: screenSize.height * 0.03),
                                  // Topics grid
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 800),
                                    delay: const Duration(milliseconds: 300),
                                    child: _buildTopicsGrid(context, screenSize),
                                  ),
                                  SizedBox(height: screenSize.height * 0.35),
                                ],
                              ),
                            ),
                          );
                        }),
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

  // Build statistics section
  Widget _buildStatisticsSection(BuildContext context, Size screenSize) {
    // Calculate total lessons across all units
    final totalLessons = controller.units.fold<int>(
      0,
      (sum, unit) => sum + unit.lessons.length,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'number_of_students'.tr,
            'students_count'.tr.replaceAll('@count', '30'),
            AppImages.icon24,
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            context,
            'number_of_hours'.tr,
            'hours_count'.tr.replaceAll('@count', '36'),
            AppImages.icon24,
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            context,
            'number_of_topics'.tr,
            'topics_count'.tr.replaceAll('@count', '${controller.units.length}'),
            AppImages.icon25,
          ),
        ],
      ),
    );
  }

  // Build individual stat item
  Widget _buildStatItem(BuildContext context, String label, String value, String iconPath) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 28,
          height: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.statisticsLabel(context),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.statisticsValue(context),
        ),
      ],
    );
  }

  // Build topics grid
  Widget _buildTopicsGrid(BuildContext context, Size screenSize) {
    // Check if units list is empty
    if (controller.units.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: screenSize.height * 0.1),
        child: Text(
          'no_data_available'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
      ),
      itemCount: controller.units.length,
      itemBuilder: (context, index) {
        final unit = controller.units[index];

        return _buildTopicCard(
          context,
          unit,
        );
      },
    );
  }

  // Build individual topic card
  Widget _buildTopicCard(BuildContext context, unit) {
    return InkWell(
      onTap: () {
        Get.to(
          () => LessonDetailView(unit: unit),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LessonDetailController());
          }),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Unit image
            unit.image != null && unit.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ApiImage(
                      imageUrl: unit.image!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorWidget: Image.asset(
                        AppImages.icon19,
                        width: 88,
                        height: 88,
                      ),
                    ),
                  )
                : Image.asset(
                    AppImages.icon19,
                    width: 88,
                    height: 88,
                  ),
            const SizedBox(height: 12),
            // Title
            Text(
              unit.name,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
