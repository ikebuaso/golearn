import 'package:flutter_test/flutter_test.dart';
import 'package:golearn/core/services/firestore_service.dart';
import 'package:golearn/models/course.dart';
import 'package:golearn/models/lesson.dart';
import 'package:golearn/models/submission.dart';
import 'package:golearn/models/user_profile.dart';

void main() {
  group('Go Learn Data Models & Service Test', () {
    test('UserProfile serialization and role checks', () {
      final user = UserProfile(
        id: 'usr_1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: 'instructor',
        approved: true,
      );

      expect(user.isInstructor, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isStudent, isFalse);

      final map = user.toFirestore();
      expect(map['role'], 'instructor');
      expect(map['approved'], isTrue);

      final fromMap = UserProfile.fromFirestore(map, 'usr_1');
      expect(fromMap.name, 'Jane Doe');
      expect(fromMap.role, 'instructor');
    });

    test('Course and Lesson models', () {
      const course = Course(
        id: 'c_1',
        title: 'Flutter Advanced',
        category: 'Mobile',
        description: 'Deep dive into state management',
        lessonsCount: 3,
      );

      final courseMap = course.toFirestore();
      expect(courseMap['title'], 'Flutter Advanced');

      const lesson = Lesson(
        id: 'l_1',
        dayNumber: 1,
        title: 'State Architecture',
        contentMarkdown: '# Day 1',
        starterCode: 'void main() {}',
      );

      final lessonMap = lesson.toFirestore();
      expect(lessonMap['dayNumber'], 1);
    });

    test('Quiz scoring logic', () {
      const quiz = Quiz(
        id: 'q_1',
        question: 'Which method starts a Flutter app?',
        options: ['start()', 'runApp()', 'init()'],
        correctAnswerIndex: 1,
      );

      expect(quiz.correctAnswerIndex, 1);
      expect(quiz.options[quiz.correctAnswerIndex], 'runApp()');
    });

    test('Submission model and grading', () {
      final sub = Submission(
        id: 's_1',
        studentId: 'student_1',
        courseId: 'c_1',
        lessonId: 'l_1',
        codeSubmitted: 'print("test")',
      );

      expect(sub.graded, isFalse);
      final graded = sub.copyWith(score: 95, graded: true, feedback: 'Well done');
      expect(graded.score, 95);
      expect(graded.graded, isTrue);
      expect(graded.feedback, 'Well done');
    });

    test('FirestoreService mock offline fallback streams courses', () async {
      final courses = await FirestoreService.instance.streamCourses().first;
      expect(courses, isNotEmpty);
      expect(courses.any((c) => c.title.contains('Python')), isTrue);
    });
  });
}
