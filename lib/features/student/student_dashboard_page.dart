import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../models/course.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeobrutalismTheme.backgroundMint,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NeobrutalismTheme.neonGreen,
                border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: NeobrutalismTheme.pureBlack,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Go Learn',
              style: NeobrutalismTheme.headingBold(fontSize: 20),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalButton(
              label: 'Code Lab',
              icon: Icons.code_rounded,
              compact: true,
              variant: BrutalButtonVariant.primary,
              onPressed: () => context.go('/codelab'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Card
            BrutalCard(
              color: NeobrutalismTheme.primaryBlue,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: NeobrutalismTheme.neonGreen,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: NeobrutalismTheme.pureBlack,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'STUDENT DASHBOARD',
                            style: NeobrutalismTheme.headingBold(
                              fontSize: 11,
                              color: NeobrutalismTheme.pureBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keep Building Your Skills.',
                          style: NeobrutalismTheme.headingBold(
                            fontSize: 24,
                            color: NeobrutalismTheme.cardWhite,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Read daily notes, take quizzes, and write code in the interactive desktop lab.',
                          style: NeobrutalismTheme.bodyText(
                            fontSize: 14,
                            color: NeobrutalismTheme.cardWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Metrics / Stats Row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatBadge(
                  icon: Icons.bolt_rounded,
                  label: 'Current Streak',
                  value: '5 Days',
                  color: NeobrutalismTheme.accentYellow,
                ),
                _buildStatBadge(
                  icon: Icons.emoji_events_rounded,
                  label: 'Department Rank',
                  value: '#3 on Leaderboard',
                  color: NeobrutalismTheme.neonGreen,
                ),
                _buildStatBadge(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed Quizzes',
                  value: '12 Quizzes Passed',
                  color: NeobrutalismTheme.cardWhite,
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              'Enrolled Courses & Schemes',
              style: NeobrutalismTheme.headingBold(fontSize: 22),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Course>>(
              stream: FirestoreService.instance.streamCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data ?? [];
                if (courses.isEmpty) {
                  return const BrutalCard(
                    child: Center(
                      child: Text('No courses published yet. Check back soon!'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildCourseCard(context, course);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: NeobrutalismTheme.pureBlack,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: NeobrutalismTheme.pureBlack),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: NeobrutalismTheme.pureBlack,
                ),
              ),
              Text(
                value,
                style: NeobrutalismTheme.headingBold(
                  fontSize: 15,
                  color: NeobrutalismTheme.pureBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return BrutalCard(
      color: NeobrutalismTheme.cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NeobrutalismTheme.accentYellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: NeobrutalismTheme.pureBlack,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  course.category.toUpperCase(),
                  style: NeobrutalismTheme.headingBold(fontSize: 10),
                ),
              ),
              const Spacer(),
              if (course.isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: NeobrutalismTheme.crimsonRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'LOCKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '${course.lessonsCount} Schemes',
                  style: NeobrutalismTheme.headingBold(
                    fontSize: 12,
                    color: NeobrutalismTheme.primaryBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            course.title,
            style: NeobrutalismTheme.headingBold(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            course.description,
            style: NeobrutalismTheme.bodyText(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              BrutalButton(
                label: course.isLocked ? 'Locked' : 'Open Course',
                icon: Icons.arrow_forward_rounded,
                compact: true,
                variant: course.isLocked
                    ? BrutalButtonVariant.secondary
                    : BrutalButtonVariant.accent,
                onPressed: course.isLocked
                    ? null
                    : () => context.go('/course/${course.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
