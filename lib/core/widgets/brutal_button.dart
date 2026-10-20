import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum BrutalButtonVariant {
  primary, // Blue
  accent, // Neon Green
  secondary, // White
  danger, // Crimson Red
}

class BrutalButton extends StatelessWidget {
  const BrutalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BrutalButtonVariant.accent,
    this.compact = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BrutalButtonVariant variant;
  final bool compact;
  final IconData? icon;
  final bool expand;

  Color get _backgroundColor {
    switch (variant) {
      case BrutalButtonVariant.primary:
        return NeobrutalismTheme.primaryBlue;
      case BrutalButtonVariant.accent:
        return NeobrutalismTheme.neonGreen;
      case BrutalButtonVariant.secondary:
        return NeobrutalismTheme.cardWhite;
      case BrutalButtonVariant.danger:
        return NeobrutalismTheme.crimsonRed;
    }
  }

  Color get _textColor {
    switch (variant) {
      case BrutalButtonVariant.primary:
      case BrutalButtonVariant.danger:
        return NeobrutalismTheme.cardWhite;
      case BrutalButtonVariant.accent:
      case BrutalButtonVariant.secondary:
        return NeobrutalismTheme.pureBlack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    final childWidget = Container(
      decoration: BoxDecoration(
        color: isEnabled ? _backgroundColor : const Color(0xFFDDDDDD),
        border: Border.all(color: NeobrutalismTheme.pureBlack, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isEnabled
            ? const [
                BoxShadow(
                  color: NeobrutalismTheme.pureBlack,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 20,
              vertical: compact ? 9 : 13,
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: compact ? 17 : 20, color: _textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: NeobrutalismTheme.headingBold(
                    fontSize: compact ? 13 : 15,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: childWidget);
    }
    return childWidget;
  }
}
