enum AuthFlowStep { phone, verify, name, birthday }

extension AuthFlowStepLabels on AuthFlowStep {
  int get progressIndex => switch (this) {
        AuthFlowStep.phone => 1,
        AuthFlowStep.verify => 2,
        AuthFlowStep.name => 3,
        AuthFlowStep.birthday => 4,
      };

  AuthFlowStep? get previous => switch (this) {
        AuthFlowStep.phone => null,
        AuthFlowStep.verify => AuthFlowStep.phone,
        AuthFlowStep.name => AuthFlowStep.verify,
        AuthFlowStep.birthday => AuthFlowStep.name,
      };
}
