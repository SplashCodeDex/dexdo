import 'dart:ui';
import 'package:flutter/material.dart';

class VoicePreviewWindow extends StatelessWidget {
  const VoicePreviewWindow({
    super.key,
    required this.transcript,
    required this.categories,
    required this.isProcessing,
  });

  final String transcript;
  final List<String> categories;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Body showing transcription with entity highlighting
              Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 150),
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: isProcessing
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI is parsing your task...',
                              style: TextStyle(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : transcript.isEmpty
                          ? Text(
                              'Say something like: "Call Dad tomorrow at 2 PM under Personal"',
                              style: TextStyle(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                                children: _highlightTranscript(transcript, isDark),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _highlightTranscript(String text, bool isDark) {
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
        // Date/Time entities highlighted in Green
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: TextStyle(
              color: isDark ? Colors.greenAccent : Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (cleanCategories.contains(cleanWord)) {
        // Category entities highlighted in Purple
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: TextStyle(
              color: isDark ? Colors.purpleAccent : Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word$suffix'));
      }
    }
    return spans;
  }
}
