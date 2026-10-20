import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'brutal_card.dart';

/// Mobile lockout widget shown when accessing Desktop Code Lab on a screen width < 800px
/// or mobile form factor, per PRD Section 4.
class MobileLockoutPromptWidget extends StatelessWidget {
  const MobileLockoutPromptWidget({
    super.key,
    this.assignmentTitle = 'Interactive Code Lab',
  });

  final String assignmentTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    color: NeobrutalismTheme.accentYellow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: NeobrutalismTheme.pureBlack,
                      width: 2.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NeobrutalismTheme.pureBlack,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 38,
                    color: NeobrutalismTheme.pureBlack,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Desktop Only Environment',
                  textAlign: TextAlign.center,
                  style: NeobrutalismTheme.headingBold(
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
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
                    assignmentTitle.toUpperCase(),
                    style: NeobrutalismTheme.headingBold(
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The interactive code editor and Piston runtime require a larger display (≥ 800px).\n\n'
                  'Please open Go Learn on a desktop browser or expand your window to practice coding.',
                  textAlign: TextAlign.center,
                  style: NeobrutalismTheme.bodyText(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.laptop_chromebook_rounded,
                      size: 20,
                      color: NeobrutalismTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended: 1024px or wider',
                      style: NeobrutalismTheme.headingBold(
                        fontSize: 12,
                        color: NeobrutalismTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
