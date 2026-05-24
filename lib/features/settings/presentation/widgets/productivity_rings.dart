import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class ProductivityRings extends StatelessWidget {

  const ProductivityRings({
    super.key,
    required this.mainTaskProgress,
    required this.subtaskProgress,
    this.size = 80,
  });
  final double mainTaskProgress;
  final double subtaskProgress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Outer Ring (Main Tasks)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: mainTaskProgress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutBack,
            builder: (context, value, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: value,
                  color: const Color(0xFFFF2D55), // Apple Activity Red
                  secondaryColor: const Color(0xFFFF2D55).withValues(alpha: 0.2),
                  strokeWidth: size * 0.12,
                ),
              );
            },
          ),
          // Inner Ring (Subtasks)
          Padding(
            padding: EdgeInsets.all(size * 0.15),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: subtaskProgress),
              duration: const Duration(milliseconds: 1800),
              curve: Curves.easeOutBack,
              builder: (context, value, _) {
                return CustomPaint(
                  size: Size(size * 0.7, size * 0.7),
                  painter: _RingPainter(
                    progress: value,
                    color: const Color(0xFF6366F1), // Indigo/Purple
                    secondaryColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    strokeWidth: size * 0.12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {

  _RingPainter({
    required this.progress,
    required this.color,
    required this.secondaryColor,
    required this.strokeWidth,
  });
  final double progress;
  final Color color;
  final Color secondaryColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.01, 1.0), // Ensure small bit is always visible if progress > 0
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

@widgetbook.UseCase(
  name: 'Default',
  type: ProductivityRings,
)
Widget buildProductivityRingsUseCase(BuildContext context) {
  return Center(
    child: ProductivityRings(
      mainTaskProgress: context.knobs.double.slider(
        label: 'Main Task Progress',
        initialValue: 0.7,
        min: 0,
        max: 1,
      ),
      subtaskProgress: context.knobs.double.slider(
        label: 'Subtask Progress',
        initialValue: 0.4,
        min: 0,
        max: 1,
      ),
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 80,
        min: 40,
        max: 200,
      ),
    ),
  );
}
