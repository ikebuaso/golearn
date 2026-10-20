import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../models/submission.dart';

class InstructorDashboardPage extends StatefulWidget {
  const InstructorDashboardPage({super.key});

  @override
  State<InstructorDashboardPage> createState() => _InstructorDashboardPageState();
}

class _InstructorDashboardPageState extends State<InstructorDashboardPage> {
  Submission? _selectedSubmission;
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectSubmission(Submission sub) {
    setState(() {
      _selectedSubmission = sub;
      _scoreController.text = sub.score > 0 ? sub.score.toString() : '';
      _feedbackController.text = sub.feedback;
    });
  }

  Future<void> _submitGrade() async {
    if (_selectedSubmission == null) return;

    final score = int.tryParse(_scoreController.text.trim()) ?? 0;
    final feedback = _feedbackController.text.trim();

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.gradeSubmission(
        submissionId: _selectedSubmission!.id,
        score: score,
        feedback: feedback,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: NeobrutalismTheme.neonGreen,
            content: Text(
              'Grade & feedback submitted successfully!',
              style: TextStyle(color: NeobrutalismTheme.pureBlack, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                color: NeobrutalismTheme.neonGreen,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
              ),
              child: const Text(
                'INSTRUCTOR',
                style: TextStyle(
                  color: NeobrutalismTheme.pureBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Grading Suite',
              style: NeobrutalismTheme.headingBold(fontSize: 18),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Submission>>(
        stream: FirestoreService.instance.streamSubmissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final submissions = snapshot.data ?? [];
          if (submissions.isEmpty) {
            return const Center(
              child: BrutalCard(child: Text('No student submissions in grading queue.')),
            );
          }

          final current = _selectedSubmission ?? submissions.first;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Panel: Submissions Queue
                SizedBox(
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submissions Queue (${submissions.length})',
                        style: NeobrutalismTheme.headingBold(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: submissions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = submissions[index];
                            final isSelected = item.id == current.id;

                            return InkWell(
                              onTap: () => _selectSubmission(item),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? NeobrutalismTheme.accentYellow
                                      : NeobrutalismTheme.cardWhite,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.studentName.isNotEmpty
                                                ? item.studentName
                                                : 'Student',
                                            style: NeobrutalismTheme.headingBold(fontSize: 14),
                                          ),
                                        ),
                                        if (item.graded)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: NeobrutalismTheme.neonGreen,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${item.score}/100',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        else
                                          const Text(
                                            'UNGRADED',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: NeobrutalismTheme.crimsonRed,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.lessonTitle.isNotEmpty
                                          ? item.lessonTitle
                                          : 'Practical Code Lab',
                                      style: NeobrutalismTheme.bodyText(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Center/Right: Split View (Submitted Code on left, Score & Feedback on right)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Submitted Code Viewer
                      Expanded(
                        flex: 6,
                        child: BrutalCard(
                          color: NeobrutalismTheme.pureBlack,
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                ),
                                child: Text(
                                  'Student Code Submission — ${current.studentName}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: SelectableText(
                                    current.codeSubmitted.isEmpty
                                        ? '# No code provided'
                                        : current.codeSubmitted,
                                    style: const TextStyle(
                                      color: NeobrutalismTheme.neonGreen,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Scoring & Feedback Panel
                      Expanded(
                        flex: 4,
                        child: BrutalCard(
                          color: NeobrutalismTheme.cardWhite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Evaluate Submission',
                                style: NeobrutalismTheme.headingBold(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              BrutalTextField(
                                label: 'Score (0 - 100)',
                                hintText: 'e.g. 95',
                                controller: _scoreController,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: BrutalTextField(
                                  label: 'Instructor Feedback',
                                  hintText: 'Great implementation of loops! Consider checking edge cases...',
                                  maxLines: 8,
                                  controller: _feedbackController,
                                ),
                              ),
                              const SizedBox(height: 16),
                              BrutalButton(
                                label: _isSaving ? 'Saving...' : 'Save Grade & Feedback',
                                icon: Icons.save_rounded,
                                variant: BrutalButtonVariant.primary,
                                onPressed: _isSaving ? null : _submitGrade,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
