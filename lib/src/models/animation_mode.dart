/// Animation modes for markdown typing animation.
enum AnimationMode {
  /// Character-by-character animation (smooth, slower).
  character,

  /// Word-by-word animation (faster, more natural).
  word,

  /// Token-based animation (optimal for LLM streaming).
  token,

  /// Custom chunk-based animation (configurable batch size).
  custom,
}
