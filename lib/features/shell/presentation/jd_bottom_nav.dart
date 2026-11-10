import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Fixed bottom bar — cyan inset bar over a full-width pink band (PDF ~9).
class JdBottomNav extends StatelessWidget {
  const JdBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _barHeight = 58.0;
  static const _horizontalInset = 38.0;

  static double heightFor(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return _barHeight + bottom;
  }

  static const _tabs = [
    _NavTab(label: 'Home', icon: Icons.home_rounded),
    _NavTab(label: 'Reward', crown: true),
    _NavTab(label: 'Donuts', rewardBall: true),
    _NavTab(label: 'Wallet', icon: Icons.account_balance_wallet_rounded),
    _NavTab(label: 'More', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final pinkBehind = _barHeight / 2;

    return Material(
      color: AppColors.pageBg,
      child: SizedBox(
        height: _barHeight + bottomInset,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: pinkBehind + bottomInset,
              child: const ColoredBox(color: AppColors.pink),
            ),
            Positioned(
              left: _horizontalInset,
              right: _horizontalInset,
              bottom: bottomInset,
              height: _barHeight,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _tabs.length,
                      (i) => _NavSlot(
                        tab: _tabs[i],
                        active: currentIndex == i,
                        onTap: () => onSelect(i),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    this.icon,
    this.crown = false,
    this.rewardBall = false,
  });

  final String label;
  final IconData? icon;
  final bool crown;
  final bool rewardBall;
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: active ? 10 : 6,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: active ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tabIcon(Colors.white, 20, active),
              if (active) ...[
                const SizedBox(width: 4),
                Text(
                  tab.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabIcon(Color color, double size, bool active) {
    if (tab.icon != null) {
      return Icon(tab.icon, color: color, size: size);
    }
    if (tab.crown) {
      return _CrownIcon(color: color, size: size);
    }
    if (tab.rewardBall) {
      return _RewardBallIcon(
        color: color,
        size: size,
        holeColor: active ? AppColors.pink : AppColors.cyan,
      );
    }
    return Icon(Icons.circle, color: color, size: size);
  }
}

class _CrownIcon extends StatelessWidget {
  const _CrownIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CrownPainter(color),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.06, h * 0.68, w * 0.88, h * 0.24),
      const Radius.circular(2),
    );
    canvas.drawRRect(band, fill);

    const peaksX = [0.12, 0.3, 0.5, 0.7, 0.88];
    const peaksY = [0.38, 0.22, 0.12, 0.22, 0.38];

    final crown = Path()..moveTo(w * 0.08, h * 0.68);
    for (var i = 0; i < peaksX.length; i++) {
      crown.lineTo(w * peaksX[i], h * peaksY[i]);
    }
    crown
      ..lineTo(w * 0.92, h * 0.68)
      ..close();
    canvas.drawPath(crown, fill);

    for (var i = 0; i < peaksX.length; i++) {
      canvas.drawCircle(Offset(w * peaksX[i], h * peaksY[i]), w * 0.055, fill);
    }

    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.09, stroke);
    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.035, fill);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => oldDelegate.color != color;
}

/// Donut hole + pokeball-style split ring for Rewards.
class _RewardBallIcon extends StatelessWidget {
  const _RewardBallIcon({
    required this.color,
    required this.size,
    required this.holeColor,
  });

  final Color color;
  final double size;
  final Color holeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RewardBallPainter(color, holeColor),
      ),
    );
  }
}

class _RewardBallPainter extends CustomPainter {
  _RewardBallPainter(this.color, this.holeColor);

  final Color color;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 0.5;

    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, radius, ring);

    final fill = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 0.8),
      -3.14159,
      3.14159,
      true,
      fill,
    );

    final hole = Paint()
      ..color = holeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.28, hole);
    canvas.drawCircle(center, radius * 0.28, ring);
  }

  @override
  bool shouldRepaint(covariant _RewardBallPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.holeColor != holeColor;
}
