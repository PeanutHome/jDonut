import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/jd_motion.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_flow_notifier.dart';
import '../../auth/application/auth_session_notifier.dart';
import 'widgets/welcome_donut_showcase.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  static const routePath = '/welcome';
  static const routeName = 'welcome';

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
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

  Animation<double> _slot(double a, double b) => CurvedAnimation(
        parent: _enter,
        curve: Interval(a, b, curve: JdMotion.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxHeight < 640;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppColors.pad,
                      tight ? 0 : 8,
                      AppColors.pad,
                      0,
                    ),
                    child: WelcomeDonutShowcase(
                      compactHeights: tight,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppColors.pad,
                    tight ? 0 : 4,
                    AppColors.pad,
                    AppColors.pad + bottomPad,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(
                        opacity: _slot(0.25, 0.65),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_slot(0.25, 0.65)),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Welcome to the world of J'donuts",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    fontSize: tight ? 20 : 22,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: tight ? 12 : 16),
                      FadeTransition(
                        opacity: _slot(0.45, 0.9),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(_slot(0.45, 0.9)),
                          child: FilledButton(
                            onPressed: () => _explore(context, ref),
                            style: FilledButton.styleFrom(
                              minimumSize: Size.fromHeight(tight ? 48 : AppColors.buttonHeight),
                            ),
                            child: const Text("LET'S EXPLORE"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _explore(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authFlowProvider).registeredUser;
    if (user != null) {
      await ref.read(authSessionProvider.notifier).setUser(user);
      ref.read(authFlowProvider.notifier).clearRegisteredUser();
    }
    if (context.mounted) context.go(AppRoutes.home);
  }
}
