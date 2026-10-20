import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/submission.dart';
import '../../models/user_profile.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore {
    if (!isFirebaseAvailable) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // --- In-Memory Mock Store for Offline / Pre-Firebase Testing ---
  final List<UserProfile> _mockUsers = [
    UserProfile(
      id: 'usr_student_1',
      name: 'Alex Johnson',
      email: 'alex.j@example.com',
      role: 'student',
      approved: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UserProfile(
      id: 'usr_student_2',
      name: 'Jordan Smith',
      email: 'jordan.s@example.com',
      role: 'student',
      approved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UserProfile(
      id: 'usr_instructor_1',
      name: 'Dr. Sarah Connor',
      email: 'sarah.c@example.com',
      role: 'instructor',
      approved: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UserProfile(
      id: 'usr_admin_1',
      name: 'Master Admin',
      email: 'admin@golearn.com',
      role: 'admin',
      approved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  final List<Course> _mockCourses = [
    const Course(
      id: 'course_python_101',
      title: 'Python Core Fundamentals',
      category: 'Software Engineering',
      description:
          'Learn variables, loops, data structures, and functions step-by-step.',
      lessonsCount: 5,
    ),
    const Course(
      id: 'course_web_dev',
      title: 'Modern Web & JavaScript',
      category: 'Web Development',
      description:
          'Master modern JavaScript ES6+, DOM manipulation, and asynchronous programming.',
      lessonsCount: 4,
    ),
    const Course(
      id: 'course_dsa',
      title: 'Data Structures & Algorithms',
      category: 'Computer Science',
      description:
          'Deep dive into arrays, linked lists, trees, recursion, and algorithm efficiency.',
      lessonsCount: 6,
      isLocked: true,
    ),
  ];

  final Map<String, List<Lesson>> _mockLessons = {
    'course_python_101': [
      const Lesson(
        id: 'lesson_py_day_1',
        dayNumber: 1,
        title: 'Variables, Types, and Output',
        contentMarkdown: '''
# Day 1: Python Basics

Welcome to Day 1 of Python Core Fundamentals! Today we learn about printing output, declaring variables, and handling basic types.

### Key Concepts:
1. `print()` function sends text to the standard output.
2. Variables do not require explicit type declarations in Python.
3. Strings are enclosed in single or double quotes.

```python
name = "Go Learn"
version = 3.10
print(f"Welcome to {name} Python {version}!")
```

### Try it out:
Head over to the Desktop Code Lab to execute your code live!
''',
        starterCode: '''# Day 1 Practice
name = "Go Learn Student"
score = 100

print(f"Hello, {name}!")
print(f"Starting score: {score}")
''',
        courseId: 'course_python_101',
      ),
      const Lesson(
        id: 'lesson_py_day_2',
        dayNumber: 2,
        title: 'Conditionals and Logical Flow',
        contentMarkdown: '''
# Day 2: Making Decisions

In Python, we use `if`, `elif`, and `else` to control program flow based on boolean expressions.

```python
score = 85
if score >= 90:
    print("Grade: A")
elif score >= 80:
    print("Grade: B")
else:
    print("Keep practicing!")
```
''',
        starterCode: '''# Write a program that checks if a number is positive, negative, or zero
num = 42

if num > 0:
    print("Positive")
elif num < 0:
    print("Negative")
else:
    print("Zero")
''',
        courseId: 'course_python_101',
      ),
    ],
    'course_web_dev': [
      const Lesson(
        id: 'lesson_js_day_1',
        dayNumber: 1,
        title: 'Modern JavaScript (ES6+)',
        contentMarkdown: '''
# Day 1: Modern JavaScript

Explore `const`, `let`, arrow functions, and template literals in modern JavaScript.

```javascript
const greet = (name) => `Hello, \${name}!`;
console.log(greet("Go Learn"));
```
''',
        starterCode: '''const calculateTotal = (price, taxRate = 0.08) => {
  return price + (price * taxRate);
};

console.log("Total:", calculateTotal(100));
''',
        courseId: 'course_web_dev',
      ),
    ],
  };

  final Map<String, List<Quiz>> _mockQuizzes = {
    'lesson_py_day_1': [
      const Quiz(
        id: 'quiz_py_1_1',
        question: 'Which built-in function in Python writes output to the console?',
        options: ['echo()', 'System.out.println()', 'print()', 'console.log()'],
        correctAnswerIndex: 2,
      ),
      const Quiz(
        id: 'quiz_py_1_2',
        question: 'What is the correct syntax for a string variable in Python?',
        options: [
          'string x = "hello"',
          'x = "hello"',
          'val x: String = "hello"',
          'char x = \'hello\''
        ],
        correctAnswerIndex: 1,
      ),
    ],
    'lesson_py_day_2': [
      const Quiz(
        id: 'quiz_py_2_1',
        question: 'What keyword represents "else if" in Python?',
        options: ['else if', 'elseif', 'elif', 'elsif'],
        correctAnswerIndex: 2,
      ),
    ],
  };

  final List<Submission> _mockSubmissions = [
    Submission(
      id: 'sub_1',
      studentId: 'usr_student_2',
      studentName: 'Jordan Smith',
      courseId: 'course_python_101',
      courseTitle: 'Python Core Fundamentals',
      lessonId: 'lesson_py_day_1',
      lessonTitle: 'Variables, Types, and Output',
      codeSubmitted: '''name = "Jordan"
for i in range(3):
    print(f"Run {i + 1}: Welcome, {name}!")
''',
      score: 0,
      graded: false,
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ================= USERS =================

  Stream<List<UserProfile>> streamUnapprovedUsers() async* {
    final db = _firestore;
    if (db != null) {
      yield* db
          .collection('users')
          .where('approved', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => UserProfile.fromFirestore(doc.data(), doc.id))
              .toList());
    } else {
      yield _mockUsers.where((u) => !u.approved).toList();
    }
  }

  Stream<List<UserProfile>> streamAllUsers() async* {
    final db = _firestore;
    if (db != null) {
      yield* db.collection('users').snapshots().map((snapshot) =>
          snapshot.docs
              .map((doc) => UserProfile.fromFirestore(doc.data(), doc.id))
              .toList());
    } else {
      yield List.unmodifiable(_mockUsers);
    }
  }

  Future<void> updateUserApproval(String userId, bool approved) async {
    final db = _firestore;
    if (db != null) {
      await db.collection('users').doc(userId).update({'approved': approved});
    } else {
      final index = _mockUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _mockUsers[index] = _mockUsers[index].copyWith(approved: approved);
      }
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    final db = _firestore;
    if (db != null) {
      await db.collection('users').doc(userId).update({'role': role});
    } else {
      final index = _mockUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _mockUsers[index] = _mockUsers[index].copyWith(role: role);
      }
    }
  }

  // ================= COURSES =================

  Stream<List<Course>> streamCourses() async* {
    final db = _firestore;
    if (db != null) {
      yield* db.collection('courses').snapshots().map((snapshot) =>
          snapshot.docs
              .map((doc) => Course.fromFirestore(doc.data(), doc.id))
              .toList());
    } else {
      yield List.unmodifiable(_mockCourses);
    }
  }

  Future<void> createCourse(Course course) async {
    final db = _firestore;
    if (db != null) {
      await db.collection('courses').add(course.toFirestore());
    } else {
      _mockCourses.add(course);
    }
  }

  // ================= LESSONS =================

  Future<List<Lesson>> getLessons(String courseId) async {
    final db = _firestore;
    if (db != null) {
      final snapshot = await db
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .orderBy('dayNumber')
          .get();
      return snapshot.docs
          .map((doc) => Lesson.fromFirestore(doc.data(), doc.id, courseId: courseId))
          .toList();
    } else {
      return _mockLessons[courseId] ?? [];
    }
  }

  Future<void> createLesson(String courseId, Lesson lesson) async {
    final db = _firestore;
    if (db != null) {
      await db
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .add(lesson.toFirestore());
      await db.collection('courses').doc(courseId).update({
        'lessonsCount': FieldValue.increment(1),
      });
    } else {
      final list = _mockLessons.putIfAbsent(courseId, () => []);
      list.add(lesson);
    }
  }

  // ================= QUIZZES =================

  Future<List<Quiz>> getQuizzes(String courseId, String lessonId) async {
    final db = _firestore;
    if (db != null) {
      final snapshot = await db
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('quizzes')
          .get();
      return snapshot.docs
          .map((doc) => Quiz.fromFirestore(doc.data(), doc.id))
          .toList();
    } else {
      return _mockQuizzes[lessonId] ?? [];
    }
  }

  Future<void> createQuiz(String courseId, String lessonId, Quiz quiz) async {
    final db = _firestore;
    if (db != null) {
      await db
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('quizzes')
          .add(quiz.toFirestore());
    } else {
      final list = _mockQuizzes.putIfAbsent(lessonId, () => []);
      list.add(quiz);
    }
  }

  // ================= SUBMISSIONS =================

  Stream<List<Submission>> streamSubmissions({bool ungradedOnly = false}) async* {
    final db = _firestore;
    if (db != null) {
      Query<Map<String, dynamic>> query = db.collection('submissions');
      if (ungradedOnly) {
        query = query.where('graded', isEqualTo: false);
      }
      yield* query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Submission.fromFirestore(doc.data(), doc.id))
          .toList());
    } else {
      if (ungradedOnly) {
        yield _mockSubmissions.where((s) => !s.graded).toList();
      } else {
        yield List.unmodifiable(_mockSubmissions);
      }
    }
  }

  Future<void> submitAssignment(Submission submission) async {
    final db = _firestore;
    if (db != null) {
      await db.collection('submissions').add(submission.toFirestore());
    } else {
      _mockSubmissions.add(submission);
    }
  }

  Future<void> gradeSubmission({
    required String submissionId,
    required int score,
    required String feedback,
  }) async {
    final db = _firestore;
    if (db != null) {
      await db.collection('submissions').doc(submissionId).update({
        'score': score,
        'feedback': feedback,
        'graded': true,
      });
    } else {
      final index = _mockSubmissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        _mockSubmissions[index] = _mockSubmissions[index].copyWith(
          score: score,
          graded: true,
          feedback: feedback,
        );
      }
    }
  }
}
