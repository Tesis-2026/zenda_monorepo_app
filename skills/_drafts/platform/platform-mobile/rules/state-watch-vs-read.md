---
title: ref.watch vs ref.read vs ref.listen
impact: CRITICAL
tags: state, riverpod, ref
---

## ref.watch vs ref.read vs ref.listen

Using the wrong `ref` method is one of the most common Riverpod bugs — it causes stale state, missed rebuilds, or infinite loops.

| Method | Where | Purpose |
|--------|-------|---------|
| `ref.watch` | Inside `build()` only | Subscribes to provider; widget rebuilds when value changes |
| `ref.read` | Inside callbacks and mutations | One-shot read; does NOT rebuild |
| `ref.listen` | Inside `build()`, top-level | Side-effects on state change (snackbars, navigation) |

```dart
// ANTI-PATTERN — ref.read in build() misses future updates
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.read(userProvider); // stale after first build!
}

// CORRECT
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider);
}

// CORRECT — ref.read in callback
ElevatedButton(
  onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
)

// ANTI-PATTERN — ref.watch in callback causes rebuild loop
ElevatedButton(
  onPressed: () {
    final count = ref.watch(counterProvider); // rebuilds trigger onPressed rebuild
  },
)

// CORRECT — ref.listen for side-effects (snackbar, navigation)
ref.listen(authNotifierProvider, (prev, next) {
  if (next.status == AuthStatus.unauthenticated) {
    context.go('/login');
  }
});

// CORRECT — ref.listen for transient error toasts
ref.listen(createTransactionProvider, (_, next) {
  next.whenOrNull(
    error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is ApiException ? e.userMessage : 'Failed to save')),
    ),
  );
});
```

**AsyncValue — always handle all three states:**

```dart
ref.watch(transactionListProvider).when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorBanner(message: e is ApiException ? e.userMessage : 'Error'),
  data: (items) => TransactionListView(items: items),
);

// Show old data while refreshing (preferred for pull-to-refresh)
ref.watch(transactionListProvider).when(
  skipLoadingOnReload: true,
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorBanner(message: e.toString()),
  data: (items) => TransactionListView(items: items),
);
```

**`AsyncValue.guard` — idiomatic mutation wrapper:**

```dart
Future<void> save(CreateTransactionDto dto) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    await ref.read(transactionRepositoryProvider).create(dto);
    return ref.read(transactionRepositoryProvider).fetchAll();
  });
  // AsyncValue.guard catches exceptions → converts to AsyncError automatically
}
```
