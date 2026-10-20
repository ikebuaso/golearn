import 'package:go_router/go_router.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/instructor/instructor_dashboard_page.dart';
import '../features/student/course_reader_page.dart';
import '../features/student/desktop_code_lab_page.dart';
import '../features/student/quiz_screen.dart';
import '../features/student/student_dashboard_page.dart';
import '../main.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/course/:courseId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId'] ?? 'course_python_101';
        return CourseReaderPage(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/quiz/:courseId/:lessonId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId'] ?? 'course_python_101';
        final lessonId = state.pathParameters['lessonId'] ?? 'lesson_py_day_1';
        return QuizScreen(courseId: courseId, lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/codelab',
      builder: (context, state) {
        final lessonId = state.uri.queryParameters['lessonId'];
        final courseId = state.uri.queryParameters['courseId'];
        return DesktopCodeLabPage(lessonId: lessonId, courseId: courseId);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/instructor',
      builder: (context, state) => const InstructorDashboardPage(),
    ),
  ],
);
