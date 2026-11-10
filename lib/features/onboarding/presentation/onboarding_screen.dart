import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/jd_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_legal_footer.dart';
import '../../auth/application/auth_flow_notifier.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/presentation/auth_flow_screen.dart';
import 'widgets/onboarding_hero.dart';
import 'widgets/onboarding_social_logos.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';
  static const routeName = 'onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: JdMotion.entrance);
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

  Animation<double> _slot(double start, double end) {
    return CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: JdMotion.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 640;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const Flexible(flex: 12, child: OnboardingHero()),
          Flexible(
            flex: 11,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppColors.pad,
                  12,
                  AppColors.pad,
                  AppColors.pad,
                ),
                child: compact
                    ? _OnboardingScrollContent(ref: ref, enter: _enter, slot: _slot)
                    : _OnboardingExpandedContent(ref: ref, enter: _enter, slot: _slot),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _SlotFn = Animation<double> Function(double start, double end);

class _OnboardingExpandedContent extends StatelessWidget {
  const _OnboardingExpandedContent({
    required this.ref,
    required this.enter,
    required this.slot,
  });

  final WidgetRef ref;
  final AnimationController enter;
  final _SlotFn slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerFadeSlide(
          animation: slot(0.2, 0.55),
          child: Text(
            'Round food for \nevery mood',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _OnboardingActions(ref: ref, slot: slot)),
      ],
    );
  }
}

class _OnboardingScrollContent extends StatelessWidget {
  const _OnboardingScrollContent({
    required this.ref,
    required this.enter,
    required this.slot,
  });

  final WidgetRef ref;
  final AnimationController enter;
  final _SlotFn slot;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StaggerFadeSlide(
            animation: slot(0.2, 0.55),
            child: Text(
              'Round food for \nevery mood',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          _OnboardingActions(ref: ref, slot: slot),
        ],
      ),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({required this.ref, required this.slot});

  final WidgetRef ref;
  final _SlotFn slot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxHeight < 280;
        final gap = tight ? 10.0 : 14.0;
        final children = <Widget>[
          _StaggerFadeSlide(
            animation: slot(0.35, 0.7),
            child: FilledButton(
              onPressed: () {
                ref.read(authFlowProvider.notifier)
                  ..resetFlow()
                  ..setMode(AuthFlowMode.register);
                context.push(AuthFlowScreen.routePath);
              },
              child: const Text("LET'S GET STARTED"),
            ),
          ),
          if (tight) SizedBox(height: gap),
          _StaggerFadeSlide(
            animation: slot(0.45, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(authFlowProvider.notifier)
                      ..resetFlow()
                      ..setMode(AuthFlowMode.login);
                    context.push(AuthFlowScreen.routePath);
                  },
                  child: Text(
                    'Log in',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (tight) SizedBox(height: gap),
          _StaggerFadeSlide(
            animation: slot(0.55, 0.9),
            child: const OnboardingSocialLogos(),
          ),
          if (tight) SizedBox(height: gap),
          _StaggerFadeSlide(
            animation: slot(0.65, 1.0),
            child: const JdLegalFooter(),
          ),
        ];

        if (tight) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}

class _StaggerFadeSlide extends StatelessWidget {
  const _StaggerFadeSlide({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
