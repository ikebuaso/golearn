import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/piston_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/mobile_lockout_widget.dart';
import '../../models/submission.dart';

class DesktopCodeLabPage extends StatefulWidget {
  const DesktopCodeLabPage({
    super.key,
    this.lessonId,
    this.courseId,
  });

  final String? lessonId;
  final String? courseId;

  @override
  State<DesktopCodeLabPage> createState() => _DesktopCodeLabPageState();
}

class _DesktopCodeLabPageState extends State<DesktopCodeLabPage> {
  String _selectedLanguage = 'python';
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _stdinController = TextEditingController();

  String _consoleOutput = 'Click "Run Code" to execute using Piston API runtime.\n';
  bool _isRunning = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _codeController.text = '''# Python 3 Code Lab
# Write and run your code in real-time

def main():
    name = "Go Learn Developer"
    print(f"Hello, {name}!")
    for i in range(1, 4):
        print(f"  Step {i}: executing...")

if __name__ == "__main__":
    main()
''';
  }

  @override
  void dispose() {
    _codeController.disposeWidget();
    _stdinController.dispose();
    super.dispose();
  }

  void _onLanguageChanged(String newLang) {
    setState(() {
      _selectedLanguage = newLang;
      if (newLang == 'javascript') {
        _codeController.text = '''// Modern JavaScript (ES6+) Code Lab
function runLab() {
    const skills = ["Flutter", "Clerk", "Firebase", "Piston API"];
    console.log("Go Learn Tech Stack:");
    skills.forEach((skill, index) => {
        console.log(` \${index + 1}. \${skill}`);
    });
}

runLab();
''';
      } else {
        _codeController.text = '''# Python 3 Code Lab
def main():
    print("Welcome to Go Learn Desktop Code Lab!")

if __name__ == "__main__":
    main()
''';
      }
    });
  }

  Future<void> _executeCode() async {
    setState(() {
      _isRunning = true;
      _consoleOutput = 'Executing on Piston runtime... Please wait.\n';
    });

    final result = await PistonService.executeCode(
      language: _selectedLanguage,
      code: _codeController.text,
      stdin: _stdinController.text.trim().isEmpty ? null : _stdinController.text,
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _consoleOutput = result.output;
      });
    }
  }

  Future<void> _submitAssignment() async {
    setState(() => _isSubmitting = true);

    try {
      final submission = Submission(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        studentId: 'student_current',
        studentName: 'Active Student',
        courseId: widget.courseId ?? 'course_python_101',
        courseTitle: 'Python Core Fundamentals',
        lessonId: widget.lessonId ?? 'lesson_py_day_1',
        lessonTitle: 'Interactive Practical Assignment',
        codeSubmitted: _codeController.text,
        submittedAt: DateTime.now(),
      );

      await FirestoreService.instance.submitAssignment(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: NeobrutalismTheme.neonGreen,
            content: Text(
              'Assignment submitted to instructor grading queue!',
              style: TextStyle(color: NeobrutalismTheme.pureBlack, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

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
                const Icon(Icons.terminal_rounded, color: NeobrutalismTheme.primaryBlue),
                const SizedBox(width: 10),
                Text(
                  'Desktop Code Lab',
                  style: NeobrutalismTheme.headingBold(fontSize: 18),
                ),
              ],
            ),
            actions: isDesktop
                ? [
                    // Language Switcher
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: NeobrutalismTheme.cardWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: NeobrutalismTheme.cardWhite,
                          style: NeobrutalismTheme.headingBold(fontSize: 13),
                          items: const [
                            DropdownMenuItem(value: 'python', child: Text('Python 3.10')),
                            DropdownMenuItem(value: 'javascript', child: Text('JavaScript ES6+')),
                          ],
                          onChanged: (val) {
                            if (val != null) _onLanguageChanged(val);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BrutalButton(
                        label: _isRunning ? 'Running...' : 'Run Code',
                        icon: Icons.play_arrow_rounded,
                        compact: true,
                        variant: BrutalButtonVariant.accent,
                        onPressed: _isRunning ? null : _executeCode,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: BrutalButton(
                        label: _isSubmitting ? 'Submitting...' : 'Submit',
                        icon: Icons.cloud_upload_rounded,
                        compact: true,
                        variant: BrutalButtonVariant.primary,
                        onPressed: _isSubmitting ? null : _submitAssignment,
                      ),
                    ),
                  ]
                : null,
          ),
          body: isDesktop ? _buildDesktopLab() : const MobileLockoutPromptWidget(),
        );
      },
    );
  }

  Widget _buildDesktopLab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Code Editor
          Expanded(
            flex: 6,
            child: BrutalCard(
              color: NeobrutalismTheme.pureBlack,
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 16, color: NeobrutalismTheme.neonGreen),
                        const SizedBox(width: 8),
                        Text(
                          'main.${_selectedLanguage == "python" ? "py" : "js"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        color: NeobrutalismTheme.cardWhite,
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right: Standard Input & Execution Output Console
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Stdin Input
                BrutalCard(
                  color: NeobrutalismTheme.cardWhite,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Standard Input (Optional)',
                        style: NeobrutalismTheme.headingBold(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _stdinController,
                        maxLines: 2,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter input lines to pass to stdin...',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: NeobrutalismTheme.pureBlack, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Console Output
                Expanded(
                  child: BrutalCard(
                    color: const Color(0xFF161B22),
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D1117),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.terminal, size: 16, color: NeobrutalismTheme.accentYellow),
                              const SizedBox(width: 8),
                              const Text(
                                'Piston Runtime Console',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              if (_isRunning)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(NeobrutalismTheme.neonGreen),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _consoleOutput,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on TextEditingController {
  void disposeWidget() {
    dispose();
  }
}
