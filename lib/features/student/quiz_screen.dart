import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../models/quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasSubmittedCurrent = false;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final list = await FirestoreService.instance.getQuizzes(
      widget.courseId,
      widget.lessonId,
    );
    if (mounted) {
      setState(() {
        _quizzes = list;
        _isLoading = false;
      });
    }
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null || _hasSubmittedCurrent) return;

    final quiz = _quizzes[_currentIndex];
    final isCorrect = _selectedAnswerIndex == quiz.correctAnswerIndex;

    setState(() {
      _hasSubmittedCurrent = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _quizzes.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _hasSubmittedCurrent = false;
      });
    } else {
      setState(() {
        _isFinished = true;
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

    if (_quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: NeobrutalismTheme.backgroundMint,
          title: Text('Daily Quiz', style: NeobrutalismTheme.headingBold(fontSize: 18)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BrutalCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz_outlined, size: 40),
                  const SizedBox(height: 12),
                  const Text('No quiz questions added for this scheme yet.'),
                  const SizedBox(height: 16),
                  BrutalButton(
                    label: 'Back to Course',
                    onPressed: () => context.go('/course/${widget.courseId}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isFinished) {
      final total = _quizzes.length;
      final percentage = (total > 0 ? (_score / total * 100).round() : 0);
      final isPassing = percentage >= 70;

      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BrutalCard(
                color: NeobrutalismTheme.cardWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isPassing
                            ? NeobrutalismTheme.neonGreen
                            : NeobrutalismTheme.accentYellow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
                      ),
                      child: Icon(
                        isPassing ? Icons.emoji_events_rounded : Icons.replay_rounded,
                        size: 38,
                        color: NeobrutalismTheme.pureBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isPassing ? 'Quiz Completed!' : 'Keep Practicing!',
                      style: NeobrutalismTheme.headingBold(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Score: $_score / $total ($percentage%)',
                      style: NeobrutalismTheme.headingBold(
                        fontSize: 20,
                        color: NeobrutalismTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassing
                          ? 'Great job! Your score has been credited to your daily learning rank.'
                          : 'Review the day’s scheme notes and try again to improve your score.',
                      textAlign: TextAlign.center,
                      style: NeobrutalismTheme.bodyText(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BrutalButton(
                          label: 'Return to Course',
                          variant: BrutalButtonVariant.accent,
                          onPressed: () => context.go('/course/${widget.courseId}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final quiz = _quizzes[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeobrutalismTheme.backgroundMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: NeobrutalismTheme.pureBlack),
          onPressed: () => context.go('/course/${widget.courseId}'),
        ),
        title: Text(
          'Daily Quiz — Question ${_currentIndex + 1}/${_quizzes.length}',
          style: NeobrutalismTheme.headingBold(fontSize: 16),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: NeobrutalismTheme.cardWhite,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentIndex + 1) / _quizzes.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeobrutalismTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Question Card
                BrutalCard(
                  color: NeobrutalismTheme.cardWhite,
                  child: Text(
                    quiz.question,
                    style: NeobrutalismTheme.headingBold(fontSize: 20, height: 1.3),
                  ),
                ),
                const SizedBox(height: 20),

                // Options List
                ...List.generate(quiz.options.length, (index) {
                  final optionText = quiz.options[index];
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == quiz.correctAnswerIndex;

                  Color optionBg = NeobrutalismTheme.cardWhite;
                  if (_hasSubmittedCurrent) {
                    if (isCorrect) {
                      optionBg = NeobrutalismTheme.neonGreen;
                    } else if (isSelected) {
                      optionBg = NeobrutalismTheme.crimsonRed.withValues(alpha: 0.2);
                    }
                  } else if (isSelected) {
                    optionBg = NeobrutalismTheme.accentYellow;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: _hasSubmittedCurrent
                          ? null
                          : () => setState(() => _selectedAnswerIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: optionBg,
                          borderRadius: BorderRadius.circular(10),
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
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: NeobrutalismTheme.cardWhite,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NeobrutalismTheme.pureBlack,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: NeobrutalismTheme.headingBold(fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                optionText,
                                style: NeobrutalismTheme.bodyText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (_hasSubmittedCurrent && isCorrect)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: NeobrutalismTheme.pureBlack,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                if (!_hasSubmittedCurrent)
                  BrutalButton(
                    label: 'Submit Answer',
                    variant: BrutalButtonVariant.primary,
                    expand: true,
                    onPressed: _selectedAnswerIndex != null ? _submitAnswer : null,
                  )
                else
                  BrutalButton(
                    label: _currentIndex + 1 < _quizzes.length
                        ? 'Next Question'
                        : 'See Final Results',
                    variant: BrutalButtonVariant.accent,
                    expand: true,
                    onPressed: _nextQuestion,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
