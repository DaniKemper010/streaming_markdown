import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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

  /// Whether to animate the markdown text.
  /// When `false`, the markdown is rendered instantly without animation.
  final bool shouldAnimate;

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
    this.shouldAnimate = true,
  }) : assert(
         (markdown != null && stream == null) ||
             (markdown == null && stream != null),
         'Exactly one of markdown or stream must be provided.',
       );

  @override
  State<AnimatedMarkdown> createState() => _AnimatedMarkdownState();
}

class _AnimatedMarkdownState extends State<AnimatedMarkdown> {
  MarkdownTypingController? _controller;
  String _accumulatedText = '';
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.shouldAnimate) {
      _controller = MarkdownTypingController(
        fullText: widget.markdown,
        stream: widget.stream,
        config: widget.config,
      );
      if (widget.autoStart) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller?.start();
        });
      }
    } else {
      if (widget.markdown != null) {
        _accumulatedText = widget.markdown!;
      } else if (widget.stream != null) {
        _accumulatedText = '';
        _streamSubscription = widget.stream!.listen(
          (String chunk) {
            if (mounted) {
              setState(() {
                _accumulatedText += chunk;
              });
            }
          },
          onError: (Object error) {
            // Keep current accumulated text on error
          },
          onDone: () {
            // Stream completed
          },
        );
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate) {
      if (_controller == null ||
          oldWidget.markdown != widget.markdown ||
          oldWidget.stream != widget.stream ||
          oldWidget.config != widget.config ||
          oldWidget.shouldAnimate != widget.shouldAnimate) {
        _streamSubscription?.cancel();
        _streamSubscription = null;
        _controller?.stop();
        _controller?.dispose();
        _controller = MarkdownTypingController(
          fullText: widget.markdown,
          stream: widget.stream,
          config: widget.config,
        );
        if (widget.autoStart) {
          _controller?.start();
        }
      }
    } else {
      _controller?.stop();
      _controller?.dispose();
      _controller = null;
      if (widget.markdown != null) {
        _accumulatedText = widget.markdown!;
        _streamSubscription?.cancel();
        _streamSubscription = null;
      } else if (widget.stream != null) {
        if (oldWidget.stream != widget.stream ||
            oldWidget.shouldAnimate != widget.shouldAnimate) {
          _streamSubscription?.cancel();
          _accumulatedText = '';
          _streamSubscription = widget.stream!.listen(
            (String chunk) {
              if (mounted) {
                setState(() {
                  _accumulatedText += chunk;
                });
              }
            },
            onError: (Object error) {
              // Keep current accumulated text on error
            },
            onDone: () {
              // Stream completed
            },
          );
        }
      } else {
        _accumulatedText = '';
        _streamSubscription?.cancel();
        _streamSubscription = null;
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildMarkdownRenderer(String data) {
    return MarkdownRenderer(
      data: data,
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
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate) {
      return _buildMarkdownRenderer(_accumulatedText);
    }
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _controller!,
      builder: (BuildContext context, Widget? child) {
        return _buildMarkdownRenderer(_controller!.text);
      },
    );
  }

  /// Gets the typing controller for external control.
  /// Returns `null` if `shouldAnimate` is `false`.
  MarkdownTypingController? get controller => _controller;
}
