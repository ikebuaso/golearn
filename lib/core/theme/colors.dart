import 'package:flutter/material.dart';

/// Neobrutalism color palette specification extracted from the design guide.
abstract final class NeobrutalismColors {
  /// Primary Royal Blue: Hero panels, main CTA button fill
  static const Color primaryBlue = Color(0xFF5346E0);

  /// Accent Neon Green: Highlight text, badge indicators, callouts
  static const Color neonGreen = Color(0xFF00FF87);

  /// Background Pale Mint: Global web & mobile screen background
  static const Color backgroundMint = Color(0xFFE3FBEB);

  /// Secondary Crimson Red: Badges, alert banners, tags
  static const Color crimsonRed = Color(0xFF9E1B22);

  /// Neutral Dark Charcoal / Pure Black: Thick borders, hard offset shadows
  static const Color pureBlack = Color(0xFF0C1810);

  /// Surface White: Card backgrounds, input container fills
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Accent Yellow: Callout boxes, highlight cards
  static const Color accentYellow = Color(0xFFFFE18A);

  /// Muted gray for borders/dividers where needed
  static const Color subtleGray = Color(0xFFECECEC);
}
