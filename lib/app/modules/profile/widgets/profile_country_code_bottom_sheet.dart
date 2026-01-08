import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/profile_controller.dart';

class ProfileCountryCodeBottomSheet extends GetView<ProfileController> {
  const ProfileCountryCodeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ProfileCountryCodeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadius(context, 0.05)),
          topRight: Radius.circular(AppDimensions.borderRadius(context, 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(
              vertical: AppDimensions.spacing(context, 0.02),
            ),
            width: AppDimensions.screenWidth(context) * 0.12,
            height: AppDimensions.spacing(context, 0.01),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.01),
              ),
            ),
          ),

          // Title
          Padding(
            padding: AppDimensions.paddingAll(context, 0.04),
            child: Text(
              'select_country_code'.tr,
              style: AppTextStyles.sectionTitle(context),
            ),
          ),

          // Countries list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.countries.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.grey200,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final country = controller.countries[index];
                return Obx(
                  () => ListTile(
                    contentPadding: AppDimensions.paddingHorizontal(context, 0.04),
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      country['name']!,
                      style: AppTextStyles.bodyText(context),
                    ),
                    trailing: Text(
                      country['code']!,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    selected: controller.selectedCountryCode.value == country['code'],
                    selectedTileColor: AppColors.grey100,
                    onTap: () {
                      controller.updateCountryCode(country['code']!);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        ],
      ),
    );
  }
}
