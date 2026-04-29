import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double borderRadius;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderRadius = 20,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? AppTheme.cardBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double borderRadius;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    this.borderRadius = 20,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: widget.padding,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}
