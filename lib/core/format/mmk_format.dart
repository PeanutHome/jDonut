import 'package:intl/intl.dart';

final _mmk = NumberFormat('#,###');

String formatMmk(int amount) => _mmk.format(amount);
