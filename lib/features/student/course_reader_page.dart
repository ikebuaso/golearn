import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../models/lesson.dart';

class CourseReaderPage extends StatefulWidget {
  const CourseReaderPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<CourseReaderPage> createState() => _CourseReaderPageState();
}

class _CourseReaderPageState extends State<CourseReaderPage> {
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  int _selectedLessonIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final list = await FirestoreService.instance.getLessons(widget.courseId);
    if (mounted) {
      setState(() {
        _lessons = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: NeobrutalismTheme.backgroundMint,
          title: Text('Course Schemes', style: NeobrutalismTheme.headingBold(fontSize: 18)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BrutalCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text('No lessons currently published for this course.'),
                  const SizedBox(height: 16),
                  BrutalButton(
                    label: 'Back to Dashboard',
                    onPressed: () => context.go('/dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final activeLesson = _lessons[_selectedLessonIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeobrutalismTheme.backgroundMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeobrutalismTheme.pureBlack),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          'Scheme: Day ${activeLesson.dayNumber}',
          style: NeobrutalismTheme.headingBold(fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: BrutalButton(
              label: 'Daily Quiz',
              icon: Icons.quiz_rounded,
              compact: true,
              variant: BrutalButtonVariant.accent,
              onPressed: () => context.go(
                '/quiz/${widget.courseId}/${activeLesson.id}',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalButton(
              label: 'Code Lab',
              icon: Icons.terminal_rounded,
              compact: true,
              variant: BrutalButtonVariant.primary,
              onPressed: () => context.go(
                '/codelab?lessonId=${activeLesson.id}&courseId=${widget.courseId}',
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Navigation Sidebar
                SizedBox(
                  width: 280,
                  child: _buildLessonList(),
                ),
                const VerticalDivider(width: 2, thickness: 2, color: NeobrutalismTheme.pureBlack),
                // Lesson Content View
                Expanded(
                  child: _buildLessonReader(activeLesson),
                ),
              ],
            );
          }

          // Mobile View
          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedLessonIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BrutalButton(
                        label: 'Day ${_lessons[index].dayNumber}',
                        compact: true,
                        variant: isSelected
                            ? BrutalButtonVariant.accent
                            : BrutalButtonVariant.secondary,
                        onPressed: () => setState(() => _selectedLessonIndex = index),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildLessonReader(activeLesson),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLessonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        final isSelected = index == _selectedLessonIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => setState(() => _selectedLessonIndex = index),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? NeobrutalismTheme.neonGreen
                    : NeobrutalismTheme.cardWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NeobrutalismTheme.pureBlack,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: NeobrutalismTheme.pureBlack,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY ${lesson.dayNumber}',
                    style: NeobrutalismTheme.headingBold(
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style: NeobrutalismTheme.headingBold(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonReader(Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: NeobrutalismTheme.accentYellow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: NeobrutalismTheme.pureBlack, width: 1.5),
            ),
            child: Text(
              'DAY ${lesson.dayNumber} SCHEME OF WORK',
              style: NeobrutalismTheme.headingBold(fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            style: NeobrutalismTheme.headingBold(fontSize: 30, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          BrutalCard(
            color: NeobrutalismTheme.cardWhite,
            child: SelectableText(
              lesson.contentMarkdown,
              style: NeobrutalismTheme.bodyText(fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 24),
          if (lesson.starterCode.isNotEmpty) ...[
            Text('Starter Practice Code', style: NeobrutalismTheme.headingBold(fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeobrutalismTheme.pureBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
              ),
              child: SelectableText(
                lesson.starterCode,
                style: const TextStyle(
                  color: NeobrutalismTheme.neonGreen,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            BrutalButton(
              label: 'Launch in Interactive Code Lab',
              icon: Icons.play_arrow_rounded,
              variant: BrutalButtonVariant.primary,
              onPressed: () => context.go(
                '/codelab?lessonId=${lesson.id}&courseId=${widget.courseId}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
