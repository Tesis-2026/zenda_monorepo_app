---
title: Choose the Right Riverpod 3 Provider Type
impact: CRITICAL
tags: state, riverpod, async
---

## Choose the Right Riverpod 3 Provider Type

Pick the narrowest provider type that fits. Wrong choices cause unnecessary rebuilds or missing async state handling.

| Scenario | Provider type |
|----------|--------------|
| Derived/computed value, no mutation | `Provider` |
| Sync mutable state (toggle, counter) | `NotifierProvider` |
| Async data loaded on first watch (API list) | `AsyncNotifierProvider` |
| Single async value that is never mutated | `FutureProvider` |
| Real-time stream (WebSocket, live updates) | `StreamProvider` |
| Per-ID instances (transaction detail by id) | Any above + `.family` |

**Never use `StateNotifierProvider`** — deprecated in Riverpod 3. Migrate to `NotifierProvider` or `AsyncNotifierProvider`.

```dart
// CORRECT — async list loaded from API
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    return ref.watch(transactionRepositoryProvider).fetchAll();
  }

  Future<void> add(Transaction t) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).create(t);
      return ref.read(transactionRepositoryProvider).fetchAll();
    });
  }
}

// CORRECT — sync mutable state
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.light; // synchronous default

  void toggle() => state =
      state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}

// ANTI-PATTERN — StateNotifierProvider (Riverpod 1/2 style)
final counterProvider = StateNotifierProvider<CounterNotifier, int>(...);
```

**Family providers — when to use:**

```dart
// Use .family for per-parameter instances
@riverpod
Future<Transaction> transaction(Ref ref, String id) async {
  return ref.watch(transactionRepositoryProvider).findById(id);
}

// In widget
ref.watch(transactionProvider('txn-abc123'))
```

Family parameter must be a primitive or value-equal object (`String`, `int`, enum, or a class with `==` and `hashCode` overrides). Never pass `BuildContext` as a family argument.

**keepAlive — when to use:**

```dart
// Auth state and global session must survive navigation
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier { ... }

// Screen-scoped data: leave as auto-dispose (default)
@riverpod
class TransactionList extends _$TransactionList { ... }
```
