import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'custom_markdown_builder.dart';

/// Builder for math/LaTeX widgets: [[math:Formula]]
/// Note: This is a placeholder. For actual math rendering, integrate a math package.
class MathBuilder extends InlineBuilder {
  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String formula = element.textContent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          formula,
          style: style?.copyWith(
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

