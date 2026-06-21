import 'dart:math' as math;
import 'dart:ui';
import 'package:dexdo/core/services/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppVoiceOverlay extends ConsumerWidget {
  const AppVoiceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechProvider);
    final isListening = speechState.isListening;
    final soundLevel = speechState.soundLevel;

    // Normalize soundLevel (usually ranges from -2.0 to 10.0 or more depending on platforms)
    // 0.0 - 1.0 multiplier range for voice activity responsiveness
    final double pulse = soundLevel.clamp(0.0, 10.0) / 10.0;

    return AnimatedOpacity(
      opacity: isListening ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _GlowFog(pulse: pulse, isListening: isListening),
        ),
      ),
    );
  }
}

class _GlowFog extends StatefulWidget {
  const _GlowFog({
    required this.pulse,
    required this.isListening,
  });

  final double pulse;
  final bool isListening;

  @override
  State<_GlowFog> createState() => _GlowFogState();
}

class _GlowFogState extends State<_GlowFog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _GlowFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isListening && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        
        // Slowly rotate gradient alignments to simulate organic live blob blending
        final double angle = t * 2 * math.pi;
        final Alignment begin = Alignment(
          math.sin(angle) * 0.6 - 0.4,
          math.cos(angle) * 0.4 - 0.6,
        );
        final Alignment end = Alignment(
          math.cos(angle) * 0.6 + 0.4,
          math.sin(angle) * 0.4 + 0.6,
        );

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: widget.pulse),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, smoothedPulse, child) {
            // Highly subtle organic colors (Gemini Live inspired)
            final Color color1 = Color.lerp(
              Colors.cyan,
              Colors.deepPurpleAccent,
              (math.sin(t * 2 * math.pi) + 1) / 2,
            )!.withValues(alpha: 0.38 + (smoothedPulse * 0.22));
            
            final Color color2 = Color.lerp(
              Colors.purpleAccent,
              Colors.orangeAccent,
              (math.cos(t * 2 * math.pi) + 1) / 2,
            )!.withValues(alpha: 0.32 + (smoothedPulse * 0.18));

            final Color color3 = Color.lerp(
              Colors.blueAccent,
              Colors.cyanAccent,
              (math.sin((t + 0.5) * 2 * math.pi) + 1) / 2,
            )!.withValues(alpha: 0.38 + (smoothedPulse * 0.22));

            // Visual height based on smoothed sound level
            final double visualHeight = 110.0 + (smoothedPulse * 70.0);

            return RepaintBoundary(
              child: SizedBox(
                height: 320, // Ceiling container height
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // 1. Shifting colored sheet at the bottom with ImageFiltered blur (blurs only the gradient, not the background)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 320, // Full height to prevent blur clipping
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.45, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Container(
                              height: visualHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: begin,
                                  end: end,
                                  colors: [
                                    color1,
                                    color2,
                                    color3,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
