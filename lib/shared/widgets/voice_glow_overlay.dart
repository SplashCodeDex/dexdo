import 'dart:math' as math;
import 'dart:ui';
import 'package:dexdo/core/services/speech_service.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppVoiceOverlay extends ConsumerWidget {
  const AppVoiceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechProvider);
    final isListening = speechState.isListening;
    final soundLevel = speechState.soundLevel;
    final isProcessing = speechState.isProcessing;

    // Normalize soundLevel (usually ranges from -2.0 to 10.0 or more depending on platforms)
    // 0.0 - 1.0 multiplier range for voice activity responsiveness
    final double pulse = soundLevel.clamp(0.0, 10.0) / 10.0;

    final showOverlay = isListening || isProcessing;
    final taskState = ref.watch(taskProvider);

    return AnimatedOpacity(
      opacity: showOverlay ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _GlowFog(
              pulse: pulse,
              isListening: isListening,
              isProcessing: isProcessing,
              transcript: speechState.lastWords,
              categories: taskState.categories,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowFog extends StatefulWidget {
  const _GlowFog({
    required this.pulse,
    required this.isListening,
    required this.isProcessing,
    required this.transcript,
    required this.categories,
  });

  final double pulse;
  final bool isListening;
  final bool isProcessing;
  final String transcript;
  final List<String> categories;

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

  List<TextSpan> _highlightTranscript(String text, List<String> categories) {
    final List<TextSpan> spans = [];
    final List<String> words = text.split(' ');
    
    // Quick patterns for real-time highlighting
    final dateKeywords = {
      'today', 'tomorrow', 'monday', 'tuesday', 'wednesday', 'thursday', 
      'friday', 'saturday', 'sunday', 'january', 'february', 'march', 
      'april', 'may', 'june', 'july', 'august', 'september', 'october', 
      'november', 'december', 'pm', 'am', 'morning', 'afternoon', 
      'evening', 'night', 'at', 'next', 'in', 'o\'clock'
    };

    final cleanCategories = categories.map((c) => c.toLowerCase()).toSet();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      final suffix = i == words.length - 1 ? '' : ' ';

      if (dateKeywords.contains(cleanWord) || RegExp(r'^\d+$').hasMatch(cleanWord)) {
        // Date/Time entities highlighted in Light Green
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: const TextStyle(
              color: Colors.lightGreenAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      } else if (cleanCategories.contains(cleanWord)) {
        // Category entities highlighted in Amber
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word$suffix'));
      }
    }
    return spans;
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
            )!.withValues(alpha: 0.48 + (smoothedPulse * 0.32));
            
            final Color color2 = Color.lerp(
              Colors.purpleAccent,
              Colors.orangeAccent,
              (math.cos(t * 2 * math.pi) + 1) / 2,
            )!.withValues(alpha: 0.42 + (smoothedPulse * 0.28));

            final Color color3 = Color.lerp(
              Colors.blueAccent,
              Colors.cyanAccent,
              (math.sin((t + 0.5) * 2 * math.pi) + 1) / 2,
            )!.withValues(alpha: 0.48 + (smoothedPulse * 0.32));

            // Visual height based on smoothed sound level
            final double visualHeight = 110.0 + (smoothedPulse * 70.0);

            return RepaintBoundary(
              child: SizedBox(
                height: 320, // Ceiling container height
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // 1. Shifting colored sheet at the bottom with ImageFiltered blur
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

                    // 2. Transcription text floating directly on top of the fog
                    Positioned(
                      left: 28,
                      right: 28,
                      bottom: 120, // Positioned above the bottom navigation bar and FAB
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isProcessing)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'AI is parsing your task...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else if (widget.transcript.isEmpty)
                            const _BreathingListeningPrompt()
                          else
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                  letterSpacing: 0.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                children: _highlightTranscript(widget.transcript, widget.categories),
                              ),
                            ),
                        ],
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

class _BreathingListeningPrompt extends StatefulWidget {
  const _BreathingListeningPrompt();

  @override
  State<_BreathingListeningPrompt> createState() => _BreathingListeningPromptState();
}

class _BreathingListeningPromptState extends State<_BreathingListeningPrompt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        'Listening...',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
