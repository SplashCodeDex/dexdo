import 'package:flutter/material.dart';

/// A premium animated splash screen that mirrors the native Android AVD animation.
/// Used for Web and iOS platforms where the native Android SplashScreen API isn't available.
class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedSplashScreen({super.key, required this.onComplete});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleStrokeController;
  late AnimationController _circleFillController;
  late AnimationController _smallCircleController;
  late AnimationController _path1StrokeController;
  late AnimationController _path1FillController;
  late AnimationController _path2StrokeController;
  late AnimationController _path2FillController;

  @override
  void initState() {
    super.initState();

    // Background circle stroke draw: 0ms → 800ms
    _circleStrokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Background circle fill: 800ms → 1500ms
    _circleFillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Small decorative circle fade: 600ms → 1000ms
    _smallCircleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Checkmark path 1 stroke: 200ms → 800ms
    _path1StrokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Checkmark path 1 fill: 700ms → 1000ms
    _path1FillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Checkmark path 2 stroke: 400ms → 1000ms
    _path2StrokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Checkmark path 2 fill: 900ms → 1200ms
    _path2FillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Stagger the animations to match the CSS/AVD timing
    _circleStrokeController.forward(); // Start immediately

    await Future.delayed(const Duration(milliseconds: 200));
    _path1StrokeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _path2StrokeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _smallCircleController.forward();
    _circleFillController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _path1FillController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _path2FillController.forward();

    // Wait for last animation to finish, then dismiss
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _circleStrokeController.dispose();
    _circleFillController.dispose();
    _smallCircleController.dispose();
    _path1StrokeController.dispose();
    _path1FillController.dispose();
    _path2StrokeController.dispose();
    _path2FillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _circleStrokeController,
              _circleFillController,
              _smallCircleController,
              _path1StrokeController,
              _path1FillController,
              _path2StrokeController,
              _path2FillController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _DeXDoLogoPainter(
                  circleStroke: _circleStrokeController.value,
                  circleFill: _circleFillController.value,
                  smallCircle: _smallCircleController.value,
                  path1Stroke: _path1StrokeController.value,
                  path1Fill: _path1FillController.value,
                  path2Stroke: _path2StrokeController.value,
                  path2Fill: _path2FillController.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeXDoLogoPainter extends CustomPainter {
  final double circleStroke;
  final double circleFill;
  final double smallCircle;
  final double path1Stroke;
  final double path1Fill;
  final double path2Stroke;
  final double path2Fill;

  _DeXDoLogoPainter({
    required this.circleStroke,
    required this.circleFill,
    required this.smallCircle,
    required this.path1Stroke,
    required this.path1Fill,
    required this.path2Stroke,
    required this.path2Fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 1024;
    canvas.save();
    canvas.scale(scale);

    // --- 1. Background Circle ---
    const circleCenter = Offset(512, 512);
    const circleRadius = 485.52;

    // Fill (gradient)
    if (circleFill > 0) {
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-0.3, -0.35),
          end: Alignment(0.8, 0.95),
          colors: [Color(0xFF6439AB), Color(0xFF885AD2)],
          stops: [0.22, 0.67],
        ).createShader(Rect.fromCircle(center: circleCenter, radius: circleRadius))
        ..color = Color.fromRGBO(255, 255, 255, circleFill);
      canvas.drawCircle(circleCenter, circleRadius, fillPaint);
    }

    // Stroke (draw animation)
    if (circleStroke > 0 && circleStroke < 1.0) {
      final strokePaint = Paint()
        ..color = const Color(0xFF6439AB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      final circlePath = Path()
        ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius));
      final metric = circlePath.computeMetrics().first;
      final extractedPath = metric.extractPath(0, metric.length * circleStroke);
      canvas.drawPath(extractedPath, strokePaint);
    }

    // --- 2. Small Decorative Circle ---
    if (smallCircle > 0) {
      final smallPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-0.5, 0.3),
          end: Alignment(0.5, -0.7),
          colors: [Color(0xFFD9D3E3), Color(0xFF885AD2)],
          stops: [0.22, 0.67],
        ).createShader(Rect.fromCircle(center: const Offset(458.71, 391.06), radius: 91.62))
        ..color = Color.fromRGBO(255, 255, 255, smallCircle);
      canvas.drawCircle(const Offset(458.71, 391.06), 91.62, smallPaint);
    }

    // --- 3. Checkmark Path 1 (short arm) ---
    _drawAnimatedPath(
      canvas,
      'M519.97,725.43 L500.46,744.94 C480.54,764.86 448.24,764.86 428.31,744.94 L230.22,546.85 C210.3,526.93 210.3,494.63 230.22,474.7 L249.73,455.19 C269.65,435.27 301.95,435.27 321.88,455.19 L519.97,653.28 C539.89,673.21 539.89,705.5 519.97,725.43 Z',
      path1Stroke,
      path1Fill,
      const Color(0xFFD9D3E3),
    );

    // --- 4. Checkmark Path 2 (long arm) ---
    _drawAnimatedPath(
      canvas,
      'M824.62,336.75 L824.68,336.81 C849.97,362.1 849.97,403.11 824.68,428.41 L513.31,739.78 C488.02,765.07 447.01,765.07 421.71,739.78 L421.65,739.72 C396.36,714.42 396.36,673.42 421.65,648.12 L733.02,336.75 C758.32,311.46 799.33,311.46 824.62,336.75 Z',
      path2Stroke,
      path2Fill,
      const Color(0xFFD9D3E3),
    );

    canvas.restore();
  }

  void _drawAnimatedPath(
    Canvas canvas,
    String pathData,
    double strokeProgress,
    double fillProgress,
    Color color,
  ) {
    final path = _parseSvgPath(pathData);

    // Fill
    if (fillProgress > 0) {
      final fillPaint = Paint()
        ..color = color.withValues(alpha: fillProgress)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Stroke draw
    if (strokeProgress > 0 && strokeProgress < 1.0) {
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final metric = path.computeMetrics().first;
      final extractedPath = metric.extractPath(0, metric.length * strokeProgress);
      canvas.drawPath(extractedPath, strokePaint);
    }
  }

  Path _parseSvgPath(String d) {
    final path = Path();
    final commands = RegExp(r'[MmLlCcZz][^MmLlCcZz]*').allMatches(d);

    for (var match in commands) {
      final cmd = match.group(0)!;
      final type = cmd[0];
      final nums = RegExp(r'-?\d+\.?\d*').allMatches(cmd.substring(1)).map((m) => double.parse(m.group(0)!)).toList();

      switch (type) {
        case 'M':
          path.moveTo(nums[0], nums[1]);
          break;
        case 'L':
          path.lineTo(nums[0], nums[1]);
          break;
        case 'C':
          for (int i = 0; i < nums.length; i += 6) {
            path.cubicTo(nums[i], nums[i + 1], nums[i + 2], nums[i + 3], nums[i + 4], nums[i + 5]);
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _DeXDoLogoPainter oldDelegate) {
    return circleStroke != oldDelegate.circleStroke ||
        circleFill != oldDelegate.circleFill ||
        smallCircle != oldDelegate.smallCircle ||
        path1Stroke != oldDelegate.path1Stroke ||
        path1Fill != oldDelegate.path1Fill ||
        path2Stroke != oldDelegate.path2Stroke ||
        path2Fill != oldDelegate.path2Fill;
  }
}
