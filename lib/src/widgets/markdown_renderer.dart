import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../builders/custom_markdown_builder.dart';
import '../syntax/dynamic_inline_syntax.dart';
import '../models/animation_config.dart';

/// Renders markdown with custom builders and syntaxes.
class MarkdownRenderer extends StatelessWidget {
  /// Markdown text to render.
  final String data;

  /// Custom widget builders.
  final Map<String, CustomMarkdownBuilder>? customBuilders;

  /// Custom regex patterns for builders. Maps builder keys to their regex patterns.
  /// If a builder key has a custom pattern, it will be used instead of the default [[key:content]] pattern.
  final Map<String, String>? customSyntaxPatterns;

  /// Whether text is selectable.
  final bool selectable;

  /// Style sheet for markdown.
  final MarkdownStyleSheet? styleSheet;

  /// Animation configuration for unit-level animations.
  final AnimationConfig? animationConfig;

  /// Creates a [MarkdownRenderer] with the given markdown data.
  const MarkdownRenderer({
    super.key,
    required this.data,
    this.customBuilders,
    this.customSyntaxPatterns,
    this.selectable = true,
    this.styleSheet,
    this.animationConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty data gracefully to prevent parsing errors
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    final Map<String, CustomMarkdownBuilder>? buildersMap = customBuilders;

    final Map<String, MarkdownElementBuilder> builders = {};
    final List<md.InlineSyntax> inlineSyntaxes = [];

    if (buildersMap != null) {
      for (final MapEntry<String, CustomMarkdownBuilder> entry in buildersMap.entries) {
        builders[entry.key] = entry.value;
        // Use custom pattern if provided, otherwise use default [[key:content]] pattern
        final String? customPattern = customSyntaxPatterns?[entry.key];
        inlineSyntaxes.add(DynamicInlineSyntax(entry.key, customPattern: customPattern));
      }
    }

    final md.ExtensionSet extensionSet = md.ExtensionSet(md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
      ...inlineSyntaxes,
    ]);

    // Use a key based on data to force rebuild when data changes
    // This helps prevent stale widgets from causing errors
    return MarkdownBody(
      key: ValueKey<String>(data),
      data: data,
      selectable: selectable,
      styleSheet: styleSheet ?? MarkdownStyleSheet(),
      builders: builders,
      extensionSet: extensionSet,
    );
  }
}
