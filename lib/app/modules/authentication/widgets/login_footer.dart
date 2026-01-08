import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../controllers/authentication_controller.dart';

class LoginFooter extends GetView<AuthenticationController> {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: controller.createAccount,
        child: RichText(
          text: TextSpan(
            text: 'new_here'.tr,
            style: AppTextStyles.footerNormalText(context),
            children: [
              TextSpan(
                text: 'create_account'.tr,
                style: AppTextStyles.footerLinkText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
