import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../controllers/markdown_typing_controller.dart';
import '../models/animation_config.dart';
import '../builders/custom_markdown_builder.dart';
import 'markdown_renderer.dart';

/// Animated markdown widget with ChatGPT-style typing animation.
class AnimatedMarkdown extends StatefulWidget {
  /// Markdown text to animate.
  final String? markdown;

  /// Stream of markdown text chunks to animate.
  final Stream<String>? stream;

  /// Animation configuration.
  final AnimationConfig? config;

  /// Custom widget builders.
  final Map<String, CustomMarkdownBuilder>? customBuilders;

  /// Custom regex patterns for builders. Maps builder keys to their regex patterns.
  final Map<String, String>? customSyntaxPatterns;

  /// Whether text is selectable.
  final bool selectable;

  /// Style sheet for markdown.
  final MarkdownStyleSheet? styleSheet;

  /// Custom extension set for markdown parsing.
  /// If not provided, uses GitHub Flavored Markdown as default.
  final md.ExtensionSet? extensionSet;

  /// Syntax highlighter for code blocks.
  final SyntaxHighlighter? syntaxHighlighter;

  /// Callback for handling link taps.
  final MarkdownTapLinkCallback? onTapLink;

  /// Whether the widget should take the minimum height that wraps its content.
  final bool shrinkWrap;

  /// Whether to handle soft line breaks.
  final bool softLineBreak;

  /// Whether to auto-start animation.
  final bool autoStart;

  /// Creates an [AnimatedMarkdown] widget.
  const AnimatedMarkdown({
    super.key,
    this.markdown,
    this.stream,
    this.config,
    this.customBuilders,
    this.customSyntaxPatterns,
    this.selectable = true,
    this.styleSheet,
    this.extensionSet,
    this.syntaxHighlighter,
    this.onTapLink,
    this.shrinkWrap = true,
    this.softLineBreak = false,
    this.autoStart = true,
  }) : assert(
         (markdown != null && stream == null) || (markdown == null && stream != null),
         'Exactly one of markdown or stream must be provided.',
       );

  @override
  State<AnimatedMarkdown> createState() => _AnimatedMarkdownState();
}

class _AnimatedMarkdownState extends State<AnimatedMarkdown> {
  late MarkdownTypingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MarkdownTypingController(fullText: widget.markdown, stream: widget.stream, config: widget.config);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.start();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown ||
        oldWidget.stream != widget.stream ||
        oldWidget.config != widget.config) {
      _controller.stop();
      _controller.dispose();
      _controller = MarkdownTypingController(fullText: widget.markdown, stream: widget.stream, config: widget.config);
      if (widget.autoStart) {
        _controller.start();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return MarkdownRenderer(
          data: _controller.text,
          customBuilders: widget.customBuilders,
          customSyntaxPatterns: widget.customSyntaxPatterns,
          selectable: widget.selectable,
          styleSheet: widget.styleSheet,
          animationConfig: widget.config,
          extensionSet: widget.extensionSet,
          syntaxHighlighter: widget.syntaxHighlighter,
          onTapLink: widget.onTapLink,
          shrinkWrap: widget.shrinkWrap,
          softLineBreak: widget.softLineBreak,
        );
      },
    );
  }

  /// Gets the typing controller for external control.
  MarkdownTypingController get controller => _controller;
}
