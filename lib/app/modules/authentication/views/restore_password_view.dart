import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/restore_password_form.dart';

class RestorePasswordView extends GetView<AuthenticationController> {
  const RestorePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Obx(() {
        return AppScaffold(
          backgroundImage: AppImages.image2,
          showContentContainer: true,
          headerChildren: controller.isSignUpMode.value && controller.isActiveRegistrationSession.value
              ? [
                  SizedBox(height: screenSize.height * 0.06),
                  _buildHeader(context),
                  SizedBox(height: screenSize.height * 0.08),
                ]
              : null,
          children: const [
            RestorePasswordForm(),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (appears on the left in LTR, right in RTL)
          if (!isRtl)
            GestureDetector(
              onTap: controller.backToSignUpFromOtp,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox.shrink(), // Empty center
          // Back button (appears on the right in RTL, spacer in LTR)
          if (isRtl)
            GestureDetector(
              onTap: controller.backToSignUpFromOtp,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 28,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}
