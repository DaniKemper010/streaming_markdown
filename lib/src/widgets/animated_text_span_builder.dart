import 'package:flutter/material.dart';
import '../models/animation_config.dart';
import '../models/animation_mode.dart';
import '../utils/string_utils.dart';
import 'animated_text_unit.dart';

/// Helper class to build animated text spans.
class AnimatedTextSpanBuilder {
  /// Animation configuration.
  final AnimationConfig config;

  /// Current unit index for staggered animations.
  int _unitIndex = 0;

  /// Creates an [AnimatedTextSpanBuilder].
  AnimatedTextSpanBuilder({required this.config});

  /// Resets the unit index counter.
  void reset() {
    _unitIndex = 0;
  }

  /// Builds an animated text span from the given text.
  InlineSpan buildAnimatedSpan(String text, {TextStyle? style}) {
    if (!config.animateUnits || text.isEmpty) {
      final String safeText = StringUtils.sanitizeUtf16(text);
      return TextSpan(text: safeText, style: style);
    }
    final List<InlineSpan> spans = [];
    final List<String> units = _splitIntoUnits(text);
    for (final String unit in units) {
      if (unit.isEmpty) continue;
      final String safeUnit = StringUtils.sanitizeUtf16(unit);
      if (safeUnit.isEmpty) continue;
      final int currentIndex = _unitIndex++;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: AnimatedTextUnit(text: safeUnit, config: config, unitIndex: currentIndex, style: style),
        ),
      );
    }
    if (spans.length == 1) {
      return spans.first;
    }
    return TextSpan(children: spans);
  }

  List<String> _splitIntoUnits(String text) {
    switch (config.mode) {
      case AnimationMode.character:
        return StringUtils.splitByCodePoints(text);
      case AnimationMode.word:
        final List<String> words = text.split(RegExp(r'(\s+)'));
        return words
            .map((String word) => StringUtils.sanitizeUtf16(word))
            .where((String word) => word.isNotEmpty)
            .toList();
      case AnimationMode.token:
        final List<String> tokens = text.split(RegExp(r'(\s+|[.,!?;:])'));
        return tokens
            .map((String token) => StringUtils.sanitizeUtf16(token))
            .where((String token) => token.isNotEmpty)
            .toList();
      case AnimationMode.custom:
        final List<String> chunks = [];
        for (int i = 0; i < text.length; i += config.chunkSize) {
          final int end = (i + config.chunkSize).clamp(0, text.length);
          final String chunk = StringUtils.safeSubstring(text, i, end);
          if (chunk.isNotEmpty) {
            chunks.add(chunk);
          }
        }
        return chunks;
    }
  }
}
