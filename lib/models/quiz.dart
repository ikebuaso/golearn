class Quiz {
  const Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  factory Quiz.fromFirestore(Map<String, dynamic> data, String documentId) {
    final rawOptions = data['options'];
    final optionsList = rawOptions is List
        ? rawOptions.map((e) => e.toString()).toList()
        : <String>[];

    return Quiz(
      id: documentId,
      question: (data['question'] as String?) ?? '',
      options: optionsList,
      correctAnswerIndex: (data['correctAnswerIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}
