import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// connectivity_plus alone is not enough — also probe a public host.
Future<bool> hasInternetReachability({
  Duration timeout = const Duration(seconds: 2),
}) async {
  final links = await Connectivity().checkConnectivity();
  if (links.every((r) => r == ConnectivityResult.none)) return false;

  try {
    final result = await InternetAddress.lookup('example.com').timeout(timeout);
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on Exception {
    return false;
  }
}
