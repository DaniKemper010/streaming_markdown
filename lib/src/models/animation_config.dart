import 'animation_mode.dart';

/// Configuration for markdown typing animation.
class AnimationConfig {
  /// Animation mode to use.
  final AnimationMode mode;

  /// Delay between characters in character mode.
  final Duration charDelay;

  /// Delay between words in word mode.
  final Duration wordDelay;

  /// Delay between tokens in token mode.
  final Duration tokenDelay;

  /// Chunk size for custom mode (number of characters/words/tokens per chunk).
  final int chunkSize;

  /// Threshold for performance throttling (text length).
  final int throttleThreshold;

  /// Creates an [AnimationConfig] with the specified parameters.
  const AnimationConfig({
    this.mode = AnimationMode.word,
    this.charDelay = const Duration(milliseconds: 15),
    this.wordDelay = const Duration(milliseconds: 50),
    this.tokenDelay = const Duration(milliseconds: 30),
    this.chunkSize = 1,
    this.throttleThreshold = 1000,
  }) : assert(chunkSize > 0, 'chunkSize must be greater than 0'),
       assert(
         throttleThreshold > 0,
         'throttleThreshold must be greater than 0',
       );

  /// Creates a copy of this config with the given fields replaced.
  AnimationConfig copyWith({
    AnimationMode? mode,
    Duration? charDelay,
    Duration? wordDelay,
    Duration? tokenDelay,
    int? chunkSize,
    int? throttleThreshold,
    bool? animateUnits,
    Duration? unitAnimationDuration,
    double? slideOffset,
  }) {
    return AnimationConfig(
      mode: mode ?? this.mode,
      charDelay: charDelay ?? this.charDelay,
      wordDelay: wordDelay ?? this.wordDelay,
      tokenDelay: tokenDelay ?? this.tokenDelay,
      chunkSize: chunkSize ?? this.chunkSize,
      throttleThreshold: throttleThreshold ?? this.throttleThreshold,
    );
  }

  /// Preset configuration matching ChatGPT's typing style.
  /// Word-based animation with moderate speed and smooth typing.
  static const AnimationConfig chatGPT = AnimationConfig(
    mode: AnimationMode.character,
    wordDelay: Duration(milliseconds: 50),
    charDelay: Duration(milliseconds: 15),
    tokenDelay: Duration(milliseconds: 30),
    chunkSize: 1,
    throttleThreshold: 1000,
  );

  /// Preset configuration matching Claude's typing style.
  /// Similar to ChatGPT but with slightly faster word timing.
  static const AnimationConfig claude = AnimationConfig(
    mode: AnimationMode.word,
    wordDelay: Duration(milliseconds: 45),
    charDelay: Duration(milliseconds: 12),
    tokenDelay: Duration(milliseconds: 28),
    chunkSize: 1,
    throttleThreshold: 1000,
  );

  /// Preset configuration matching Grok's typing style.
  /// Fast token-based animation optimized for quick responses and real-time interactions.
  static const AnimationConfig grok = AnimationConfig(
    mode: AnimationMode.token,
    wordDelay: Duration(milliseconds: 40),
    charDelay: Duration(milliseconds: 10),
    tokenDelay: Duration(milliseconds: 25),
    chunkSize: 1,
    throttleThreshold: 1000,
  );

  /// Preset configuration matching Perplexity's typing style.
  /// Fast word-based animation optimized for quick information delivery.
  static const AnimationConfig perplexity = AnimationConfig(
    mode: AnimationMode.word,
    wordDelay: Duration(milliseconds: 40),
    charDelay: Duration(milliseconds: 12),
    tokenDelay: Duration(milliseconds: 25),
    chunkSize: 1,
    throttleThreshold: 1000,
  );

  /// Preset configuration matching Gemini's typing style.
  /// Moderate word-based animation with slightly slower pacing.
  static const AnimationConfig gemini = AnimationConfig(
    mode: AnimationMode.word,
    wordDelay: Duration(milliseconds: 55),
    charDelay: Duration(milliseconds: 18),
    tokenDelay: Duration(milliseconds: 35),
    chunkSize: 1,
    throttleThreshold: 1000,
  );

  /// Preset configuration matching Copilot's typing style.
  /// Very fast token-based animation optimized for code generation and technical content.
  static const AnimationConfig copilot = AnimationConfig(
    mode: AnimationMode.token,
    wordDelay: Duration(milliseconds: 35),
    charDelay: Duration(milliseconds: 8),
    tokenDelay: Duration(milliseconds: 20),
    chunkSize: 1,
    throttleThreshold: 1000,
  );
}
