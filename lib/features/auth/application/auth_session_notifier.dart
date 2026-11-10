import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/app_user.dart';
import 'auth_providers.dart';

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AppUser?>(AuthSessionNotifier.new);

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final listenable = AuthRefreshListenable();
  ref.onDispose(listenable.dispose);
  ref.listen(authSessionProvider, (_, _) => listenable.refresh());
  return listenable;
});

class AuthRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class AuthSessionNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    return result.when(ok: (u) => u, err: (_) => null);
  }

  Future<void> setUser(AppUser user) async {
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AsyncData(null);
  }
}
