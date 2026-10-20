class Submission {
  const Submission({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.lessonId,
    required this.codeSubmitted,
    this.studentName = '',
    this.lessonTitle = '',
    this.courseTitle = '',
    this.fileUrl = '',
    this.score = 0,
    this.graded = false,
    this.feedback = '',
    this.submittedAt,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String lessonId;
  final String codeSubmitted;
  final String studentName;
  final String lessonTitle;
  final String courseTitle;
  final String fileUrl;
  final int score;
  final bool graded;
  final String feedback;
  final DateTime? submittedAt;

  factory Submission.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Submission(
      id: documentId,
      studentId: (data['studentId'] as String?) ?? '',
      studentName: (data['studentName'] as String?) ?? '',
      courseId: (data['courseId'] as String?) ?? '',
      lessonId: (data['lessonId'] as String?) ?? '',
      lessonTitle: (data['lessonTitle'] as String?) ?? '',
      courseTitle: (data['courseTitle'] as String?) ?? '',
      codeSubmitted: (data['codeSubmitted'] as String?) ?? '',
      fileUrl: (data['fileUrl'] as String?) ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      graded: (data['graded'] as bool?) ?? false,
      feedback: (data['feedback'] as String?) ?? '',
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] is DateTime
              ? data['submittedAt'] as DateTime
              : DateTime.tryParse(data['submittedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'courseTitle': courseTitle,
      'codeSubmitted': codeSubmitted,
      'fileUrl': fileUrl,
      'score': score,
      'graded': graded,
      'feedback': feedback,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  Submission copyWith({
    int? score,
    bool? graded,
    String? feedback,
  }) {
    return Submission(
      id: id,
      studentId: studentId,
      studentName: studentName,
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      courseTitle: courseTitle,
      codeSubmitted: codeSubmitted,
      fileUrl: fileUrl,
      score: score ?? this.score,
      graded: graded ?? this.graded,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt,
    );
  }
}
