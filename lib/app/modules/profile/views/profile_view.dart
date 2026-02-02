import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_list_widget.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      onRefresh: controller.onRefresh,
      headerChildren: [
        SafeArea(
          child: FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: SizedBox(
              height: screenSize.height * 0.17,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                child: const ProfileHeaderWidget(),
              ),
            ),
          ),
        ),
      ],
      sliverChildren: const [
        ProfileMenuSliverList(),
      ],
    );
  }
}
