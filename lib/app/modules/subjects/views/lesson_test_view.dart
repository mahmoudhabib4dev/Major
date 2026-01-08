import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_images.dart';
import '../controllers/lesson_test_controller.dart';

class LessonTestView extends GetView<LessonTestController> {
  const LessonTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.image3),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, screenSize),
                // Content
                Expanded(
                  child: ClipPath(
                    clipper: _TopCurveClipper(),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.05,
                        left: screenSize.width * 0.05,
                        right: screenSize.width * 0.05,
                      ),
                      child: Obx(() => controller.isFinished.value
                          ? _buildResults(context, screenSize)
                          : _buildQuestion(context, screenSize)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              controller.testData.testName,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, Size screenSize) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          Obx(() => Text(
            'سؤال ${controller.currentQuestionIndex.value + 1} من ${controller.totalQuestions}',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 20),
          // Question
          Obx(() => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8F7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              controller.currentQuestion.question,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000D47),
              ),
            ),
          )),
          const SizedBox(height: 30),
          // Options
          Obx(() => Column(
            children: List.generate(
              controller.currentQuestion.options.length,
              (index) => _buildOption(context, index),
            ),
          )),
          const SizedBox(height: 30),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              Obx(() => controller.currentQuestionIndex.value > 0
                  ? ElevatedButton(
                      onPressed: controller.previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000D47),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'السابق',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              // Next button
              Obx(() => ElevatedButton(
                    onPressed: controller.isCurrentQuestionAnswered()
                        ? controller.nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB2B3A),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      controller.currentQuestionIndex.value < controller.totalQuestions - 1
                          ? 'التالي'
                          : 'إنهاء',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, int index) {
    return Obx(() {
      final isSelected = controller.getSelectedAnswer() == (index + 1);
      return GestureDetector(
        onTap: () => controller.selectAnswer(index + 1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4D9F7) : const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF000D47) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF000D47) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFF000D47),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF000D47),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  controller.currentQuestion.options[index],
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: isSelected ? const Color(0xFF000D47) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildResults(BuildContext context, Size screenSize) {
    final score = controller.calculateScore();
    final percentage = (score / controller.totalQuestions * 100).round();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'تم إنهاء الاختبار',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000D47),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'النتيجة: $score من ${controller.totalQuestions}',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFB2B3A),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000D47),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'العودة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    path.lineTo(0, notchRadius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, notchRadius);

    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(notchCenterX + notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchCenterX,
      -notchRadius * 0.5,
      notchCenterX - notchWidth / 2,
      0,
    );

    path.lineTo(notchRadius, 0);

    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
