# J'Donuts — Senior Flutter Code Test (`zawe`)

Offline-first Flutter slice of the J'Donuts customer app: fake auth/registration, Home + Product detail from local data, and an animated Rewards tab.

**Platforms:** Android + iOS (run on emulator / Simulator).  
**Flutter:** 3.47.6 (stable) · **Dart:** 3.13.5 · **Package:** `zawe` · **Lints:** `flutter_lints` (`flutter analyze` clean)

---

## How to run

```bash
flutter pub get
flutter run -t lib/main_dev.dart --flavor dev
```

| Flavor | Entry | Command |
|--------|-------|---------|
| Dev | `lib/main_dev.dart` | `flutter run -t lib/main_dev.dart --flavor dev` |
| Staging | `lib/main_staging.dart` | `flutter run -t lib/main_staging.dart --flavor staging` |
| Prod | `lib/main_prod.dart` | `flutter run -t lib/main_prod.dart --flavor prod` |

Default `lib/main.dart` also works with `--dart-define=APP_FLAVOR=dev` (or `flavors/dev.json`).

### Demo credentials

| Field | Value |
|-------|--------|
| **Fake OTP** | `123456` |
| Phone | Myanmar mobile after `+95` (e.g. `9254135592`) |
| Wrong OTP | 3 failures lock until Resend (countdown from `5:00`) |

Log out from the **More** tab to re-test Onboarding → Register / Login.

### Tests

If the project path contains an apostrophe (e.g. `J'Donuts`), run tests via a junction without `'` in the path:

```bash
# Windows example
mklink /J C:\zawe_test "E:\cdtest\J'Donuts\zawe"
cd C:\zawe_test

flutter test
flutter test integration_test/register_home_product_test.dart -d flutter-tester
flutter analyze
```

### Release builds (submission)

```bash
# Prefer C:\zawe_test if the real path has an apostrophe
cd C:\zawe_test   # or your project root

# Android release APK (prod flavor)
flutter build apk --release -t lib/main_prod.dart --flavor prod
# → build/app/outputs/flutter-apk/app-prod-release.apk

# iOS Simulator .app (macOS + Xcode required)
flutter build ios --simulator -t lib/main_prod.dart
# Zip the .app under build/ios/iphonesimulator/ for submission
```

---

## Architecture

Clean, feature-first layout. **Presentation → application → domain ← data.** Domain has no Flutter UI imports. UI never constructs repositories; Riverpod providers wire dependencies.

### Is this MVVM?

**Loosely yes** — the presentation layer behaves like MVVM — but the project is intentionally **Clean Architecture** with Riverpod, not a pure MVVM textbook stack.

| MVVM idea | In this app |
|-----------|-------------|
| **View** | Widgets / screens (`presentation`) — layout and gestures only |
| **ViewModel** | Riverpod notifiers + providers (`application`) — screen state, loading/error, user intents |
| **Model** | Domain entities + use cases + repository interfaces; **data** implements those interfaces |

Why this shape (instead of fat widgets or a single “ViewModel package”):

1. **Testable validation & auth** — pure domain validators / use cases without Flutter  
2. **Swap the fake** — `AuthRepository` / `CatalogRepository` can become a real API without rewriting UI  
3. **Offline-first** — UI always reads providers that sit on the local DB, not hard-coded lists in widgets  
4. **Riverpod as ViewModel + DI** — one mechanism for state and wiring; easy overrides in tests  

So: **MVVM-style separation at the UI boundary**, with **domain/data layers under it** for the code-test architecture score.

```
lib/
  bootstrap.dart / app.dart / main_*.dart
  core/                 # theme, motion, router, Result/AppFailure, shared widgets
  features/
    auth/               # presentation · application · domain · data
    catalog/            # shared offline catalog (Home / Product / Rewards source of truth)
    onboarding/ welcome/ home/ product/ rewards/
    shell/ settings/ donuts/ wallet/   # shell + placeholders where brief allows
```

