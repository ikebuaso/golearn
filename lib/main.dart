import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'firebase_options.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/instructor/instructor_dashboard_page.dart';
import 'features/student/desktop_code_lab_page.dart';
import 'features/student/student_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GoLearnApp());
}

class GoLearnApp extends StatelessWidget {
  const GoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Go Learn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: GoLearnColors.mint,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GoLearnColors.blue,
          surface: GoLearnColors.mint,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: GoLearnColors.ink),
          bodyMedium: TextStyle(color: GoLearnColors.ink),
        ),
      ),
      home: const _FirebaseAuthGate(),
    );
    return app;
  }
}

// ---------------------------------------------------------------------------
// Firebase Auth Gate
// ---------------------------------------------------------------------------

class _FirebaseAuthGate extends StatelessWidget {
  const _FirebaseAuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return _AccountStatusPage(user: snapshot.data!);
        }
        return const LandingPage();
      },
    );
  }
}

class _AccountStatusPage extends StatelessWidget {
  const _AccountStatusPage({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: GoLearnColors.white,
                  border: Border.all(color: GoLearnColors.ink, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: GoLearnColors.ink,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: _AccountStatusContent(user: user),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountStatusContent extends StatelessWidget {
  const _AccountStatusContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.split(' ').first ?? 'learner';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BrandMark(),
        const SizedBox(height: 28),
        Text(
          'Welcome, $name!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your account is active. Jump into your courses or start practising code below.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        _BrutalButton(
          label: 'Enter Student Dashboard',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const StudentDashboardPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _BrutalButton(
          label: 'Admin Management Panel',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminDashboardPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _BrutalButton(
          label: 'Instructor Grading Suite',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const InstructorDashboardPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _BrutalButton(
          label: 'Interactive Desktop Code Lab',
          secondary: true,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DesktopCodeLabPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _BrutalButton(
          label: 'Sign out',
          secondary: true,
          onPressed: () => AuthService.instance.signOut(),
        ),
      ],
    );
  }
}

abstract final class GoLearnColors {
  static const blue = Color(0xFF5346E0);
  static const green = Color(0xFF00FF87);
  static const mint = Color(0xFFE3FBEB);
  static const ink = Color(0xFF0C1810);
  static const white = Color(0xFFFFFFFF);
  static const red = Color(0xFF9E1B22);
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSignUp(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SignUpPage()));
  }

  void _openDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StudentDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 48 : 22,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LandingHeader(
                          onSignUp: () => _openSignUp(context),
                          onDashboard: () => _openDashboard(context),
                        ),
                        const SizedBox(height: 36),
                        _HeroSection(
                          isWide: isWide,
                          onSignUp: () => _openSignUp(context),
                          onDownload: () => _showNotice(
                            context,
                            'The Android download will be available here soon.',
                          ),
                        ),
                        const SizedBox(height: 76),
                        const _SectionHeading(
                          eyebrow: 'MADE FOR EVERY LEARNER',
                          title: 'Everything you need to keep growing.',
                          description:
                              'Go Learn brings lessons, practice, and progress '
                              'together in one welcoming place.',
                        ),
                        const SizedBox(height: 28),
                        _FeatureGrid(isWide: isWide),
                        const SizedBox(height: 64),
                        _DownloadBanner(
                          isWide: isWide,
                          onDownload: () => _showNotice(
                            context,
                            'The Android download will be available here soon.',
                          ),
                        ),
                        const SizedBox(height: 56),
                        const Divider(color: GoLearnColors.ink, thickness: 2),
                        const SizedBox(height: 18),
                        const Text(
                          '© Go Learn',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
    required this.onSignUp,
    required this.onDashboard,
  });

  final VoidCallback onSignUp;
  final VoidCallback onDashboard;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const _BrandMark(),
        Wrap(
          spacing: 10,
          children: [
            _BrutalButton(
              label: 'Explore App',
              secondary: true,
              compact: true,
              onPressed: onDashboard,
            ),
            _BrutalButton(label: 'Sign up', onPressed: onSignUp, compact: true),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: GoLearnColors.green,
            border: Border.all(color: GoLearnColors.ink, width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: GoLearnColors.ink,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.menu_book_rounded, size: 25),
        ),
        const SizedBox(width: 12),
        const Text(
          'Go Learn',
          style: TextStyle(
            color: GoLearnColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.isWide,
    required this.onSignUp,
    required this.onDownload,
  });

  final bool isWide;
  final VoidCallback onSignUp;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: GoLearnColors.green,
            border: Border.all(color: GoLearnColors.ink, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'YOUR NEXT CHAPTER STARTS HERE',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Learn something.\nBecome someone.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: GoLearnColors.ink,
            fontSize: isWide ? 56 : 42,
            height: 1.02,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.1,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 510),
          child: Text(
            'A better way to learn, practice, and see how far you have come. '
            'Go Learn puts your courses and daily learning in one place.',
            textAlign: isWide ? TextAlign.left : TextAlign.center,
            style: const TextStyle(fontSize: 17, height: 1.55),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            _BrutalButton(
              label: 'Create your account',
              onPressed: onSignUp,
              icon: Icons.arrow_forward_rounded,
            ),
            _BrutalButton(
              label: 'Get the Android app',
              onPressed: onDownload,
              secondary: true,
              icon: Icons.android_rounded,
            ),
          ],
        ),
      ],
    );

    final illustration = _LearningIllustration(isWide: isWide);

