import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Base class for custom markdown builders.
abstract class CustomMarkdownBuilder extends MarkdownElementBuilder {
  /// Builds a widget from the markdown element.
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    return buildWidget(element, style);
  }

  /// Builds the widget for the given element.
  Widget? buildWidget(md.Element element, TextStyle? style);
}

/// Base class for inline widget builders.
abstract class InlineBuilder extends CustomMarkdownBuilder {
  @override
  Widget? buildWidget(md.Element element, TextStyle? style) {
    return buildInline(element, style);
  }

  /// Builds an inline widget that can appear within text and list items.
  Widget buildInline(md.Element element, TextStyle? style);
}
