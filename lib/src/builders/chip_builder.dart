import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'custom_markdown_builder.dart';

/// Builder for inline chip widgets: [[chip:Label]]
class ChipBuilder extends InlineBuilder {
  /// Callback when chip is pressed.
  final void Function(String label)? onPressed;

  /// Chip color.
  final Color? color;

  /// Creates a [ChipBuilder] with optional callback and color.
  ChipBuilder({
    this.onPressed,
    this.color,
  });

  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String label = element.textContent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(label),
        onPressed: onPressed != null ? () => onPressed!(label) : null,
        backgroundColor: color?.withOpacity(0.1),
        side: BorderSide(color: color ?? Colors.grey, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

