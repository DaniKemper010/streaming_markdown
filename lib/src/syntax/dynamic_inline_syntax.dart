import 'package:markdown/markdown.dart' as md;
import 'custom_inline_syntax.dart';

/// Generic inline syntax that automatically handles any key: [[key:content]]
/// This allows users to add custom builders without needing to create syntax classes.
/// Can also accept custom regex patterns for more flexible matching.
class DynamicInlineSyntax extends CustomInlineSyntax {
  /// The key/tag name for this syntax (e.g., 'button', 'chip', 'source').
  final String key;

  /// Optional custom regex pattern. If provided, this pattern will be used instead
  /// of the default [[key:content]] pattern. The pattern should include at least
  /// one capture group to extract the content.
  final String? customPattern;

  /// Creates a [DynamicInlineSyntax] for the given key.
  /// The syntax will match patterns like [[key:content]] by default.
  ///
  /// If [customPattern] is provided, it will be used instead of the default pattern.
  /// The custom pattern should include at least one capture group for content extraction.
  DynamicInlineSyntax(this.key, {this.customPattern})
    : super(customPattern ?? _createPattern(key));

  /// Creates a regex pattern string for the given key.
  static String _createPattern(String key) {
    // Escape special regex characters in the key
    final String escapedKey = RegExp.escape(key);
    return r'\[\[' + escapedKey + r':(.*?)\]\]';
  }

  @override
  md.Node parseMatch(md.InlineParser parser, Match match) {
    // Extract content from the first capture group
    // For default pattern, this is group 1 (the content after the colon)
    // For custom patterns, this should be the first capture group
    final String content = match.groupCount > 0
        ? (match.group(1)?.trim() ?? '')
        : '';
    return md.Element.text(key, content);
  }
}
