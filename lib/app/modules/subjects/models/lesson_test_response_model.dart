class LessonTestResponseModel {
  final bool status;
  final LessonTestData data;

  LessonTestResponseModel({
    required this.status,
    required this.data,
  });

  factory LessonTestResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonTestResponseModel(
      status: json['status'] as bool? ?? false,
      data: LessonTestData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class LessonTestData {
  final String testName;
  final List<TestQuestion> questions;

  LessonTestData({
    required this.testName,
    required this.questions,
  });

  factory LessonTestData.fromJson(Map<String, dynamic> json) {
    return LessonTestData(
      testName: json['test_name'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => TestQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_name': testName,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class TestQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int rightAnswer;
  final String explanation;

  TestQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.rightAnswer,
    required this.explanation,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'] as int,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((option) => option.toString())
          .toList(),
      rightAnswer: json['right_answer'] as int,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'right_answer': rightAnswer,
      'explanation': explanation,
    };
  }

  // Helper methods for QuizView compatibility
  List<String> getValidOptions() {
    return options.where((option) => option.isNotEmpty).toList();
  }

  String? getOptionKey(int index) {
    if (index >= 0 && index < options.length) {
      return (index + 1).toString(); // Return "1", "2", "3", etc.
    }
    return null;
  }
}
