# References: Phase 11 — Notifications and Alerts

## Key Files

### Backend (`zenda_backend_app`)

| File | Change |
|------|--------|
| `prisma/schema.prisma` | Added `Notification` model + indexes; added `User.fcmToken`, `User.dailyReminderAt` |
| `prisma/migrations/20260604023629_add_notifications_inbox_and_fcm_token/migration.sql` | Generated migration (also reconciled drift for `AiConversation`/`AiMessage`) |
| `package.json` / `package-lock.json` | `@nestjs/schedule`, `firebase-admin` |
| `src/app.module.ts` | Wired `ScheduleModule.forRoot()`, `FcmModule`, `NotificationsModule` |
| `src/shared/config/configuration.ts` | Added `fcm: { projectId, clientEmail, privateKey }` |
| `src/infra/fcm/fcm.service.ts` | New — `firebase-admin` wrapper with graceful no-op |
| `src/infra/fcm/fcm.module.ts` | New — `@Global()` module exporting `FcmService` |
| `src/modules/notifications/domain/notification.entity.ts` | New — pure TS entity + `NotificationKind` union |
| `src/modules/notifications/domain/ports/notification.repository.ts` | New — `INotificationRepository` port |
| `src/modules/notifications/domain/ports/notification-user.port.ts` | New — `INotificationUserPort` port |
| `src/modules/notifications/application/use-cases/send-notification.use-case.ts` | New — central dispatch gateway |
| `src/modules/notifications/application/use-cases/list-inbox.use-case.ts` | New |
| `src/modules/notifications/application/use-cases/mark-read.use-case.ts` | New |
| `src/modules/notifications/application/use-cases/register-fcm-token.use-case.ts` | New |
| `src/modules/notifications/infrastructure/persistence/prisma-notification.repository.ts` | New — Prisma adapter |
| `src/modules/notifications/infrastructure/persistence/prisma-notification-user.adapter.ts` | New — reads `User.fcmToken` + `notificationPrefs` JSON |
| `src/modules/notifications/interface/dto/notification.response.dto.ts` | New |
| `src/modules/notifications/interface/dto/register-fcm-token.dto.ts` | New |
| `src/modules/notifications/interface/notifications-inbox.controller.ts` | New — 6 routes |
| `src/modules/notifications/schedule/notifications-schedule.service.ts` | New — 3 `@Cron` jobs |
| `src/modules/notifications/notifications.module.ts` | New — exports `SendNotificationUseCase` |
| `src/modules/budgets/domain/ports/budget.repository.ts` | Added `findForCategoryAndPeriod` |
| `src/modules/budgets/infrastructure/persistence/prisma-budgets.repository.ts` | Implemented `findForCategoryAndPeriod` |
| `src/modules/budgets/application/budgets.facade.ts` | New — `BudgetsFacade.getSnapshotForCategory` |
| `src/modules/budgets/budgets.module.ts` | Exports `BudgetsFacade` |
| `src/modules/badges/badges.module.ts` | Imports `NotificationsModule` |
| `src/modules/badges/infrastructure/persistence/prisma-badge.repository.ts` | Injects `SendNotificationUseCase`; fires `BADGE_EARNED` after insert |
| `src/modules/transactions/transactions.module.ts` | Imports `BudgetsModule` + `NotificationsModule` |
| `src/modules/transactions/interface/transactions.controller.ts` | Dispatches `ANOMALY_ALERT` + `BUDGET_ALERT` after create (monthly idempotency) |

### Frontend (`zenda_fronted_app`)

