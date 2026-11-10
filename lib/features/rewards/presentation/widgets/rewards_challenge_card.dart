import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_catalog_image.dart';

class RewardsChallengeCard extends StatelessWidget {
  const RewardsChallengeCard({
    super.key,
    required this.title,
    required this.progressLabel,
    required this.points,
    required this.imageAsset,
    this.earnEnabled = false,
    this.buttonLabel = 'EARN',
    this.arcProgress,
    this.pieceCurrent,
    this.pieceTotal,
  });

  final String title;
  final String progressLabel;
  final int points;
  final String imageAsset;
  final bool earnEnabled;
  final String buttonLabel;
  final double? arcProgress;
  final int? pieceCurrent;
  final int? pieceTotal;

  static const _cyan = AppColors.cyan;
  static const _cardBg = AppColors.surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ChallengeThumb(
            asset: imageAsset,
            arcProgress: arcProgress,
            pieceCurrent: pieceCurrent,
            pieceTotal: pieceTotal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  progressLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Material(
                      color: earnEnabled ? _cyan : AppColors.disabled,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: earnEnabled ? () {} : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          child: Text(
                            buttonLabel,
                            style: const TextStyle(
                              color: AppColors.onAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$points pts',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeThumb extends StatelessWidget {
  const _ChallengeThumb({
    required this.asset,
    this.arcProgress,
    this.pieceCurrent,
    this.pieceTotal,
  });

  final String asset;
  final double? arcProgress;
  final int? pieceCurrent;
  final int? pieceTotal;

  @override
  Widget build(BuildContext context) {
    const w = 88.0;
    const arcH = 13.0;
    const imgH = 76.0;
    // Pie overlay sits inside the photo so 1/4 wedges don't dwarf the donut.
    const donutSize = 72.0;
    const chartSize = 58.0;

    return SizedBox(
      width: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (arcProgress != null)
            SizedBox(
              width: w,
              height: arcH,
              child: CustomPaint(
                painter: _TopArcProgressPainter(arcProgress!.clamp(0, 1)),
              ),
            ),
          if (arcProgress != null) const SizedBox(height: 2),
          SizedBox(
            width: w,
            height: imgH,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (pieceTotal != null)
                  ClipOval(
                    child: SizedBox(
                      width: donutSize,
                      height: donutSize,
                      child: JdCatalogImage(
                        asset: asset,
                        preferAsset: true,
                        fit: BoxFit.cover,
                        width: donutSize,
                        height: donutSize,
                      ),
                    ),
                  )
                else
                  JdCatalogImage(
                    asset: asset,
                    preferAsset: true,
                    fit: BoxFit.contain,
                    width: w,
                    height: imgH,
                  ),
                if (pieceTotal != null && pieceCurrent != null)
                  SizedBox(
                    width: chartSize,
                    height: chartSize,
                    child: CustomPaint(
                      painter: _PieceDimPainter(
                        current: pieceCurrent!,
                        total: pieceTotal!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopArcProgressPainter extends CustomPainter {
  _TopArcProgressPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 2, size.width - 12, size.height * 1.6);
    const start = math.pi;
    const sweep = math.pi;

    final track = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, track);

    final fill = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep * value, false, fill);
  }

  @override
  bool shouldRepaint(covariant _TopArcProgressPainter old) => old.value != value;
}

class _PieceDimPainter extends CustomPainter {
  _PieceDimPainter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.5;
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.38);

    for (var i = 0; i < total; i++) {
      if (i < current) continue;
      final a0 = -math.pi / 2 + (2 * math.pi / total) * i;
      final a1 = a0 + 2 * math.pi / total;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: r), a0, a1 - a0, false)
        ..close();
      canvas.drawPath(path, dim);
    }
  }

  @override
  bool shouldRepaint(covariant _PieceDimPainter old) =>
      old.current != current || old.total != total;
}