| Concern | Choice |
|---------|--------|
| State | **Riverpod** — compile-time safe DI, `AsyncNotifier` for session/catalog, easy test overrides |
| Navigation | **go_router** — auth redirect guard; product as nested `/home/product/:productId` (also under shop/donuts) so **Hero** shares one navigator |
| Session | **flutter_secure_storage** (+ prefs migration) |
| Auth | `AuthRepository` + `FakeAuthRepository` (~1s delay, local users) — swap for a real API without UI changes |
| Errors | Typed `Result` / `AppFailure`; screens use loading / error / empty where data is async |
| Local DB | **sqflite** with versioned schema (`schemaVersion` 3, seed `v3`) |
| Images | Bundled assets + `cached_network_image` (disk cache, placeholder / error) |
| Connectivity | `connectivity_plus` + DNS reachability probe; offline banner + pull-to-refresh |
| Theme | Tokens in `AppColors` / `AppTheme` (Poppins); painters still have some local colours |
| Models | Dart 3 `final class` + sealed `Result` / `AppFailure` (no freezed codegen) |
| l10n | ARB + `gen-l10n` — `en` default, `my` (Burmese) in `lib/l10n/`; set `locale: Locale('my')` in `App` to demo |
| Layout | Text scale clamped to **1.3** in `App` builder; ellipsis on key labels |
| Network | No mock server → **no Dio** (YAGNI). Add Dio only if `/v1` is introduced |

**Shared member:** Home and Rewards both read the same catalog member (Bronze / points from seed) — mock-ups disagree; data wins.

**Folder note:** Brief asks for `home` / `product` / `rewards` each with domain+data. Shared catalog lives under `features/catalog` so one DB feeds all three; each screen keeps its own `presentation`.

### Why Riverpod

One place for DI and async state (session, catalog, product-by-id) without service locators inside widgets. Overrides make unit/widget/integration tests fast (zero-delay fake auth, in-memory secure store, ffi SQLite).

### Why sqflite (not Drift)

The brief recommends Drift; this app uses **sqflite** intentionally:

- Seed JSON → single blob + meta table is enough for the offline slice
- Schema bumps via `onUpgrade` + seed version key (re-seed when seed version changes)
- Less codegen for a fixed local catalog; UI still talks only to `CatalogRepository`

Defended here so a real API / Drift can replace the data layer later without touching presentation.

### Offline strategy

1. First launch: `assets/data/catalog_v1.json` seeds SQLite  
2. Home / Product / Rewards / member / challenges all read that DB  
3. Airplane mode: assets + DB keep screens and images working  
4. Online again: background refresh + pull-to-refresh; soft offline banner while link is down  

---

## Screens & flow

| Path | Behavior |
|------|----------|
| Register | Phone → OTP → Name → DOB → Welcome → Home |
| Login | Phone → OTP → Home (unregistered number → inline link to register) |
| Session | Logged in → Home on relaunch; logged out → Onboarding |
| Shell | Home + Reward fully wired; Donuts / Wallet / More are simple placeholders |

Product detail opens from Home (and Donuts) with a shared-element **Hero** on the product image.

---

## Animations (named in `lib/core/motion/jd_motion.dart`)

- Onboarding / Welcome entrance + donut motion  
- Auth step transitions; progress ring 25%→100% then check morph  
- OTP shake; Continue press scale + loading morph  
- Home skeleton shimmer, section stagger, banner auto-play  
- Product image Hero; quantity scale on change  
- Rewards: points ring + count to **680,000**, tier stagger, challenge stagger, badge pop, tab indicator  
- Bottom-nav active pill morph  

**Reduce Motion:** `MediaQuery.disableAnimations` shortens or skips where wired (auth, welcome, banners, rewards entrances, qty).

---

## Tests

| Layer | Coverage |
|-------|----------|
| Unit | Phone / OTP / name / DOB validators; auth use cases |
| Widget | Auth validation UI (phone, name, OTP lock, DOB) |
| Integration | Register → Welcome → Home → Coconut Donut product detail |

---

## Known gaps

- No public mock `/v1` server + Dio (optional; intentionally skipped)  
- No CI workflow yet (optional)  
- Not all UI strings migrated to ARB yet (core product / offline / badges are; auth copy still partly hard-coded)  
- Rewards painter widgets still use some local colours  
- A few presentation files exceed ~300 lines (home strips / rewards)  
- Persistent cart is visual-only (snackbar) — bonus not implemented  
- Path with `'` breaks `flutter test` listener — use a junction (see Tests)  

---

## Time spent

Within the allotted **2-day** code-test window (implementation + polish + tests + README).

Design screenshots from the client brief are **not** committed.
