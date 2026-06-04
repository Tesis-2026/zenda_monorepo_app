# Standards Applied: Phase 11 — Notifications and Alerts

## Database

- **Soft-delete-free aggregate** — `Notification` has no `deletedAt`. Rationale: notifications are append-only history; users either read them or ignore them. Hard-delete is acceptable because there is no compliance requirement to retain unread alerts indefinitely. Matches the existing pattern for `AnalyticsEvent` and `AuditLog`.
- **Indexes pay for queries actually run** — `(userId, createdAt)` powers inbox listing (newest first); `(userId, readAt)` powers unread count. No speculative composite indexes.
- **JSON column for opaque routing payload** — `Notification.data` is `Json?`; consumers cast via type-guard at the boundary. Avoids growing the schema each time a new notification type adds a new key.
- **`Decimal` not used** — no monetary fields on the notification itself. `BUDGET_ALERT.data.percentageUsed` is stored as a string (post-`Math.round`) to keep the payload JSON-safe.

## Domain (NestJS DDD)

- **Pure TypeScript entity** — `NotificationEntity` has zero NestJS decorators and zero `@prisma/client` imports. `NotificationKind` is a string union defined in the domain layer; the repository maps to/from `NotificationType` from `@prisma/client` at the persistence boundary.
- **Repository ports as abstract classes** — `INotificationRepository` and `INotificationUserPort` are abstract classes paired with injection token symbols (`NOTIFICATION_REPOSITORY`, `NOTIFICATION_USER_PORT`). Bound to Prisma implementations via `{ provide, useClass }` in the module.
- **Use cases own orchestration** — `SendNotificationUseCase` reads two ports + an infra service and writes via the repository port. No business logic leaks into the controller.

## Application

- **Fire-and-forget cross-cutting effects** — Inbox dispatch from `TransactionsController.create` and badge award are wrapped in `.catch(() => null)`. The caller's primary outcome (transaction created, badge granted) is the source of truth; notification delivery is best-effort.
- **Single command object** — `SendNotificationCommand` carries all idempotency hints (`idempotencySince`, `idempotencyDataKey`, `idempotencyDataValue`, `respectPreferences`). Callers do not need to know which gates run; the use case decides.
- **Facade for cross-context reads** — `BudgetsFacade.getSnapshotForCategory` exposes a read DTO to `TransactionsController` instead of leaking `IBudgetRepository` across module boundaries. Matches the B19 pattern (BadgesFacade / ChallengesFacade / CategoriesFacade).

## API

- **DTO validation at the boundary** — `RegisterFcmTokenDto` (length bounds), `SetDailyReminderTimeDto` (HH:mm regex). Invalid payloads return 400 before hitting the use case.
- **`ParseUUIDPipe` on path params** — `PATCH /:id/read` returns 400 on a malformed id instead of falling through to a 404 from the repository.
- **`SuccessResponseDto` not wrapped** — Inbox returns the raw `NotificationInboxResponseDto`. Matches the existing controllers that already return DTOs directly (e.g. `PredictionsController`).
- **Swagger annotations on every route** — `@ApiOperation`, `@ApiOkResponse` / `@ApiNoContentResponse` typed against response DTOs.
- **HTTP semantics respected** — Token registration is `POST /fcm-token` 204; token clear is `DELETE /fcm-token` 204; preference update remains `PATCH` to align with the existing controller in `UsersModule`.

## Scheduling

- **`@nestjs/schedule` cron declarations** — Use `CronExpression.EVERY_HOUR` / `EVERY_DAY_AT_9AM` constants where available; raw cron string only for the monthly job (`'0 9 1 * *'`) which has no constant.
- **Per-job log line** — Every cron run emits `LOG: <type>: scanned=N sent=M` so frequency and effectiveness are auditable from the boot log.
- **Idempotency in cron is mandatory** — Every cron sets `idempotencySince` to the appropriate window (last 23h for hourly DAILY, last 24h for daily CHALLENGE, month-start for monthly PREDICTION). Without this, restarts or clock skew would double-send.

## Frontend (Flutter + Riverpod)

- **`AsyncNotifier` not raw `FutureProvider`** — `NotificationsInboxNotifier` exposes `refresh`, `markRead`, and `markAllRead` as imperative methods; the UI calls them and the state stream re-renders. Matches the project's existing pattern in `dashboard_providers`.
- **No `setState` for cross-screen state** — The unread badge consumes `unreadNotificationsCountProvider` (a `Provider<int>` derived from the AsyncValue). The dashboard bell rebuilds via `ref.watch`, never via callback.
- **Auto-sync side effects in `App` via `ref.listen`** — Auth state transitions trigger FCM token register / unregister. The widget is a `ConsumerStatefulWidget` so the listener can subscribe once in `initState` (FCM tap stream) and use `ref.listen` for declarative reactions (auth state).
- **Provider overrides for eagerly-initialised singletons** — `FcmService` is constructed and `await initialize()`'d in `main` before `runApp`, then injected via `fcmServiceProvider.overrideWithValue(fcm)`. Avoids the race where `Firebase.initializeApp` would otherwise lazy-fire on first `ref.read`.
- **All UI strings in Spanish in `build`** — Notification titles, bodies, the bell tooltip, "Marcar todas como leídas", "No tienes notificaciones", "Hace 2 h", etc. Per the project rule that user-facing strings are Spanish-only and locale is forced to `es`.

## Cross-cutting

- **Graceful degradation, not exceptions, for missing config** — Missing `FCM_PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY` produces a single warn at boot; `FcmService.sendToToken` returns `{ skipped: true }`. The system keeps working with the inbox alone.
- **Placeholders detected** — `FcmService.tryInit` compares against the documented placeholder strings from `.env.example` so a developer who clones the repo and runs without filling values does not get cryptic Firebase errors.
- **Documented exceptions** — Two intentional DDD violations (`PrismaBadgeRepository` cross-layer DI, `NotificationsScheduleService` direct Prisma) are marked with an inline rationale and an "Alternative considered" note in `shape.md`.
