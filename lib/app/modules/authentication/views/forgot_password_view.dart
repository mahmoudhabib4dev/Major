import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordView extends GetView<AuthenticationController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        backgroundImage: AppImages.image2,
        showContentContainer: true,
        children: const [
          ForgotPasswordForm(),
        ],
      ),
    );
  }
}
