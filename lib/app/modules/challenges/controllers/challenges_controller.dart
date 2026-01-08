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
          title: 'تحدي الأسبوع',
          subtitle: 'أكمل 5 دروس هذا الأسبوع',
          isCompleted: false,
          points: 100,
        ),
        ChallengeModel(
          id: '2',
          title: 'تحدي الاختبارات',
          subtitle: 'احصل على 90% في 3 اختبارات',
          isCompleted: true,
          points: 150,
        ),
        ChallengeModel(
          id: '3',
          title: 'تحدي المثابرة',
          subtitle: 'ادخل التطبيق 7 أيام متتالية',
          isCompleted: false,
          points: 200,
        ),
        ChallengeModel(
          id: '4',
          title: 'تحدي السرعة',
          subtitle: 'أكمل درس في أقل من 10 دقائق',
          isCompleted: false,
          points: 50,
        ),
        ChallengeModel(
          id: '5',
          title: 'تحدي التفوق',
          subtitle: 'احصل على الدرجة الكاملة في اختبار',
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
        message: 'لقد أكملت هذا التحدي وحصلت على ${challenge.points} نقطة',
      );
    } else {
      AppDialog.showInfo(
        message: '${challenge.title}\n${challenge.subtitle}',
      );
    }
  }
}
