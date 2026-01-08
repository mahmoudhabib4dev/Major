import 'package:get/get.dart';
import 'package:maajor/app/modules/subjects/controllers/subjects_controller.dart';

import '../../home/controllers/home_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../authentication/providers/auth_provider.dart';
import '../controllers/parent_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(),
    );

    // Parent controller
    Get.lazyPut<ParentController>(
      () => ParentController(),
    );

    // Child page controllers
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
   Get.lazyPut<SubjectsController>(
      () => SubjectsController(),
    );
    Get.lazyPut<FavoriteController>(
      () => FavoriteController(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
