import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maajor/app/core/api_client.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../models/self_test_question_model.dart';
import '../models/test_start_response_model.dart';

class QuizController extends GetxController {
  final String lessonTitle;
  final int? subjectId;
  final int? testId; // For starting a test
  final List<dynamic>? initialQuestions; // Can be SelfTestQuestionModel or TestQuestion

  QuizController({
    required this.lessonTitle,
    this.subjectId,
    this.testId,
    this.initialQuestions,
  });

  // Observable state variables
  final currentQuestionIndex = 0.obs;
  final totalQuestions = 0.obs;
  final selectedAnswerKey = Rxn<String>();
  final isCorrectAnswer = Rxn<bool>();
  final hasCheckedAnswer = false.obs;
  final showExplanation = false.obs;
  final isLoading = true.obs;

  // Timer variables
  final remainingSeconds = 0.obs;
  Timer? _timer;

  // Test state
  int? attemptId; // Store the attempt ID from the API
  String testMode = 'test'; // 'test', 'review', or 'finished'
  bool isReviewMode = false;

  // Questions data - can be either SelfTestQuestionModel or TestQuestion
  final questions = <dynamic>[].obs;
  final userAnswers = <int, String>{}.obs; // questionIndex -> optionKey
  final correctAnswersCount = 0.obs;
  final wrongAnswersCount = 0.obs;

  // Scroll controller for progress indicators
  final scrollController = ScrollController();

