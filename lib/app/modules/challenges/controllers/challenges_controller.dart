import 'package:get/get.dart';
import '../../../core/widgets/app_dialog.dart';

class ChallengeModel {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final int points;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.points = 0,
  });
}

class ChallengesController extends GetxController {
  // Observable list of challenges
  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  // Load challenges (mock data for now)
  void loadChallenges() {
    isLoading.value = true;

    // Simulating API call with mock data
    Future.delayed(const Duration(milliseconds: 500), () {
      challenges.value = [
        ChallengeModel(
          id: '1',
          title: 'challenge_week_title'.tr,
          subtitle: 'challenge_week_subtitle'.tr,
          isCompleted: false,
          points: 100,
        ),
        ChallengeModel(
          id: '2',
          title: 'challenge_tests_title'.tr,
          subtitle: 'challenge_tests_subtitle'.tr,
          isCompleted: true,
          points: 150,
        ),
        ChallengeModel(
          id: '3',
          title: 'challenge_persistence_title'.tr,
          subtitle: 'challenge_persistence_subtitle'.tr,
          isCompleted: false,
          points: 200,
        ),
        ChallengeModel(
          id: '4',
          title: 'challenge_speed_title'.tr,
          subtitle: 'challenge_speed_subtitle'.tr,
          isCompleted: false,
          points: 50,
        ),
        ChallengeModel(
          id: '5',
          title: 'challenge_excellence_title'.tr,
          subtitle: 'challenge_excellence_subtitle'.tr,
          isCompleted: true,
          points: 250,
        ),
      ];
      isLoading.value = false;
    });
  }

  // Handle challenge tap
  void onChallengeTap(ChallengeModel challenge) {
    if (challenge.isCompleted) {
      AppDialog.showSuccess(
        message: 'challenge_completed_points'.tr.replaceAll('@points', '${challenge.points}'),
      );
    } else {
      AppDialog.showInfo(
        message: '${challenge.title}\n${challenge.subtitle}',
      );
    }
  }
}
