import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_auth_scaffold.dart';
import '../../application/auth_flow_notifier.dart';
import '../../domain/validators/name_validator.dart';

class AuthNameStep extends ConsumerStatefulWidget {
  const AuthNameStep({super.key, required this.onAdvanced});

  final VoidCallback onAdvanced;

  @override
  ConsumerState<AuthNameStep> createState() => _AuthNameStepState();
}

class _AuthNameStepState extends ConsumerState<AuthNameStep> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final FocusNode _firstFocus;
  late final FocusNode _lastFocus;
  String? _firstError;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    final flow = ref.read(authFlowProvider);
    _first = TextEditingController(text: flow.firstName);
    _last = TextEditingController(text: flow.lastName);
    _firstFocus = FocusNode()..addListener(_onFirstFocus);
    _lastFocus = FocusNode()..addListener(_onLastFocus);
    _first.addListener(() => ref.read(authFlowProvider.notifier).setFirstName(_first.text));
    _last.addListener(() => ref.read(authFlowProvider.notifier).setLastName(_last.text));
  }

  @override
  void dispose() {
    _firstFocus
      ..removeListener(_onFirstFocus)
      ..dispose();
    _lastFocus
      ..removeListener(_onLastFocus)
      ..dispose();
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _onFirstFocus() {
    if (!_firstFocus.hasFocus) _validateFirst();
  }

  void _onLastFocus() {
    if (!_lastFocus.hasFocus) _validateLast();
  }

  void _validateFirst() {
    final v = validateFirstName(_first.text);
    setState(() => _firstError = v.isValid ? null : v.error);
  }

  void _validateLast() {
    final v = validateLastName(_last.text);
    setState(() => _lastError = v.isValid ? null : v.error);
  }

  bool get _canContinue =>
      validateFirstName(_first.text).isValid && validateLastName(_last.text).isValid;

  void _continue() {
    _validateFirst();
    _validateLast();
    if (_canContinue) widget.onAdvanced();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _first,
          focusNode: _firstFocus,
          textInputAction: TextInputAction.next,
          scrollPadding: AppColors.fieldScrollPadding,
          decoration: InputDecoration(
            hintText: 'First Name',
            errorText: _firstError,
          ),
          onChanged: (_) => setState(() => _firstError = null),
          onEditingComplete: () {
            _validateFirst();
            _lastFocus.requestFocus();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _last,
          focusNode: _lastFocus,
          textInputAction: TextInputAction.done,
          scrollPadding: AppColors.fieldScrollPadding,
          decoration: InputDecoration(
            hintText: 'Last Name',
            errorText: _lastError,
          ),
          onChanged: (_) => setState(() => _lastError = null),
          onEditingComplete: () {
            _validateLast();
            FocusScope.of(context).unfocus();
          },
        ),
        const SizedBox(height: 32),
        jdContinue(
          label: 'Continue',
          enabled: _canContinue,
          onPressed: _continue,
        ),
      ],
    );
  }
}
