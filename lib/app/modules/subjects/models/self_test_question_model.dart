class SelfTestQuestionModel {
  final int id;
  final String question;
  final Map<String, String?> options;
  final int? rightAnswer;
  final String? explanation;

  SelfTestQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.rightAnswer,
    this.explanation,
  });

  factory SelfTestQuestionModel.fromJson(Map<String, dynamic> json) {
    // Convert options map to Map<String, String?>
    final optionsData = json['options'] as Map<String, dynamic>;
    final options = <String, String?>{};
    optionsData.forEach((key, value) {
      // Filter out empty strings
      final stringValue = value as String?;
      if (stringValue != null && stringValue.isNotEmpty) {
        options[key] = stringValue;
      }
    });

    return SelfTestQuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: options,
      rightAnswer: json['right_answer'] as int?,
      explanation: json['explanation'] as String?,
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
