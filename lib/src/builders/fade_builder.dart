import 'dart:async';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'custom_markdown_builder.dart';

/// Builder for inline fade widgets: [[fade:text]]
class FadeBuilder extends InlineBuilder {
  /// Duration for fade-in animation.
  final Duration fadeDuration;

  /// Creates a [FadeBuilder] with the specified fade duration.
  FadeBuilder({required this.fadeDuration});

  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String label = element.textContent;
    return _FadeInWidget(
      key: ValueKey<String>(label),
      duration: fadeDuration,
      child: Text(label, style: style),
    );
  }
}

/// Tracks which fade widgets have started their animation.
/// This persists across widget recreations.
final Set<String> _animatedFadeKeys = <String>{};

/// Internal widget that handles fade-in animation from 0 to 1.
class _FadeInWidget extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const _FadeInWidget({super.key, required this.duration, required this.child});

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget> {
  String? _widgetKey;
  double _opacity = 0.0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _widgetKey = (widget.key as ValueKey<String>?)?.value;
    _checkAndStartAnimation();
  }

  @override
  void didUpdateWidget(_FadeInWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndStartAnimation();
  }

  void _checkAndStartAnimation() {
    if (_widgetKey == null) return;
    if (_animatedFadeKeys.contains(_widgetKey!)) {
      if (_opacity < 1.0) {
        setState(() {
          _opacity = 1.0;
        });
      }
      return;
    }
    _animatedFadeKeys.add(_widgetKey!);
    _animationTimer?.cancel();
    _animationTimer = Timer(Duration.zero, () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(opacity: _opacity, duration: widget.duration, child: widget.child);
  }
}
