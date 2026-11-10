import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/motion/jd_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_auth_scaffold.dart';
import '../../application/auth_flow_notifier.dart';
import '../../application/auth_providers.dart';
import '../../domain/validators/date_of_birth_validator.dart';
import '../../../welcome/presentation/welcome_screen.dart';

class AuthBirthdayStep extends ConsumerStatefulWidget {
  const AuthBirthdayStep({
    super.key,
    required this.onRingComplete,
  });

  final ValueChanged<bool> onRingComplete;

  @override
  ConsumerState<AuthBirthdayStep> createState() => _AuthBirthdayStepState();
}

class _AuthBirthdayStepState extends ConsumerState<AuthBirthdayStep> {
  late final TextEditingController _month;
  late final TextEditingController _day;
  late final TextEditingController _year;
  late final FocusNode _monthFocus;
  late final FocusNode _dayFocus;
  late final FocusNode _yearFocus;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final flow = ref.read(authFlowProvider);
    _month = TextEditingController(text: flow.birthMonth);
    _day = TextEditingController(text: flow.birthDay);
    _year = TextEditingController(text: flow.birthYear);
    _monthFocus = FocusNode()..addListener(_onAnyBlur);
    _dayFocus = FocusNode()..addListener(_onAnyBlur);
    _yearFocus = FocusNode()..addListener(_onAnyBlur);
    _month.addListener(() => ref.read(authFlowProvider.notifier).setBirthMonth(_month.text));
    _day.addListener(() => ref.read(authFlowProvider.notifier).setBirthDay(_day.text));
    _year.addListener(() => ref.read(authFlowProvider.notifier).setBirthYear(_year.text));
  }

  @override
  void dispose() {
    _monthFocus
      ..removeListener(_onAnyBlur)
      ..dispose();
    _dayFocus
      ..removeListener(_onAnyBlur)
      ..dispose();
    _yearFocus
      ..removeListener(_onAnyBlur)
      ..dispose();
    _month.dispose();
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  void _onAnyBlur() {
    final anyFocused =
        _monthFocus.hasFocus || _dayFocus.hasFocus || _yearFocus.hasFocus;
    if (!anyFocused) _showInlineIfReady();
  }

  DateOfBirthValidation _validate() {
    return validateDateOfBirth(
      month: int.tryParse(_month.text.trim()) ?? 0,
      day: int.tryParse(_day.text.trim()) ?? 0,
      year: int.tryParse(_year.text.trim()) ?? 0,
    );
  }

  bool get _fieldsTouched =>
      _month.text.trim().isNotEmpty ||
      _day.text.trim().isNotEmpty ||
      _year.text.trim().isNotEmpty;

  void _showInlineIfReady() {
    if (!_fieldsTouched) {
      setState(() => _error = null);
      return;
    }
    final v = _validate();
    setState(() => _error = v.isValid ? null : v.error);
  }

  Future<void> _continue() async {
    if (_loading) return;
    final v = _validate();
    if (!v.isValid) {
      setState(() => _error = v.error);
      return;
    }
    final flow = ref.read(authFlowProvider);
    final phone = flow.phoneE164;
    if (phone == null || v.date == null) return;

    setState(() => _loading = true);
    try {
      final result = await ref.read(completeRegistrationProvider)(
        phoneE164: phone,
        firstName: flow.firstName,
        lastName: flow.lastName,
        dateOfBirth: v.date!,
      );
      switch (result) {
        case Ok(:final value):
          ref.read(authFlowProvider.notifier).setRegisteredUser(value);
          if (!mounted) return;
          widget.onRingComplete(true);
          final reduce = MediaQuery.disableAnimationsOf(context);
          if (!reduce) {
            await Future<void>.delayed(
              JdMotion.ringMorph + const Duration(milliseconds: 200),
            );
          }
          if (mounted) context.push(WelcomeScreen.routePath);
        case Err(:final failure):
          if (mounted) setState(() => _error = failure.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _validate().isValid;

    return Column(
      children: [
        _field(_month, _monthFocus, 'Month', TextInputAction.next, () {
          _dayFocus.requestFocus();
        }),
        const SizedBox(height: 12),
        _field(_day, _dayFocus, 'Day', TextInputAction.next, () {
          _yearFocus.requestFocus();
        }),
        const SizedBox(height: 12),
        _field(_year, _yearFocus, 'Year', TextInputAction.done, () {
          FocusScope.of(context).unfocus();
        }),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 32),
        jdContinue(
          label: 'Continue',
          enabled: canContinue,
          loading: _loading,
          onPressed: _continue,
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    FocusNode focus,
    String label,
    TextInputAction action,
    VoidCallback onComplete,
  ) {
    return TextField(
      controller: c,
      focusNode: focus,
      keyboardType: TextInputType.number,
      textInputAction: action,
      scrollPadding: AppColors.fieldScrollPadding,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(hintText: label),
      onChanged: (_) => setState(() => _error = null),
      onEditingComplete: () {
        _showInlineIfReady();
        onComplete();
      },
    );
  }
}
