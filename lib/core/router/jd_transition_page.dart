import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../motion/jd_motion.dart';

/// Auth routes: single fade + slide (no Hero coupling).
CustomTransitionPage<void> jdAuthTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: JdMotion.page,
    reverseTransitionDuration: JdMotion.pageReverse,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: JdMotion.easeInOut);

      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
