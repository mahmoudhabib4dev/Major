import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:maajor/app/core/constants/api_constants.dart';
import 'package:maajor/app/modules/subjects/views/pdf_viewer_screen.dart';
import 'package:maajor/app/modules/subjects/views/video_player_screen.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_loader.dart';
import '../models/pdf_resource_model.dart';
import '../controllers/subjects_controller.dart';

class PdfListView extends GetView<SubjectsController> {
  final String pageTitle;
  final RxList<PDFResourceModel> pdfList;
  final RxBool isLoading;

  const PdfListView({
    super.key,
    required this.pageTitle,
    required this.pdfList,
    required this.isLoading,
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
                      // Spacer (right side in RTL)
                      const SizedBox(width: 48),
                      // Title
                      Expanded(
                        child: Text(
                          pageTitle,
                          style: AppTextStyles.subjectDetailTitle(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Back button (left side in RTL)
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
            // White container with PDF list
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
                          if (isLoading.value) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: screenSize.height * 0.2),
                                child: const AppLoader(size: 60),
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
                                children: [
                                  SizedBox(height: screenSize.height * 0.03),
                                  // PDF list
                                  if (pdfList.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: screenSize.height * 0.15),
                                      child: Text(
                                        'no_data_available'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  else
                                    ...pdfList.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final pdf = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: FadeInUp(
                                          duration: const Duration(milliseconds: 600),
                                          delay: Duration(milliseconds: 100 * index),
                                          child: _buildPdfCard(context, screenSize, pdf),
                                        ),
                                      );
                                    }),
                                  SizedBox(height: screenSize.height * 0.15),
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

  Widget _buildPdfCard(BuildContext context, Size screenSize, PDFResourceModel resource) {
    return GestureDetector(
      onTap: () {
        // Check if it's a video
        if (resource.isVideo) {
          // Open video in video player
          final videoUrl = resource.videoUrl!;
          Get.to(
            () => VideoPlayerScreen(
              videoUrl: videoUrl,
              title: resource.name,
            ),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        }
        // Check if it's a PDF
        else if (resource.isPdf) {
          // Check if the URL is already complete (starts with http/https)
          final pdfUrl = resource.pdfFile!.startsWith('http')
              ? resource.pdfFile!
              : '${ApiConstants.storageUrl}/${resource.pdfFile}';
          Get.to(
            () => PdfViewerScreen(
              pdfUrl: pdfUrl,
              title: resource.name,
            ),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          AppDialog.showError(
            message: 'لا يوجد ملف متاح',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Icon (right side in RTL) - PDF or Video
            if (resource.isVideo)
              // Video icon
              Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: Color(0xFFFF6B6B),
                  size: 32,
                ),
              )
            else
              // PDF icon
              Image.asset(
                AppImages.icon55,
                width: 48,
                height: 56,
              ),
            const SizedBox(width: 16),
            // Title (left side in RTL)
            Expanded(
              child: Text(
                resource.name,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000D47),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for the wavy top edge
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    path.lineTo(0, notchRadius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, notchRadius);

    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(notchCenterX + notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchCenterX,
      -notchRadius * 0.5,
      notchCenterX - notchWidth / 2,
      0,
    );

    path.lineTo(notchRadius, 0);

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
