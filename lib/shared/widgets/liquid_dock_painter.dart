import 'dart:ui';
import 'package:flutter/material.dart';

/// Generates the morphing liquid path that transitions from
/// [pill + gap + circle] → [single wide pill] via a bézier-based liquid neck.
///
/// **Animation timeline:**
/// - `progress = 0.0`: Dock mode — separate pill (nav) and circle (FAB)
/// - `progress = 0.0–0.4`: Neck formation — FAB slides left, liquid bridge grows
/// - `progress = 0.4–1.0`: Smoothing — shapes merge into one unified pill
/// - `progress = 1.0`: Input mode — single wide glassmorphic pill
class LiquidDockPathGenerator {
  const LiquidDockPathGenerator._();

  // ── Geometry constants ──
  static const double dockHeight = 64.0;
  static const double dockRadius = 32.0;
  static const double fabDiameter = 56.0;
  static const double fabRadius = 28.0;
  static const double gapWidth = 16.0;
  static const double horizontalPadding = 20.0;

  /// Builds the unified morphing path for the given [progress] (0..1).
  ///
  /// [totalWidth] is the available width minus horizontal padding on both sides.
  /// The path describes the outer contour of the combined navbar + FAB shape.
  static Path buildPath(double progress, double totalWidth) {
    // Key measurements
    final double navWidth = totalWidth - gapWidth - fabDiameter;
    const double centerY = dockHeight / 2;

    // Eased sub-progress values for the two phases
    // Phase 1 (0.0-0.4): Slide + neck formation
    final double slideT = Curves.easeInOutCubic.transform(
      (progress / 0.4).clamp(0.0, 1.0),
    );
    // Phase 2 (0.4-1.0): Smoothing into final pill
    final double smoothT = Curves.easeInOutCubic.transform(
      ((progress - 0.4) / 0.6).clamp(0.0, 1.0),
    );

    // ── FAB position & shape ──
    // The FAB slides leftward from its dock position toward the navbar
    final double currentGap = gapWidth * (1.0 - slideT);
    final double fabLeft = navWidth + currentGap;
    final double fabRight = fabLeft + fabDiameter;

    // FAB vertical expansion: starts at fabDiameter height, expands to dockHeight
    final double fabH = lerpDouble(fabDiameter, dockHeight, smoothT)!;
    final double fabTop = centerY - fabH / 2;
    final double fabBottom = centerY + fabH / 2;

    // FAB corner radius: starts as circle (fabRadius), morphs to dockRadius
    final double fabCorner = lerpDouble(fabRadius, dockRadius, smoothT)!;

    // ── Neck bridge properties ──
    // The neck only forms when there's a gap and we're in phase 1
    final double neckProgress = slideT; // 0..1 during phase 1
    // Neck vertical opening: starts thin, widens to full height
    final double neckHalfH = lerpDouble(
      4.0, // very thin initial neck
      dockHeight / 2,
      Curves.easeOut.transform(neckProgress),
    )!;
    final double neckTop = centerY - neckHalfH;
    final double neckBottom = centerY + neckHalfH;

    // Control point pull distance for the bézier curves (how far the curve bows)
    final double pullDistance = currentGap * 0.6;

    // ── Build the unified clockwise path ──
    final path = Path();

    if (progress == 0.0) {
      // Pure dock mode: two separate shapes
      _addSeparateShapes(path, navWidth, totalWidth, centerY);
      return path;
    }

    if (progress >= 1.0) {
      // Pure input mode: single wide pill
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, totalWidth, dockHeight),
        const Radius.circular(dockRadius),
      ));
      return path;
    }

    // ── Morphing state: connected liquid path ──
    // Start at top-left of the navbar pill
    path.moveTo(dockRadius, 0);

    // Top edge of navbar pill (straight line to where the right curve begins)
    path.lineTo(navWidth - dockRadius, 0);

    if (currentGap > 0.5) {
      // Gap still exists — draw navbar's right rounded corner, then bridge to FAB

      // Navbar pill: top-right corner arc
      path.arcToPoint(
        Offset(navWidth, dockRadius),
        radius: const Radius.circular(dockRadius),
      );

      // Right edge of navbar pill down to neck top
      path.lineTo(navWidth, neckTop);

      // ── Top neck bridge (bézier from navbar right → FAB left) ──
      path.cubicTo(
        navWidth + pullDistance, neckTop, // cp1: pull right from navbar
        fabLeft - pullDistance, fabTop,    // cp2: pull left from FAB
        fabLeft, fabTop,                  // end: FAB top-left
      );

      // FAB shape: top-left corner to top-right corner
      path.lineTo(fabRight - fabCorner, fabTop);
      path.arcToPoint(
        Offset(fabRight, fabTop + fabCorner),
        radius: Radius.circular(fabCorner),
      );

      // FAB right edge
      path.lineTo(fabRight, fabBottom - fabCorner);

      // FAB bottom-right corner
      path.arcToPoint(
        Offset(fabRight - fabCorner, fabBottom),
        radius: Radius.circular(fabCorner),
      );

      // FAB bottom edge
      path.lineTo(fabLeft, fabBottom);

      // ── Bottom neck bridge (bézier from FAB left → navbar right) ──
      path.cubicTo(
        fabLeft - pullDistance, fabBottom, // cp1: pull left from FAB
        navWidth + pullDistance, neckBottom, // cp2: pull right from navbar
        navWidth, neckBottom,             // end: navbar right at neck bottom
      );

      // Right edge of navbar pill from neck bottom to bottom-right corner
      path.lineTo(navWidth, dockHeight - dockRadius);

      // Navbar pill: bottom-right corner arc
      path.arcToPoint(
        Offset(navWidth - dockRadius, dockHeight),
        radius: const Radius.circular(dockRadius),
      );
    } else {
      // Gap is closed — shapes are touching/merging.
      // Smooth transition from navbar's right edge to FAB shape.
      // The smoothT handles the vertical alignment differences.

      // Right side transitions from navbar to FAB arc smoothly
      final double mergedRight = lerpDouble(navWidth + fabDiameter, totalWidth, smoothT)!;
      final double mergedCornerR = lerpDouble(dockRadius, fabCorner, 1.0)!;

      // Top-right corner of the merged shape
      path.arcToPoint(
        Offset(mergedRight, mergedCornerR),
        radius: Radius.circular(mergedCornerR),
      );

      // Right edge
      path.lineTo(mergedRight, dockHeight - mergedCornerR);

      // Bottom-right corner
      path.arcToPoint(
        Offset(mergedRight - mergedCornerR, dockHeight),
        radius: Radius.circular(mergedCornerR),
      );
    }

    // Bottom edge back to left
    path.lineTo(dockRadius, dockHeight);

    // Bottom-left corner
    path.arcToPoint(
      const Offset(0, dockHeight - dockRadius),
      radius: const Radius.circular(dockRadius),
    );

    // Left edge
    path.lineTo(0, dockRadius);

    // Top-left corner
    path.arcToPoint(
      const Offset(dockRadius, 0),
      radius: const Radius.circular(dockRadius),
    );

    path.close();
    return path;
  }

  /// Builds two separate paths for the dock state (progress = 0).
  static void _addSeparateShapes(
    Path path,
    double navWidth,
    double totalWidth,
    double centerY,
  ) {
    // Navbar pill
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, navWidth, dockHeight),
      const Radius.circular(dockRadius),
    ));

    // FAB circle
    final double fabLeft = navWidth + gapWidth;
    path.addOval(Rect.fromLTWH(
      fabLeft,
      centerY - fabRadius,
      fabDiameter,
      fabDiameter,
    ));
  }
}

/// [CustomClipper] that clips the widget tree to the liquid morphing shape.
/// Used with [ClipPath] + [BackdropFilter] for the glassmorphic effect.
class LiquidDockClipper extends CustomClipper<Path> {
  LiquidDockClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    return LiquidDockPathGenerator.buildPath(progress, size.width);
  }

  @override
  bool shouldReclip(LiquidDockClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// [CustomPainter] that draws the glassmorphic border stroke on the liquid shape.
class LiquidDockBorderPainter extends CustomPainter {
  LiquidDockBorderPainter({
    required this.progress,
    required this.borderColor,
    this.borderWidth = 1.0,
  });

  final double progress;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = LiquidDockPathGenerator.buildPath(progress, size.width);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidDockBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// [CustomPainter] that draws a subtle shadow beneath the liquid shape.
class LiquidDockShadowPainter extends CustomPainter {
  LiquidDockShadowPainter({
    required this.progress,
    required this.shadowColor,
  });

  final double progress;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = LiquidDockPathGenerator.buildPath(progress, size.width);

    canvas.drawShadow(path, shadowColor, 10.0, false);
  }

  @override
  bool shouldRepaint(LiquidDockShadowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.shadowColor != shadowColor;
  }
}
