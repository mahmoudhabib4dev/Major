class TestStartResponseModel {
  final String mode; // "start", "review", or "finished"
  final int attemptId;
  final String? expiresAt; // Timer expiration time
  final String? status; // "in_progress", "finished", etc. (only in review mode)
  final int? score; // Only in review/finished mode
  final int? questionsCount; // Only in review/finished mode
  final List<TestQuestionModel> questions;

  TestStartResponseModel({
    required this.mode,
    required this.attemptId,
    this.expiresAt,
    this.status,
    this.score,
    this.questionsCount,
    required this.questions,
  });

  factory TestStartResponseModel.fromJson(Map<String, dynamic> json) {
    return TestStartResponseModel(
      mode: json['mode'] as String,
      attemptId: json['attempt_id'] as int,
      expiresAt: json['expires_at'] as String?,
      status: json['status'] as String?,
      score: json['score'] as int?,
      questionsCount: json['questions_count'] as int?,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => TestQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'attempt_id': attemptId,
      'status': status,
      'score': score,
      'questions_count': questionsCount,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  bool get isReviewMode => mode == 'review';
  bool get isTestMode => mode == 'test';
  bool get isFinished => status == 'finished';
}

class TestQuestionModel {
  final int id;
  final String question;
  final Map<String, String?> options;
  final int? rightAnswer; // Only in review mode
  final String? explanation; // Only in review mode
  final int? studentAnswer; // User's answer (if already answered in review mode)
  final bool? isCorrect; // Whether the student's answer is correct (only in review mode)

  TestQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.rightAnswer,
    this.explanation,
    this.studentAnswer,
    this.isCorrect,
  });

  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    // Convert options map to Map<String, String?>
    final optionsData = json['options'] as Map<String, dynamic>? ?? {};
    final options = <String, String?>{};
    optionsData.forEach((key, value) {
      // Handle null values in options
      if (value != null) {
        final stringValue = value.toString();
        if (stringValue.isNotEmpty) {
          options[key] = stringValue;
        }
      }
    });

    return TestQuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: options,
      rightAnswer: json['right_answer'] as int?,
      explanation: json['explanation'] as String?,
      studentAnswer: json['student_answer'] as int?,
      isCorrect: json['is_correct'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'right_answer': rightAnswer,
      'explanation': explanation,
      'student_answer': studentAnswer,
      'is_correct': isCorrect,
    };
  }

  // Get non-null options as a list
  List<String> getValidOptions() {
    return options.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .map((entry) => entry.value!)
        .toList();
  }

  // Get option key for a given index (0-based)
  String? getOptionKey(int index) {
    final validEntries = options.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .toList();
    if (index >= 0 && index < validEntries.length) {
      return validEntries[index].key;
    }
    return null;
  }
}

class AnswerSubmitResponseModel {
  final bool success;
  final String message;
  final bool? isCorrect;
  final int? correctAnswer;
  final String? explanation;

  AnswerSubmitResponseModel({
    required this.success,
    required this.message,
    this.isCorrect,
    this.correctAnswer,
    this.explanation,
  });

  factory AnswerSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return AnswerSubmitResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      isCorrect: json['is_correct'] as bool?,
      correctAnswer: json['correct_answer'] as int?,
      explanation: json['explanation'] as String?,
    );
  }
}
