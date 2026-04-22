import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShadows {
  /// Standard soft shadow for 2026 design.
  /// Uses a two-layer approach: broad ambient + subtle key.
  static List<BoxShadow> standard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Elevated shadow for starred or priority items.
  static List<BoxShadow> priority(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = color ?? Theme.of(context).colorScheme.primary;
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: shadowColor.withValues(alpha: isDark ? 0.15 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Color-matched glow shadow for category cards.
  static List<BoxShadow> glow(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.1 : 0.03),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Extremely subtle shadow for quiet UI elements.
  static List<BoxShadow> quiet(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

class AppGradients {
  static LinearGradient primary(BuildContext context) {
    return LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient premium(BuildContext context) {
    return const LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
        Color(0xFFD946EF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class AppTypography {
  static TextStyle logoStyle(BuildContext context) {
    return GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.0,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static TextStyle headingStyle(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
