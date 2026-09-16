# Inventario AST de rutas y DTO

Generado sin arrancar la app ni leer secretos. Guards globales, pipes e interceptores se revisan por separado. `inferred` requiere leer el mapper/servicio.

| Metodo | Ruta | Handler | Entrada | Salida | Archivo:linea |
| --- | --- | --- | --- | --- | --- |
| GET | /api/live | HealthController.live |  | HealthResponseDto | zenda_backend_app/src/health/health.controller.ts:22 |
| GET | /api/ready | HealthController.ready |  | Promise<HealthResponseDto> | zenda_backend_app/src/health/health.controller.ts:38 |
| GET | /api/health | HealthController.health |  | Promise<HealthResponseDto> | zenda_backend_app/src/health/health.controller.ts:52 |
| POST | /api/analytics/events | AnalyticsController.track | UserId string; Body TrackAnalyticsEventDto | Promise<{ accepted: true }> | zenda_backend_app/src/infra/analytics/analytics.controller.ts:31 |
| GET | /api/accounts | AccountsController.list | UserId string | Promise<AccountResponseDto[]> | zenda_backend_app/src/modules/accounts/interface/accounts.controller.ts:19 |
| POST | /api/accounts | AccountsController.create | UserId string; Body CreateAccountDto | Promise<AccountResponseDto> | zenda_backend_app/src/modules/accounts/interface/accounts.controller.ts:27 |
| POST | /api/accounts/transfer | AccountsController.transfer | UserId string; Body TransferAccountsDto | inferred | zenda_backend_app/src/modules/accounts/interface/accounts.controller.ts:39 |
| GET | /api/accounts/report | AccountsController.report | UserId string; Query string; Query string | Promise<AccountReportResponseDto> | zenda_backend_app/src/modules/accounts/interface/accounts.controller.ts:48 |
| POST | /api/auth/register | AuthController.register | Body RegisterDto; Req Request | Promise<RegisterPendingVerificationResponseDto> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:66 |
| POST | /api/auth/login | AuthController.login | Body LoginDto | Promise<AuthTokenResponseDto> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:94 |
| POST | /api/auth/refresh | AuthController.refresh | Body RefreshTokenDto | Promise<AuthTokenResponseDto> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:113 |
| POST | /api/auth/logout | AuthController.logout | UserId string | Promise<void> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:125 |
| POST | /api/auth/forgot-password | AuthController.forgotPassword | Body ForgotPasswordDto | Promise<void> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:136 |
| POST | /api/auth/send-otp | AuthController.sendOtp | Body SendOtpDto | Promise<void> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:147 |
| POST | /api/auth/verify-otp | AuthController.verifyOtp | Body VerifyOtpDto | Promise<{ resetToken: string }> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:158 |
| POST | /api/auth/verify-email | AuthController.verifyEmail | Body VerifyEmailDto | Promise<AuthTokenResponseDto> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:170 |
| POST | /api/auth/resend-verification | AuthController.resendVerification | Body SendOtpDto | Promise<void> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:185 |
| POST | /api/auth/reset-password | AuthController.resetPassword | Body ResetPasswordDto | Promise<void> | zenda_backend_app/src/modules/auth/interface/auth.controller.ts:196 |
| GET | /api/badges | BadgesController.list | UserId string | Promise<BadgeResponseDto[]> | zenda_backend_app/src/modules/badges/interface/badges.controller.ts:16 |
| POST | /api/budgets | BudgetsController.create | UserId string; Body CreateBudgetDto | Promise<BudgetResponseDto> | zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts:52 |
| GET | /api/budgets | BudgetsController.findAll | UserId string; Query ListBudgetsDto | Promise<BudgetResponseDto[]> | zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts:73 |
| PUT | /api/budgets/:id | BudgetsController.update | UserId string; Param string; Body UpdateBudgetDto | Promise<BudgetResponseDto> | zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts:89 |
| DELETE | /api/budgets/:id | BudgetsController.remove | UserId string; Param string | Promise<void> | zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts:109 |
| POST | /api/categories | CategoriesController.create | UserId string; Body CreateCategoryDto | Promise<CategoryResponseDto> | zenda_backend_app/src/modules/categories/interface/categories.controller.ts:47 |
| GET | /api/categories | CategoriesController.findAll | UserId string | Promise<CategoryResponseDto[]> | zenda_backend_app/src/modules/categories/interface/categories.controller.ts:61 |
| PUT | /api/categories/:id | CategoriesController.update | UserId string; Param string; Body UpdateCategoryDto | Promise<CategoryResponseDto> | zenda_backend_app/src/modules/categories/interface/categories.controller.ts:70 |
| DELETE | /api/categories/:id | CategoriesController.remove | UserId string; Param string | Promise<void> | zenda_backend_app/src/modules/categories/interface/categories.controller.ts:85 |
| GET | /api/challenges | ChallengesController.list | UserId string | Promise<ChallengeResponseDto[]> | zenda_backend_app/src/modules/challenges/interface/challenges.controller.ts:20 |
| POST | /api/challenges/:id/accept | ChallengesController.accept | Param string; UserId string | Promise<ChallengeResponseDto> | zenda_backend_app/src/modules/challenges/interface/challenges.controller.ts:29 |
| POST | /api/challenges/:id/complete | ChallengesController.complete | Param string; UserId string | Promise<ChallengeResponseDto> | zenda_backend_app/src/modules/challenges/interface/challenges.controller.ts:41 |
| GET | /api/ai/chat/active | ChatController.active | UserId string | Promise<ActiveConversationResponseDto> | zenda_backend_app/src/modules/conversations/interface/chat.controller.ts:55 |
| POST | /api/ai/chat | ChatController.send | UserId string; Body SendChatMessageDto | Promise<ChatReplyResponseDto> | zenda_backend_app/src/modules/conversations/interface/chat.controller.ts:71 |
| POST | /api/ai/chat/messages/:id/feedback | ChatController.feedback | UserId string; Param string; Body SubmitChatFeedbackDto | Promise<{ accepted: true }> | zenda_backend_app/src/modules/conversations/interface/chat.controller.ts:95 |
| POST | /api/ai/chat/close | ChatController.close | UserId string | Promise<void> | zenda_backend_app/src/modules/conversations/interface/chat.controller.ts:145 |
| GET | /api/education/topics | EducationController.list | UserId string | Promise<TopicResponseDto[]> | zenda_backend_app/src/modules/education/interface/education.controller.ts:36 |
| GET | /api/education/topics/:id | EducationController.detail | Param string; UserId string | Promise<TopicResponseDto> | zenda_backend_app/src/modules/education/interface/education.controller.ts:45 |
| PATCH | /api/education/topics/:id/complete | EducationController.complete | Param string; UserId string | Promise<void> | zenda_backend_app/src/modules/education/interface/education.controller.ts:57 |
| PATCH | /api/education/topics/:id/read | EducationController.read | Param string; UserId string | Promise<void> | zenda_backend_app/src/modules/education/interface/education.controller.ts:67 |
| GET | /api/education/topics/:id/quiz | EducationController.quiz | Param string; Query inferred | Promise<QuizResponseDto> | zenda_backend_app/src/modules/education/interface/education.controller.ts:77 |
| POST | /api/education/topics/:id/quiz/submit | EducationController.quizSubmit | Param string; UserId string; Body SubmitQuizDto | Promise<QuizSubmitResponseDto> | zenda_backend_app/src/modules/education/interface/education.controller.ts:89 |
| GET | /api/education/quiz/personalized | PersonalizedQuizController.personalized | UserId string; Query inferred | inferred | zenda_backend_app/src/modules/education/interface/education.controller.ts:127 |
| POST | /api/education/quiz/personalized/submit | PersonalizedQuizController.submitPersonalized | UserId string; Body SubmitQuizDto | Promise<QuizSubmitResponseDto> | zenda_backend_app/src/modules/education/interface/education.controller.ts:141 |
| GET | /api/education/learning-path/personalized | PersonalizedLearningPathController.personalized | UserId string; Query inferred | Promise<PersonalizedLearningPathResponseDto> | zenda_backend_app/src/modules/education/interface/education.controller.ts:167 |
| POST | /api/feedback | FeedbackController.create | UserId string; Body CreateFeedbackDto | Promise<FeedbackCreatedResponseDto> | zenda_backend_app/src/modules/feedback/interface/feedback.controller.ts:22 |
| GET | /api/financial-progress | FinancialProgressController.findAll | UserId string; Query ListProgressDto | Promise<FinancialProgressResponseDto[]> | zenda_backend_app/src/modules/financial-progress/interface/financial-progress.controller.ts:22 |
| GET | /api/financial-progress/current | FinancialProgressController.findCurrent | UserId string | Promise<FinancialProgressResponseDto> | zenda_backend_app/src/modules/financial-progress/interface/financial-progress.controller.ts:38 |
| POST | /api/goals | GoalsController.create | UserId string; Body CreateGoalDto | Promise<GoalResponseDto> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:58 |
| GET | /api/goals | GoalsController.findAll | UserId string | Promise<GoalResponseDto[]> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:73 |
| GET | /api/goals/:id/contributions | GoalsController.getContributions | UserId string; Param string | Promise<GoalContributionResponseDto[]> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:82 |
| POST | /api/goals/:id/contribute | GoalsController.contribute | UserId string; Param string; Body ContributeGoalDto | Promise<GoalResponseDto> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:95 |
| POST | /api/goals/:id/complete | GoalsController.complete | UserId string; Param string | Promise<GoalResponseDto> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:112 |
| PUT | /api/goals/:id | GoalsController.update | UserId string; Param string; Body UpdateGoalDto | Promise<GoalResponseDto> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:128 |
| DELETE | /api/goals/:id | GoalsController.remove | UserId string; Param string | Promise<void> | zenda_backend_app/src/modules/goals/interface/goals.controller.ts:145 |
| GET | /api/reports/export/pdf | ReportsController.exportPdf | UserId string; Query ReportRangeDto; Res Response | Promise<void> | zenda_backend_app/src/modules/insights/interface/reports.controller.ts:17 |
| GET | /api/summary/month | SummaryController.getMonth | UserId string; Query MonthSummaryDto | Promise<MonthSummaryResponseDto> | zenda_backend_app/src/modules/insights/interface/summary.controller.ts:43 |
| GET | /api/summary/week | SummaryController.getWeek | UserId string; Query WeekSummaryDto | Promise<MonthSummaryResponseDto> | zenda_backend_app/src/modules/insights/interface/summary.controller.ts:62 |
| GET | /api/summary/day | SummaryController.getDay | UserId string; Query DaySummaryDto | Promise<MonthSummaryResponseDto> | zenda_backend_app/src/modules/insights/interface/summary.controller.ts:78 |
| GET | /api/summary/comparison | SummaryController.getComparison | UserId string; Query ComparisonDto | Promise<MonthComparisonEntryDto[]> | zenda_backend_app/src/modules/insights/interface/summary.controller.ts:92 |
| GET | /api/summary/progress | SummaryController.getProgress | UserId string | Promise<ProgressResponseDto> | zenda_backend_app/src/modules/insights/interface/summary.controller.ts:104 |
| GET | /api/notifications/inbox | NotificationsInboxController.getInbox | UserId string; Query string; Query string | Promise<NotificationInboxResponseDto> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:47 |
| PATCH | /api/notifications/:id/read | NotificationsInboxController.markOneRead | UserId string; Param string | Promise<NotificationResponseDto> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:69 |
| PATCH | /api/notifications/read-all | NotificationsInboxController.markAll | UserId string | Promise<{ updated: number }> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:80 |
| POST | /api/notifications/fcm-token | NotificationsInboxController.registerToken | UserId string; Body RegisterFcmTokenDto | Promise<void> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:88 |
| DELETE | /api/notifications/fcm-token | NotificationsInboxController.clearToken | UserId string | Promise<void> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:99 |
| PATCH | /api/notifications/daily-reminder-time | NotificationsInboxController.setDailyReminderTime | UserId string; Body SetDailyReminderTimeDto | Promise<void> | zenda_backend_app/src/modules/notifications/interface/notifications-inbox.controller.ts:107 |
| GET | /api/predictions/expenses | PredictionsController.expenses | UserId string | Promise<PredictionResponseDto> | zenda_backend_app/src/modules/predictions/interface/predictions.controller.ts:42 |
| POST | /api/predictions/accuracy-check | PredictionsController.accuracyCheck | UserId string; Body AccuracyCheckDto | Promise<PredictionAccuracyResponseDto> | zenda_backend_app/src/modules/predictions/interface/predictions.controller.ts:53 |
| POST | /api/receipts/analyze | ReceiptsController.analyze | UploadedFile Express.Multer.File | Promise<ReceiptAnalyzeResponseDto> | zenda_backend_app/src/modules/receipts/interface/receipts.controller.ts:47 |
| GET | /api/recommendations | RecommendationsController.list | UserId string | Promise<RecommendationResponseDto[]> | zenda_backend_app/src/modules/recommendations/interface/recommendations.controller.ts:24 |
| GET | /api/recommendations/stats | RecommendationsController.stats | UserId string | Promise<RecommendationStatsResponseDto> | zenda_backend_app/src/modules/recommendations/interface/recommendations.controller.ts:33 |
| POST | /api/recommendations/:id/feedback | RecommendationsController.feedback | Param string; UserId string; Body FeedbackDto | Promise<void> | zenda_backend_app/src/modules/recommendations/interface/recommendations.controller.ts:41 |
| GET | /api/research-dashboard | ResearchDashboardController.view | Query ResearchDashboardQueryDto; Headers string | Promise<string> | zenda_backend_app/src/modules/research-dashboard/interface/research-dashboard.controller.ts:26 |
| GET | /api/research-dashboard/summary | ResearchDashboardController.summary | Query ResearchDashboardQueryDto; Headers string | Promise<ResearchDashboardData> | zenda_backend_app/src/modules/research-dashboard/interface/research-dashboard.controller.ts:41 |
| GET | /api/research-dashboard/export.json | ResearchDashboardController.exportJson | Query ResearchDashboardQueryDto; Headers string | Promise<ResearchDashboardData> | zenda_backend_app/src/modules/research-dashboard/interface/research-dashboard.controller.ts:54 |
| GET | /api/research-dashboard/export.csv | ResearchDashboardController.exportCsv | Query ResearchDashboardQueryDto; Headers string | Promise<string> | zenda_backend_app/src/modules/research-dashboard/interface/research-dashboard.controller.ts:68 |
| GET | /api/surveys/pre | SurveysController.getPreSurvey |  | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:50 |
| GET | /api/surveys/post | SurveysController.getPostSurvey |  | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:62 |
| POST | /api/surveys/pre/response | SurveysController.submitPre | UserId string; Body SubmitSurveyDto | Promise<{ score: number; level: string }> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:74 |
| POST | /api/surveys/post/response | SurveysController.submitPost | UserId string; Body SubmitSurveyDto | Promise<{ score: number; improvement: number &#124; null }> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:125 |
| GET | /api/surveys/sus | SurveysController.getSusSurvey |  | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:172 |
| GET | /api/surveys/sus/status | SurveysController.getSusStatus | UserId string | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:184 |
| POST | /api/surveys/sus/response | SurveysController.submitSus | UserId string; Body SubmitSurveyDto | Promise<{ susScore: number; grade: string }> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:281 |
| GET | /api/surveys/satisfaction | SurveysController.getSatisfactionSurvey |  | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:351 |
| GET | /api/surveys/satisfaction/status | SurveysController.getSatisfactionStatus | UserId string | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:365 |
| POST | /api/surveys/satisfaction/response | SurveysController.submitSatisfaction | UserId string; Body SubmitSurveyDto | Promise<{ score: number; averageLikert: number; likertCount: number }> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:390 |
| GET | /api/surveys/comparison | SurveysController.comparison | UserId string | Promise<object> | zenda_backend_app/src/modules/surveys/interface/surveys.controller.ts:469 |
| POST | /api/transactions/classify | TransactionsController.classify | UserId string; Body ClassifyTransactionDto | Promise<{ categoryName: string; confidence: number }> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:74 |
| POST | /api/transactions/voice-draft | TransactionsController.voiceDraft | UserId string; Body VoiceTransactionDraftRequestDto | Promise<VoiceTransactionDraftResponseDto> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:94 |
| POST | /api/transactions | TransactionsController.create | UserId string; Body CreateTransactionDto | Promise<TransactionResponseDto> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:111 |
| GET | /api/transactions | TransactionsController.findAll | UserId string; Query ListTransactionsDto | Promise<TransactionResponseDto[]> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:222 |
| GET | /api/transactions/:id | TransactionsController.findOne | UserId string; Param string | Promise<TransactionResponseDto> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:234 |
| PUT | /api/transactions/:id | TransactionsController.update | UserId string; Param string; Body UpdateTransactionDto | Promise<TransactionResponseDto> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:247 |
| DELETE | /api/transactions/:id | TransactionsController.remove | UserId string; Param string | Promise<void> | zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts:262 |
| GET | /api/notifications/preferences | NotificationsController.list | UserId string | Promise<NotificationPreferenceResponseDto[]> | zenda_backend_app/src/modules/users/interface/notifications.controller.ts:38 |
| PATCH | /api/notifications/preferences/:type | NotificationsController.update | UserId string; Param string; Body UpdatePreferenceDto | Promise<void> | zenda_backend_app/src/modules/users/interface/notifications.controller.ts:47 |
| GET | /api/users/me | UsersController.getMe | UserId string | Promise<UserProfileResponseDto> | zenda_backend_app/src/modules/users/interface/users.controller.ts:26 |
| PUT | /api/users/me | UsersController.updateMe | UserId string; Body UpdateProfileDto | Promise<UserProfileResponseDto> | zenda_backend_app/src/modules/users/interface/users.controller.ts:34 |
| GET | /api/users/me/export | UsersController.exportMe | UserId string | Promise<UserDataExportResponseDto> | zenda_backend_app/src/modules/users/interface/users.controller.ts:46 |
| DELETE | /api/users/me | UsersController.deleteMe | UserId string | Promise<void> | zenda_backend_app/src/modules/users/interface/users.controller.ts:54 |

## DTO

| DTO | Campo | Tipo | Opcional TS | Validadores | Archivo |
| --- | --- | --- | --- | --- | --- |
| HealthCheckItemDto | status | 'ok' &#124; 'down' | false |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthCheckItemDto | error | string | true |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthCheckItemDto | latencyMs | number | true |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthResponseDto | status | 'ok' &#124; 'degraded' | false |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthResponseDto | timestamp | string | false |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthResponseDto | version | string | false |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| HealthResponseDto | checks | Record<string, HealthCheckItemDto> | true |  | zenda_backend_app/src/health/dto/health.response.dto.ts |
| TrackAnalyticsEventDto | eventType | string | false | IsString, MaxLength, Matches | zenda_backend_app/src/infra/analytics/dto/track-analytics-event.dto.ts |
| TrackAnalyticsEventDto | metadata | Record<string, unknown> | true | IsOptional, IsObject | zenda_backend_app/src/infra/analytics/dto/track-analytics-event.dto.ts |
| AccountReportItemDto | income | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportItemDto | expenses | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportItemDto | transferIn | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportItemDto | transferOut | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportItemDto | netChange | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportResponseDto | totalAssets | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportResponseDto | totalCreditDebt | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportResponseDto | accounts | AccountReportItemDto[] | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountReportResponseDto | insights | string[] | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account-report.response.dto.ts |
| AccountResponseDto | id | string | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | name | string | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | type | 'CASH' &#124; 'BANK_ACCOUNT' &#124; 'DIGITAL_WALLET' &#124; 'CREDIT_CARD' | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | currency | string | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | openingBalance | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | currentBalance | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | debt | number | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | creditLimit | number &#124; null | true |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | institution | string &#124; null | true |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| AccountResponseDto | isDefault | boolean | false |  | zenda_backend_app/src/modules/accounts/interface/dto/account.response.dto.ts |
| CreateAccountDto | name | string | false | IsString, MaxLength | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | type | AccountTypeDto | false | IsEnum | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | currency | string | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | openingBalance | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | creditLimit | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | institution | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| CreateAccountDto | isDefault | boolean | true | IsOptional, IsBoolean | zenda_backend_app/src/modules/accounts/interface/dto/create-account.dto.ts |
| TransferAccountsDto | fromAccountId | string | false | IsUUID | zenda_backend_app/src/modules/accounts/interface/dto/transfer-accounts.dto.ts |
| TransferAccountsDto | toAccountId | string | false | IsUUID | zenda_backend_app/src/modules/accounts/interface/dto/transfer-accounts.dto.ts |
| TransferAccountsDto | amount | number | false | Type, IsNumber, Min | zenda_backend_app/src/modules/accounts/interface/dto/transfer-accounts.dto.ts |
| TransferAccountsDto | description | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/accounts/interface/dto/transfer-accounts.dto.ts |
| TransferAccountsDto | occurredAt | string | true | IsOptional, IsISO8601 | zenda_backend_app/src/modules/accounts/interface/dto/transfer-accounts.dto.ts |
| AuthTokenResponseDto | accessToken | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/auth-token.response.dto.ts |
| AuthTokenResponseDto | refreshToken | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/auth-token.response.dto.ts |
| ForgotPasswordDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/forgot-password.dto.ts |
| LoginErrorResponseDto | statusCode | number | false |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | message | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | error | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | path | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | timestamp | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | failedAttempts | number &#124; null | true |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | attemptsRemaining | number &#124; null | true |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginErrorResponseDto | lockedUntil | string &#124; null | true |  | zenda_backend_app/src/modules/auth/interface/dto/login-error.response.dto.ts |
| LoginDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/login.dto.ts |
| LoginDto | password | string | false | IsString, MinLength, MaxLength | zenda_backend_app/src/modules/auth/interface/dto/login.dto.ts |
| RefreshTokenDto | refreshToken | string | false | IsString, IsNotEmpty | zenda_backend_app/src/modules/auth/interface/dto/refresh-token.dto.ts |
| RegisterPendingVerificationResponseDto | userId | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/register-pending-verification.response.dto.ts |
| RegisterPendingVerificationResponseDto | email | string | false |  | zenda_backend_app/src/modules/auth/interface/dto/register-pending-verification.response.dto.ts |
| RegisterPendingVerificationResponseDto | requiresEmailVerification | true | false |  | zenda_backend_app/src/modules/auth/interface/dto/register-pending-verification.response.dto.ts |
| RegisterDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| RegisterDto | password | string | false | IsString, MinLength, MaxLength | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| RegisterDto | fullName | string | false | IsString, MaxLength | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| RegisterDto | consentGiven | true | false | Equals | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| RegisterDto | privacyPolicyVersion | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| RegisterDto | termsVersion | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts |
| ResetPasswordDto | token | string | false | IsString | zenda_backend_app/src/modules/auth/interface/dto/reset-password.dto.ts |
| ResetPasswordDto | newPassword | string | false | IsString, Length | zenda_backend_app/src/modules/auth/interface/dto/reset-password.dto.ts |
| SendOtpDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/send-otp.dto.ts |
| VerifyEmailDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/verify-email.dto.ts |
| VerifyEmailDto | code | string | false | IsString, Length | zenda_backend_app/src/modules/auth/interface/dto/verify-email.dto.ts |
| VerifyOtpDto | email | string | false | IsEmail | zenda_backend_app/src/modules/auth/interface/dto/verify-otp.dto.ts |
| VerifyOtpDto | code | string | false | IsString, Length | zenda_backend_app/src/modules/auth/interface/dto/verify-otp.dto.ts |
| BadgeResponseDto | id | string | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | name | string | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | description | string | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | criteria | string | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | iconUrl | string &#124; null | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | isEarned | boolean | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BadgeResponseDto | earnedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/badges/interface/dto/badge.response.dto.ts |
| BudgetResponseDto | id | string | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | userId | string | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | categoryId | string &#124; null | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | categoryName | string &#124; null | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | name | string &#124; null | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | amountLimit | number | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | month | number | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | year | number | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | currentSpent | number | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | percentageUsed | number | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| BudgetResponseDto | updatedAt | string | false |  | zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts |
| CreateBudgetDto | categoryId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts |
| CreateBudgetDto | name | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts |
| CreateBudgetDto | amountLimit | number | false | IsNumber, IsPositive | zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts |
| CreateBudgetDto | month | number | false | IsInt, Min, Max | zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts |
| CreateBudgetDto | year | number | false | IsInt, Min, Max | zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts |
| ListBudgetsDto | month | number | true | IsOptional, Type, IsInt, Min, Max | zenda_backend_app/src/modules/budgets/interface/dto/list-budgets.dto.ts |
| ListBudgetsDto | year | number | true | IsOptional, Type, IsInt, Min, Max | zenda_backend_app/src/modules/budgets/interface/dto/list-budgets.dto.ts |
| UpdateBudgetDto | amountLimit | number | true | IsOptional, IsNumber, IsPositive | zenda_backend_app/src/modules/budgets/interface/dto/update-budget.dto.ts |
| UpdateBudgetDto | name | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/budgets/interface/dto/update-budget.dto.ts |
| CategoryResponseDto | id | string | false |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | name | string | false |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | type | 'SYSTEM' &#124; 'CUSTOM' | false |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | icon | string &#124; null | true |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | transactionType | 'INCOME' &#124; 'EXPENSE' &#124; null | true |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | userId | string &#124; null | true |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CategoryResponseDto | updatedAt | string | false |  | zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts |
| CreateCategoryDto | name | string | false | IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/categories/interface/dto/create-category.dto.ts |
| UpdateCategoryDto | name | string | false | IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/categories/interface/dto/update-category.dto.ts |
| ChallengeResponseDto | id | string | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | title | string | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | description | string | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | reward | string &#124; null | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | pointsReward | number | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | badgeReward | string &#124; null | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | status | string | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | acceptedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | completedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| ChallengeResponseDto | expiresAt | Date &#124; null | false |  | zenda_backend_app/src/modules/challenges/interface/dto/challenge.response.dto.ts |
| SendChatMessageDto | userId | string | true | IsOptional, IsString | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SendChatMessageDto | message | string | false | IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatMessageResponseDto | id | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatMessageResponseDto | role | 'user' &#124; 'assistant' | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatMessageResponseDto | content | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatMessageResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ActiveConversationResponseDto | conversationId | string &#124; null | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ActiveConversationResponseDto | messages | ChatMessageResponseDto[] | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | type | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | fileId | string | true |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | quote | string | true |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | url | string | true |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | title | string | true |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatSourceResponseDto | text | string | true |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | conversationId | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | assistantMessageId | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | reply | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | answer | string | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | sources | ChatSourceResponseDto[] | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| ChatReplyResponseDto | metadata | {<br>    agent: string;<br>    usedRag: boolean;<br>    mode?: 'foundry_agent' &#124; 'classic_assistant';<br>    runId?: string;<br>    threadId?: string;<br>    responseId?: string;<br>    remoteConversationId?: string;<br>  } | false |  | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SubmitChatFeedbackDto | rating | number | false | IsInt, Min, Max | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SubmitChatFeedbackDto | helpful | boolean | true | IsOptional, IsBoolean | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SubmitChatFeedbackDto | clear | boolean | true | IsOptional, IsBoolean | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SubmitChatFeedbackDto | personalized | boolean | true | IsOptional, IsBoolean | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| SubmitChatFeedbackDto | comment | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/conversations/interface/dto/chat.dto.ts |
| LearningPathStepDto | id | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | kind | LearningPathStepKind | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | topicId | string &#124; null | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | title | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | reason | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | focus | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | difficulty | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | status | LearningPathStepStatus | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | order | number | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | estimatedMinutes | number | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| LearningPathStepDto | quizMode | LearningPathQuizMode | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| PersonalizedLearningPathResponseDto | generatedAt | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| PersonalizedLearningPathResponseDto | source | LearningPathSource | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| PersonalizedLearningPathResponseDto | summary | string | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| PersonalizedLearningPathResponseDto | steps | LearningPathStepDto[] | false |  | zenda_backend_app/src/modules/education/interface/dto/learning-path-response.dto.ts |
| QuizQuestionDto | id | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizQuestionDto | difficulty | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizQuestionDto | text | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizQuestionDto | options | string[] | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizResponseDto | topicId | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizResponseDto | language | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizResponseDto | questions | QuizQuestionDto[] | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizFeedbackItemDto | questionId | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizFeedbackItemDto | correct | boolean | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizFeedbackItemDto | correctAnswer | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizSubmitResponseDto | score | number | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizSubmitResponseDto | correctCount | number | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizSubmitResponseDto | totalCount | number | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizSubmitResponseDto | level | string | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| QuizSubmitResponseDto | feedback | QuizFeedbackItemDto[] | false |  | zenda_backend_app/src/modules/education/interface/dto/quiz-response.dto.ts |
| SubmitQuizDto | answers | Record<string, string> | false | IsObject, IsBoundedAnswersMap | zenda_backend_app/src/modules/education/interface/dto/submit-quiz.dto.ts |
| TopicResponseDto | id | string | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | title | string | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | content | string | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | difficulty | string | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | order | number | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | category | string | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | questionCount | number | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | isCompleted | boolean | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | isRead | boolean | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| TopicResponseDto | completedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/education/interface/dto/topic.response.dto.ts |
| CreateFeedbackDto | type | FeedbackTypeEnum | true | IsOptional, IsEnum | zenda_backend_app/src/modules/feedback/interface/dto/create-feedback.dto.ts |
| CreateFeedbackDto | message | string | false | IsString, MaxLength | zenda_backend_app/src/modules/feedback/interface/dto/create-feedback.dto.ts |
| CreateFeedbackDto | screenName | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/feedback/interface/dto/create-feedback.dto.ts |
| CreateFeedbackDto | rating | number | true | IsOptional, IsInt, Min, Max | zenda_backend_app/src/modules/feedback/interface/dto/create-feedback.dto.ts |
| FeedbackCreatedResponseDto | id | string | false |  | zenda_backend_app/src/modules/feedback/interface/dto/feedback-created.response.dto.ts |
| FinancialProgressResponseDto | id | string | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | userId | string | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | period | string | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | budgetComplianceScore | number &#124; null | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | savingsRatePct | number &#124; null | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | overspendCategoriesCount | number | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | recommendationsShown | number | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | recommendationsAccepted | number | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | recommendationAcceptanceRate | number &#124; null | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | quizzesCompleted | number | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | avgQuizScore | number &#124; null | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| FinancialProgressResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/financial-progress/interface/dto/financial-progress.response.dto.ts |
| ListProgressDto | from | string | true | IsOptional, Matches | zenda_backend_app/src/modules/financial-progress/interface/dto/list-progress.dto.ts |
| ListProgressDto | to | string | true | IsOptional, Matches | zenda_backend_app/src/modules/financial-progress/interface/dto/list-progress.dto.ts |
| ContributeGoalDto | amount | number | false | Type, IsNumber, Min | zenda_backend_app/src/modules/goals/interface/dto/contribute-goal.dto.ts |
| CreateGoalDto | name | string | false | IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/goals/interface/dto/create-goal.dto.ts |
| CreateGoalDto | targetAmount | number | false | Type, IsNumber, Min | zenda_backend_app/src/modules/goals/interface/dto/create-goal.dto.ts |
| CreateGoalDto | dueDate | Date | true | IsOptional, Type, IsDate | zenda_backend_app/src/modules/goals/interface/dto/create-goal.dto.ts |
| GoalContributionResponseDto | id | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal-contribution.response.dto.ts |
| GoalContributionResponseDto | goalId | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal-contribution.response.dto.ts |
| GoalContributionResponseDto | amount | number | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal-contribution.response.dto.ts |
| GoalContributionResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal-contribution.response.dto.ts |
| GoalResponseDto | id | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | userId | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | name | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | targetAmount | number | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | currentAmount | number | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | isCompleted | boolean | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | completedAt | string &#124; null | true |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | dueDate | string &#124; null | true |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| GoalResponseDto | updatedAt | string | false |  | zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts |
| UpdateGoalDto | name | string | true | IsOptional, IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/goals/interface/dto/update-goal.dto.ts |
| UpdateGoalDto | targetAmount | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/goals/interface/dto/update-goal.dto.ts |
| UpdateGoalDto | dueDate | Date | true | IsOptional, Type, IsDate | zenda_backend_app/src/modules/goals/interface/dto/update-goal.dto.ts |
| ComparisonDto | months | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/comparison.dto.ts |
| MonthComparisonEntryDto | year | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts |
| MonthComparisonEntryDto | month | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts |
| MonthComparisonEntryDto | totalIncome | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts |
| MonthComparisonEntryDto | totalExpense | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts |
| MonthComparisonEntryDto | netBalance | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts |
| DaySummaryDto | date | string | false | Matches | zenda_backend_app/src/modules/insights/interface/dto/day-summary.dto.ts |
| MonthSummaryDto | year | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/month-summary.dto.ts |
| MonthSummaryDto | month | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/month-summary.dto.ts |
| TopCategoryItemDto | name | string | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| TopCategoryItemDto | amount | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| GoalProgressItemDto | name | string | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| GoalProgressItemDto | currentAmount | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| GoalProgressItemDto | targetAmount | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| GoalProgressItemDto | progressPercent | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | totalIncome | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | totalExpense | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | netBalance | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | topCategories | TopCategoryItemDto[] | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | goalsProgress | GoalProgressItemDto[] | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthSummaryResponseDto | dailyBreakdown | DailyBreakdownItemDto[] | true |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| DailyBreakdownItemDto | date | string | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| DailyBreakdownItemDto | totalIncome | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| DailyBreakdownItemDto | totalExpense | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts |
| MonthTotalsDto | income | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| MonthTotalsDto | expenses | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| MonthTotalsDto | balance | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| MonthTotalsDto | savings | number | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ChangesDto | expensesChangePercent | number &#124; null | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ChangesDto | savingsChangePercent | number &#124; null | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ChangesDto | balanceChangePercent | number &#124; null | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ProgressResponseDto | currentMonth | MonthTotalsDto | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ProgressResponseDto | previousMonth | MonthTotalsDto | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ProgressResponseDto | changes | ChangesDto | false |  | zenda_backend_app/src/modules/insights/interface/dto/progress.response.dto.ts |
| ReportRangeDto | fromYear | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/report-range.dto.ts |
| ReportRangeDto | fromMonth | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/report-range.dto.ts |
| ReportRangeDto | toYear | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/report-range.dto.ts |
| ReportRangeDto | toMonth | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/report-range.dto.ts |
| WeekSummaryDto | year | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/week-summary.dto.ts |
| WeekSummaryDto | week | number | false | Type, IsInt, Min, Max | zenda_backend_app/src/modules/insights/interface/dto/week-summary.dto.ts |
| NotificationResponseDto | id | string | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | type | NotificationType | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | title | string | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | body | string | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | data | Record<string, string> &#124; null | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | readAt | string &#124; null | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | sentAt | string &#124; null | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationInboxResponseDto | items | NotificationResponseDto[] | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| NotificationInboxResponseDto | unreadCount | number | false |  | zenda_backend_app/src/modules/notifications/interface/dto/notification.response.dto.ts |
| RegisterFcmTokenDto | token | string | false | IsString, MinLength, MaxLength | zenda_backend_app/src/modules/notifications/interface/dto/register-fcm-token.dto.ts |
| SetDailyReminderTimeDto | time | string &#124; null | false | IsOptional, IsString, Matches | zenda_backend_app/src/modules/notifications/interface/dto/register-fcm-token.dto.ts |
| PredictionAccuracyResponseDto | period | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction-accuracy.response.dto.ts |
| PredictionAccuracyResponseDto | predictedTotal | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction-accuracy.response.dto.ts |
| PredictionAccuracyResponseDto | actualTotal | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction-accuracy.response.dto.ts |
| PredictionAccuracyResponseDto | accuracyPct | number &#124; null | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction-accuracy.response.dto.ts |
| CategoryPredictionDto | categoryId | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| CategoryPredictionDto | categoryName | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| CategoryPredictionDto | amount | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| ConfidenceIntervalDto | lower | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| ConfidenceIntervalDto | upper | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | id | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | period | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | type | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | predictedTotal | number | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | predictedByCategory | CategoryPredictionDto[] | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | confidenceLevel | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | confidenceInterval | ConfidenceIntervalDto | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | narrative | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | modelVersion | string | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | actualTotal | number &#124; null | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | accuracy | number &#124; null | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| PredictionResponseDto | createdAt | Date | false |  | zenda_backend_app/src/modules/predictions/interface/dto/prediction.response.dto.ts |
| ReceiptAnalyzeResponseDto | amount | number &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | date | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | time | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | merchant | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | tax | number &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | items | ReceiptItemDto[] | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | suggestedCategory | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | paymentMethod | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | suggestedAccountName | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | suggestedAccountType | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | note | string | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | confidence | number | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptAnalyzeResponseDto | warnings | string[] | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-analyze-response.dto.ts |
| ReceiptItemDto | name | string &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-item.dto.ts |
| ReceiptItemDto | amount | number &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-item.dto.ts |
| ReceiptItemDto | quantity | number &#124; null | false |  | zenda_backend_app/src/modules/receipts/interface/dto/receipt-item.dto.ts |
| FeedbackDto | accepted | boolean | false | IsBoolean | zenda_backend_app/src/modules/recommendations/interface/dto/feedback.dto.ts |
| RecommendationStatsResponseDto | total | number | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation-stats.response.dto.ts |
| RecommendationStatsResponseDto | accepted | number | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation-stats.response.dto.ts |
| RecommendationStatsResponseDto | acceptanceRate | number | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation-stats.response.dto.ts |
| RecommendationResponseDto | id | string | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | type | string | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | message | string | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | suggestedAction | string &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | isActive | boolean | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | viewedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | dismissedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | expiresAt | Date &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | feedbackAccepted | boolean &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | feedbackAt | Date &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | modelVersion | string &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | source | string &#124; null | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | inputContextJson | unknown | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| RecommendationResponseDto | createdAt | Date | false |  | zenda_backend_app/src/modules/recommendations/interface/dto/recommendation.response.dto.ts |
| ResearchDashboardQueryDto | from | string | true | Transform, IsOptional, IsDateString | zenda_backend_app/src/modules/research-dashboard/interface/dto/research-dashboard-query.dto.ts |
| ResearchDashboardQueryDto | to | string | true | Transform, IsOptional, IsDateString | zenda_backend_app/src/modules/research-dashboard/interface/dto/research-dashboard-query.dto.ts |
| ResearchDashboardQueryDto | token | string | true | Transform, IsOptional, IsString | zenda_backend_app/src/modules/research-dashboard/interface/dto/research-dashboard-query.dto.ts |
| SubmitSurveyDto | answers | Record<string, string> | false | IsObject | zenda_backend_app/src/modules/surveys/interface/dto/submit-survey.dto.ts |
| ClassifyTransactionDto | description | string | false | IsString | zenda_backend_app/src/modules/transactions/interface/dto/classify-transaction.dto.ts |
| ClassifyTransactionDto | amount | number | false | IsNumber, Min | zenda_backend_app/src/modules/transactions/interface/dto/classify-transaction.dto.ts |
| CreateTransactionDto | categoryId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | budgetId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | accountId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | newCategoryName | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | amount | number | false | Type, IsNumber, Min | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | description | string | false | IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | type | TransactionType | false | IsEnum | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | currency | string | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | occurredAt | string | true | IsOptional, IsISO8601 | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | suggestedCategoryId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| CreateTransactionDto | aiConfidence | number | true | IsOptional, Type, IsNumber, Min, Max | zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts |
| ListTransactionsDto | from | Date | true | IsOptional, Type, IsDate | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | to | Date | true | IsOptional, Type, IsDate | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | type | TransactionType | true | IsOptional, IsEnum | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | categoryId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | accountId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | skip | number | true | IsOptional, Type, IsInt, Min | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | take | number | true | IsOptional, Type, IsInt, Min, Max | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | minAmount | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | maxAmount | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | search | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| ListTransactionsDto | sort | 'asc' &#124; 'desc' | true | IsOptional, IsIn | zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts |
| TransactionCategoryDto | id | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionCategoryDto | name | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionCategoryDto | icon | string &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionAccountDto | id | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionAccountDto | name | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionAccountDto | type | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionAccountDto | currency | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | id | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | userId | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | categoryId | string &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | accountId | string &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | toAccountId | string &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | type | 'expense' &#124; 'income' &#124; 'transfer' | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | currency | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | amount | number | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | description | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | occurredAt | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | createdAt | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | updatedAt | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | category | TransactionCategoryDto &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | account | TransactionAccountDto &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | toAccount | TransactionAccountDto &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | suggestedCategoryId | string &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | aiConfidence | number &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | categorySource | 'AI' &#124; 'AI_OVERRIDDEN' &#124; 'USER' | false |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | newlyCompletedChallenges | string[] | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| TransactionResponseDto | anomalyAlert | {<br>    categoryName: string;<br>    pctOver: number;<br>    currentTotal: number;<br>    historicalAverage: number;<br>    explanation: string;<br>    explanationSource: 'rag-agent' &#124; 'local-fallback';<br>  } &#124; null | true |  | zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts |
| UpdateTransactionDto | type | TransactionType | true | IsOptional, IsEnum | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | categoryId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | accountId | string | true | IsOptional, IsUUID | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | newCategoryName | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | amount | number | true | IsOptional, Type, IsNumber, Min | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | description | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | currency | string | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| UpdateTransactionDto | occurredAt | string | true | IsOptional, IsISO8601 | zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts |
| VoiceTransactionDraftRequestDto | text | string | false | IsString, IsNotEmpty, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftRequestDto | timezone | string | true | IsOptional, IsString, MaxLength | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | type | TransactionType | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | amount | number &#124; null | false | Type | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | description | string | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | occurredAt | string &#124; null | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | suggestedCategoryName | string &#124; null | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | suggestedAccountName | string &#124; null | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | suggestedAccountType | string &#124; null | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | confidence | number | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| VoiceTransactionDraftResponseDto | warnings | string[] | false |  | zenda_backend_app/src/modules/transactions/interface/dto/voice-transaction-draft.dto.ts |
| NotificationPreferenceResponseDto | type | NotificationType | false |  | zenda_backend_app/src/modules/users/interface/dto/notification-preference.response.dto.ts |
| NotificationPreferenceResponseDto | enabled | boolean | false |  | zenda_backend_app/src/modules/users/interface/dto/notification-preference.response.dto.ts |
| UpdatePreferenceDto | enabled | boolean | false | IsBoolean | zenda_backend_app/src/modules/users/interface/dto/update-preference.dto.ts |
| UpdateProfileDto | fullName | string | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | age | number &#124; null | true | IsOptional, IsInt, Min, Max | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | university | string &#124; null | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | incomeType | IncomeType &#124; null | true | IsOptional, IsEnum | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | averageMonthlyIncome | number &#124; null | true | IsOptional, IsNumber, Min | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | financialLiteracyLevel | FinancialLiteracyLevel &#124; null | true | IsOptional, IsEnum | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | profileCompleted | boolean | true | IsOptional, IsBoolean | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UpdateProfileDto | currency | string | true | IsOptional, IsString, Length | zenda_backend_app/src/modules/users/interface/dto/update-profile.dto.ts |
| UserDataExportResponseDto | exportedAt | string | false |  | zenda_backend_app/src/modules/users/interface/dto/user-data-export.response.dto.ts |
| UserDataExportResponseDto | privacyPolicyVersion | string &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-data-export.response.dto.ts |
| UserDataExportResponseDto | termsVersion | string &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-data-export.response.dto.ts |
| UserDataExportResponseDto | profile | Record<string, unknown> | false |  | zenda_backend_app/src/modules/users/interface/dto/user-data-export.response.dto.ts |
| UserDataExportResponseDto | data | Record<string, unknown> | false |  | zenda_backend_app/src/modules/users/interface/dto/user-data-export.response.dto.ts |
| UserProfileResponseDto | id | string | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | email | string | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | fullName | string | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | emailVerifiedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | age | number &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | university | string &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | incomeType | IncomeType &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | averageMonthlyIncome | number &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | financialLiteracyLevel | FinancialLiteracyLevel &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | profileCompleted | boolean | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | currency | string | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | createdAt | Date | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | consentGiven | boolean | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | consentAt | Date &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | privacyPolicyVersion | string &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | termsVersion | string &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | dataAnonymizedAt | Date &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | failedLoginAttempts | number | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| UserProfileResponseDto | lockedUntil | Date &#124; null | false |  | zenda_backend_app/src/modules/users/interface/dto/user-profile.response.dto.ts |
| SuccessResponseDto | success | boolean | false |  | zenda_backend_app/src/shared/dto/success-response.dto.ts |

## Entidades y relaciones

| Entidad | Campo | Tipo | Lista | Requerido | Relacion |
| --- | --- | --- | --- | --- | --- |
| User | id | String | false | true |  |
| User | email | String | false | true |  |
| User | passwordHash | String | false | true |  |
| User | fullName | String | false | true |  |
| User | emailVerifiedAt | DateTime | false | false |  |
| User | age | Int | false | false |  |
| User | university | String | false | false |  |
| User | incomeType | IncomeType | false | false |  |
| User | averageMonthlyIncome | Decimal | false | false |  |
| User | financialLiteracyLevel | FinancialLiteracyLevel | false | false |  |
| User | profileCompleted | Boolean | false | true |  |
| User | currency | String | false | true |  |
| User | consentGiven | Boolean | false | true |  |
| User | consentAt | DateTime | false | false |  |
| User | privacyPolicyVersion | String | false | false |  |
| User | termsVersion | String | false | false |  |
| User | consentIp | String | false | false |  |
| User | consentUserAgent | String | false | false |  |
| User | dataAnonymizedAt | DateTime | false | false |  |
| User | anonymizationReason | String | false | false |  |
| User | failedLoginAttempts | Int | false | true |  |
| User | lockedUntil | DateTime | false | false |  |
| User | tokenVersion | Int | false | true |  |
| User | notificationPrefs | Json | false | true |  |
| User | fcmToken | String | false | false |  |
| User | dailyReminderAt | String | false | false |  |
| User | categories | Category | true | true | CategoryToUser |
| User | accounts | Account | true | true | AccountToUser |
| User | transactions | Transaction | true | true | TransactionToUser |
| User | savingsGoals | SavingsGoal | true | true | SavingsGoalToUser |
| User | budgets | Budget | true | true | BudgetToUser |
| User | userTopicProgress | UserTopicProgress | true | true | UserToUserTopicProgress |
| User | quizAttempts | QuizAttempt | true | true | QuizAttemptToUser |
| User | userChallenges | UserChallenge | true | true | UserToUserChallenge |
| User | userBadges | UserBadge | true | true | UserToUserBadge |
| User | predictions | Prediction | true | true | PredictionToUser |
| User | recommendations | Recommendation | true | true | RecommendationToUser |
| User | surveyResponses | SurveyResponse | true | true | SurveyResponseToUser |
| User | analyticsEvents | AnalyticsEvent | true | true | AnalyticsEventToUser |
| User | auditLogs | AuditLog | true | true | AuditLogToUser |
| User | feedbacks | Feedback | true | true | FeedbackToUser |
| User | authChallenges | AuthChallenge | true | true | AuthChallengeToUser |
| User | refreshTokens | RefreshToken | true | true | RefreshTokenToUser |
| User | aiConversations | AiConversation | true | true | AiConversationToUser |
| User | financialProgress | UserFinancialProgress | true | true | UserToUserFinancialProgress |
| User | idempotencyKeys | IdempotencyKey | true | true | IdempotencyKeyToUser |
| User | notifications | Notification | true | true | NotificationToUser |
| User | createdAt | DateTime | false | true |  |
| User | updatedAt | DateTime | false | true |  |
| User | deletedAt | DateTime | false | false |  |
| Category | id | String | false | true |  |
| Category | name | String | false | true |  |
| Category | type | CategoryType | false | true |  |
| Category | icon | String | false | false |  |
| Category | transactionType | TransactionType | false | false |  |
| Category | userId | String | false | false |  |
| Category | user | User | false | false | CategoryToUser |
| Category | transactions | Transaction | true | true | TransactionCategory |
| Category | suggestedForTransactions | Transaction | true | true | TransactionSuggestedCategory |
| Category | budgets | Budget | true | true | BudgetToCategory |
| Category | createdAt | DateTime | false | true |  |
| Category | updatedAt | DateTime | false | true |  |
| Category | deletedAt | DateTime | false | false |  |
| Account | id | String | false | true |  |
| Account | userId | String | false | true |  |
| Account | name | String | false | true |  |
| Account | type | AccountType | false | true |  |
| Account | currency | String | false | true |  |
| Account | openingBalance | Decimal | false | true |  |
| Account | creditLimit | Decimal | false | false |  |
| Account | institution | String | false | false |  |
| Account | isDefault | Boolean | false | true |  |
| Account | user | User | false | true | AccountToUser |
| Account | sourceTransactions | Transaction | true | true | TransactionSourceAccount |
| Account | destinationTransactions | Transaction | true | true | TransactionDestinationAccount |
| Account | createdAt | DateTime | false | true |  |
| Account | updatedAt | DateTime | false | true |  |
| Account | deletedAt | DateTime | false | false |  |
| Transaction | id | String | false | true |  |
| Transaction | userId | String | false | true |  |
| Transaction | categoryId | String | false | false |  |
| Transaction | accountId | String | false | false |  |
| Transaction | toAccountId | String | false | false |  |
| Transaction | budgetId | String | false | false |  |
| Transaction | type | TransactionType | false | true |  |
| Transaction | currency | String | false | true |  |
| Transaction | amount | Decimal | false | true |  |
| Transaction | description | String | false | true |  |
| Transaction | occurredAt | DateTime | false | true |  |
| Transaction | suggestedCategoryId | String | false | false |  |
| Transaction | aiConfidence | Decimal | false | false |  |
| Transaction | categorySource | CategorySource | false | true |  |
| Transaction | user | User | false | true | TransactionToUser |
| Transaction | category | Category | false | false | TransactionCategory |
| Transaction | suggestedCategory | Category | false | false | TransactionSuggestedCategory |
| Transaction | account | Account | false | false | TransactionSourceAccount |
| Transaction | toAccount | Account | false | false | TransactionDestinationAccount |
| Transaction | budget | Budget | false | false | BudgetToTransaction |
| Transaction | createdAt | DateTime | false | true |  |
| Transaction | updatedAt | DateTime | false | true |  |
| Transaction | deletedAt | DateTime | false | false |  |
| SavingsGoal | id | String | false | true |  |
| SavingsGoal | userId | String | false | true |  |
| SavingsGoal | name | String | false | true |  |
| SavingsGoal | targetAmount | Decimal | false | true |  |
| SavingsGoal | currentAmount | Decimal | false | true |  |
| SavingsGoal | dueDate | DateTime | false | false |  |
| SavingsGoal | completedAt | DateTime | false | false |  |
| SavingsGoal | user | User | false | true | SavingsGoalToUser |
| SavingsGoal | createdAt | DateTime | false | true |  |
| SavingsGoal | updatedAt | DateTime | false | true |  |
| SavingsGoal | deletedAt | DateTime | false | false |  |
| SavingsGoal | contributions | GoalContribution | true | true | GoalContributionToSavingsGoal |
| GoalContribution | id | String | false | true |  |
| GoalContribution | goalId | String | false | true |  |
| GoalContribution | amount | Decimal | false | true |  |
| GoalContribution | goal | SavingsGoal | false | true | GoalContributionToSavingsGoal |
| GoalContribution | createdAt | DateTime | false | true |  |
| Budget | id | String | false | true |  |
| Budget | userId | String | false | true |  |
| Budget | categoryId | String | false | false |  |
| Budget | name | String | false | false |  |
| Budget | amountLimit | Decimal | false | true |  |
| Budget | month | Int | false | true |  |
| Budget | year | Int | false | true |  |
| Budget | user | User | false | true | BudgetToUser |
| Budget | category | Category | false | false | BudgetToCategory |
| Budget | transactions | Transaction | true | true | BudgetToTransaction |
| Budget | createdAt | DateTime | false | true |  |
| Budget | updatedAt | DateTime | false | true |  |
| Budget | deletedAt | DateTime | false | false |  |
| EducationalTopic | id | String | false | true |  |
| EducationalTopic | title | String | false | true |  |
| EducationalTopic | content | String | false | true |  |
| EducationalTopic | difficulty | TopicDifficulty | false | true |  |
| EducationalTopic | order | Int | false | true |  |
| EducationalTopic | category | String | false | true |  |
| EducationalTopic | userProgress | UserTopicProgress | true | true | EducationalTopicToUserTopicProgress |
| EducationalTopic | quizQuestions | QuizQuestion | true | true | EducationalTopicToQuizQuestion |
| EducationalTopic | quizAttempts | QuizAttempt | true | true | EducationalTopicToQuizAttempt |
| EducationalTopic | createdAt | DateTime | false | true |  |
| EducationalTopic | updatedAt | DateTime | false | true |  |
| QuizQuestion | id | String | false | true |  |
| QuizQuestion | topicId | String | false | false |  |
| QuizQuestion | questionGroupKey | String | false | true |  |
| QuizQuestion | language | String | false | true |  |
| QuizQuestion | difficulty | TopicDifficulty | false | true |  |
| QuizQuestion | text | String | false | true |  |
| QuizQuestion | options | Json | false | true |  |
| QuizQuestion | correctAnswer | String | false | true |  |
| QuizQuestion | topic | EducationalTopic | false | false | EducationalTopicToQuizQuestion |
| QuizQuestion | attempts | QuizAttempt | true | true | QuizAttemptToQuizQuestion |
| QuizQuestion | createdAt | DateTime | false | true |  |
| QuizQuestion | updatedAt | DateTime | false | true |  |
| UserTopicProgress | id | String | false | true |  |
| UserTopicProgress | userId | String | false | true |  |
| UserTopicProgress | topicId | String | false | true |  |
| UserTopicProgress | completedAt | DateTime | false | false |  |
| UserTopicProgress | readAt | DateTime | false | false |  |
| UserTopicProgress | score | Decimal | false | false |  |
| UserTopicProgress | attemptsCount | Int | false | true |  |
| UserTopicProgress | user | User | false | true | UserToUserTopicProgress |
| UserTopicProgress | topic | EducationalTopic | false | true | EducationalTopicToUserTopicProgress |
| UserTopicProgress | createdAt | DateTime | false | true |  |
| QuizAttempt | id | String | false | true |  |
| QuizAttempt | userId | String | false | true |  |
| QuizAttempt | questionId | String | false | true |  |
| QuizAttempt | topicId | String | false | false |  |
| QuizAttempt | selectedAnswer | String | false | true |  |
| QuizAttempt | isCorrect | Boolean | false | true |  |
| QuizAttempt | attemptedAt | DateTime | false | true |  |
| QuizAttempt | user | User | false | true | QuizAttemptToUser |
| QuizAttempt | question | QuizQuestion | false | true | QuizAttemptToQuizQuestion |
| QuizAttempt | topic | EducationalTopic | false | false | EducationalTopicToQuizAttempt |
| QuizAttempt | createdAt | DateTime | false | true |  |
| Challenge | id | String | false | true |  |
| Challenge | title | String | false | true |  |
| Challenge | description | String | false | true |  |
| Challenge | criteriaJson | Json | false | true |  |
| Challenge | reward | String | false | false |  |
| Challenge | pointsReward | Int | false | true |  |
| Challenge | userChallenges | UserChallenge | true | true | ChallengeToUserChallenge |
| Challenge | createdAt | DateTime | false | true |  |
| Challenge | updatedAt | DateTime | false | true |  |
| UserChallenge | id | String | false | true |  |
| UserChallenge | userId | String | false | true |  |
| UserChallenge | challengeId | String | false | true |  |
| UserChallenge | acceptedAt | DateTime | false | false |  |
| UserChallenge | completedAt | DateTime | false | false |  |
| UserChallenge | user | User | false | true | UserToUserChallenge |
| UserChallenge | challenge | Challenge | false | true | ChallengeToUserChallenge |
| UserChallenge | createdAt | DateTime | false | true |  |
| UserChallenge | updatedAt | DateTime | false | true |  |
| Badge | id | String | false | true |  |
| Badge | name | String | false | true |  |
| Badge | description | String | false | true |  |
| Badge | criteria | String | false | true |  |
| Badge | iconUrl | String | false | false |  |
| Badge | userBadges | UserBadge | true | true | BadgeToUserBadge |
| Badge | createdAt | DateTime | false | true |  |
| Badge | updatedAt | DateTime | false | true |  |
| UserBadge | id | String | false | true |  |
| UserBadge | userId | String | false | true |  |
| UserBadge | badgeId | String | false | true |  |
| UserBadge | earnedAt | DateTime | false | true |  |
| UserBadge | user | User | false | true | UserToUserBadge |
| UserBadge | badge | Badge | false | true | BadgeToUserBadge |
| Prediction | id | String | false | true |  |
| Prediction | userId | String | false | true |  |
| Prediction | period | String | false | true |  |
| Prediction | type | TransactionType | false | true |  |
| Prediction | predictedTotal | Decimal | false | true |  |
| Prediction | predictedByCategory | Json | false | false |  |
| Prediction | confidenceInterval | Json | false | false |  |
| Prediction | confidenceLevel | String | false | false |  |
| Prediction | narrative | String | false | false |  |
| Prediction | modelVersion | String | false | false |  |
| Prediction | actualTotal | Decimal | false | false |  |
| Prediction | accuracy | Decimal | false | false |  |
| Prediction | user | User | false | true | PredictionToUser |
| Prediction | createdAt | DateTime | false | true |  |
| Prediction | updatedAt | DateTime | false | true |  |
| Recommendation | id | String | false | true |  |
| Recommendation | userId | String | false | true |  |
| Recommendation | type | RecommendationType | false | true |  |
| Recommendation | message | String | false | true |  |
| Recommendation | suggestedAction | String | false | false |  |
| Recommendation | isActive | Boolean | false | true |  |
| Recommendation | modelVersion | String | false | false |  |
| Recommendation | source | String | false | false |  |
| Recommendation | inputContextJson | Json | false | false |  |
| Recommendation | viewedAt | DateTime | false | false |  |
| Recommendation | dismissedAt | DateTime | false | false |  |
| Recommendation | expiresAt | DateTime | false | false |  |
| Recommendation | feedbackAccepted | Boolean | false | false |  |
| Recommendation | feedbackAt | DateTime | false | false |  |
| Recommendation | user | User | false | true | RecommendationToUser |
| Recommendation | createdAt | DateTime | false | true |  |
| Recommendation | updatedAt | DateTime | false | true |  |
| UserFinancialProgress | id | String | false | true |  |
| UserFinancialProgress | userId | String | false | true |  |
| UserFinancialProgress | period | String | false | true |  |
| UserFinancialProgress | budgetComplianceScore | Decimal | false | false |  |
| UserFinancialProgress | savingsRatePct | Decimal | false | false |  |
| UserFinancialProgress | overspendCategoriesCount | Int | false | true |  |
| UserFinancialProgress | recommendationsShown | Int | false | true |  |
| UserFinancialProgress | recommendationsAccepted | Int | false | true |  |
| UserFinancialProgress | quizzesCompleted | Int | false | true |  |
| UserFinancialProgress | avgQuizScore | Decimal | false | false |  |
| UserFinancialProgress | user | User | false | true | UserToUserFinancialProgress |
| UserFinancialProgress | createdAt | DateTime | false | true |  |
| Survey | id | String | false | true |  |
| Survey | type | SurveyType | false | true |  |
| Survey | questionsJson | Json | false | true |  |
| Survey | responses | SurveyResponse | true | true | SurveyToSurveyResponse |
| Survey | createdAt | DateTime | false | true |  |
| Survey | updatedAt | DateTime | false | true |  |
| SurveyResponse | id | String | false | true |  |
| SurveyResponse | userId | String | false | true |  |
| SurveyResponse | surveyId | String | false | true |  |
| SurveyResponse | answersJson | Json | false | true |  |
| SurveyResponse | score | Decimal | false | false |  |
| SurveyResponse | completedAt | DateTime | false | true |  |
| SurveyResponse | user | User | false | true | SurveyResponseToUser |
| SurveyResponse | survey | Survey | false | true | SurveyToSurveyResponse |
| AnalyticsEvent | id | String | false | true |  |
| AnalyticsEvent | userId | String | false | true |  |
| AnalyticsEvent | eventType | String | false | true |  |
| AnalyticsEvent | metadata | Json | false | false |  |
| AnalyticsEvent | user | User | false | true | AnalyticsEventToUser |
| AnalyticsEvent | createdAt | DateTime | false | true |  |
| AuditLog | id | String | false | true |  |
| AuditLog | userId | String | false | false |  |
| AuditLog | action | String | false | true |  |
| AuditLog | resource | String | false | true |  |
| AuditLog | resourceId | String | false | false |  |
| AuditLog | status | AuditStatus | false | true |  |
| AuditLog | requestId | String | false | false |  |
| AuditLog | httpMethod | String | false | false |  |
| AuditLog | httpPath | String | false | false |  |
| AuditLog | ipAddress | String | false | false |  |
| AuditLog | userAgent | String | false | false |  |
| AuditLog | beforeJson | Json | false | false |  |
| AuditLog | afterJson | Json | false | false |  |
| AuditLog | metadata | Json | false | false |  |
| AuditLog | user | User | false | false | AuditLogToUser |
| AuditLog | createdAt | DateTime | false | true |  |
| AuthChallenge | id | String | false | true |  |
| AuthChallenge | userId | String | false | true |  |
| AuthChallenge | kind | AuthChallengeKind | false | true |  |
| AuthChallenge | secret | String | false | true |  |
| AuthChallenge | email | String | false | false |  |
| AuthChallenge | expiresAt | DateTime | false | true |  |
| AuthChallenge | usedAt | DateTime | false | false |  |
| AuthChallenge | user | User | false | true | AuthChallengeToUser |
| AuthChallenge | createdAt | DateTime | false | true |  |
| RefreshToken | id | String | false | true |  |
| RefreshToken | userId | String | false | true |  |
| RefreshToken | token | String | false | true |  |
| RefreshToken | expiresAt | DateTime | false | true |  |
| RefreshToken | user | User | false | true | RefreshTokenToUser |
| RefreshToken | createdAt | DateTime | false | true |  |
| Feedback | id | String | false | true |  |
| Feedback | userId | String | false | true |  |
| Feedback | type | FeedbackType | false | true |  |
| Feedback | message | String | false | true |  |
| Feedback | screenName | String | false | false |  |
| Feedback | rating | Int | false | false |  |
| Feedback | user | User | false | true | FeedbackToUser |
| Feedback | createdAt | DateTime | false | true |  |
| AiConversation | id | String | false | true |  |
| AiConversation | userId | String | false | true |  |
| AiConversation | status | AiConversationStatus | false | true |  |
| AiConversation | startedAt | DateTime | false | true |  |
| AiConversation | endedAt | DateTime | false | false |  |
| AiConversation | user | User | false | true | AiConversationToUser |
| AiConversation | messages | AiMessage | true | true | AiConversationToAiMessage |
| AiConversation | createdAt | DateTime | false | true |  |
| AiConversation | updatedAt | DateTime | false | true |  |
| AiMessage | id | String | false | true |  |
| AiMessage | conversationId | String | false | true |  |
| AiMessage | role | AiMessageRole | false | true |  |
| AiMessage | content | String | false | true |  |
| AiMessage | feedbackRating | Int | false | false |  |
| AiMessage | feedbackHelpful | Boolean | false | false |  |
| AiMessage | feedbackClear | Boolean | false | false |  |
| AiMessage | feedbackPersonalized | Boolean | false | false |  |
| AiMessage | feedbackComment | String | false | false |  |
| AiMessage | feedbackAt | DateTime | false | false |  |
| AiMessage | conversation | AiConversation | false | true | AiConversationToAiMessage |
| AiMessage | createdAt | DateTime | false | true |  |
| IdempotencyKey | id | String | false | true |  |
| IdempotencyKey | key | String | false | true |  |
| IdempotencyKey | userId | String | false | true |  |
| IdempotencyKey | requestHash | String | false | true |  |
| IdempotencyKey | statusCode | Int | false | true |  |
| IdempotencyKey | responseBody | Json | false | true |  |
| IdempotencyKey | createdAt | DateTime | false | true |  |
| IdempotencyKey | user | User | false | true | IdempotencyKeyToUser |
| Notification | id | String | false | true |  |
| Notification | userId | String | false | true |  |
| Notification | type | NotificationType | false | true |  |
| Notification | title | String | false | true |  |
| Notification | body | String | false | true |  |
| Notification | data | Json | false | false |  |
| Notification | readAt | DateTime | false | false |  |
| Notification | sentAt | DateTime | false | false |  |
| Notification | user | User | false | true | NotificationToUser |
| Notification | createdAt | DateTime | false | true |  |
