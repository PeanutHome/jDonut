// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get letsGetStarted => 'စတင်လိုက်ပါ';

  @override
  String get letsExplore => 'လေ့လာကြည့်မယ်';

  @override
  String get continueLabel => 'ဆက်လုပ်မည်';

  @override
  String get logOut => 'ထွက်မည်';

  @override
  String get offlineBanner => 'အင်တာနက်မရှိ — သိမ်းထားသောဒေတာကို ပြသနေသည်';

  @override
  String get addToCart => 'ခြင်းတောင်းထည့်မည်';

  @override
  String get whatsThis => 'ဒါဘာလဲ?';

  @override
  String get whatsThisShort => 'ဒါ\nဘာလဲ?';

  @override
  String get newBadge => 'အသစ်';

  @override
  String percentOff(int percent) {
    return '$percent% လျှော့';
  }

  @override
  String get productNotFound => 'ပစ္စည်းမတွေ့ပါ';

  @override
  String get retry => 'ပြန်ကြိုးစားမည်';

  @override
  String get addedToCart => 'ခြင်းတောင်းထည့်ပြီး';

  @override
  String get noChallengesYet => 'စိန်ခေါ်မှုမရှိသေးပါ';

  @override
  String get exploreNow => 'ရှာဖွေမည်';

  @override
  String get orderOnline => 'အွန်လိုင်းမှာယူမည်';

  @override
  String shopsNearYou(int count) {
    return 'အနီးအနားတွင် J\'Donut ဆိုင် $count ဆိုင် ရှိသည်။';
  }

  @override
  String mmkPrice(String amount) {
    return '$amount ကျပ်';
  }

  @override
  String get couldNotLoadHome => 'ပင်မစာမျက်နှာ မရနိုင်ပါ';
}
