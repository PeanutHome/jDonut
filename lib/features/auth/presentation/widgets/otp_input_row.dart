import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.shakeKey,
    this.forceError = false,
  });

  final bool enabled;
  final ValueChanged<String> onChanged;
  final int shakeKey;
  final bool forceError;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant OtpInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shakeKey != widget.shakeKey) {
      _controller.clear();
      widget.onChanged('');
      _focusNode.requestFocus();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final boxW = ((w - AppColors.pad * 2 - 40 - 40) / 6).clamp(40.0, 52.0);
    final gap = boxW < 44 ? 6.0 : 8.0;

    PinTheme theme(Color? border) => PinTheme(
          width: boxW,
          height: boxW * 1.15,
          textStyle: TextStyle(
            fontSize: boxW * 0.46,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: border == null ? null : Border.all(color: border, width: 1.5),
          ),
        );

    final base = theme(null);
    final focused = theme(AppColors.cyan);
    final error = theme(Colors.redAccent);

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx = _shake.value < 0.5 ? -1.0 : 1.0;
        final nudge = 18 * _shake.value * dx * (_shake.value % 0.25);
        return Transform.translate(offset: Offset(nudge, 0), child: child);
      },
      child: Pinput(
        length: 6,
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        autofocus: true,
        forceErrorState: widget.forceError,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofillHints: const [AutofillHints.oneTimeCode],
        defaultPinTheme: base,
        focusedPinTheme: focused,
        submittedPinTheme: focused,
        errorPinTheme: error,
        separatorBuilder: (_) => SizedBox(width: gap),
        onChanged: widget.onChanged,
      ),
    );
  }
}
