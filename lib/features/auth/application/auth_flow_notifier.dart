import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_constants.dart';
import '../domain/auth_flow_step.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthFlowState {
  const AuthFlowState({
    this.step = AuthFlowStep.phone,
    this.mode = AuthFlowMode.register,
    this.phoneLocal = '',
    this.phoneE164,
    this.firstName = '',
    this.lastName = '',
    this.birthMonth = '',
    this.birthDay = '',
    this.birthYear = '',
    this.wrongOtpAttempts = 0,
    this.otpLocked = false,
    this.registeredUser,
  });

  final AuthFlowStep step;
  final AuthFlowMode mode;
  final String phoneLocal;
  final String? phoneE164;
  final String firstName;
  final String lastName;
  final String birthMonth;
  final String birthDay;
  final String birthYear;
  final int wrongOtpAttempts;
  final bool otpLocked;
  final AppUser? registeredUser;

  AuthFlowState copyWith({
    AuthFlowStep? step,
    AuthFlowMode? mode,
    String? phoneLocal,
    String? phoneE164,
    String? firstName,
    String? lastName,
    String? birthMonth,
    String? birthDay,
    String? birthYear,
    int? wrongOtpAttempts,
    bool? otpLocked,
    AppUser? registeredUser,
    bool clearRegisteredUser = false,
    bool clearPhoneE164 = false,
  }) {
    return AuthFlowState(
      step: step ?? this.step,
      mode: mode ?? this.mode,
      phoneLocal: phoneLocal ?? this.phoneLocal,
      phoneE164: clearPhoneE164 ? null : (phoneE164 ?? this.phoneE164),
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      birthYear: birthYear ?? this.birthYear,
      wrongOtpAttempts: wrongOtpAttempts ?? this.wrongOtpAttempts,
      otpLocked: otpLocked ?? this.otpLocked,
      registeredUser:
          clearRegisteredUser ? null : (registeredUser ?? this.registeredUser),
    );
  }
}

final authFlowProvider =
    NotifierProvider<AuthFlowNotifier, AuthFlowState>(AuthFlowNotifier.new);

class AuthFlowNotifier extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  void resetFlow() => state = const AuthFlowState();

  void goTo(AuthFlowStep step) => state = state.copyWith(step: step);

  void back() {
    final prev = state.step.previous;
    if (prev != null) state = state.copyWith(step: prev);
  }

  void setMode(AuthFlowMode mode) => state = state.copyWith(mode: mode);

  void setPhoneLocal(String value) =>
      state = state.copyWith(phoneLocal: value);

  void setPhoneE164(String? e164) =>
      state = state.copyWith(phoneE164: e164, clearPhoneE164: e164 == null);

  void setFirstName(String value) => state = state.copyWith(firstName: value);
  void setLastName(String value) => state = state.copyWith(lastName: value);
  void setBirthMonth(String v) => state = state.copyWith(birthMonth: v);
  void setBirthDay(String v) => state = state.copyWith(birthDay: v);
  void setBirthYear(String v) => state = state.copyWith(birthYear: v);

  void registerWrongOtp() {
    final next = state.wrongOtpAttempts + 1;
    state = state.copyWith(
      wrongOtpAttempts: next,
      otpLocked: next >= AuthConstants.maxWrongOtpAttempts,
    );
  }

  void resetOtpAttempts() =>
      state = state.copyWith(wrongOtpAttempts: 0, otpLocked: false);

  void switchToRegisterKeepingPhone() =>
      state = state.copyWith(mode: AuthFlowMode.register);

  void setRegisteredUser(AppUser user) =>
      state = state.copyWith(registeredUser: user);

  void clearRegisteredUser() =>
      state = state.copyWith(clearRegisteredUser: true);
}
