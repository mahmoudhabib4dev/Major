import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_page_header_widget.dart';

class PrivacyPolicyView extends GetView<ProfileController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load privacy policy when page opens
    controller.loadPrivacyPolicy();

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'privacy_policy'.tr,
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
                  if (controller.isLoadingPrivacyPolicy.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    );
                  }

                  if (controller.privacyPolicyDescription.value.isEmpty) {
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
                        controller.privacyPolicyDescription.value,
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
