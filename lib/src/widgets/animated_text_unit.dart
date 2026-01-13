import 'package:flutter/material.dart';
import '../models/animation_config.dart';

/// Widget that animates individual text units (words, characters, or tokens).
class AnimatedTextUnit extends StatefulWidget {
  /// The text content to display.
  final String text;

  /// Animation configuration.
  final AnimationConfig config;

  /// The index of this unit (for staggered animations).
  final int unitIndex;

  /// Text style to apply.
  final TextStyle? style;

  /// Creates an [AnimatedTextUnit] widget.
  const AnimatedTextUnit({super.key, required this.text, required this.config, required this.unitIndex, this.style});

  @override
  State<AnimatedTextUnit> createState() => _AnimatedTextUnitState();
}

class _AnimatedTextUnitState extends State<AnimatedTextUnit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.config.animateUnits) {
      _controller = AnimationController(duration: widget.config.unitAnimationDuration, vsync: this);
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      if (widget.config.slideOffset > 0.0) {
        _slideAnimation = Tween<Offset>(
          begin: Offset(widget.config.slideOffset, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      }
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.config.animateUnits) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.animateUnits) {
      return Text(widget.text, style: widget.style);
    }
    Widget child = Text(widget.text, style: widget.style);
    if (_slideAnimation != null) {
      child = SlideTransition(position: _slideAnimation!, child: child);
    }
    return FadeTransition(opacity: _fadeAnimation, child: child);
  }
}
