import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/user_profile.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeobrutalismTheme.backgroundMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeobrutalismTheme.pureBlack),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NeobrutalismTheme.crimsonRed,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Management Panel',
              style: NeobrutalismTheme.headingBold(fontSize: 18),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: NeobrutalismTheme.pureBlack,
          indicatorColor: NeobrutalismTheme.primaryBlue,
          indicatorWeight: 4,
          labelStyle: NeobrutalismTheme.headingBold(fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.how_to_reg_rounded), text: 'User Approvals'),
            Tab(icon: Icon(Icons.add_box_rounded), text: 'Course & Scheme Creator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UserApprovalsTab(),
          _CourseCreatorTab(),
        ],
      ),
    );
  }
}

class _UserApprovalsTab extends StatelessWidget {
  const _UserApprovalsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserProfile>>(
      stream: FirestoreService.instance.streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(
            child: BrutalCard(child: Text('No registered users found.')),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Registration & Role Approvals',
                style: NeobrutalismTheme.headingBold(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Review pending accounts and configure access permissions (student, instructor, admin).',
                style: NeobrutalismTheme.bodyText(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Neobrutal Table
              BrutalCard(
                padding: const EdgeInsets.all(0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(NeobrutalismTheme.subtleGray),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 72,
                    columns: [
                      DataColumn(label: Text('Name', style: NeobrutalismTheme.headingBold(fontSize: 14))),
                      DataColumn(label: Text('Email', style: NeobrutalismTheme.headingBold(fontSize: 14))),
                      DataColumn(label: Text('Role', style: NeobrutalismTheme.headingBold(fontSize: 14))),
                      DataColumn(label: Text('Status', style: NeobrutalismTheme.headingBold(fontSize: 14))),
                      DataColumn(label: Text('Actions', style: NeobrutalismTheme.headingBold(fontSize: 14))),
                    ],
                    rows: users.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text(user.email)),
                        DataCell(
                          DropdownButton<String>(
                            value: user.role,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'student', child: Text('Student')),
                              DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            ],
                            onChanged: (newRole) {
                              if (newRole != null && newRole != user.role) {
                                FirestoreService.instance.updateUserRole(user.id, newRole);
                              }
                            },
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.approved
                                  ? NeobrutalismTheme.neonGreen
                                  : NeobrutalismTheme.accentYellow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: NeobrutalismTheme.pureBlack, width: 1.5),
                            ),
                            child: Text(
                              user.approved ? 'APPROVED' : 'PENDING',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: NeobrutalismTheme.pureBlack,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              if (!user.approved)
                                BrutalButton(
                                  label: 'Approve',
                                  compact: true,
                                  variant: BrutalButtonVariant.accent,
                                  onPressed: () => FirestoreService.instance
                                      .updateUserApproval(user.id, true),
                                )
                              else
                                BrutalButton(
                                  label: 'Revoke',
                                  compact: true,
                                  variant: BrutalButtonVariant.danger,
                                  onPressed: () => FirestoreService.instance
                                      .updateUserApproval(user.id, false),
                                ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseCreatorTab extends StatefulWidget {
  const _CourseCreatorTab();

  @override
  State<_CourseCreatorTab> createState() => _CourseCreatorTabState();
}

class _CourseCreatorTabState extends State<_CourseCreatorTab> {
  final _courseTitleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Software Engineering');
  final _descriptionController = TextEditingController();

  final _lessonTitleController = TextEditingController();
  final _dayNumberController = TextEditingController(text: '1');
  final _markdownController = TextEditingController();
  final _starterCodeController = TextEditingController();

  final _quizQuestionController = TextEditingController();
  final _opt1Controller = TextEditingController();
  final _opt2Controller = TextEditingController();
  final _opt3Controller = TextEditingController();
  final _opt4Controller = TextEditingController();
  int _correctAnswerIndex = 0;

  @override
  void dispose() {
    _courseTitleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _lessonTitleController.dispose();
    _dayNumberController.dispose();
    _markdownController.dispose();
    _starterCodeController.dispose();
    _quizQuestionController.dispose();
    _opt1Controller.dispose();
    _opt2Controller.dispose();
    _opt3Controller.dispose();
    _opt4Controller.dispose();
    super.dispose();
  }

  Future<void> _createFullCourse() async {
    final title = _courseTitleController.text.trim();
    if (title.isEmpty) return;

    final courseId = 'course_${DateTime.now().millisecondsSinceEpoch}';
    final course = Course(
      id: courseId,
      title: title,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      lessonsCount: 1,
    );

    await FirestoreService.instance.createCourse(course);

    if (_lessonTitleController.text.trim().isNotEmpty) {
      final lessonId = 'lesson_${DateTime.now().millisecondsSinceEpoch}';
      final lesson = Lesson(
        id: lessonId,
        dayNumber: int.tryParse(_dayNumberController.text) ?? 1,
        title: _lessonTitleController.text.trim(),
        contentMarkdown: _markdownController.text.trim(),
        starterCode: _starterCodeController.text.trim(),
        courseId: courseId,
      );
      await FirestoreService.instance.createLesson(courseId, lesson);

      if (_quizQuestionController.text.trim().isNotEmpty) {
        final quiz = Quiz(
          id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
          question: _quizQuestionController.text.trim(),
          options: [
            _opt1Controller.text.trim(),
            _opt2Controller.text.trim(),
            _opt3Controller.text.trim(),
            _opt4Controller.text.trim(),
          ].where((o) => o.isNotEmpty).toList(),
          correctAnswerIndex: _correctAnswerIndex,
        );
        await FirestoreService.instance.createQuiz(courseId, lessonId, quiz);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: NeobrutalismTheme.neonGreen,
          content: Text(
            'New course, scheme of work, and quiz published successfully!',
            style: TextStyle(color: NeobrutalismTheme.pureBlack, fontWeight: FontWeight.bold),
          ),
        ),
      );
      _courseTitleController.clear();
      _descriptionController.clear();
      _lessonTitleController.clear();
      _markdownController.clear();
      _starterCodeController.clear();
      _quizQuestionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course Creator', style: NeobrutalismTheme.headingBold(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              'Publish new course schemes, lesson notes, starter code, and daily quizzes.',
              style: NeobrutalismTheme.bodyText(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Step 1: Course Info
            BrutalCard(
              color: NeobrutalismTheme.cardWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Course Information', style: NeobrutalismTheme.headingBold(fontSize: 16)),
                  const SizedBox(height: 16),
                  BrutalTextField(
                    label: 'Course Title',
                    hintText: 'e.g. Flutter Cross-Platform Development',
                    controller: _courseTitleController,
                  ),
                  const SizedBox(height: 14),
                  BrutalTextField(
                    label: 'Category',
                    hintText: 'e.g. Mobile Engineering',
                    controller: _categoryController,
                  ),
                  const SizedBox(height: 14),
                  BrutalTextField(
                    label: 'Course Description',
                    hintText: 'Brief summary of what students will master...',
                    maxLines: 3,
                    controller: _descriptionController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 2: Scheme / Lesson
            BrutalCard(
              color: NeobrutalismTheme.cardWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('2. Daily Scheme of Work (Day 1)', style: NeobrutalismTheme.headingBold(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: BrutalTextField(
                          label: 'Day #',
                          controller: _dayNumberController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BrutalTextField(
                          label: 'Lesson Title',
                          hintText: 'e.g. Widgets & Layouts',
                          controller: _lessonTitleController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BrutalTextField(
                    label: 'Scheme Notes (Markdown Supported)',
                    hintText: '# Title\n\nExplanation of core concepts...',
                    maxLines: 5,
                    controller: _markdownController,
                  ),
                  const SizedBox(height: 14),
                  BrutalTextField(
                    label: 'Starter Code for Code Lab',
                    hintText: '// Starter practice code...',
                    maxLines: 4,
                    controller: _starterCodeController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 3: Daily Quiz
            BrutalCard(
              color: NeobrutalismTheme.cardWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3. Daily Quiz Question', style: NeobrutalismTheme.headingBold(fontSize: 16)),
                  const SizedBox(height: 16),
                  BrutalTextField(
                    label: 'Question',
                    hintText: 'e.g. What widget is the root of Material apps?',
                    controller: _quizQuestionController,
                  ),
                  const SizedBox(height: 14),
                  BrutalTextField(label: 'Option A', controller: _opt1Controller),
                  const SizedBox(height: 10),
                  BrutalTextField(label: 'Option B', controller: _opt2Controller),
                  const SizedBox(height: 10),
                  BrutalTextField(label: 'Option C', controller: _opt3Controller),
                  const SizedBox(height: 10),
                  BrutalTextField(label: 'Option D', controller: _opt4Controller),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('Correct Option: ', style: NeobrutalismTheme.headingBold(fontSize: 13)),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: _correctAnswerIndex,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Option A')),
                          DropdownMenuItem(value: 1, child: Text('Option B')),
                          DropdownMenuItem(value: 2, child: Text('Option C')),
                          DropdownMenuItem(value: 3, child: Text('Option D')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _correctAnswerIndex = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            BrutalButton(
              label: 'Publish Course & Lesson',
              icon: Icons.check_circle_rounded,
              variant: BrutalButtonVariant.primary,
              expand: true,
              onPressed: _createFullCourse,
            ),
          ],
        ),
      ),
    );
  }
}
