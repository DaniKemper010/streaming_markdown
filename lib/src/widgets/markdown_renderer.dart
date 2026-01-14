import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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

  /// Syntax highlighter for code blocks.
  final SyntaxHighlighter? syntaxHighlighter;

  /// Callback for handling link taps.
  final MarkdownTapLinkCallback? onTapLink;

  /// Whether the widget should take the minimum height that wraps its content.
  final bool shrinkWrap;

  /// Whether to handle soft line breaks.
  final bool softLineBreak;

  /// Custom extension set for markdown parsing.
  /// If not provided, uses GitHub Flavored Markdown as default.
  final md.ExtensionSet? extensionSet;

  /// Creates a [MarkdownRenderer] with the given markdown data.
  const MarkdownRenderer({
    super.key,
    required this.data,
    this.customBuilders,
    this.customSyntaxPatterns,
    this.selectable = true,
    this.styleSheet,
    this.animationConfig,
    this.syntaxHighlighter,
    this.onTapLink,
    this.shrinkWrap = true,
    this.softLineBreak = false,
    this.extensionSet,
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

    final md.ExtensionSet finalExtensionSet;
    if (extensionSet != null) {
      finalExtensionSet = md.ExtensionSet(extensionSet!.blockSyntaxes, [
        ...extensionSet!.inlineSyntaxes,
        ...inlineSyntaxes,
      ]);
    } else {
      // Put custom inline syntaxes FIRST so they're processed before default syntaxes
      // This prevents conflicts with markdown's link syntax [text](url) when using patterns like [1]
      finalExtensionSet = md.ExtensionSet(md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
        ...inlineSyntaxes,
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
      ]);
    }

    return MarkdownBody(
      key: ValueKey<String>(data),
      data: data,
      selectable: selectable,
      styleSheet: styleSheet ?? MarkdownStyleSheet(),
      builders: builders,
      extensionSet: finalExtensionSet,
      syntaxHighlighter: syntaxHighlighter,
      onTapLink: onTapLink,
      shrinkWrap: shrinkWrap,
      softLineBreak: softLineBreak,
    );
  }
}
