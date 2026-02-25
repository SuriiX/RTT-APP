import 'package:flutter/material.dart';

/// A widget that scales down slightly when pressed, giving tactile feedback.
///
/// Wraps any child with a press-to-shrink animation (default 0.95).
class RttScaleTap extends StatefulWidget {
  const RttScaleTap({
    super.key,
    required this.onTap,
    required this.child,
    this.scaleDown = 0.95,
  });

  final VoidCallback onTap;
  final Widget child;
  final double scaleDown;

  @override
  State<RttScaleTap> createState() => _RttScaleTapState();
}

class _RttScaleTapState extends State<RttScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
