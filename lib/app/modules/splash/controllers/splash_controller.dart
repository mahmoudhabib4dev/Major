import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  final progress = 0.0.obs;
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _startLoadingAnimation();
  }

  void _startLoadingAnimation() {
    const incrementInterval = Duration(milliseconds: 50);
    const incrementValue = 100 / (5000 / 50); // Smooth increment

    Future.delayed(Duration.zero, () async {
      int count = 0;
      final maxIterations = 5000 ~/ 50;

      while (count < maxIterations && progress.value < 100) {
        await Future.delayed(incrementInterval);
        if (progress.value < 90) {
          progress.value += incrementValue;
        } else {
          // Slow down towards 100%
          progress.value += incrementValue * 0.3;
        }
        count++;
      }

      // Complete the progress
      progress.value = 100;

      // Navigate based on app state
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final route = _storageService.getInitialRoute();
    Get.offNamed(route);
  }
}
