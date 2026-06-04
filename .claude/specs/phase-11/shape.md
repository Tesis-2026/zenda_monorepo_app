# Shape: Phase 11 — Notifications and Alerts

## Decisions

- **Persistent inbox first, push best-effort** — Every notification is `INSERT`ed into `Notification` before FCM is attempted. Push failure does not block; the user still sees the alert when they next open the app. Alternative considered: push-only with no inbox. Rejected because thesis demo needs notifications to remain visible when the jury opens the app days after they fire, and because FCM has no delivery guarantee.

- **Single dispatch gateway (`SendNotificationUseCase`)** — Every trigger (3 crons + 3 event hooks) calls the same use case, which centralises preference filtering, idempotency, FCM dispatch, and inbox writing. Alternative considered: per-type services. Rejected because it would duplicate the three gates (preference / idempotency / FCM) six times and let them drift.

- **Idempotency by `(userId, type, createdAt >= since, data->>key == value)` query at send time** — No separate "dedup ledger" table. Alternative considered: a dedicated `NotificationDedupKey` table. Rejected as over-engineering for thesis volume; the existing inbox already records every dispatch, so checking against it is cheap (uses `(userId, createdAt)` index) and naturally expires when the calling cron advances its window.

- **No `NotificationPreference` table — `User.notificationPrefs` JSON column** — Inherited from Tier-A normalisation (2026-05-15). Phase 11 reads from this JSON via `INotificationUserPort.isEnabled` and `listEligibleUsers`. Alternative considered: re-introduce the table. Rejected because preferences are 6 booleans per user and JSON is sufficient.

- **`fcmToken` as a single column on `User`** — Single-device model. Alternative considered: separate `FcmToken` table for multi-device. Rejected because thesis pilot uses ≤30 users on one device each; multi-device is post-thesis scope and easy to migrate to later (move column → table).

- **Cron jobs query directly via `PrismaService` in `NotificationsScheduleService`** — Documented exception to the DDD inward-pointing rule. The scheduler aggregates across `Transaction`, `UserChallenge`, and `Prediction`; wrapping each in a port would triple the surface area for ~30 lines of query. Alternative considered: a `INotificationsCronQueryPort`. Rejected as premature abstraction; revisit if the scheduler grows past three queries.

- **`PrismaBadgeRepository` injects `SendNotificationUseCase`** — Pragmatic cross-layer DI: infrastructure layer calls an application use case from another module. Alternative considered: change the port signature to return `{ awarded: boolean }` and update all 8 callers. Rejected because most callers discard the return value already and there is no behavioural reason for them to start handling badge notifications individually. Documented exception in the file.

- **Two controllers share the `/api/notifications` prefix** — `NotificationsController` (in `UsersModule`, owns `/preferences/*`) and `NotificationsInboxController` (in `NotificationsModule`, owns `/inbox`, `/:id/read`, `/read-all`, `/fcm-token`, `/daily-reminder-time`). Verified at runtime: no route collision because path segments are mutually exclusive. Alternative considered: move preferences into `NotificationsModule`. Rejected to avoid undoing B13's recent refactor; the preferences write to `User.notificationPrefs` which is semantically owned by `UsersModule`.

- **Dashboard bell points at the inbox, not at preferences** — UX inversion: users open the bell to read notifications, not to configure them. Preferences remain reachable via `Settings → Notificaciones`. Alternative considered: split into two icons (bell + cog). Rejected as visual clutter.

- **Foreground messages rendered via `flutter_local_notifications`** — FCM does not auto-display when the app is foreground. Without `flutter_local_notifications`, users would only see the in-app inbox update, not a system-tray banner. Alternative considered: in-app snackbar only. Rejected because a banner is the expected behaviour from other apps and matches the post-background experience.

- **Graceful no-op when FCM credentials are missing** — `FcmService.tryInit` detects empty / placeholder values and emits a single warn at boot; `sendToToken` returns `{ delivered: false, skipped: true }`. Inbox path is unaffected. Alternative considered: refuse to boot. Rejected because demo / dev environments often lack Firebase, and the inbox alone is defensible for thesis.

## Constraints

- **One notification per `(user, type)` per logical period** — enforced by `INotificationRepository.existsRecent` query in `SendNotificationUseCase` (uses `Notification_userId_createdAt_idx`). Window/scope per trigger documented in `spec.md`.

- **Every dispatched notification appears in the inbox** — enforced by always calling `repo.create` after the FCM attempt, regardless of FCM result.

- **Token invalidation clears `User.fcmToken`** — enforced in `SendNotificationUseCase` when `FcmService.sendToToken` returns `{ tokenInvalid: true }` for FCM error codes `messaging/registration-token-not-registered`, `messaging/invalid-registration-token`, or `messaging/invalid-argument`. Prevents repeated push failures against a stale token.

- **Notification dispatch never aborts the originating transaction** — enforced by `.catch(() => null)` wrappers around `sendNotification.execute` in `TransactionsController.create` and by fire-and-forget `Promise.catch` in `PrismaBadgeRepository.awardIfNotEarned`. Failing to send must not roll back a transaction or a badge grant.

- **`dailyReminderAt` validated as `HH:mm`** — enforced by `class-validator` `@Matches(/^([01]\d|2[0-3]):[0-5]\d$/)` on `SetDailyReminderTimeDto`.

- **FCM token bounded length** — enforced by `@MinLength(10) @MaxLength(4096)` on `RegisterFcmTokenDto.token`.

- **JWT required on every notification endpoint** — enforced by `@UseGuards(JwtAuthGuard)` at the controller level.

- **Inbox queries filter by `userId`** — enforced in `PrismaNotificationRepository.findRecent` / `countUnread` / `markRead`. No cross-user access path exists.
