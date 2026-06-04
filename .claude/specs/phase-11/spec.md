# Phase 11: Notifications and Alerts

## Context

Before this phase, Zenda had only a `NotificationType` enum (6 values) and a `notificationPrefs` JSON column on `User` for on/off toggles. There was **no persistent inbox**, **no FCM integration**, **no scheduled or event-driven dispatch**, and **no UI to view notification history**. The compliance plan tracked this as Phase 11 (Notifications, 0%) and as `GAP-01` in `docs/audit-issues.md`.

User stories addressed:

- **US-016** — AI anomaly alert when category spending exceeds >20% of the 3-month average. Calculation already existed in `SpendingAlertService` and was returned in the POST `/transactions` response, but did not produce a persistent notification or push.
- **US-020** — Budget 80% threshold notification when a transaction crosses the limit. Neither the cross-detection nor the alert dispatch existed before.
- Implicit US for `BADGE_EARNED`, `CHALLENGE_REMINDER`, `DAILY_REMINDER`, `PREDICTION_READY` — documented in the roadmap but never built.

## Tasks Completed

### Backend (`zenda_backend_app`)

1. `prisma/schema.prisma` — added `Notification` model (id, userId, type, title, body, data, readAt, sentAt, createdAt) + indexes `(userId, createdAt)` and `(userId, readAt)`; added `User.fcmToken` and `User.dailyReminderAt`.
2. `prisma/migrations/20260604023629_add_notifications_inbox_and_fcm_token/migration.sql` — applied (also reconciled drift for `AiConversation`/`AiMessage` tables that were in schema but not in DB).
3. `src/infra/fcm/fcm.service.ts` + `fcm.module.ts` — `firebase-admin` wrapper. Lazy init from `FCM_PROJECT_ID` + `FCM_CLIENT_EMAIL` + `FCM_PRIVATE_KEY` env vars; **graceful no-op when not configured** (warn + skip push, inbox still works); detects placeholder values; clears tokens on `messaging/invalid-registration-token`.
4. `src/modules/notifications/` — new DDD bounded context:
   - `domain/notification.entity.ts` + `NotificationKind` union
   - `domain/ports/notification.repository.ts` (`INotificationRepository`)
   - `domain/ports/notification-user.port.ts` (`INotificationUserPort` — read prefs, get/set fcmToken, list eligible users for cron)
   - `application/use-cases/send-notification.use-case.ts` — gateway through preference check + idempotency check + FCM dispatch + inbox row
   - `application/use-cases/list-inbox.use-case.ts`
   - `application/use-cases/mark-read.use-case.ts`
   - `application/use-cases/register-fcm-token.use-case.ts`
   - `infrastructure/persistence/prisma-notification.repository.ts`
   - `infrastructure/persistence/prisma-notification-user.adapter.ts`
   - `interface/notifications-inbox.controller.ts` + 2 DTOs
   - `schedule/notifications-schedule.service.ts` — 3 `@Cron` jobs (DAILY hourly, CHALLENGE daily 9 AM, PREDICTION monthly day-1 9 AM)
   - `notifications.module.ts` (exports `SendNotificationUseCase` for cross-module event hooks)
5. `src/app.module.ts` — wires `ScheduleModule.forRoot()` + `FcmModule` + `NotificationsModule`.
6. `src/shared/config/configuration.ts` — added `fcm: { projectId, clientEmail, privateKey }` (key newline-unescaped at read time).
7. `src/modules/badges/badges.module.ts` + `infrastructure/persistence/prisma-badge.repository.ts` — `BadgesModule` imports `NotificationsModule`; `PrismaBadgeRepository` injects `SendNotificationUseCase` and fires `BADGE_EARNED` after `awardIfNotEarned` grants a new row (fire-and-forget, swallows on error). Documented cross-layer DI exception.
8. `src/modules/budgets/domain/ports/budget.repository.ts` — added `findForCategoryAndPeriod(userId, categoryId, month, year)`.
9. `src/modules/budgets/infrastructure/persistence/prisma-budgets.repository.ts` — implemented above.
10. `src/modules/budgets/application/budgets.facade.ts` — new `BudgetsFacade.getSnapshotForCategory(userId, categoryId, occurredAt)` returning `{ budgetId, categoryName, amountLimit, currentSpent, percentageUsed }` or null. Exported from `BudgetsModule`.
11. `src/modules/transactions/transactions.module.ts` — imports `BudgetsModule` + `NotificationsModule`.
12. `src/modules/transactions/interface/transactions.controller.ts` — after the existing anomaly check, dispatches `ANOMALY_ALERT` and `BUDGET_ALERT` via `SendNotificationUseCase` with monthly idempotency keyed on `categoryId` / `budgetId`. Fire-and-forget; failure does not roll back the transaction.

### Frontend (`zenda_fronted_app`)

