import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_auth_scaffold.dart';
import '../../application/auth_flow_notifier.dart';
import '../../application/auth_providers.dart';
import '../../application/auth_session_notifier.dart';
import '../../domain/auth_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/otp_validator.dart';
import '../widgets/otp_input_row.dart';

class AuthOtpStep extends ConsumerStatefulWidget {
  const AuthOtpStep({
    super.key,
    required this.onRegisterVerified,
  });

  final VoidCallback onRegisterVerified;

  @override
  ConsumerState<AuthOtpStep> createState() => _AuthOtpStepState();
}

class _AuthOtpStepState extends ConsumerState<AuthOtpStep> {
  String _otp = '';
  String? _otpError;
  int _shakeKey = 0;
  bool _loading = false;
  Timer? _timer;
  int _resendSeconds = AuthConstants.resendSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = AuthConstants.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatResend(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    final phone = ref.read(authFlowProvider).phoneE164;
    if (phone == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(sendOtpProvider)(phone);
      ref.read(authFlowProvider.notifier).resetOtpAttempts();
      setState(() {
        _otpError = null;
        _shakeKey++;
      });
      _startTimer();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (_loading) return;
    final flow = ref.read(authFlowProvider);
    if (flow.otpLocked) return;

    final format = validateOtpCode(_otp);
    if (!format.isValid) {
      setState(() => _otpError = format.error);
      return;
    }

    if (!isFakeOtpCorrect(_otp)) {
      ref.read(authFlowProvider.notifier).registerWrongOtp();
      final locked = ref.read(authFlowProvider).otpLocked;
      setState(() {
        _otpError = locked
            ? 'Too many wrong codes. Tap Resend to try again.'
            : 'Incorrect code. Try again.';
        _shakeKey++;
        _otp = '';
      });
      return;
    }

    final phone = flow.phoneE164;
    if (phone == null) return;

    setState(() => _loading = true);
    try {
      if (flow.mode == AuthFlowMode.login) {
        final result = await ref.read(loginWithOtpProvider)(
          phoneE164: phone,
          otp: _otp,
        );
        switch (result) {
          case Ok(:final value):
            await ref.read(authSessionProvider.notifier).setUser(value);
            if (mounted) context.go(AppRoutes.home);
          case Err(:final failure):
            setState(() => _otpError = failure.message);
        }
      } else {
        await ref.read(sendOtpProvider)(phone);
        if (mounted) widget.onRegisterVerified();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(authFlowProvider);
    final locked = flow.otpLocked;
    final phone = flow.phoneE164 ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "We've sent 6 digit OTP to $phone",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        OtpInputRow(
          key: ValueKey(_shakeKey),
          enabled: !locked,
          shakeKey: _shakeKey,
          forceError: _otpError != null,
          onChanged: (v) => setState(() {
            _otp = v;
            _otpError = null;
          }),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 12),
          Text(_otpError!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 16),
        if (_resendSeconds > 0)
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: "Didn't receive the code? resend in "),
                TextSpan(
                  text: '${_formatResend(_resendSeconds)} min',
                  style: const TextStyle(
                    color: AppColors.pink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          TextButton(
            onPressed: _loading ? null : _resend,
            child: const Text('Resend'),
          ),
        const SizedBox(height: 32),
        jdContinue(
          label: 'Continue',
          enabled: _otp.length == 6 && !locked,
          loading: _loading,
          onPressed: _verify,
        ),
      ],
    );
  }
}
