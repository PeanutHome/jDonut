import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pill phone row: country code | divider | input (Base44 field feel).
class JdPhoneField extends StatelessWidget {
  const JdPhoneField({
    super.key,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.onEditingComplete,
    this.onTapOutside,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final VoidCallback? onEditingComplete;
  final void Function(PointerDownEvent)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText != null
        ? Colors.redAccent
        : AppColors.textSecondary.withValues(alpha: 0.22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MOBILE NUMBER',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.surface,
          elevation: 0,
          shape: StadiumBorder(side: BorderSide(color: borderColor)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  '+95',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 28,
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enableInteractiveSelection: true,
                    scrollPadding: AppColors.fieldScrollPadding,
                    onEditingComplete: onEditingComplete,
                    onTapOutside: onTapOutside,
                    style: Theme.of(context).textTheme.titleMedium,
                    decoration: const InputDecoration(
                      hintText: '09254135592',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
      ],
    );
  }
}
