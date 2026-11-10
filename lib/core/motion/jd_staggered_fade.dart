import 'package:flutter/material.dart';

import 'jd_motion.dart';

/// Fade + slight rise with a staggered delay. Skips when Reduce Motion is on.
class JdStaggeredFade extends StatefulWidget {
  const JdStaggeredFade({
    super.key,
    required this.index,
    required this.child,
    this.duration = JdMotion.rewardsChallenge,
    this.stagger = JdMotion.stagger,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration stagger;

  @override
  State<JdStaggeredFade> createState() => _JdStaggeredFadeState();
}

class _JdStaggeredFadeState extends State<JdStaggeredFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _c, curve: JdMotion.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: JdMotion.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      return;
    }
    if (_c.isCompleted || _c.isAnimating) return;
    final delay = widget.stagger * widget.index;
    Future<void>.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
