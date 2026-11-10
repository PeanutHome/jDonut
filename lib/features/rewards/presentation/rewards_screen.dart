import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/jd_motion.dart';
import '../../../core/motion/jd_staggered_fade.dart';
import '../../../core/theme/app_colors.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../shell/presentation/jd_bottom_nav.dart';
import '../../catalog/domain/catalog_models.dart';
import 'widgets/rewards_challenge_card.dart';
import 'widgets/rewards_points_donut.dart';
import 'widgets/rewards_tier_ladder.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  static const routePath = '/rewards';
  static const routeName = 'rewards';

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _segment = 0;

  static const _cyan = AppColors.cyan;
  static const _orange = AppColors.accentOrange;

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(memberProvider);
    final challenges = ref.watch(challengesProvider);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        left: true,
        top: true,
        right: false,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 8, 0, JdBottomNav.heightFor(context) + 16),
          children: [
            _rewardsBody(member, challenges),
          ],
        ),
      ),
    );
  }

  Widget _rewardsBody(CatalogMember? member, List<CatalogChallenge> challenges) {
    final total = member?.totalPoints ?? 4710;
    final ptsNext = member?.pointsToNextTier ?? 1290;
    final progress = member == null
        ? 0.68
        : (1 - (ptsNext / (ptsNext + total))).clamp(0.15, 0.88).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "J' Donuts Rewards",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF29323A)),
                  ),
                ),
                const _RewardsBadgePop(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final diameter = (w * 0.62).clamp(176.0, 236.0);
              final overhang = (diameter * 0.22).clamp(28.0, 48.0);
              final ladderRight = diameter - overhang + 16;
              final ladderNeed = RewardsTierLadder.contentHeight + 18 + 64;
              final heroH = math.max(ladderNeed, diameter + 40).clamp(360.0, 420.0);

              return SizedBox(
                height: heroH,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 18, ladderRight, 56),
                      child: RewardsTierLadder(member: member),
                    ),
                    Positioned(
                      right: -overhang,
                      top: 8,
                      child: RewardsPointsDonut(
                        totalPoints: total,
                        progress: progress,
                        diameter: diameter,
                        displayPoints: JdMotion.rewardsPointsCountTarget,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 4,
                      child: _segmentControl(),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEDF0F2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            child: AnimatedSwitcher(
              duration: JdMotion.reduced(context, JdMotion.fast),
              child: _segment == 0
                  ? Column(
                      key: const ValueKey('eat'),
                      children: _eatMoreChallenges(challenges),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('gift'),
                      child: _giftPlaceholder(),
                    ),
            ),
          ),
        ],
    );
  }

  Widget _segmentControl() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        final pillW = trackW * 0.58;

        return SizedBox(
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E8EB),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              AnimatedPositioned(
                duration: JdMotion.reduced(context, JdMotion.fast),
                curve: JdMotion.easeInOut,
                left: _segment == 0 ? 2 : null,
                right: _segment == 1 ? 2 : null,
                width: pillW,
                top: 2,
                bottom: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _cyan,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _segmentTap(
                      label: 'Eat more earn more',
                      selected: _segment == 0,
                      onTap: () => setState(() => _segment = 0),
                    ),
                  ),
                  Expanded(
                    child: _segmentTap(
                      label: 'Gift',
                      selected: _segment == 1,
                      onTap: () => setState(() => _segment = 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _segmentTap({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: selected ? Colors.white : const Color(0xFF6B7780),
                ),
              ),
            ),
        ),
      ),
    );
  }

  List<Widget> _eatMoreChallenges(List<CatalogChallenge> challenges) {
    if (challenges.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No challenges yet',
              style: TextStyle(color: Color(0xFF8A939C), fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ];
    }
    return [
      for (var i = 0; i < challenges.length; i++)
        JdStaggeredFade(
          index: i,
          child: RewardsChallengeCard(
            title: challenges[i].title,
            progressLabel: challenges[i].progressLabel,
            points: challenges[i].points,
            imageAsset: challenges[i].imageAsset,
            earnEnabled: challenges[i].isComplete,
            buttonLabel: challenges[i].buttonLabel,
            pieceCurrent:
                challenges[i].kind == 'pieces' ? challenges[i].current : null,
            pieceTotal:
                challenges[i].kind == 'pieces' ? challenges[i].total : null,
            arcProgress: challenges[i].kind == 'arc'
                ? challenges[i].progressFraction
                : null,
          ),
        ),
    ];
  }


  Widget _giftPlaceholder() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Gift rewards coming soon',
          style: TextStyle(color: Color(0xFF8A939C), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _RewardsBadgePop extends StatefulWidget {
  const _RewardsBadgePop();

  @override
  State<_RewardsBadgePop> createState() => _RewardsBadgePopState();
}

class _RewardsBadgePopState extends State<_RewardsBadgePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: JdMotion.rewardsBadgePop);
    _scale = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _c, curve: JdMotion.emphasize),
    );
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
    return ScaleTransition(
      scale: _scale,
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 8, top: 6, bottom: 6),
        decoration: const BoxDecoration(
          color: _RewardsScreenState._orange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rewards',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  color: _RewardsScreenState._orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
