import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/jd_motion.dart';
import '../../../catalog/domain/catalog_models.dart';

/// Page 10 — tiers stagger in; line fills toward next tier.
class RewardsTierLadder extends StatefulWidget {
  const RewardsTierLadder({super.key, required this.member});

  final CatalogMember? member;

  static const gap = 34.0;
  static const defaultRowH = 46.0;
  static const goldRowH = 72.0;

  static double get contentHeight =>
      defaultRowH + gap + goldRowH + gap + defaultRowH;

  @override
  State<RewardsTierLadder> createState() => _RewardsTierLadderState();
}

class _RewardsTierLadderState extends State<RewardsTierLadder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _lineFill;

  double _rowH(int index) => index == 1 ? RewardsTierLadder.goldRowH : RewardsTierLadder.defaultRowH;

  double _totalHeight(int count) {
    var h = 0.0;
    for (var i = 0; i < count; i++) {
      h += _rowH(i);
      if (i < count - 1) h += RewardsTierLadder.gap;
    }
    return h;
  }

  double _badgeCenterY(int index) {
    var y = 0.0;
    for (var j = 0; j < index; j++) {
      y += _rowH(j) + RewardsTierLadder.gap;
    }
    return y + _rowH(index) / 2;
  }

  int get _activeIndex {
    final tier = (widget.member?.tier ?? 'Silver').toLowerCase();
    if (tier.contains('plat')) return 2;
    if (tier.contains('gold')) return 1;
    return 0; // Silver / Bronze mockups map to first rung
  }

  double get _progressToNext {
    final m = widget.member;
    if (m == null) return 0.35;
    final total = m.totalPoints + m.pointsToNextTier;
    if (total <= 0) return 0;
    return (m.totalPoints / total).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: JdMotion.rewardsRing);
    _lineFill = CurvedAnimation(parent: _c, curve: JdMotion.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isCompleted && !_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = widget.member?.nextTier ?? 'Gold';
    final pts = widget.member?.pointsToNextTier ?? 1290;
    final active = _activeIndex;

    final steps = [
      _TierStep(
        label: 'Silver',
        subtitle: "You're here now.",
        style: _BadgeStyle.silver,
        stars: 1,
        active: active == 0,
      ),
      _TierStep(
        label: 'Gold',
        subtitle: null,
        style: _BadgeStyle.gold,
        stars: 2,
        active: active == 1,
      ),
      _TierStep(
        label: 'Platinum',
        subtitle: "You'll be here soon.",
        style: _BadgeStyle.platinum,
        stars: 3,
        active: active == 2,
      ),
    ];

    final goldSubtitle = '$pts pts Remaining to become $next.';
    final rowHeights = [for (var i = 0; i < steps.length; i++) _rowH(i)];
    final centers = [for (var i = 0; i < steps.length; i++) _badgeCenterY(i)];
    final totalH = _totalHeight(steps.length);

    return SizedBox(
      height: totalH,
      child: AnimatedBuilder(
        animation: _lineFill,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                width: 48,
                top: 0,
                height: totalH,
                child: CustomPaint(
                  painter: _TierLinePainter(
                    centersY: centers,
                    activeIndex: active,
                    fillT: _lineFill.value,
                    progressToNext: _progressToNext,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    SizedBox(
                      height: rowHeights[i],
                      child: _TierRowEntrance(
                        index: i,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 48),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _TierCopy(
                                step: steps[i],
                                subtitleOverride: i == 1 ? goldSubtitle : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      const SizedBox(height: RewardsTierLadder.gap),
                  ],
                ],
              ),
              Column(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    SizedBox(
                      height: rowHeights[i],
                      width: 48,
                      child: Center(
                        child: _TierRowEntrance(
                          index: i,
                          child: _TierBadge(step: steps[i]),
                        ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      const SizedBox(height: RewardsTierLadder.gap),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TierRowEntrance extends StatefulWidget {
  const _TierRowEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TierRowEntrance> createState() => _TierRowEntranceState();
}

class _TierRowEntranceState extends State<_TierRowEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: JdMotion.rewardsTier);
    _fade = CurvedAnimation(parent: _c, curve: JdMotion.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.08, 0),
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
    Future<void>.delayed(JdMotion.stagger * widget.index, () {
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

enum _BadgeStyle { silver, gold, platinum }

class _TierStep {
  const _TierStep({
    required this.label,
    required this.subtitle,
    required this.style,
    required this.stars,
    this.active = false,
  });

  final String label;
  final String? subtitle;
  final _BadgeStyle style;
  final int stars;
  final bool active;
}

class _TierLinePainter extends CustomPainter {
  _TierLinePainter({
    required this.centersY,
    required this.activeIndex,
    required this.fillT,
    required this.progressToNext,
  });

  final List<double> centersY;
  final int activeIndex;
  final double fillT;
  final double progressToNext;

  @override
  void paint(Canvas canvas, Size size) {
    if (centersY.isEmpty) return;
    const x = 23.0;
    final startY = centersY.first;
    final endY = centersY.last;

    final base = Paint()
      ..color = const Color(0xFFD8DEE3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, startY), Offset(x, endY), base);

    final from = centersY[activeIndex.clamp(0, centersY.length - 1)];
    final toIndex = (activeIndex + 1).clamp(0, centersY.length - 1);
    final to = centersY[toIndex];
    final targetY = from + (to - from) * progressToNext;
    final drawY = startY + (targetY - startY) * fillT;

    final progress = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8A50), Color(0xFFF34E9B)],
      ).createShader(Rect.fromLTRB(x, startY, x, drawY))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, startY), Offset(x, drawY), progress);

    final dot = Paint()..color = const Color(0xFFF34E9B);
    canvas.drawCircle(Offset(x, drawY), 4.5, dot);
    canvas.drawCircle(Offset(x, drawY), 2.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TierLinePainter old) =>
      old.activeIndex != activeIndex ||
      old.fillT != fillT ||
      old.progressToNext != progressToNext ||
      old.centersY != centersY;
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.step});

  final _TierStep step;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(42, 46),
      painter: _ShieldPainter(step.style, step.label.substring(0, 1), step.stars),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter(this.style, this.letter, this.starCount);

  final _BadgeStyle style;
  final String letter;
  final int starCount;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.06)
      ..lineTo(size.width * 0.9, size.height * 0.22)
      ..lineTo(size.width * 0.82, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 1.02,
        size.width * 0.18,
        size.height * 0.88,
      )
      ..lineTo(size.width * 0.1, size.height * 0.22)
      ..close();

    final colors = switch (style) {
      _BadgeStyle.silver => [
          const Color(0xFFF8FAFC),
          const Color(0xFFC5CDD6),
          const Color(0xFF909AA8),
        ],
      _BadgeStyle.gold => [
          const Color(0xFFFFF4D6),
          const Color(0xFFEAB94A),
          const Color(0xFFBB7A10),
        ],
      _BadgeStyle.platinum => [
          const Color(0xFFE8FAFF),
          const Color(0xFF5FD4EC),
          const Color(0xFF2A9DB8),
        ],
    };

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, fill);

    canvas.save();
    canvas.clipPath(path);
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.55), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.45), gloss);
    canvas.restore();

    final border = Paint()
      ..color = switch (style) {
        _BadgeStyle.silver => const Color(0xFF7A8490),
        _BadgeStyle.gold => const Color(0xFFB8860B),
        _BadgeStyle.platinum => const Color(0xFF2E9DB8),
      }
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(path, border);

    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 17,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height * 0.3));

    final star = Paint()..color = const Color(0xFFFFB800);
    const spacing = 7.0;
    final offset = (starCount - 1) * spacing / 2;
    for (var i = 0; i < starCount; i++) {
      final x = size.width * 0.5 - offset + i * spacing;
      _drawStar(canvas, Offset(x, size.height * 0.78), 3.5, star);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final ang = -math.pi / 2 + i * 4 * math.pi / 5;
      final pt = Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => false;
}

class _TierCopy extends StatelessWidget {
  const _TierCopy({required this.step, this.subtitleOverride});

  final _TierStep step;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: step.active ? const Color(0xFF29323A) : const Color(0xFF6B7780),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitleOverride ?? step.subtitle ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, height: 1.2, color: Color(0xFF8A939C)),
          ),
        ],
      ),
    );
  }
}
