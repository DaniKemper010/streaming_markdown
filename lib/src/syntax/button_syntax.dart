import 'package:markdown/markdown.dart' as md;
import 'custom_inline_syntax.dart';

/// Inline syntax for buttons: [[button:Label]]
class ButtonSyntax extends CustomInlineSyntax {
  ButtonSyntax() : super(r'\[\[button:(.*?)\]\]');

  @override
  md.Node parseMatch(md.InlineParser parser, Match match) {
    final String label = match.group(1)?.trim() ?? '';
    return md.Element.text('button', label);
  }
}
