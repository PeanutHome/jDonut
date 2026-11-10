import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/motion/jd_motion.dart';

/// Page 10 — ring sweeps 0→progress; center counts up to [displayPoints].
class RewardsPointsDonut extends StatefulWidget {
  const RewardsPointsDonut({
    super.key,
    required this.totalPoints,
    required this.progress,
    this.diameter = 220,
    this.displayPoints = JdMotion.rewardsPointsCountTarget,
  });

  final int totalPoints;
  final double progress;
  final double diameter;
  final int displayPoints;

  static const _pink = Color(0xFFF34E9B);

  @override
  State<RewardsPointsDonut> createState() => _RewardsPointsDonutState();
}

class _RewardsPointsDonutState extends State<RewardsPointsDonut>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _enter;
  late final Animation<double> _progressAnim;
  late final Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    );
    _enter = AnimationController(vsync: this, duration: JdMotion.rewardsRing);
    _progressAnim = Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _enter, curve: JdMotion.easeOut));
    _countAnim = Tween<double>(begin: 0, end: widget.displayPoints.toDouble())
        .animate(CurvedAnimation(parent: _enter, curve: JdMotion.easeOut));
  }

  @override
  void didUpdateWidget(covariant RewardsPointsDonut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.displayPoints != widget.displayPoints) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _enter, curve: JdMotion.easeOut));
      _countAnim = Tween<double>(
        begin: _countAnim.value,
        end: widget.displayPoints.toDouble(),
      ).animate(CurvedAnimation(parent: _enter, curve: JdMotion.easeOut));
      _enter.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _spin.stop();
      _spin.value = 0;
      _enter.value = 1;
    } else {
      if (!_spin.isAnimating) _spin.repeat();
      if (!_enter.isCompleted && !_enter.isAnimating) _enter.forward();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final hole = d * 0.42;

    return SizedBox(
      width: d,
      height: d,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _enter]),
        builder: (context, _) {
          final progress = _progressAnim.value.clamp(0.0, 1.0);
          final painted = progress.clamp(0.12, 0.78);
          final count = _countAnim.value.round();
          final formatted = NumberFormat('#,###').format(count);

          return Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _spin,
                child: CustomPaint(
                  size: Size.square(d),
                  painter: _RealisticDonutPainter(painted),
                ),
              ),
              Container(
                width: hole,
                height: hole,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: hole * 0.88,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total points',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: RewardsPointsDonut._pink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatted,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: RewardsPointsDonut._pink,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RealisticDonutPainter extends CustomPainter {
  _RealisticDonutPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.46;
    final inner = outer * 0.48;
    final band = outer - inner;
    final midR = (outer + inner) / 2;

    canvas.drawCircle(
      center + const Offset(2, 5),
      outer + 3,
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    final under = Paint()
      ..color = const Color(0xFFD9BF98)
      ..style = PaintingStyle.stroke
      ..strokeWidth = band + 1;
    canvas.drawCircle(center, midR, under);

    final dough = Paint()
      ..shader = ui.Gradient.radial(
        center,
        outer,
        [const Color(0xFFF3E2C8), const Color(0xFFE2C49A), const Color(0xFFD4AE7A)],
        [0.35, 0.75, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = band;

    canvas.drawCircle(center, midR, dough);

    const start = -math.pi / 2;
    final sweep = math.pi * 2 * progress;

    final glaze = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [
          const Color(0xFFFF8FD0),
          const Color(0xFFF34E9B),
          const Color(0xFFE62882),
          const Color(0xFFFF9FD4),
        ],
        [0.0, 0.32, 0.68, 1.0],
        TileMode.clamp,
        start,
        start + math.pi * 2,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = band
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: midR), start, sweep, false, glaze);

    final glazeShine = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [Colors.white.withValues(alpha: 0.65), Colors.transparent, Colors.transparent],
        [0.0, 0.2, 1.0],
        TileMode.clamp,
        start,
        start + sweep,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = band * 0.42;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midR - band * 0.22),
      start,
      sweep * 0.55,
      false,
      glazeShine,
    );

    final unglazed = Paint()
      ..color = const Color(0xFFE8D4B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = band - 1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midR),
      start + sweep,
      math.pi * 2 - sweep,
      false,
      unglazed,
    );

    final shine = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - outer, center.dy - outer),
        Offset(center.dx + outer * 0.2, center.dy),
        [Colors.white.withValues(alpha: 0.55), Colors.transparent],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = band * 0.35;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midR),
      start + 0.2,
      sweep * 0.35,
      false,
      shine,
    );

    final rng = math.Random(12);
    for (var i = 0; i < 34; i++) {
      final t = start + sweep * rng.nextDouble();
      final r = midR + (rng.nextDouble() - 0.5) * (band * 0.35);
      final sprinkle = Paint()
        ..color = [
          const Color(0xFFFFE566),
          const Color(0xFF6EE7A8),
          const Color(0xFFFF9ECD),
          const Color(0xFF7EC8FF),
          Colors.white,
        ][i % 5];
      final len = 2.0 + rng.nextDouble() * 2.5;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + r * math.cos(t), center.dy + r * math.sin(t)),
          width: len,
          height: 1.2,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, sprinkle);
    }

    final crust = Paint()
      ..color = const Color(0xFFB8895A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, outer, crust);
  }

  @override
  bool shouldRepaint(covariant _RealisticDonutPainter old) => old.progress != progress;
}
