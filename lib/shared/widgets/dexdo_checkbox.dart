import 'dart:math';
import 'package:flutter/material.dart';

class DexDoCheckBox extends StatefulWidget {
  const DexDoCheckBox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size = 24.0,
    this.progress,
    this.isCircle = false,
    this.isSelectionMode = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final double? progress;
  final bool isCircle;
  final bool isSelectionMode;

  @override
  State<DexDoCheckBox> createState() => _DexDoCheckBoxState();
}

class _DexDoCheckBoxState extends State<DexDoCheckBox> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _popController;
  late Animation<double> _checkAnimation;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    );

    _popAnimation = CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOutCubic,
    );

    if (widget.value) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DexDoCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _checkController.forward();
        _popController.forward(from: 0.0);
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final checkColor = widget.checkColor ?? Colors.white;

    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Ring
          if (widget.progress != null && !widget.value)
            SizedBox(
              width: widget.size + 10,
              height: widget.size + 10,
              child: CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 2.5,
                backgroundColor: activeColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progress == 1.0 ? Colors.green : activeColor,
                ),
              ),
            ),

          // Pop Effect
          AnimatedBuilder(
            animation: _popAnimation,
            builder: (context, child) {
              if (_popAnimation.value == 0 || _popAnimation.value == 1) {
                return const SizedBox.shrink();
              }
              return CustomPaint(
                size: Size(widget.size * 2, widget.size * 2),
                painter: _PopPainter(
                  progress: _popAnimation.value,
                  color: activeColor,
                ),
              );
            },
          ),

          // Main Checkbox
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.isSelectionMode
                      ? activeColor
                      : Color.lerp(
                          Colors.transparent,
                          widget.value ? activeColor : activeColor.withValues(alpha: 0.15),
                          _checkAnimation.value,
                        ),
                  shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: widget.isCircle ? null : BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.value || widget.isSelectionMode
                        ? activeColor
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: (widget.value || widget.isSelectionMode) ? 0 : 1.5,
                  ),
                ),
                child: CustomPaint(
                  painter: _CheckPainter(
                    progress: _checkAnimation.value,
                    color: checkColor,
                    isCompleted: widget.value || widget.isSelectionMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.progress,
    required this.color,
    required this.isCompleted,
  });

  final double progress;
  final Color color;
  final bool isCompleted;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 && !isCompleted) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Checkmark points relative to size
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final midX = size.width * 0.45;
    final midY = size.height * 0.7;
    final endX = size.width * 0.75;
    final endY = size.height * 0.3;

    path.moveTo(startX, startY);
    path.lineTo(midX, midY);
    path.lineTo(endX, endY);

    final pathMetrics = path.computeMetrics().first;
    final extractPath = pathMetrics.extractPath(
      0.0,
      pathMetrics.length * (isCompleted ? 1.0 : progress),
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

class _PopPainter extends CustomPainter {
  _PopPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * progress;

    // Main ring that fades out
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (1.0 - progress);

    canvas.drawCircle(center, radius, paint);

    // Particles/Sparks
    const particleCount = 6;
    final particlePaint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * pi) / particleCount;
      final distance = radius * 1.2;
      final particleSize = 2.0 * (1.0 - progress);

      final particleOffset = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawCircle(particleOffset, particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_PopPainter oldDelegate) => progress != oldDelegate.progress;
}