| File | Change |
|------|--------|
| `pubspec.yaml` | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| `android/settings.gradle.kts` | `com.google.gms.google-services` 4.4.2 plugin (apply false) |
| `android/app/build.gradle.kts` | Applies the google-services plugin |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` permission |
| `lib/main.dart` | Eager `Firebase.initializeApp` + override `fcmServiceProvider` |
| `lib/app.dart` | Converted to `ConsumerStatefulWidget`; auth listener; tap-stream listener |
| `lib/core/models/notification.dart` | New — `AppNotification` + `NotificationInboxPage` |
| `lib/core/services/user_api_service.dart` | Extended `NotificationsApiService` with inbox + FCM token methods |
| `lib/core/services/fcm_service.dart` | New — Firebase init, permission, listeners, local notifications channel |
| `lib/providers/repositories_providers.dart` | `fcmServiceProvider` |
| `lib/features/notifications/notifications_inbox_providers.dart` | New — `AsyncNotifier` + unread count Provider |
| `lib/features/notifications/notification_bell_icon.dart` | New — reusable AppBar action with badge |
| `lib/features/notifications/notifications_inbox_screen.dart` | New — inbox UI |
| `lib/features/dashboard/dashboard_screen.dart` | Replaced hand-rolled bell with `_DashboardBell` (inbox + unread badge) |
| `lib/routing/app_router.dart` | Added `/notifications/inbox` route |

## Test Files

No test files were created in this phase. Test coverage gap is tracked under Phase 14 (Testing).

## Standards Applied

- `skills/platform/platform-backend/domain-driven-design-nestjs/SKILL.md` — bounded-context structure (`domain` / `application` / `infrastructure` / `interface` + `schedule`), abstract-class ports, module-level facade export. Two documented exceptions (cross-layer DI for badge notification and direct Prisma in scheduler) are called out in `shape.md`.
- `skills/_drafts/framework/tech-prisma/SKILL.md` — `Decimal` not relevant (no money on notification), repository ownership of `Notification`, soft-delete intentionally skipped for append-only history.
- `skills/platform/platform-backend/SKILL.md` — guard clauses (preference / idempotency / token-presence) at the top of `SendNotificationUseCase.execute`, no swallowed errors except the documented fire-and-forget paths.
- `skills/universal/lang-typescript/SKILL.md` — no `any`, no type assertions; `NotificationKind` is a string union, JSON parsed via type guards.
- `skills/platform/platform-mobile/flutter/SKILLS.md` — `AsyncNotifier` for shared state, `ref.listen` for side effects, Spanish-only user strings.
- `skills/assistant/pre-work-audit/SKILL.md` — Pre-audit and post-audit run on backend (`tsc --noEmit` + `prisma validate` clean both times). Frontend audit deferred because no Flutter SDK is installed in this environment; user must run `flutter analyze` after their setup.

## Live verification

End-to-end behaviour verified beyond `tsc`:

- `npx prisma migrate dev` applied the schema migration cleanly against Postgres in Docker.
- `npm run start:dev` booted with `Nest application successfully started` and emitted the expected `WARN [FcmService] FCM not configured` (graceful degradation path active).
- `RouterExplorer` log lines confirm all 6 inbox routes mapped under `/api/notifications`; coexist with the pre-existing `/api/notifications/preferences[/:type]` from `UsersModule.NotificationsController`.
- `Invoke-WebRequest` probes return HTTP 401 (without JWT) on every new endpoint → guard active, no route mismatch.

## Open follow-ups

- `flutter analyze` and `flutter pub get` must be run after the user installs the Flutter SDK locally.
- Firebase Console: create project, register Android app `com.zenda.zenda_fronted`, drop `google-services.json` into `zenda_fronted_app/android/app/`, generate service-account JSON and populate `FCM_PROJECT_ID` / `FCM_CLIENT_EMAIL` / `FCM_PRIVATE_KEY` in `zenda_backend_app/.env`.
- iOS push not configured (Apple Developer Account required for APNS); documented as out-of-pilot scope.
- Spending alert UI banner in the response of `POST /transactions` still co-exists with the new inbox-side `ANOMALY_ALERT`; can be removed in a later cleanup once the frontend reads the alert from the inbox instead of the response payload.
- ERD docs (`docs/zenda-erd.dbml`, `docs/zenda-erd-conceptual.dbml`, `docs/zenda-schema.sql`) should be regenerated to reflect the new `Notification` table and `User` columns.
