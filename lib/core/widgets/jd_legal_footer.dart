import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/widgets/auth_placeholder.dart';
import '../theme/app_colors.dart';

class JdLegalFooter extends StatelessWidget {
  const JdLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        );
  final link = base?.copyWith(
      color: AppColors.pink,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            const TextSpan(
              text:
                  'By continuing, you acknowledge that you have read and agree to our ',
            ),
            TextSpan(
              text: 'Terms of Use',
              style: link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => showAuthPlaceholder(context, 'Terms of Use'),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => showAuthPlaceholder(context, 'Privacy Policy'),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
