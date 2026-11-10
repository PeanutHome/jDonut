// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get letsGetStarted => 'LET\'S GET STARTED';

  @override
  String get letsExplore => 'LET\'S EXPLORE';

  @override
  String get continueLabel => 'Continue';

  @override
  String get logOut => 'Log out';

  @override
  String get offlineBanner => 'You\'re offline — showing saved data';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String get whatsThisShort => 'What\'s\nthis?';

  @override
  String get newBadge => 'New';

  @override
  String percentOff(int percent) {
    return '$percent% off';
  }

  @override
  String get productNotFound => 'Product not found';

  @override
  String get retry => 'Retry';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get noChallengesYet => 'No challenges yet';

  @override
  String get exploreNow => 'EXPLORE NOW';

  @override
  String get orderOnline => 'Order Online';

  @override
  String shopsNearYou(int count) {
    return 'There are $count J\'Donut shops\nnear you.';
  }

  @override
  String mmkPrice(String amount) {
    return '$amount MMK';
  }

  @override
  String get couldNotLoadHome => 'Could not load home';
}
