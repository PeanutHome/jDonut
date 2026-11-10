import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/widgets/jd_auth_scaffold.dart';
import '../../../../core/widgets/jd_phone_field.dart';
import '../../application/auth_flow_notifier.dart';
import '../../application/auth_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/phone_validator.dart';

class AuthPhoneStep extends ConsumerStatefulWidget {
  const AuthPhoneStep({super.key, required this.onAdvanced});

  final VoidCallback onAdvanced;

  @override
  ConsumerState<AuthPhoneStep> createState() => _AuthPhoneStepState();
}

class _AuthPhoneStepState extends ConsumerState<AuthPhoneStep> {
  late final TextEditingController _controller;
  late final FocusNode _phoneFocus;
  String? _blurError;
  String? _loginNotRegisteredError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(authFlowProvider).phoneLocal,
    );
    _phoneFocus = FocusNode();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _phoneFocus.requestFocus();
    });
  }

  void _onChanged() {
    ref.read(authFlowProvider.notifier).setPhoneLocal(_controller.text);
    setState(() => _loginNotRegisteredError = null);
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => validatePhoneLocalPart(_controller.text).isValid;

  Future<void> _continue() async {
    if (_loading || !_isValid) return;
    final validation = validatePhoneLocalPart(_controller.text);
    final e164 = validation.e164!;
    setState(() => _loading = true);
    try {
      final flow = ref.read(authFlowProvider);
      if (flow.mode == AuthFlowMode.login) {
        final registered = await ref.read(checkPhoneRegisteredProvider)(e164);
        final ok = registered.when(ok: (v) => v, err: (_) => false);
        if (!ok) {
          setState(
            () => _loginNotRegisteredError = 'This number is not registered yet.',
          );
          return;
        }
      }
      ref.read(authFlowProvider.notifier).setPhoneE164(e164);
      final sent = await ref.read(sendOtpProvider)(e164);
      if (sent case Err(:final failure)) {
        setState(() => _blurError = failure.message);
        return;
      }
      if (mounted) widget.onAdvanced();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JdPhoneField(
          controller: _controller,
          focusNode: _phoneFocus,
          errorText: _blurError,
          onEditingComplete: () => _setBlurError(),
          onTapOutside: (_) {
            _setBlurError();
            FocusScope.of(context).unfocus();
          },
        ),
        if (_loginNotRegisteredError != null) ...[
          const SizedBox(height: 12),
          Text(
            _loginNotRegisteredError!,
            style: const TextStyle(color: Colors.redAccent),
          ),
          TextButton(
            onPressed: () {
              ref.read(authFlowProvider.notifier).switchToRegisterKeepingPhone();
              setState(() => _loginNotRegisteredError = null);
            },
            child: const Text('Register with this number'),
          ),
        ],
        const SizedBox(height: 32),
        jdContinue(
          label: 'Continue',
          enabled: _isValid,
          loading: _loading,
          onPressed: _continue,
        ),
      ],
    );
  }

  void _setBlurError() {
    final v = validatePhoneLocalPart(_controller.text);
    setState(() {
      _blurError = _controller.text.isEmpty ? null : (v.isValid ? null : v.error);
    });
  }
}
