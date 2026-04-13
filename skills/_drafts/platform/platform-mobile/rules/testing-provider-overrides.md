---
title: Testing — Provider Overrides and ProviderContainer
impact: MEDIUM
tags: testing, riverpod, mocking, unit-test, widget-test
---

## Testing — Provider Overrides and ProviderContainer

### Unit Tests — ProviderContainer

Use `ProviderContainer` for pure Dart tests (no Flutter widgets needed).

```dart
void main() {
  late ProviderContainer container;
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    container = ProviderContainer(overrides: [
      transactionRepositoryProvider.overrideWithValue(mockRepo),
    ]);
  });

  tearDown(() => container.dispose()); // always dispose

  test('build() loads transactions sorted by date', () async {
    when(mockRepo.fetchAll).thenAnswer((_) async => [tx2, tx1]);

    final result = await container.read(transactionListProvider.future);

    expect(result.first.occurredAt, greaterThan(result.last.occurredAt));
  });

  test('add() calls repository create and refreshes list', () async {
    when(mockRepo.fetchAll).thenAnswer((_) async => [newTx]);
    when(() => mockRepo.create(any())).thenAnswer((_) async => newTx);

    await container.read(transactionListProvider.notifier).add(newTx);

    verify(() => mockRepo.create(any())).called(1);
  });
}
```

### Widget Tests — ProviderScope Overrides

```dart
Widget buildTestWidget(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

testWidgets('shows transaction list', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const TransactionsScreen(),
    [transactionListProvider.overrideWith(() => FakeTransactionListNotifier())],
  ));
  await tester.pumpAndSettle();

  expect(find.byType(TransactionTile), findsWidgets);
});

testWidgets('shows error banner on load failure', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const TransactionsScreen(),
    [transactionListProvider.overrideWith(() => FailingTransactionListNotifier())],
  ));
  await tester.pumpAndSettle();

  expect(find.byType(ErrorBanner), findsOneWidget);
});
```

### Rules

- Use `mocktail` (not `mockito`) — no code-gen required, works with Dart 3 null safety cleanly.
- Override at the **repository level**, not the notifier level — this tests the full notifier logic.
- Always `dispose()` the `ProviderContainer` in `tearDown` to prevent cross-test state leaks.
- Never create a real `ApiClient` in tests — always override with a mock or fake.
- For GoRouter navigation tests, provide the router as a `MaterialApp.router` override.

### Fake Notifiers for Widget Tests

```dart
class FakeTransactionListNotifier extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async => [fakeTransaction];
}

class FailingTransactionListNotifier extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async =>
      throw const NetworkException();
}
```

Fake notifiers are simpler than mocks for widget tests — they provide a complete, predictable state without mock setup.