  final ApiClient apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    if (testId != null) {
      // Lesson tests: Start a test using the test ID (with timer from server)
      startTest();
    } else if (initialQuestions != null && initialQuestions!.isNotEmpty) {
      // Use provided questions (e.g., for lesson tests that don't have test_id)
      _loadProvidedQuestions();
    } else if (subjectId != null) {
      // Subject self-tests: Load from self-tests API (practice mode)
      loadSelfTest();
    }
  }

  void _loadProvidedQuestions() {
    questions.value = initialQuestions!;
    totalQuestions.value = initialQuestions!.length;

    // Start timer - 30 minutes (1800 seconds) for the test
    remainingSeconds.value = 1800;
    _startTimer();

    // Scroll to current question after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentQuestion();
    });

    isLoading.value = false;
  }

  Future<void> startTest() async {
    try {
      isLoading.value = true;
      print('🔵 Starting test with ID: $testId');

      final response = await apiClient.post(
        '${ApiConstants.baseUrl}/tests/$testId/start',
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final testResponse = TestStartResponseModel.fromJson(jsonData);

        // Store test state
        attemptId = testResponse.attemptId;
        testMode = testResponse.mode;

        // Check if test is expired
        final isExpired = testResponse.status == 'expired';
        final hasAnsweredQuestions = testResponse.questions.any((q) => q.studentAnswer != null);

        if (isExpired && !hasAnsweredQuestions) {
          // Expired test with no answers - show message and go back
          print('🔵 Test expired with no answers - showing message and going back');
          AppDialog.showInfo(
            message: 'انتهى وقت الاختبار. يمكنك بدء اختبار جديد.',
          );
          Future.delayed(const Duration(seconds: 2), () {
            Get.back();
          });
          return;
        }

        isReviewMode = testResponse.isReviewMode;

        // Load questions
        questions.value = testResponse.questions;
        totalQuestions.value = testResponse.questionsCount ?? 0;

        print('🔵 Test started successfully');
        print('🔵 Mode: $testMode');
        print('🔵 Attempt ID: $attemptId');
        print('🔵 Is Review Mode: $isReviewMode');
        print('🔵 Questions count: ${questions.length}');

        if (!isReviewMode && testResponse.expiresAt != null) {
          // Calculate timer from server's expires_at if available
          try {
            final expiresAt = DateTime.parse(testResponse.expiresAt!);
            final now = DateTime.now();
            final difference = expiresAt.difference(now);

            if (difference.inSeconds > 0) {
              remainingSeconds.value = difference.inSeconds;
              _startTimer();
            } else {
              // Timer already expired, use default
              remainingSeconds.value = 1800;
              _startTimer();
            }
          } catch (e) {
            print('⚠️ Failed to parse expires_at, using default timer: $e');
            remainingSeconds.value = 1800; // Fallback to 30 minutes
            _startTimer();
          }

          // Handle resume mode - load existing answers and navigate to first unanswered
          if (testMode == 'resume') {
            _loadResumeModeData();
          }
        } else if (!isReviewMode) {
          // No expires_at provided, use default 30 minutes
          remainingSeconds.value = 1800;
          _startTimer();

          // Handle resume mode - load existing answers and navigate to first unanswered
          if (testMode == 'resume') {
            _loadResumeModeData();
          }
        } else {
          // In review mode with actual answers, show previously answered questions
          _loadReviewModeData();
        }

        // Scroll to current question after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentQuestion();
        });
      } else {
        throw Exception('Failed to start test: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error starting test: $e');
      print('❌ Stack trace: $stackTrace');
      AppDialog.showError(
        message: 'فشل بدء الاختبار: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadReviewModeData() {
    // In review mode, the questions already have student_answer and is_correct
    // Pre-populate the UI with the answers and mark as checked
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as TestQuestionModel;
      if (question.studentAnswer != null) {
        userAnswers[i] = question.studentAnswer.toString();

        // Update counters
        if (question.isCorrect == true) {
          correctAnswersCount.value++;
        } else {
          wrongAnswersCount.value++;
        }
      }
    }

    // Mark current question as checked if it was answered
    final currentQuestion = questions[currentQuestionIndex.value] as TestQuestionModel;
    if (currentQuestion.studentAnswer != null) {
      selectedAnswerKey.value = currentQuestion.studentAnswer.toString();
      hasCheckedAnswer.value = true;
      isCorrectAnswer.value = currentQuestion.isCorrect;
      showExplanation.value = currentQuestion.isCorrect == false;
    }
  }

  void _loadResumeModeData() {
    // In resume mode, load existing answers and navigate to first unanswered question
    print('🔵 Loading resume mode data');

    int firstUnansweredIndex = -1;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as TestQuestionModel;
      if (question.studentAnswer != null) {
        // Pre-populate userAnswers with existing answers
        userAnswers[i] = question.studentAnswer.toString();

        // Update counters for already answered questions
        if (question.isCorrect == true) {
          correctAnswersCount.value++;
        } else {
          wrongAnswersCount.value++;
        }

        print('🔵 Question $i already answered: ${question.studentAnswer}, correct: ${question.isCorrect}');
      } else if (firstUnansweredIndex == -1) {
        // Track the first unanswered question
        firstUnansweredIndex = i;
        print('🔵 First unanswered question found at index: $i');
      }
    }

    // Navigate to first unanswered question, or stay at first if all answered
    if (firstUnansweredIndex != -1) {
      currentQuestionIndex.value = firstUnansweredIndex;
      print('🔵 Navigating to first unanswered question: $firstUnansweredIndex');
    } else {
      // All questions answered - stay at first question
      print('🔵 All questions already answered, staying at first question');
    }

    // Reset state for the current question
    _resetQuestionState();
  }

  /// Submits answer to the API and returns whether the answer is correct
  /// Returns null if the API call fails
  Future<bool?> submitAnswer(int questionId, int answer) async {
    try {
      print('🔵 Submitting answer for question $questionId: $answer');
      print('🔵 Attempt ID: $attemptId');
      print('🔵 Subject ID: $subjectId');

      // New API endpoint format: /api/subjects/{attempt_id}/self-test-attempts/{attempt_id}/answer
      // With query parameters: self_test_id and answer
      final response = await apiClient.post(
        '${ApiConstants.baseUrl}/subjects/$attemptId/self-test-attempts/$attemptId/answer?self_test_id=$questionId&answer=$answer',
      );

      print('🔵 Answer submit response status: ${response.statusCode}');
      print('🔵 Answer submit response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // Log the entire response to understand its structure
        print('📝 Full response data: $jsonData');

        // Get the is_correct value from API response
        final isCorrect = jsonData['is_correct'] as bool?;

        // Update the current question with the server response
        // This allows the UI to show the correct answer and explanation
        final currentQuestion = questions[currentQuestionIndex.value];
        if (currentQuestion is TestQuestionModel) {
          // Update the question with the correct answer and explanation from server
          final updatedQuestion = TestQuestionModel(
            id: currentQuestion.id,
            question: currentQuestion.question,
            options: currentQuestion.options,
            rightAnswer: jsonData['right_answer'] as int?,
            explanation: jsonData['explanation'] as String?,
            studentAnswer: answer,
            isCorrect: isCorrect,
          );

          // Replace the question in the list
          questions[currentQuestionIndex.value] = updatedQuestion;

          // Trigger UI update
          questions.refresh();
        }

        return isCorrect;
      } else if (response.statusCode == 422) {
        // Handle validation error - could be "already answered" or "time expired"
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        print('⚠️ Validation error: $jsonData');
        final errorMessage = jsonData['message'] as String? ?? 'حدث خطأ';
        AppDialog.showInfo(
          message: errorMessage,
        );
        return null;
      } else {
        throw Exception('Failed to submit answer: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error submitting answer: $e');
      print('❌ Stack trace: $stackTrace');
      AppDialog.showError(
        message: 'فشل إرسال الإجابة',
      );
      return null;
    }
  }

  Future<void> loadSelfTest() async {
    try {
      isLoading.value = true;
      print('🔵 Loading self-test for subject: $subjectId');

      final response = await apiClient.get(
        '${ApiConstants.baseUrl}/subjects/$subjectId/self-tests',
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      // Check for server errors
      if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        AppDialog.showError(
          message: 'خطأ في الخادم. يرجى المحاولة لاحقاً',
        );
        return;
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ API error: ${response.statusCode}');
        AppDialog.showError(
          message: 'فشل تحميل الاختبار',
        );
        return;
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      print('🔵 JSON decoded successfully');
      print('🔵 JSON data: $jsonData');

      // API returns format: {"mode":"start","attempt_id":7,"expires_at":"...","questions":[...]}
      // Parse using TestStartResponseModel since format is the same
      final testResponse = TestStartResponseModel.fromJson(jsonData);

      // Store test state
      attemptId = testResponse.attemptId;
      testMode = testResponse.mode;

      // Check if test is expired
      final isExpired = testResponse.status == 'expired';
      final hasAnsweredQuestions = testResponse.questions.any((q) => q.studentAnswer != null);

      if (isExpired && !hasAnsweredQuestions) {
        // Expired test with no answers - show message and go back
        print('🔵 Test expired with no answers - showing message and going back');
        AppDialog.showInfo(
          message: 'انتهى وقت الاختبار. يمكنك بدء اختبار جديد.',
        );
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
        return;
      }

      isReviewMode = testResponse.isReviewMode;

      // Load questions
      questions.value = testResponse.questions;
      totalQuestions.value = testResponse.questionsCount ?? testResponse.questions.length;

      print('🔵 Self-test loaded successfully');
      print('🔵 Mode: $testMode');
      print('🔵 Attempt ID: $attemptId');
      print('🔵 Is Review Mode: $isReviewMode');
      print('🔵 Questions count: ${questions.length}');

      if (!isReviewMode && testResponse.expiresAt != null) {
        // Calculate timer from server's expires_at if available
        try {
          final expiresAt = DateTime.parse(testResponse.expiresAt!);
          final now = DateTime.now();
          final difference = expiresAt.difference(now);

          if (difference.inSeconds > 0) {
            remainingSeconds.value = difference.inSeconds;
            _startTimer();
          } else {
            // Timer already expired, use default
            remainingSeconds.value = 1800;
            _startTimer();
          }
        } catch (e) {
          print('⚠️ Failed to parse expires_at, using default timer: $e');
          remainingSeconds.value = 1800; // Fallback to 30 minutes
          _startTimer();
        }

        // Handle resume mode - load existing answers and navigate to first unanswered
        if (testMode == 'resume') {
          _loadResumeModeData();
        }
      } else if (!isReviewMode) {
        // No expires_at provided, use default 30 minutes
        remainingSeconds.value = 1800;
        _startTimer();

        // Handle resume mode - load existing answers and navigate to first unanswered
        if (testMode == 'resume') {
          _loadResumeModeData();
        }
      } else {
        // In review mode with actual answers, show previously answered questions
        _loadReviewModeData();
      }

      // Scroll to current question after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentQuestion();
      });
    } catch (e, stackTrace) {
      print('❌ Error loading self-test: $e');
      print('❌ Stack trace: $stackTrace');
      AppDialog.showError(
        message: 'فشل تحميل الاختبار',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        // Auto submit when time is up
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    _timer?.cancel();
    _showResultsDialog(isTimeUp: true);
  }

  void _showResultsDialog({bool isTimeUp = false}) {
    _timer?.cancel();

    final totalQuestions = questions.length;
    final answeredQuestions = correctAnswersCount.value + wrongAnswersCount.value;
    final unansweredQuestions = totalQuestions - answeredQuestions;
    final scorePercentage = totalQuestions > 0
        ? ((correctAnswersCount.value / totalQuestions) * 100).toInt()
        : 0;

    Get.dialog(
      _QuizResultsDialog(
        isTimeUp: isTimeUp,
        scorePercentage: scorePercentage,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswersCount.value,
        wrongAnswers: wrongAnswersCount.value,
        unansweredQuestions: unansweredQuestions,
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void selectAnswer(String optionKey) {
    // Prevent selection in review mode or if answer already checked
    if (isReviewMode || hasCheckedAnswer.value) {
      return;
    }
    selectedAnswerKey.value = optionKey;
  }

  Future<void> checkAnswer() async {
    // Prevent checking answer in review mode
    if (isReviewMode) return;
    if (questions.isEmpty || selectedAnswerKey.value == null) return;

    final currentQuestion = questions[currentQuestionIndex.value];
    final selectedKey = int.tryParse(selectedAnswerKey.value!);

    // Store the user's answer
    userAnswers[currentQuestionIndex.value] = selectedAnswerKey.value!;
    userAnswers.refresh(); // Trigger UI update for progress indicators

    // Get question ID
    int? questionId;
    if (currentQuestion is SelfTestQuestionModel) {
      questionId = currentQuestion.id;
    } else if (currentQuestion is TestQuestionModel) {
      questionId = currentQuestion.id;
    } else {
      questionId = (currentQuestion as dynamic).id;
    }

    // Submit answer to API first if we have an attemptId (test mode)
    // The API will return whether the answer is correct
    if (attemptId != null && questionId != null && selectedKey != null) {
      final apiResult = await submitAnswer(questionId, selectedKey);

      // Use the API result to determine correctness
      if (apiResult != null) {
        isCorrectAnswer.value = apiResult;
        hasCheckedAnswer.value = true;
        showExplanation.value = !apiResult;

        // Update score counters
        if (apiResult) {
          correctAnswersCount.value++;
        } else {
          wrongAnswersCount.value++;
        }
        return;
      }
    }

    // Fallback: Check answer locally if API call failed or no attemptId
    int? correctAnswer;
    if (currentQuestion is SelfTestQuestionModel) {
      correctAnswer = currentQuestion.rightAnswer;
    } else if (currentQuestion is TestQuestionModel) {
      correctAnswer = currentQuestion.rightAnswer;
    } else {
      correctAnswer = (currentQuestion as dynamic).rightAnswer;
    }

    final isCorrect = correctAnswer != null && selectedKey == correctAnswer;
    isCorrectAnswer.value = isCorrect;
    hasCheckedAnswer.value = true;

    // Show explanation when answer is wrong
    showExplanation.value = !isCorrect;

    // Update score counters
    if (isCorrect) {
      correctAnswersCount.value++;
    } else {
      wrongAnswersCount.value++;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _resetQuestionState();
      _scrollToCurrentQuestion();
    } else {
      // Last question - show results
      _showResultsDialog();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      _resetQuestionState();
      _scrollToCurrentQuestion();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
      _resetQuestionState();
      _scrollToCurrentQuestion();
    }
  }

  void _resetQuestionState() {
    // Check if current question was already answered
    final currentIndex = currentQuestionIndex.value;
    final currentQuestion = questions[currentIndex];

    if (userAnswers.containsKey(currentIndex)) {
      // Question was already answered - show as checked
      selectedAnswerKey.value = userAnswers[currentIndex];
      hasCheckedAnswer.value = true;

      // Check if we have isCorrect from the server (review/resume mode)
      if (currentQuestion is TestQuestionModel && currentQuestion.isCorrect != null) {
        // Use the is_correct field from server (works for both review and resume modes)
        isCorrectAnswer.value = currentQuestion.isCorrect;
        showExplanation.value = currentQuestion.isCorrect == false;
      } else {
        // Fall back to local check using rightAnswer
        int? correctAnswer;
        if (currentQuestion is SelfTestQuestionModel) {
          correctAnswer = currentQuestion.rightAnswer;
        } else if (currentQuestion is TestQuestionModel) {
          correctAnswer = currentQuestion.rightAnswer;
        } else {
          correctAnswer = (currentQuestion as dynamic).rightAnswer;
        }
        final selectedKey = int.tryParse(userAnswers[currentIndex]!);
        isCorrectAnswer.value = correctAnswer != null && selectedKey == correctAnswer;
        showExplanation.value = isCorrectAnswer.value != true;
      }
    } else {
      // Fresh question
      selectedAnswerKey.value = null;
      isCorrectAnswer.value = null;
      hasCheckedAnswer.value = false;
      showExplanation.value = false;
    }
  }

  void _scrollToCurrentQuestion() {
    // Calculate the position to scroll to center the current question
    // Each circle is 37px wide + 8px margin (4px on each side) = 45px total
    final itemWidth = 45.0;
    final screenWidth = 375.0; // approximate screen width
    final position = currentQuestionIndex.value * itemWidth - (screenWidth / 2) + (itemWidth / 2);

    if (scrollController.hasClients) {
      scrollController.animateTo(
        position.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}

// Animated Quiz Results Dialog
class _QuizResultsDialog extends StatefulWidget {
  final bool isTimeUp;
  final int scorePercentage;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;

  const _QuizResultsDialog({
    required this.isTimeUp,
    required this.scorePercentage,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
  });

  @override
  State<_QuizResultsDialog> createState() => _QuizResultsDialogState();
}

class _QuizResultsDialogState extends State<_QuizResultsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _percentageAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller for percentage counter
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animate from 0 to scorePercentage
    _percentageAnimation = IntTween(
      begin: 0,
      end: widget.scorePercentage,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSuccess = widget.scorePercentage >= 50;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: ZoomIn(
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenSize.width * 0.85,
              margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              padding: EdgeInsets.all(screenSize.width * 0.06),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    widget.isTimeUp ? 'انتهى الوقت' : 'نتيجة الاختبار',
                    style: AppTextStyles.sectionTitle(context).copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.isTimeUp) ...[
                  const SizedBox(height: 8),
                  FadeIn(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      'لقد انتهى وقت الاختبار',
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: AppColors.grey500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: screenSize.height * 0.03),
                // Animated percentage circle
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    width: screenSize.width * 0.35,
                    height: screenSize.width * 0.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess
                          ? AppColors.success.withAlpha(25)
                          : AppColors.error.withAlpha(25),
                      border: Border.all(
                        color: isSuccess ? AppColors.success : AppColors.error,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _percentageAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_percentageAnimation.value}%',
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppColors.success : AppColors.error,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                // Stats
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 600),
                  child: _buildStatRow('إجمالي الأسئلة', widget.totalQuestions.toString(), AppColors.primary),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 650),
                  child: _buildStatRow('الإجابات الصحيحة', widget.correctAnswers.toString(), AppColors.success),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 700),
                  child: _buildStatRow('الإجابات الخاطئة', widget.wrongAnswers.toString(), AppColors.error),
                ),
                if (widget.unansweredQuestions > 0) ...[
                  const SizedBox(height: 8),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 750),
                    child: _buildStatRow('لم يتم الإجابة', widget.unansweredQuestions.toString(), AppColors.grey500),
                  ),
                ],
                const SizedBox(height: 8),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 800),
                  child: _buildStatRow('النقاط', '${widget.correctAnswers * 10}', Colors.amber),
                ),
                SizedBox(height: screenSize.height * 0.04),
                // Button
                ElasticIn(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 900),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'إنهاء',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
