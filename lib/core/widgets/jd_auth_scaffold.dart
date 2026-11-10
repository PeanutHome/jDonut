import 'package:flutter/material.dart';

import '../../features/auth/presentation/widgets/auth_flow_step_ring.dart';
import '../motion/jd_motion.dart';
import '../theme/app_colors.dart';
import 'jd_back_button.dart';
import 'jd_legal_footer.dart';

/// ponytail: one scroll column — fields + Continue scroll together, keyboard can't pin the button over the input.
class JdAuthScaffold extends StatelessWidget {
  const JdAuthScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.subtitle,
    this.showProgress = true,
    this.step,
    this.completed = false,
    this.onBack,
    this.showTitle = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottom;
  final bool showProgress;
  final int? step;
  final bool completed;
  final VoidCallback? onBack;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final padding = MediaQuery.paddingOf(context);
    final viewH = MediaQuery.sizeOf(context).height;
    // ponytail: minHeight ignores keyboard — avoids squashing fields / dropped focus while typing.
    final scrollMinH = viewH - padding.top - padding.bottom - AppColors.pad * 2;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minH = scrollMinH.clamp(constraints.maxHeight * 0.5, constraints.maxHeight);

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: EdgeInsets.fromLTRB(
                AppColors.pad,
                AppColors.pad,
                AppColors.pad,
                AppColors.pad + kb,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            JdBackButton(onPressed: onBack),
                            const Spacer(),
                            if (showProgress && step != null)
                              AuthFlowStepRing(step: step!, completed: completed),
                          ],
                        ),
                        if (showTitle) ...[
                          const SizedBox(height: AppColors.section),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                          const SizedBox(height: AppColors.section),
                        ],
                        body,
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (bottom != null) ...[
                          const SizedBox(height: 32),
                          bottom!,
                        ],
                        const SizedBox(height: 16),
                        const JdLegalFooter(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget jdContinue({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  bool enabled = true,
}) {
  return _JdContinueButton(
    label: label,
    onPressed: onPressed,
    loading: loading,
    enabled: enabled,
  );
}

class _JdContinueButton extends StatefulWidget {
  const _JdContinueButton({
    required this.label,
    required this.onPressed,
    required this.loading,
    required this.enabled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  State<_JdContinueButton> createState() => _JdContinueButtonState();
}

class _JdContinueButtonState extends State<_JdContinueButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && !widget.loading;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (_active) setState(() => _pressed = true);
      },
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && _active ? 0.97 : 1,
        duration: JdMotion.fast,
        curve: JdMotion.easeOut,
        child: FilledButton(
          onPressed: _active ? widget.onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppColors.buttonHeight),
            disabledBackgroundColor:
                AppColors.textSecondary.withValues(alpha: 0.12),
            disabledForegroundColor:
                AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          child: AnimatedSwitcher(
            duration: JdMotion.fast,
            switchInCurve: JdMotion.easeOut,
            switchOutCurve: Curves.easeIn,
            child: widget.loading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.label, key: ValueKey(widget.label)),
          ),
        ),
      ),
    );
  }
}