    return Container(
      padding: EdgeInsets.all(isWide ? 42 : 24),
      decoration: BoxDecoration(
        color: GoLearnColors.blue,
        border: Border.all(color: GoLearnColors.ink, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: GoLearnColors.ink,
            offset: Offset(7, 7),
            blurRadius: 0,
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 32),
                Expanded(flex: 4, child: illustration),
              ],
            )
          : Column(children: [copy, const SizedBox(height: 32), illustration]),
    );
  }
}

class _LearningIllustration extends StatelessWidget {
  const _LearningIllustration({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: isWide ? 1.08 : 1.55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 12,
            top: 8,
            child: Transform.rotate(
              angle: 0.11,
              child: Container(
                width: isWide ? 235 : 190,
                height: isWide ? 245 : 205,
                decoration: BoxDecoration(
                  color: GoLearnColors.green,
                  border: Border.all(color: GoLearnColors.ink, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: GoLearnColors.ink,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 105,
                  color: GoLearnColors.ink,
                ),
              ),
            ),
          ),
          Positioned(
            left: 2,
            bottom: 12,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: GoLearnColors.white,
                  border: Border.all(color: GoLearnColors.ink, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: GoLearnColors.ink,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 250 : 270),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: GoLearnColors.blue),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Little steps. Big progress.',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 22,
            child: Transform.rotate(
              angle: -0.12,
              child: const Icon(
                Icons.star_rounded,
                size: 45,
                color: GoLearnColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GoLearnColors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            height: 1.12,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 590),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        icon: Icons.menu_book_rounded,
        title: 'Learn at your pace',
        description: 'Clear course notes and daily lessons help you focus on what is next.',
        color: GoLearnColors.white,
      ),
      (
        icon: Icons.quiz_rounded,
        title: 'Put it into practice',
        description:
            'Quick quizzes help you check your understanding as you go.',
        color: GoLearnColors.green,
      ),
      (
        icon: Icons.trending_up_rounded,
        title: 'See your progress',
        description:
            'Keep track of completed work and celebrate each new milestone.',
        color: Color(0xFFFFE18A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 1;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 20) / columns;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            for (final feature in features)
              SizedBox(
                width: itemWidth,
                child: _FeatureCard(
                  icon: feature.icon,
                  title: feature.title,
                  description: feature.description,
                  color: feature.color,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: GoLearnColors.ink, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: GoLearnColors.ink,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

class _DownloadBanner extends StatelessWidget {
  const _DownloadBanner({required this.isWide, required this.onDownload});

  final bool isWide;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        const Text(
          'Take Go Learn with you.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'The Android app download link will be added here soon.',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.45),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE18A),
        border: Border.all(color: GoLearnColors.ink, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: GoLearnColors.ink,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 24),
                _BrutalButton(
                  label: 'Download for Android',
                  onPressed: onDownload,
                  icon: Icons.android_rounded,
                ),
              ],
            )
          : Column(
              children: [
                content,
                const SizedBox(height: 20),
                _BrutalButton(
                  label: 'Download for Android',
                  onPressed: onDownload,
                  icon: Icons.android_rounded,
                ),
              ],
            ),
    );
  }
}

class _BrutalButton extends StatelessWidget {
  const _BrutalButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.compact = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool secondary;
  final bool compact;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        secondary ? GoLearnColors.white : GoLearnColors.green;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: GoLearnColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: GoLearnColors.ink,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 20,
              vertical: compact ? 10 : 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: GoLearnColors.ink,
                      fontSize: compact ? 14 : 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 19, color: GoLearnColors.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _isSignIn = false; // toggle between sign-up and sign-in

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    final msg = e is FirebaseAuthException ? (e.message ?? e.code) : e.toString();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitEmailAuth() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;
    setState(() => _loading = true);
    try {
      if (_isSignIn) {
        await AuthService.instance.signInWithEmail(
          email: email,
          password: password,
        );
      } else {
        await AuthService.instance.signUpWithEmail(
          email: email,
          password: password,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GoLearnColors.mint,
        title: const _BrandMark(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: GoLearnColors.white,
                  border: Border.all(color: GoLearnColors.ink, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: GoLearnColors.ink,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isSignIn ? 'Welcome back.' : 'Start learning.',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignIn
                          ? 'Sign in to your Go Learn account.'
                          : 'Create your Go Learn account to get started.',
                      style: const TextStyle(height: 1.45),
                    ),
                    const SizedBox(height: 26),

                    // ── Google sign-in ──────────────────────────────────────
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                              side: const BorderSide(
                                  color: GoLearnColors.ink, width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: GoLearnColors.white,
                              foregroundColor: GoLearnColors.ink,
                            ),
                            onPressed: _signInWithGoogle,
                            icon: const Icon(Icons.login_rounded, size: 20),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),

                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: GoLearnColors.ink)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('or',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Expanded(child: Divider(color: GoLearnColors.ink)),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Email / Password ────────────────────────────────────
                    _SignUpField(
                      label: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                    ),
                    const SizedBox(height: 16),
                    _SignUpField(
                      label: 'Password',
                      obscureText: true,
                      controller: _passwordCtrl,
                    ),
                    const SizedBox(height: 24),

                    _BrutalButton(
                      label: _isSignIn ? 'Sign in' : 'Create account',
                      onPressed: _loading ? () {} : _submitEmailAuth,
                    ),
                    const SizedBox(height: 16),

                    // ── Toggle sign-in / sign-up ────────────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _isSignIn = !_isSignIn),
                      child: Text(
                        _isSignIn
                            ? "Don't have an account? Sign up"
                            : 'Already have an account? Sign in',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpField extends StatelessWidget {
  const _SignUpField({
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.controller,
  });

  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: GoLearnColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: GoLearnColors.ink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: GoLearnColors.ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: GoLearnColors.blue, width: 3),
        ),
      ),
    );
  }
}
