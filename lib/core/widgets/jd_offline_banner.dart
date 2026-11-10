import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class JdOfflineBanner extends StatelessWidget {
  const JdOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.offlineBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: AppColors.onAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.offlineBanner,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onAccent,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
