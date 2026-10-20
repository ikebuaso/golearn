export 'quiz.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.contentMarkdown,
    required this.starterCode,
    this.courseId = '',
  });

  final String id;
  final int dayNumber;
  final String title;
  final String contentMarkdown;
  final String starterCode;
  final String courseId;

  factory Lesson.fromFirestore(
    Map<String, dynamic> data,
    String documentId, {
    String courseId = '',
  }) {
    return Lesson(
      id: documentId,
      dayNumber: (data['dayNumber'] as num?)?.toInt() ?? 1,
      title: (data['title'] as String?) ?? 'Lesson',
      contentMarkdown: (data['contentMarkdown'] as String?) ?? '',
      starterCode: (data['starterCode'] as String?) ?? '',
      courseId: courseId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'contentMarkdown': contentMarkdown,
      'starterCode': starterCode,
    };
  }
}