1. `pubspec.yaml` — `firebase_core ^3.6.0`, `firebase_messaging ^15.1.3`, `flutter_local_notifications ^18.0.1`.
2. `android/settings.gradle.kts` + `android/app/build.gradle.kts` — `com.google.gms.google-services` 4.4.2 plugin.
3. `android/app/src/main/AndroidManifest.xml` — `POST_NOTIFICATIONS` permission (Android 13+).
4. `lib/core/models/notification.dart` — `AppNotification` + `NotificationInboxPage`.
5. `lib/core/services/user_api_service.dart` — extended `NotificationsApiService` with `getInbox`, `markRead`, `markAllRead`, `registerFcmToken`, `unregisterFcmToken`, `setDailyReminderTime`. Token registration uses `authenticated: true`.
6. `lib/core/services/fcm_service.dart` — `Firebase.initializeApp` + permission + background handler + foreground handler (renders via `flutter_local_notifications` because FCM does not auto-display while app is foreground) + tap stream + token refresh listener.
7. `lib/main.dart` — eager Firebase init before `runApp`; overrides `fcmServiceProvider` with the initialized instance.
8. `lib/app.dart` — converted to `ConsumerStatefulWidget`. Auth listener triggers `registerWithBackend` on authenticate / `unregisterFromBackend` on logout. Tap-stream subscriber navigates to `/notifications/inbox` and invalidates the inbox provider.
9. `lib/providers/repositories_providers.dart` — `fcmServiceProvider`.
10. `lib/features/notifications/notifications_inbox_providers.dart` — `notificationsInboxProvider` + `unreadNotificationsCountProvider`.
11. `lib/features/notifications/notification_bell_icon.dart` — reusable AppBar action.
12. `lib/features/notifications/notifications_inbox_screen.dart` — list, pull-to-refresh, mark-all, type-coloured cards, relative-time labels.
13. `lib/features/dashboard/dashboard_screen.dart` — replaced the hand-rolled bell that pointed at `/notifications` (preferences) with `_DashboardBell` that points at `/notifications/inbox` and shows an unread badge.
14. `lib/routing/app_router.dart` — `/notifications/inbox` route.

## What Was Built

### Notification (US-016, US-020, BADGE_EARNED, DAILY/CHALLENGE/PREDICTION)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | PK |
| `userId` | UUID | FK to User, cascade delete |
| `type` | NotificationType | Existing enum, 6 values |
| `title` | String | User-visible heading |
| `body` | String | User-visible body |
| `data` | JSON | Routing payload (e.g. `{ budgetId, categoryName }`) |
| `readAt` | DateTime? | Null = unread |
| `sentAt` | DateTime? | Set when FCM delivered successfully |
| `createdAt` | DateTime | Auto |

Indexes: `(userId, createdAt DESC)` for inbox listing; `(userId, readAt)` for unread count.

### Dispatch pipeline

```
TRIGGER (cron @hour | event hook)
    ↓
SendNotificationUseCase.execute(cmd)
    ↓
[gate 1] preference check ── off ─→ return { skippedReason: 'preference-off' }
    ↓
[gate 2] idempotency check ── dup ─→ return { skippedReason: 'duplicate' }
    ↓
[gate 3] fetch user.fcmToken
    ↓
FCM send (best-effort)
    ├─ delivered ──────→ sentAt = now
    ├─ tokenInvalid ───→ clear user.fcmToken, sentAt = null
    └─ skipped (FCM unconfigured) → sentAt = null
    ↓
INSERT into Notification (always; inbox is the source of truth)
```

### Triggers

| Type | Source | Cadence | Idempotency window | Idempotency scope |
|------|--------|---------|--------------------|--------------------|
| `BUDGET_ALERT` | `POST /transactions` (EXPENSE w/ category) when `Budget.percentageUsed >= 80` | event | first day of month → now | `budgetId` |
| `ANOMALY_ALERT` | `POST /transactions` when `SpendingAlertService.checkAnomaly()` returns non-null | event | first day of month → now | `categoryId` |
| `BADGE_EARNED` | `PrismaBadgeRepository.awardIfNotEarned` after successful insert | event | — (UserBadge unique already prevents dupes) | — |
| `DAILY_REMINDER` | `@Cron(EVERY_HOUR)` | hourly | last 23h | — |
| `CHALLENGE_REMINDER` | `@Cron(EVERY_DAY_AT_9AM)` | daily | last 24h | `challengeId` |
| `PREDICTION_READY` | `@Cron('0 9 1 * *')` | monthly day 1 | first day of month → now | — |

### Cron preference filtering

- `DAILY_REMINDER` only fires for users whose `dailyReminderAt` equals the current hour (or `null` and current is 20:00 default) AND who have not registered an EXPENSE/INCOME transaction so far today.
- `CHALLENGE_REMINDER` only fires for active user challenges (`acceptedAt != null AND completedAt == null`) whose derived expiry (`acceptedAt + criteriaJson.durationDays|periodDays`) is in the next 48h.
- `PREDICTION_READY` only fires for users with at least 10 EXPENSE rows from before the current month.

### REST endpoints

| Verb | Path | Auth | Purpose |
|------|------|------|---------|
| GET | `/api/notifications/inbox?limit&unreadOnly` | JWT | List + unread count |
| PATCH | `/api/notifications/:id/read` | JWT | Mark one read |
| PATCH | `/api/notifications/read-all` | JWT | Mark every unread read |
| POST | `/api/notifications/fcm-token` | JWT | Register device token |
| DELETE | `/api/notifications/fcm-token` | JWT | Clear token (on logout) |
| PATCH | `/api/notifications/daily-reminder-time` | JWT | Set HH:mm for `DAILY_REMINDER` |

Coexists with the existing `NotificationsController` (in `UsersModule`) that serves `/api/notifications/preferences[/:type]`. The two controllers share the `/api/notifications` prefix without conflict because path segments diverge.

### Flutter UX

- Dashboard bell now points at `/notifications/inbox` and renders a red badge with the unread count (`1`…`9`, `9+`, hidden when 0). The preferences screen remains accessible from Settings.
- `NotificationsInboxScreen` lists notifications newest-first with per-type colour accents, unread dot/border emphasis, pull-to-refresh, and a "mark all" action in the AppBar.
- Tap a card → marks read (badge decrements) and refreshes the inbox state.
- Foreground FCM messages are rendered as native system notifications via `flutter_local_notifications` on channel `zenda_default` (HIGH importance). Tapping any system notification — whether arrived in foreground, background, or terminated state — pushes `/notifications/inbox` and invalidates the inbox provider so the new row appears immediately.
