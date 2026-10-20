class Course {
  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.lessonsCount = 0,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int lessonsCount;
  final bool isLocked;

  factory Course.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      title: (data['title'] as String?) ?? 'Untitled Course',
      category: (data['category'] as String?) ?? 'General',
      description: (data['description'] as String?) ?? '',
      lessonsCount: (data['lessonsCount'] as num?)?.toInt() ?? 0,
      isLocked: (data['isLocked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'lessonsCount': lessonsCount,
      'isLocked': isLocked,
    };
  }
}
