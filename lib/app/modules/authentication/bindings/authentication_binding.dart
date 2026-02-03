import 'package:get/get.dart';

import '../controllers/authentication_controller.dart';
import '../providers/auth_provider.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthProvider>(
      AuthProvider(),
      permanent: true,
    );
    Get.lazyPut<AuthenticationController>(
      () => AuthenticationController(),
    );
  }
}
