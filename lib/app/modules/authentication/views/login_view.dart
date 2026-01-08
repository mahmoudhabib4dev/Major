import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/animated_login_form.dart';

class LoginView extends GetView<AuthenticationController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        backgroundImage: AppImages.image2,
        showContentContainer: true,
        children: const [
          // Animated login form
          AnimatedLoginForm(),
        ],
      ),
    );
  }
}
