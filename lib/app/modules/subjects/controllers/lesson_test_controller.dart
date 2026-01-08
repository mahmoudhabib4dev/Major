import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../models/lesson_test_response_model.dart';

class LessonTestController extends GetxController {
  final LessonTestData testData;
  final int lessonId;

  LessonTestController({
    required this.testData,
    required this.lessonId,
  });

  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<int, int> selectedAnswers = <int, int>{}.obs;
  final RxBool isFinished = false.obs;

  // Get current question
  TestQuestion get currentQuestion => testData.questions[currentQuestionIndex.value];

  // Get total questions
  int get totalQuestions => testData.questions.length;

  // Select an answer for current question
  void selectAnswer(int answerIndex) {
    selectedAnswers[currentQuestion.id] = answerIndex;
    developer.log('Selected answer $answerIndex for question ${currentQuestion.id}', name: 'LessonTestController');
  }

  // Go to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < totalQuestions - 1) {
      currentQuestionIndex.value++;
    } else {
      finishTest();
    }
  }

  // Go to previous question
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  // Finish the test
  void finishTest() {
    isFinished.value = true;
    developer.log('Test finished', name: 'LessonTestController');
  }

  // Calculate score
  int calculateScore() {
    int correct = 0;
    for (var question in testData.questions) {
      final selectedAnswer = selectedAnswers[question.id];
      if (selectedAnswer == question.rightAnswer) {
        correct++;
      }
    }
    return correct;
  }

  // Check if current question is answered
  bool isCurrentQuestionAnswered() {
    return selectedAnswers.containsKey(currentQuestion.id);
  }

  // Get selected answer for current question
  int? getSelectedAnswer() {
    return selectedAnswers[currentQuestion.id];
  }
}
