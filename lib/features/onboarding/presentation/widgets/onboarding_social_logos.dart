import 'package:flutter/material.dart';

import '../../../auth/presentation/widgets/auth_placeholder.dart';

class OnboardingSocialLogos extends StatelessWidget {
  const OnboardingSocialLogos({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Logo(
          asset: 'assets/images/google.png',
          onTap: () => showAuthPlaceholder(context, 'Google'),
        ),
        _Logo(
          asset: 'assets/images/apple-logo.png',
          onTap: () => showAuthPlaceholder(context, 'Apple'),
        ),
        _Logo(
          asset: 'assets/images/facebook.png',
          onTap: () => showAuthPlaceholder(context, 'Facebook'),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Image.asset(
          asset,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
