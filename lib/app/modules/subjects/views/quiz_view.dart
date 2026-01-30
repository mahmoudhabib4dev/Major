import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/quiz_controller.dart';
import '../models/self_test_question_model.dart';
import '../models/test_start_response_model.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          AppScaffold(
            backgroundImage: AppImages.image2,
            showContentContainer: true,
            headerChildren: [
        SizedBox(height: screenSize.height * 0.18),
        // Header with time and title
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
            ),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Title - truly centered
                  Center(
                    child: Text(
                      controller.lessonTitle,
                      style: AppTextStyles.sectionTitle(context).copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Back arrow (right side in RTL)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Time indicator (left side in RTL)
                  Positioned(
                    left: 0,
                    child: Obx(() => Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.icon63,
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.formattedTime,
                            style: const TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000D47),
                              height: 1.0,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.03),
      ],
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                child: const CircularProgressIndicator(
                  color: Color(0xFF000D47),
                ),
              ),
            );
          }

          if (controller.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.2),
                child: Text(
                  'لا توجد أسئلة متاحة',
                  style: AppTextStyles.bodyText(context),
                ),
              ),
            );
          }

          return Column(
            children: [
        // Progress indicators
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Obx(() => _buildProgressIndicators(context)),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Progress bar
        FadeInUp(
          duration: const Duration(milliseconds: 700),
          delay: const Duration(milliseconds: 300),
          child: Obx(() => _buildProgressBar(context)),
        ),
        SizedBox(height: screenSize.height * 0.03),
        FadeIn(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 350),
          child: Divider(color: AppColors.grey200, height: 1),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Question
        Obx(() => _buildQuestion(context)),
        SizedBox(height: screenSize.height * 0.03),
        // Answer options
        Obx(() => _buildAnswerOptions(context)),
        const SizedBox(height: 120), // Extra space for fixed button
            ],
          );
        }),
      ],
    ),
    // Fixed navigation buttons at bottom
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: screenSize.width * 0.05,
          right: screenSize.width * 0.05,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => _buildNavigationButtons(context)),
      ),
    ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
    return SizedBox(
      height: 37,
      child: ListView.builder(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: controller.questions.length,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        itemBuilder: (context, index) {
          final number = index + 1;
          final isCurrent = index == controller.currentQuestionIndex.value;
          final isAnswered = controller.userAnswers.containsKey(index);

          // Determine colors based on state
          Color backgroundColor;
          Color textColor;

          if (isCurrent) {
            backgroundColor = AppColors.primary;
            textColor = Colors.white;
          } else if (isAnswered) {
            backgroundColor = AppColors.success;
            textColor = Colors.white;
          } else {
            backgroundColor = AppColors.grey200;
            textColor = AppColors.grey500;
          }

          // Only allow tapping on current or future questions (not previous answered ones)
          final canTap = index >= controller.currentQuestionIndex.value;

          return GestureDetector(
            onTap: canTap ? () => controller.goToQuestion(index) : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 37,
              height: 37,
              padding: const EdgeInsets.only(top: 3.5, right: 1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = (controller.currentQuestionIndex.value + 1) / controller.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = controller.questions[controller.currentQuestionIndex.value];
    return Column(
      children: [
        CustomPaint(
          painter: _MessageBubblePainter(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.spacing(context, 0.04)),
            child: Text(
              question.question,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                height: 1.0,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // Show correct answer after checking answer (when wrong)
        if (controller.showExplanation.value) ...[
          // Get correct answer from the question
          () {
            int? rightAnswer;
            Map<String, String?>? options;
            if (question is SelfTestQuestionModel) {
              rightAnswer = question.rightAnswer;
              options = question.options;
            } else if (question is TestQuestionModel) {
              rightAnswer = question.rightAnswer;
              options = question.options;
            } else {
              rightAnswer = (question as dynamic).rightAnswer;
              options = (question as dynamic).options as Map<String, String?>?;
            }

            // Only show if answer is wrong and we have the correct answer
            if (rightAnswer != null && controller.isCorrectAnswer.value == false) {
              // Get the correct answer text
              final correctAnswerText = options?[rightAnswer.toString()] ?? '';

              return Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppDimensions.spacing(context, 0.04)),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الجواب الصحيح:',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          correctAnswerText,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }(),
        ],
      ],
    );
  }

  Widget _buildAnswerOptions(BuildContext context) {
    final question = controller.questions[controller.currentQuestionIndex.value];
    final validOptions = question.getValidOptions();

    return Column(
      children: List.generate(validOptions.length, (index) {
        final optionKey = question.getOptionKey(index)!;
        final optionLabel = (index + 1).toString(); // 1, 2, 3, 4
        final isSelected = controller.selectedAnswerKey.value == optionKey;

        // Get the correct answer key
        int? correctAnswerIndex;
        if (question is SelfTestQuestionModel) {
          correctAnswerIndex = question.rightAnswer;
        } else if (question is TestQuestionModel) {
          correctAnswerIndex = question.rightAnswer;
        } else {
          correctAnswerIndex = (question as dynamic).rightAnswer;
        }
        final correctAnswerKey = correctAnswerIndex?.toString();
        final isCorrectAnswer = optionKey == correctAnswerKey;

        Color? backgroundColor;
        Color? borderColor;
        Color? circleColor;
        Color? circleTextColor;
        Color? choiceTextColor;
        Widget? icon;

        if (controller.hasCheckedAnswer.value && isSelected) {
          if (controller.isCorrectAnswer.value == true) {
            backgroundColor = AppColors.success;
            borderColor = AppColors.success;
            icon = Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 24,
              ),
            );
          } else {
            backgroundColor = AppColors.error;
            borderColor = AppColors.error;
            icon = Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.error,
                size: 24,
              ),
            );
          }
        } else if (controller.hasCheckedAnswer.value && isCorrectAnswer && controller.isCorrectAnswer.value == false) {
          // Show correct answer in green when user selected wrong answer
          backgroundColor = AppColors.success;
          borderColor = AppColors.success;
          icon = Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.success,
              size: 24,
            ),
          );
        } else if (isSelected) {
          borderColor = const Color(0xFF000D47);
          circleColor = const Color(0xFF000D47);
          circleTextColor = Colors.white;
          choiceTextColor = const Color(0xFF000D47);
        } else {
          choiceTextColor = const Color(0xFF333333);
        }

        return FadeInRight(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 100 * index),
          child: GestureDetector(
            onTap: controller.hasCheckedAnswer.value
                ? null
                : () => controller.selectAnswer(optionKey),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor ?? const Color(0xFFEAEAEA),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon or label on the right in RTL
                  if (icon != null)
                    icon
                  else
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.only(top: 3.5, right: 1.5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: circleColor ?? AppColors.grey200,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        optionLabel,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.2,
                          color: circleTextColor ?? AppColors.grey700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Text on the left in RTL
                  Expanded(
                    child: Text(
                      validOptions[index],
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: backgroundColor != null ? Colors.white : (choiceTextColor ?? const Color(0xFF333333)),
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final isLastQuestion = controller.currentQuestionIndex.value == controller.questions.length - 1;

    return Center(
      child: SizedBox(
        width: 250,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: controller.selectedAnswerKey.value == null
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF000D47), Color(0xFF5765B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1), // Border width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
            ),
            child: ElevatedButton(
              onPressed: controller.selectedAnswerKey.value == null
                  ? null
                  : () async {
                      if (!controller.hasCheckedAnswer.value) {
                        await controller.checkAnswer();
                      } else {
                        controller.nextQuestion();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: AppColors.grey200,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: Text(
                controller.hasCheckedAnswer.value
                    ? (isLastQuestion ? 'إنهاء الاختبار' : 'next'.tr)
                    : 'check_answer'.tr,
                style: AppTextStyles.buttonText(context).copyWith(
                  color: controller.selectedAnswerKey.value == null
                      ? AppColors.grey500
                      : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Message bubble painter for question container
class _MessageBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFD3D1D1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final radius = 16.0;
    final tailWidth = 12.0;
    final tailHeight = 8.0;
    final tailPosition = size.height * 0.3;

    // Start from top left
    path.moveTo(radius, 0);

    // Top edge
    path.lineTo(size.width - radius, 0);

    // Top right corner
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
    );

    // Right edge with tail
    path.lineTo(size.width, tailPosition - tailHeight / 2);

    // Tail pointing right
    path.lineTo(size.width + tailWidth, tailPosition);
    path.lineTo(size.width, tailPosition + tailHeight / 2);

    // Continue right edge
    path.lineTo(size.width, size.height - radius);

    // Bottom right corner
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
    );

    // Bottom edge
    path.lineTo(radius, size.height);

    // Bottom left corner
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );

    // Left edge
    path.lineTo(0, radius);

    // Top left corner
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
    );

    path.close();

    // Draw fill and border
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
