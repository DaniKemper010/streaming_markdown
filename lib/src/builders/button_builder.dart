import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'custom_markdown_builder.dart';

/// Builder for inline button widgets: [[button:Label]]
class ButtonBuilder extends InlineBuilder {
  /// Callback when button is pressed.
  final void Function(String label)? onPressed;

  /// Button style.
  final ButtonStyle? style;

  /// Creates a [ButtonBuilder] with optional callback and style.
  ButtonBuilder({this.onPressed, this.style});

  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String label = element.textContent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onPressed != null ? () => onPressed!(label) : null,
        style:
            this.style ??
            TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        child: Text(label),
      ),
    );
  }
}
