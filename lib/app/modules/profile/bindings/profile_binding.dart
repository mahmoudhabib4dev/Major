import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../authentication/providers/auth_provider.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
