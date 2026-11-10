import 'package:flutter/material.dart';

import '../../../../core/motion/jd_motion.dart';
import '../../../../core/theme/app_colors.dart';

/// Full hero image entrance — scale + fade + soft drift (no overlay cutouts).
class OnboardingHero extends StatefulWidget {
  const OnboardingHero({super.key});

  @override
  State<OnboardingHero> createState() => _OnboardingHeroState();
}

class _OnboardingHeroState extends State<OnboardingHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _drift;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: JdMotion.entrance);
    _fade = CurvedAnimation(parent: _enter, curve: const Interval(0, 0.55, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _enter, curve: JdMotion.easeOut),
    );
    _drift = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: JdMotion.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
    } else if (!_enter.isAnimating && _enter.value == 0) {
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheW =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round();

    return RepaintBoundary(
      child: ColoredBox(
        color: AppColors.background,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _drift,
            child: ScaleTransition(
              scale: _scale,
              alignment: Alignment.topCenter,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.52, 0.78, 1.0],
                    colors: [
                      Colors.white,
                      Colors.white,
                      Color(0x00000000),
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/onboarding_screen1.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  height: double.infinity,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: cacheW,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
