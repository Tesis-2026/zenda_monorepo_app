---
title: Widget Performance — const, select, and ListView
impact: MEDIUM
tags: performance, const, listview, rebuilds
---

## Widget Performance — const, select, and ListView

### const Widgets

Mark every widget `const` that has no runtime-variable inputs. This is the single cheapest performance improvement in Flutter.

```dart
// Anti-pattern — rebuilds on every parent rebuild
child: Text('Transactions'),
child: SizedBox(height: 16),
child: Icon(Icons.add),

// Correct
child: const Text('Transactions'),
child: const SizedBox(height: 16),
child: const Icon(Icons.add),
```

Rules:
- All static strings, icons, padding values → `const`.
- Widget classes with `const` constructors and only final fields can be `const`.
- Move `BoxDecoration`, `TextStyle`, `BorderRadius` literals to `static const` fields — not inline in `build()`.

### provider.select() — Limit Rebuild Scope

Use `.select()` to watch only a slice of state. The widget rebuilds only when that slice changes.

```dart
// Anti-pattern — rebuilds when ANY field in AuthState changes
final authState = ref.watch(authNotifierProvider);
final isLoggedIn = authState.isAuthenticated;

// Correct — rebuilds only when isAuthenticated changes
final isLoggedIn = ref.watch(
  authNotifierProvider.select((s) => s.isAuthenticated),
);

// Correct — rebuilds only when transaction count changes
final count = ref.watch(
  transactionListProvider.select((s) => s.valueOrNull?.length ?? 0),
);
```

### ConsumerWidget vs Consumer

- Prefer `ConsumerWidget` — makes the entire widget a consumer. Simpler and easier to reason about.
- Use `Consumer` inline only when isolating rebuilds to a small subtree within a large widget is worth the added complexity.

```dart
// Preferred — whole widget is a consumer
class TransactionTile extends ConsumerWidget {
  const TransactionTile({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(transactionProvider(id));
    return tx.when(data: (t) => _TileContent(t), ...);
  }
}

// Use Consumer only to isolate a subtree
Column(
  children: [
    const StaticHeader(),
    Consumer(
      builder: (ctx, ref, _) {
        final balance = ref.watch(balanceProvider);
        return BalanceCard(amount: balance);
      },
    ),
    const StaticFooter(),
  ],
)
```

### ListView Best Practices

| Scenario | Widget |
|----------|--------|
| List that can grow (transactions, history) | `ListView.builder` — lazy, builds only visible items |
| Short static list (<10 items) | `ListView(children: [...])` acceptable |
| Fixed-height items, large dataset | `ListView.builder` + `itemExtent` for O(1) scroll |
| Transactions screen | `ListView.builder` always |

```dart
// Anti-pattern — eagerly builds all items
ListView(
  children: transactions.map((t) => TransactionTile(t)).toList(),
)

// Correct — builds lazily
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) => TransactionTile(
    key: ValueKey(transactions[index].id),
    id: transactions[index].id,
  ),
)
```

Always provide a `key: ValueKey(item.id)` to ListView items — this lets Flutter reconcile the list efficiently when items are added, removed, or reordered.

### No Computation in build()

```dart
// Anti-pattern — sorts and filters on every rebuild
@override
Widget build(BuildContext context, WidgetRef ref) {
  final sorted = ref.watch(transactionListProvider)
      .valueOrNull
      ?.sorted((a, b) => b.occurredAt.compareTo(a.occurredAt));
}

// Correct — sort/filter in provider or repository
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final all = await ref.watch(transactionRepositoryProvider).fetchAll();
    return all..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
}
```
