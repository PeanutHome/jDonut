import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/motion/jd_motion.dart';
import '../../../../core/theme/app_colors.dart';

/// Registration header: “N OF 4” + [percent_indicator] ring (no Hero / custom morph).
class AuthFlowStepRing extends StatelessWidget {
  const AuthFlowStepRing({
    super.key,
    required this.step,
    this.completed = false,
  });

  final int step;
  final bool completed;

  static const totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        );
    final label = completed ? totalSteps : step;
    final percent = (completed ? totalSteps : step.clamp(0, totalSteps)) / totalSteps;

    return Semantics(
      label: 'Step $label of $totalSteps',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label OF $totalSteps', style: labelStyle),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AnimatedSwitcher(
                duration: JdMotion.ringMorph,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    ...previous,
                    ?current,
                  ],
                ),
                child: completed
                    ? _DoneBadge(key: const ValueKey('done'))
                    : CircularPercentIndicator(
                        key: ValueKey('ring-$step'),
                        radius: 18,
                        lineWidth: 3,
                        percent: percent,
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: JdMotion.ringSweep.inMilliseconds,
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: AppColors.pink,
                        backgroundColor: AppColors.textSecondary.withValues(alpha: 0.15),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.pink, width: 3),
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.pink, size: 18),
    );
  }
}
