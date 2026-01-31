import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/home_controller.dart';
import '../widgets/user_header_widget.dart';
import '../widgets/home_carousel_widget.dart';
import '../widgets/subjects_section_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Obx(() {
        // Show full page loader while initial data is loading
        if (controller.isInitialLoading.value) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.image3),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AppScaffold(
            backgroundImage: AppImages.image3,
            showContentContainer: true,
            headerChildren: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenSize.height * 0.01),
                      // User header with notification and profile
                      const UserHeaderWidget(),
                      SizedBox(height: screenSize.height * 0.025),
                      // Carousel slider with dots indicator
                      const HomeCarouselWidget(),

                      // Space before white container (15px)
                    ],
                  ),
                ),
              ),
            ],
            children: const [
              // Subjects section
              SubjectsSectionWidget(),
            ],
          ),
        );
      }),
    );
  }
}
