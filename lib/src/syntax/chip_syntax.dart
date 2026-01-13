import 'package:markdown/markdown.dart' as md;
import 'custom_inline_syntax.dart';

/// Inline syntax for chips: [[chip:Label]]
class ChipSyntax extends CustomInlineSyntax {
  ChipSyntax() : super(r'\[\[chip:(.*?)\]\]');

  @override
  md.Node parseMatch(md.InlineParser parser, Match match) {
    final String label = match.group(1)?.trim() ?? '';
    return md.Element.text('chip', label);
  }
}

