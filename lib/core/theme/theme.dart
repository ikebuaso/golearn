import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

export 'colors.dart';

/// Design system specification for Neobrutalism.
abstract final class NeobrutalismTheme {
  static const Color primaryBlue = NeobrutalismColors.primaryBlue;
  static const Color neonGreen = NeobrutalismColors.neonGreen;
  static const Color backgroundMint = NeobrutalismColors.backgroundMint;
  static const Color crimsonRed = NeobrutalismColors.crimsonRed;
  static const Color pureBlack = NeobrutalismColors.pureBlack;
  static const Color cardWhite = NeobrutalismColors.cardWhite;
  static const Color accentYellow = NeobrutalismColors.accentYellow;
  static const Color subtleGray = NeobrutalismColors.subtleGray;

  /// Helper for Neobrutal card decoration with hard offset drop shadow & thick black border.
  static BoxDecoration neobrutalCardDecoration({
    Color color = cardWhite,
    double borderRadius = 12,
    double borderWidth = 2.5,
    Offset shadowOffset = const Offset(4, 4),
    Color shadowColor = pureBlack,
    Color borderColor = pureBlack,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: shadowOffset,
          blurRadius: 0, // Hard shadow, zero blur
        ),
      ],
    );
  }

  /// High-contrast bold heading style with Lexend typography.
  static TextStyle headingBold({
    double fontSize = 28,
    Color color = pureBlack,
    double letterSpacing = -0.7,
    FontWeight fontWeight = FontWeight.w900,
    double? height,
  }) {
    return GoogleFonts.lexend(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Body text with Lexend typography.
  static TextStyle bodyText({
    double fontSize = 15,
    Color color = pureBlack,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.45,
  }) {
    return GoogleFonts.lexend(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Material ThemeData configured for Neobrutalism.
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundMint,
      fontFamily: GoogleFonts.lexend().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: backgroundMint,
      ),
      dividerTheme: const DividerThemeData(
        color: pureBlack,
        thickness: 2,
      ),
    );
  }
}
