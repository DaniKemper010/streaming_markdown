import 'package:markdown/markdown.dart' as md;

/// Base class for custom inline syntax.
abstract class CustomInlineSyntax extends md.InlineSyntax {
  /// Creates a custom inline syntax with the given pattern.
  CustomInlineSyntax(super.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Node node = parseMatch(parser, match);
    parser.addNode(node);
    return true;
  }

  /// Parses the matched content into a markdown element.
  md.Node parseMatch(md.InlineParser parser, Match match);
}
