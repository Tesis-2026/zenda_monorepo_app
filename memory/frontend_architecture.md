---
name: Frontend Architecture
description: Flutter frontend screens, providers, routing, API services, known issues
type: project
---

## Stack
Flutter 3.10+, Dart 3.10+, Riverpod 3, GoRouter 17, fl_chart 1.1, google_fonts, http, flutter_secure_storage, shared_preferences, connectivity_plus, share_plus

## Routing (GoRouter — `lib/routing/app_router.dart`)
~30 routes. Key redirect logic:
- Unauthenticated → `/auth/login`
- Profile incomplete → `/profile-setup`
- Pre-survey not done → `/surveys/pre`
- Otherwise → `/dashboard`

## State Management (Riverpod)
- `authNotifierProvider` — auth state, login/register/logout
- `newTransactionControllerProvider` — transaction creation with validation + alerts
- Dashboard providers: `daySummaryProvider`, `weekSummaryProvider`, `monthSummaryProvider`, `accountsProvider`, `streakStateProvider`, `budgetBreakdownProvider`, `recommendationsProvider`, `aiAdviceProvider`
- Repository providers in `lib/providers/repositories_providers.dart`
- `localeProvider`, `currencyProvider`, `preSurveyProvider`

## API Client (`lib/core/services/api_client.dart`)
- **CRITICAL BUG: Merge conflict in base URL (lines 8-16)** — needs resolution before real API calls work
- Base URL: `http://localhost:3000/api` (localhost dev) / ngrok (remote)
- JWT Bearer auth, auto-refresh on 401, session expiry stream
- Services: AuthApiService, UserApiService, TransactionApiService, CategoryApiService, BudgetApiService, GoalsApiService, InsightsApiService, EducationApiService, SurveysApiService, PredictionsApiService, RecommendationsApiService, QuizApiService, ProgressApiService

## Offline Support
- `SyncService` — listens to connectivity, retries pending transactions (exponential backoff, max 3 retries)
- `PendingTransactionQueue` — persisted via SharedPreferences
- Local repositories (SharedPreferences) as primary data store, API as sync target

## Screen Inventory (all implemented, some stubs)
Auth: Login, Register, ForgotPassword, VerifyCode (OTP), ResetPassword, EmailSent, ResetSuccess
Onboarding: SplashDecider, OnboardingScreen, ProfileSetupScreen, ConsentScreen
Main: Dashboard, Transactions, AddTransaction, Budget, Goals+GoalDetail, Reports, Categories
Advanced: Predictions, Recommendations, Progress, Challenges, Badges, AiChat, NotificationPreferences, Settings
Education: EducationScreen, TopicDetail, QuizScreen, PersonalizedQuiz
Surveys: SurveyScreen (Pre/Post), SurveyComparison, SusScreen

## Models
User, Account (cash/debit/credit), TransactionModel, TransactionCategory (enum, kept in Spanish for serialization), Bucket503020 (necesidad/deseo/ahorro), Budget, CategoryModel, SavingsGoal, GoalContribution, StreakState, PeriodSummary, ProgressSummary, MonthComparisonEntry, BudgetBreakdown503020

## Demo Mode
`_kDemoMode` flag in `lib/main.dart` — when true, uses mock services instead of real API. Must be set to `false` for real usage.

## Known Issues
1. **Merge conflict in `lib/core/services/api_client.dart` (lines 8-16)** — BLOCKING real API usage
2. OCR integration (image_picker imported) not fully wired
3. Voice transaction (enum exists) has no UI
4. No pagination in transaction/goal lists
5. Static category cache in TransactionApiService (no invalidation)
6. No test files
7. Some hardcoded demo data (AI chat welcome message)
