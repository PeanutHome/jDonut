import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/features/auth/domain/auth_constants.dart';
import 'package:zawe/features/home/presentation/home_screen.dart';
import 'package:zawe/features/product/presentation/product_detail_screen.dart';
import 'package:zawe/features/welcome/presentation/welcome_screen.dart';

import 'support/test_app.dart';

void main() {
  // Widget-binding harness: same Register→Home→Product path without a
  // desktop/device project (run via `flutter test` on C:\zawe_test).
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'register flow reaches Home then opens Coconut Donut product detail',
    (tester) async {
      await pumpZaweApp(tester);

      // Onboarding
      expect(find.textContaining('Round food'), findsOneWidget);
      await tester.tap(find.text("LET'S GET STARTED"));
      await tester.pumpAndSettle();

      // Phone
      expect(find.text('Enter your phone number'), findsOneWidget);
      await tester.enterText(find.byType(TextField), uniqueTestPhone());
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // OTP
      expect(find.text('Verify your number'), findsOneWidget);
      await tester.enterText(
        find.byType(EditableText),
        AuthConstants.fakeOtpCode,
      );
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Name
      expect(find.text("What's your name?"), findsOneWidget);
      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.at(0), 'Hania');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Date of birth (age >= 13)
      expect(find.text("What's your date of birth?"), findsOneWidget);
      final dobFields = find.byType(TextField);
      await tester.enterText(dobFields.at(0), '1');
      await tester.enterText(dobFields.at(1), '15');
      await tester.enterText(dobFields.at(2), '2000');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Welcome
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.tap(find.text("LET'S EXPLORE"));
      await tester.pumpAndSettle();

      // Home
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Seasonal specials'), findsOneWidget);

      // Popular strip: title sits outside InkWell — scroll card on-screen, tap image.
      await tester.ensureVisible(find.textContaining('Popular'));
      await tester.pumpAndSettle();

      final coconut = find.text('Coconut Donut');
      expect(coconut, findsOneWidget);

      final popularList = find.ancestor(
        of: coconut,
        matching: find.byWidgetPredicate(
          (w) => w is ListView && w.scrollDirection == Axis.horizontal,
        ),
      );
      await tester.drag(popularList, const Offset(-220, 0));
      await tester.pumpAndSettle();

      final coconutInkWell = find.descendant(
        of: find.ancestor(
          of: coconut,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Column &&
                w.crossAxisAlignment == CrossAxisAlignment.stretch &&
                w.children.length >= 3,
          ),
        ),
        matching: find.byType(InkWell),
      );
      await tester.ensureVisible(coconutInkWell);
      await tester.tap(coconutInkWell);
      await tester.pumpAndSettle();

      // Product detail
      expect(find.byType(ProductDetailScreen), findsOneWidget);
      expect(find.text('JD022123'), findsOneWidget);
      expect(find.text('Coconut Donut'), findsOneWidget);
      expect(find.textContaining('ADD TO CART'), findsOneWidget);
    },
  );
}
