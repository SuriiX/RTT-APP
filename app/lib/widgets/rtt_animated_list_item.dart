import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps a child widget with a staggered fade + slide-up entrance animation.
///
/// Usage inside a `ListView.builder`:
/// ```dart
/// itemBuilder: (context, i) => RttAnimatedListItem(
///   index: i,
///   child: MyCard(...),
/// )
/// ```
class RttAnimatedListItem extends StatefulWidget {
  const RttAnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<RttAnimatedListItem> createState() => _RttAnimatedListItemState();
}

class _RttAnimatedListItemState extends State<RttAnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: 60ms per index, capped at 360ms so deep items don't wait too long.
    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 360));
    _timer = Timer(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
