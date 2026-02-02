import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_page_header_widget.dart';

class AboutView extends GetView<ProfileController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load about info and social links when page is built
    controller.loadAboutInfo();
    controller.loadSocialLinks();

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      onRefresh: () => controller.loadAboutInfo(),
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'about'.tr,
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
              // App Logo
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: Image.asset(
                    AppImages.logo,
                    width: 181.76,
                    height: 91.76,
                    fit: BoxFit.contain,
                    
                  ),
                ),
              ),
              //SizedBox(height: screenSize.height * 0.02),
              // App Name
          /*     FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'app_name'.tr,
                  style: AppTextStyles.pageTitle(context),
                  textAlign: TextAlign.center,
                ),
              ), */
              // Version
              // FadeInUp(
              //   duration: const Duration(milliseconds: 500),
              //   delay: const Duration(milliseconds: 150),
              //   child: Obx(
              //     () => Text(
              //       '${'version'.tr} ${controller.appVersion.value}',
              //       style: AppTextStyles.smallText(context),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              // ),
            SizedBox(height: screenSize.height * 0.05),
              // Description
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Obx(
                  () => controller.isLoadingAbout.value
                      ? const Center(
                          child: AppLoader(size: 50),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            controller.aboutDescription.value.isEmpty
                                ? 'app_description'.tr
                                : controller.aboutDescription.value,
                            style: AppTextStyles.bodyText(context).copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
               SizedBox(height: screenSize.height * 0.35),
              // Social Media - Dynamic from API
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 250),
                child: Obx(() {
                  if (controller.isLoadingSocialLinks.value) {
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: AppLoader(size: 40),
                      ),
                    );
                  }

                  // Filter social links that have valid icons
                  final validLinks = controller.socialLinks.where((link) {
                    final icon = controller.getSocialIcon(link.platform);
                    return icon != null;
                  }).toList();

                  if (validLinks.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: validLinks.map((link) {
                        final iconAsset = controller.getSocialIcon(link.platform);
                        return _buildSocialButton(
                          iconAsset: iconAsset!,
                          onTap: () => controller.openSocialLink(link.platform, link.url),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
              SizedBox(height: screenSize.height * 0.04),
              // Divider
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Container(
                  height: 1,
                  color: AppColors.grey300,
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              // Links Section
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 350),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    InkWell(
                      onTap: () => Get.toNamed('/privacy-policy'),
                      child: Text(
                        'privacy_policy'.tr,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.toNamed('/terms'),
                      child: Text(
                        'terms_and_conditions'.tr,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              // Copyright
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 450),
                child: Text(
                  'copyright'.tr,
                  style: AppTextStyles.smallText(context),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenSize.height * 0.1),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset(
          iconAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
