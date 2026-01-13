import 'package:markdown/markdown.dart' as md;
import 'custom_inline_syntax.dart';

/// Inline syntax for sources: [[source:Source Name]]
class SourceSyntax extends CustomInlineSyntax {
  SourceSyntax() : super(r'\[\[source:(.*?)\]\]');

  @override
  md.Node parseMatch(md.InlineParser parser, Match match) {
    final String source = match.group(1)?.trim() ?? '';
    return md.Element.text('source', source);
  }
}

