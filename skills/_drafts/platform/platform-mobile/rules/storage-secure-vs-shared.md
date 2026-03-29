---
title: Local Storage — Secure Storage vs SharedPreferences
impact: HIGH
tags: storage, security, shared-preferences, jwt
---

## Local Storage — Secure Storage vs SharedPreferences

### Decision Table

| Data | Storage | Reason |
|------|---------|--------|
| JWT access token | `flutter_secure_storage` | Encrypted in OS keychain |
| JWT refresh token | `flutter_secure_storage` | Encrypted in OS keychain |
| Biometric PIN / passcode | `flutter_secure_storage` | Sensitive credential |
| User ID (non-sensitive) | `SharedPreferences` | Fast read, not sensitive |
| Theme preference | `SharedPreferences` | Non-sensitive UX preference |
| Onboarding completed flag | `SharedPreferences` | Non-sensitive boolean |
| Local transaction cache | `SharedPreferences` (JSON) | Non-sensitive app data |
| Monthly budget limits (local) | `SharedPreferences` | Non-sensitive numbers |

**Rule:** Ask "would this data harm the user if extracted from an unencrypted backup?" — if yes, use `flutter_secure_storage`.

**Never store JWT tokens in SharedPreferences.** SharedPreferences is unencrypted and readable via Android backup or rooted device access.

### Wrapping SharedPreferences (LocalKvStore Pattern)

Never call `SharedPreferences.getInstance()` directly in providers or widgets. Wrap it in a service class and provide it via Riverpod.

```dart
// core/services/local_kv_store.dart
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

class LocalKvStore {
  LocalKvStore(this._prefs);
  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_completed';
  static const _themeKey = 'theme_mode';
  static const _accountsKey = 'zenda.accounts.v1';

  bool get onboardingDone => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> markOnboardingDone() => _prefs.setBool(_onboardingKey, true);

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> data) =>
      _prefs.setString(key, jsonEncode(data));
}

@Riverpod(keepAlive: true)
LocalKvStore localKvStore(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return LocalKvStore(prefs);
}
```

Initialize `SharedPreferences` before `runApp` to avoid async gaps:

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(AsyncData(prefs)),
      ],
      child: const ZendaApp(),
    ),
  );
}
```

### Storage Key Versioning

Suffix keys with a version when the schema changes to avoid deserialization crashes on app upgrades:

```dart
// Good
static const _accountsKey = 'zenda.accounts.v1';
static const _transactionsKey = 'zenda.transactions.v1';

// Anti-pattern — no namespace, no version
static const _key = 'accounts';
```
