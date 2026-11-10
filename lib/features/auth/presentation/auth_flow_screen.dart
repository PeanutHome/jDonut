import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/jd_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_auth_scaffold.dart';
import '../application/auth_flow_notifier.dart';
import '../domain/auth_flow_step.dart';
import '../domain/repositories/auth_repository.dart';
import 'steps/auth_birthday_step.dart';
import 'steps/auth_name_step.dart';
import 'steps/auth_otp_step.dart';
import 'steps/auth_phone_step.dart';

/// One route, in-place step changes (Duolingo-style) — shell + progress ring stay put.
class AuthFlowScreen extends ConsumerStatefulWidget {
  const AuthFlowScreen({super.key});

  static const routePath = '/auth';
  static const routeName = 'auth';

  @override
  ConsumerState<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen> {
  bool _ringComplete = false;
  bool _forward = true;

  void _onBack() {
    final step = ref.read(authFlowProvider).step;
    if (step == AuthFlowStep.phone) {
      context.pop();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _forward = false);
    ref.read(authFlowProvider.notifier).back();
  }

  void _advance(AuthFlowStep next) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _forward = true;
      _ringComplete = false;
    });
    ref.read(authFlowProvider.notifier).goTo(next);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(authFlowProvider);
    final step = flow.step;
    final isRegister = flow.mode == AuthFlowMode.register;
    final copy = _copyFor(step);
    final progressStep = isRegister ? step.progressIndex : null;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.15,
        );

    return PopScope(
      canPop: step == AuthFlowStep.phone,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: JdAuthScaffold(
        title: copy.title,
        showTitle: false,
        showProgress: isRegister,
        step: progressStep,
        completed: _ringComplete && step == AuthFlowStep.birthday,
        onBack: _onBack,
        body: AnimatedSwitcher(
          duration: JdMotion.authStep,
          switchInCurve: JdMotion.easeOut,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            children: [
              ...previous,
              ?current,
            ],
          ),
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(parent: animation, curve: JdMotion.easeInOut);
            final offset = Tween<Offset>(
              begin: Offset(_forward ? 0.12 : -0.12, 0),
              end: Offset.zero,
            ).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: Column(
            key: ValueKey(step),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppColors.section),
              Text(copy.title, style: titleStyle),
              if (copy.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  copy.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
              ],
              const SizedBox(height: AppColors.section),
              _stepBody(step),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody(AuthFlowStep step) {
    switch (step) {
      case AuthFlowStep.phone:
        return AuthPhoneStep(
          onAdvanced: () => _advance(AuthFlowStep.verify),
        );
      case AuthFlowStep.verify:
        return AuthOtpStep(
          onRegisterVerified: () => _advance(AuthFlowStep.name),
        );
      case AuthFlowStep.name:
        return AuthNameStep(
          onAdvanced: () => _advance(AuthFlowStep.birthday),
        );
      case AuthFlowStep.birthday:
        return AuthBirthdayStep(
          onRingComplete: (v) => setState(() => _ringComplete = v),
        );
    }
  }

  _StepCopy _copyFor(AuthFlowStep step) => switch (step) {
        AuthFlowStep.phone => const _StepCopy(
            title: 'Enter your phone number',
            subtitle:
                "We'll text a 6-digit code to confirm it's really you — no password to remember.",
          ),
        AuthFlowStep.verify => const _StepCopy(
            title: 'Verify your number',
          ),
        AuthFlowStep.name => const _StepCopy(
            title: "What's your name?",
          ),
        AuthFlowStep.birthday => const _StepCopy(
            title: "What's your date of birth?",
          ),
      };
}

class _StepCopy {
  const _StepCopy({required this.title, this.subtitle});
  final String title;
  final String? subtitle;
}
