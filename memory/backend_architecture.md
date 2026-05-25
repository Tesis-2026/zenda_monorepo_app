---
name: Backend Architecture
description: NestJS backend modules, Prisma data model, full API surface, implemented features, and known gaps
type: project
---

## Stack
NestJS 11, Prisma 6, PostgreSQL 15, JWT (15m access / 7d refresh), bcrypt (12 rounds), Nodemailer, PDFKit, Azure OpenAI GPT-4o-mini (with LocalRulesProvider fallback), Helmet, Throttler.

## Module Inventory (14 modules)
1. **auth** — Register, Login (lockout after 3 fails), Refresh, Logout, OTP, Forgot/Reset Password
2. **users** — Profile CRUD, Account deletion, Notification preferences
3. **transactions** — CRUD + filters, Anomaly detection (>20% over 3-month avg), Badge/challenge triggers, AI classify
4. **categories** — System + custom categories, CRUD
5. **budgets** — Per-user/category/period, unique constraint, real-time spending %
6. **goals** — Savings goals + contributions + completion + badge award
7. **insights** — Day/week/month summaries, comparison, progress, PDF export (PDFKit)
8. **predictions** — Azure GPT-4o-mini next-month expense forecast with confidence intervals
9. **recommendations** — AI-generated + feedback loop
10. **education** — Topics, quizzes (bilingual EN/ES), personalized quiz (AI, max 5/day), surveys (PRE/POST/SUS)
11. **badges** — System badges, user earning, gamification
12. **challenges** — Status machine AVAILABLE→ACTIVE→COMPLETED, auto-completion on transaction events
13. **analytics** — Fire-and-forget event tracking (AnalyticsEvent table)
14. **health** — GET /api/health

## Infrastructure Layer
- `src/infra/prisma/` — PrismaModule (global)
- `src/infra/ai/` — AiModule with `AI_PROVIDER` token; swappable Azure vs LocalRules
- `src/infra/email/` — EmailService (Nodemailer, SMTP)
- `src/infra/analytics/` — AnalyticsService (fire-and-forget)
- `src/infra/spending-alert/` — SpendingAlertService (anomaly detection)

## Key Data Models
- User (auth, profile, lockout state, Law 29733 consent)
- Transaction (income/expense, category, soft-delete)
- Category (system vs custom, per-user)
- Budget (per-user/category/month/year, unique)
- SavingsGoal + GoalContribution
- Badge + UserBadge
- Challenge + UserChallenge
- EducationalTopic + QuizQuestion + UserTopicProgress
- Prediction + Recommendation + RecommendationFeedback
- Survey + SurveyQuestion + SurveyResponse
- AnalyticsEvent + AuditLog + Feedback
- RefreshToken + PasswordResetToken + PasswordResetOtp
- NotificationPreference

## API Surface (~53 endpoints)
Auth (8), Users (4), Transactions (6), Categories (4), Budgets (4), Goals (6), Insights (6), Predictions (1), Recommendations (3), Education (7+), Badges (1), Challenges (3)

## Clean Architecture Pattern
Each module: `interface/` (controllers, DTOs) → `application/` (use-cases) → `domain/` (entities, ports) → `infrastructure/persistence/` (Prisma repos)

## Known Gaps
- No test files (`.spec.ts`) anywhere in `src/`
- Push notifications (FCM) config present but not implemented
- Surveys controllers implied but full wiring unclear
- Chat endpoint exists in recommendations but implementation detail unclear
