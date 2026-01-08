import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_page_header_widget.dart';

class TermsView extends GetView<ProfileController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load terms when page opens
    controller.loadTerms();

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'terms_and_conditions'.tr,
            onBack: () => Get.back(),
          ),
        ),
      ],
      sliverChildren: [
        SliverPadding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: screenSize.height * 0.02),
              // Content from API
              Obx(
                () {
                  if (controller.isLoadingTerms.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    );
                  }

                  if (controller.termsDescription.value.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                        child: Text(
                          'no_content_available'.tr,
                          style: AppTextStyles.bodyText(context),
                        ),
                      ),
                    );
                  }

                  return FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        controller.termsDescription.value,
                        style: AppTextStyles.bodyText(context),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenSize.height * 0.1),
            ]),
          ),
        ),
      ],
    );
  }

}
