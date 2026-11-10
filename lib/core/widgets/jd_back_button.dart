import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Outlined circle back control (Base44 auth header).
class JdBackButton extends StatelessWidget {
  const JdBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: AppColors.surface,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.25)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back_ios_new, size: 16),
        ),
      ),
    );
  }
}
