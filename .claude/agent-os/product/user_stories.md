# Zenda — User Stories

**Project:** Zenda — AI-Powered Mobile Financial Management App for University Students
**Duration:** 10.5 months (February — December 2026)
**Budget:** S/ 14,241
**Status Tracking:** Done | In Progress | Not Started | Blocked

---

## Epic 1: Authentication and User Management

**Goal:** Every user must register, authenticate, and configure their financial profile before accessing features.

### US-0101: User Registration
**As a** university student
**I want to** register with a secure method
**So that** my personal financial data is protected

**Acceptance Criteria:**
- [ ] `POST /api/v1/auth/register` accepts: email, password, name
- [ ] Email validated with correct format, no duplicates
- [ ] Password >= 8 characters with at least 1 uppercase, 1 lowercase, 1 number
- [ ] Password hashed with bcrypt (cost factor 12) before storage
- [ ] Account created with `profile_completed = false`
- [ ] Returns valid JWT token for 30 days
- [ ] Registration screen with real-time validation

**Story Points:** 5
**Status:** Not Started
**Phase:** 2 — Authentication

---

### US-0102: Login
**As a** registered user
**I want to** log in with my credentials
**So that** only I can access my financial information

**Acceptance Criteria:**
- [ ] `POST /api/v1/auth/login` accepts email and password
- [ ] Correct credentials return JWT token
- [ ] Incorrect credentials return 401 with generic message
- [ ] Temporary lockout after 3 consecutive failed attempts (15 minutes)
- [ ] JWT stored in EncryptedSharedPreferences (Android)
- [ ] Auto-login if valid JWT exists when opening app

**Story Points:** 5
**Status:** Not Started
**Phase:** 2 — Authentication

---

### US-0103: Authentication Middleware
**As a** system
**I want to** validate JWT on each authenticated request
**So that** only valid users access the API

**Acceptance Criteria:**
- [ ] Intercepts all routes `/api/v1/*` except `/api/v1/auth/*`
- [ ] Extracts token from `Authorization: Bearer {token}` header
- [ ] Validates JWT signature, expiration, and structure
- [ ] Loads `user_id` into request context for downstream use
- [ ] Returns 401 Unauthorized if token is invalid, expired, or absent
- [ ] Logging of unauthorized access attempts

**Story Points:** 3
**Status:** Not Started
**Phase:** 2 — Authentication

---

### US-0104: Password Recovery
**As a** user
**I want to** recover my account if I forget my password
**So that** I don't lose access to my financial history

**Acceptance Criteria:**
- [ ] `POST /api/v1/auth/forgot-password` accepts email
- [ ] Sends email with reset token (expires in 1 hour)
- [ ] `POST /api/v1/auth/reset-password` accepts token + new password
- [ ] Token invalidated after use (single-use)
- [ ] "Forgot my password" screen with email field
- [ ] Confirmation message: "Check your email"

**Story Points:** 3
**Status:** Not Started
**Phase:** 2 — Authentication

---

### US-0105: Initial Profile Setup (Onboarding)
**As a** student
**I want to** set up my financial profile on first login
**So that** I receive recommendations adapted to my situation

**Acceptance Criteria:**
- [ ] Presented after first successful login (if `profile_completed = false`)
- [ ] Fields: age, university, income type (scholarship/work/family/mixed), average monthly income, preferred currency (default PEN)
- [ ] Each field on individual screen with smooth transition
- [ ] Optional skip with message: "Completing your profile improves predictions by 40%"
- [ ] On completion: `profile_completed = true`, `financial_literacy_level` assigned based on responses
- [ ] Data editable later in profile

**Story Points:** 5
**Status:** Not Started
**Phase:** 2 — Authentication

---

### US-0106: Profile and Preferences Editing
**As a** user
**I want to** edit my profile and app preferences
**So that** my information stays up to date and the experience is personalized

**Acceptance Criteria:**
- [ ] `GET /api/v1/users/me` returns complete user profile
- [ ] `PUT /api/v1/users/me` accepts editable fields: name, university, income_type, average_monthly_income, currency
- [ ] Profile screen with all editable fields
- [ ] Currency selector: PEN (default), USD
- [ ] Number format: thousands separator (dot/comma)
- [ ] Changes saved with visual confirmation

**Story Points:** 3
**Status:** Not Started
**Phase:** 2 — Authentication

---

## Epic 2: Transaction Recording

**Goal:** Students can record income and expenses simply and quickly, maintaining a clean and searchable history.

### US-0201: Record Income
**As a** student
**I want to** manually record my income
**So that** I can track my money sources

**Acceptance Criteria:**
- [ ] `POST /api/v1/transactions` accepts: `type: INCOME`, `amount` (> 0), `category_id`, `description` (optional), `date`
- [ ] Validates that category exists and is of type INCOME
- [ ] Creates transaction and returns with updated monthly balance
- [ ] Screen with: type selector (Income/Expense toggle), numeric amount input, category selector, date picker (default today), description field
- [ ] Confirmation message: "Income of S/{amount} recorded"
- [ ] Balance on main screen updates immediately

**Story Points:** 5
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

### US-0202: Record Expense
**As a** student
**I want to** manually record my expenses
**So that** I know what I spend my money on

**Acceptance Criteria:**
- [ ] Same endpoint `POST /api/v1/transactions` with `type: EXPENSE`
- [ ] Validates that category is of type EXPENSE
- [ ] Updates balance by subtracting the amount
- [ ] Appears in history sorted by date descending
- [ ] If expense exceeds category average (>20%), triggers anomaly detection

**Story Points:** 5
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

### US-0203: Transaction History with Filters
**As a** user
**I want to** apply advanced filters to my history
**So that** I can quickly find specific information

**Acceptance Criteria:**
- [ ] `GET /api/v1/transactions` with query params: `type`, `category_id`, `date_from`, `date_to`, `min_amount`, `max_amount`, `search` (description), `page`, `limit`, `sort`
- [ ] Returns paginated list with total results
- [ ] Screen with collapsible filters: date range, category, type, amount range
- [ ] Text search in description
- [ ] Infinite scroll pagination
- [ ] Response time < 2 seconds with 1000+ transactions

**Story Points:** 5
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

### US-0204: Main Dashboard
**As a** student
**I want to** see a quick summary of my financial situation when opening the app
**So that** I have an instant snapshot of my status

**Acceptance Criteria:**
- [ ] Main screen shows: current month balance (income - expenses), total monthly income, total monthly expenses
- [ ] Last 5 transactions with category icon, amount, and date
- [ ] FAB (Floating Action Button) "+" to add transaction
- [ ] Pull-to-refresh to update data
- [ ] Full load in < 2 seconds
- [ ] "Suggestions" section with latest AI recommendation (if available)

**Story Points:** 8
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

### US-0205: Edit Transaction
**As a** user
**I want to** edit recorded transactions
**So that** I can correct incorrect information

**Acceptance Criteria:**
- [ ] `PUT /api/v1/transactions/{id}` accepts modifiable fields: amount, category_id, description, date
- [ ] Validates that transaction belongs to authenticated user (403 if not)
- [ ] Transactions from another user return 403 Forbidden
- [ ] Balance and reports recalculated after edit
- [ ] Tap on transaction opens pre-filled edit screen
- [ ] "Save changes" button with confirmation

**Story Points:** 3
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

### US-0206: Delete Transaction
**As a** user
**I want to** delete transactions
**So that** I maintain a clean history

**Acceptance Criteria:**
- [ ] `DELETE /api/v1/transactions/{id}` performs soft delete (`deleted_at = NOW()`)
- [ ] Validates ownership (403 if not belonging to user)
- [ ] Confirmation dialog: "Are you sure? This action will remove the transaction from your reports"
- [ ] Transaction disappears from history and reports
- [ ] Balance recalculated immediately

**Story Points:** 2
**Status:** Not Started
**Phase:** 3 — Transaction Recording

---

## Epic 3: Categorization System

**Goal:** Transactions are organized by categories that feed reports, budgets, and predictions.

### US-0301: Default Categories
**As a** student
**I want to** have predefined expense and income categories
**So that** I can categorize my transactions without prior setup

**Acceptance Criteria:**
- [ ] Expense category seed: Food, Transportation, Education, Entertainment, Health, Housing, Utilities, Clothing, Other
- [ ] Income category seed: Scholarship, Part-time work, Family, Freelance, Other
- [ ] Each category with Material Design icon and assigned color
- [ ] Available to all users without manual creation
- [ ] Not deletable or editable (system categories)

**Story Points:** 3
**Status:** Not Started
**Phase:** 4 — Categorization

---

### US-0302: Custom Categories
**As a** user
**I want to** create my own categories
**So that** I can organize my finances according to my specific needs

**Acceptance Criteria:**
- [ ] `POST /api/v1/categories` creates category: name, type (INCOME/EXPENSE), icon, color
- [ ] `GET /api/v1/categories` returns default + user's custom categories
- [ ] `PUT /api/v1/categories/{id}` edits name/icon/color (custom only)
- [ ] `DELETE /api/v1/categories/{id}` deletes (custom only, error if has transactions)
- [ ] "Create new category" option visible when recording transaction
- [ ] Quick creation modal: name, icon selection, color selection

**Story Points:** 5
**Status:** Not Started
**Phase:** 4 — Categorization

---

## Epic 4: Financial Reports

**Goal:** Users visualize their financial habits with clear data and intuitive charts.

### US-0401: Monthly Summary
**As a** user
**I want to** see a monthly summary of my finances
**So that** I can evaluate my financial health for the month

**Acceptance Criteria:**
- [ ] `GET /api/v1/reports/monthly?year={y}&month={m}` returns: total_income, total_expenses, balance, breakdown_by_category (array with name, amount, percentage), transaction_count
- [ ] Screen with: total income (green), total expenses (red), balance (green/red depending on sign)
- [ ] Pie chart of expenses by category with legend and percentages
- [ ] Top 3 expense categories with icons
- [ ] Month selector (← previous / next →)
- [ ] Response time < 2 seconds

**Story Points:** 8
**Status:** Not Started
**Phase:** 5 — Reports

---

### US-0402: Weekly Summary
**As a** user
**I want to** see a weekly summary
**So that** I can identify early trends in my spending

**Acceptance Criteria:**
- [ ] `GET /api/v1/reports/weekly?year={y}&week={w}` returns same structure as monthly
- [ ] Totals correctly grouped by ISO week
- [ ] Week selector with visible dates (Mon-Sun)

**Story Points:** 3
**Status:** Not Started
**Phase:** 5 — Reports

---

### US-0403: Daily Summary
**As a** student
**I want to** see a daily expense summary
**So that** I can monitor my financial habits day by day

**Acceptance Criteria:**
- [ ] `GET /api/v1/reports/daily?date={d}` returns: total spent for the day, breakdown by category, transaction list
- [ ] Shows daily total in < 2 seconds
- [ ] Visual calendar with spending indicator per day (color by intensity)

**Story Points:** 3
**Status:** Not Started
**Phase:** 5 — Reports

---

### US-0404: Monthly Comparison
**As a** student
**I want to** see comparative charts by month
**So that** I can analyze the evolution of my spending and savings over time

**Acceptance Criteria:**
- [ ] `GET /api/v1/reports/comparison?months=3` returns data for last N months
- [ ] Line chart with income, expense, and balance evolution
- [ ] Selector: 2, 3, 4, 6 months comparison
- [ ] Clear visualization of trends (up/down)

**Story Points:** 5
**Status:** Not Started
**Phase:** 5 — Reports

---

### US-0405: Charts by Category
**As a** student
**I want to** see expense charts by category
**So that** I can visually understand what I spend most on

**Acceptance Criteria:**
- [ ] Horizontal bar chart sorted by amount (highest to lowest)
- [ ] Alternative pie chart with percentages
- [ ] Tap on category shows detail of transactions in that category
- [ ] Period selector: week, month, quarter
- [ ] Library: MPAndroidChart

**Story Points:** 5
**Status:** Not Started
**Phase:** 5 — Reports

---

### US-0406: PDF Export
**As a** user
**I want to** export my reports as PDF
**So that** I can share or save my financial data

**Acceptance Criteria:**
- [ ] `GET /api/v1/reports/export/pdf?year={y}&month={m}` generates PDF
- [ ] PDF includes: header with period, numeric summary, category chart, detailed breakdown
- [ ] "Export PDF" button on report screen
- [ ] Allows sharing via phone apps (share intent)
- [ ] Temporary download URL (24 hours)

**Story Points:** 5
**Status:** Not Started
**Phase:** 5 — Reports

---

## Epic 5: Budgets and Goals

**Goal:** Users define spending limits and savings objectives with visual tracking.

### US-0501: Budget Management
**As a** student
**I want to** define monthly budgets by category
**So that** I can control my spending and not exceed limits

**Acceptance Criteria:**
- [ ] `POST /api/v1/budgets` creates budget: category_id (null = global), amount_limit, month, year
- [ ] `GET /api/v1/budgets?month={m}&year={y}` returns with current_spent and percentage_used
- [ ] Screen with budget list and visual progress bar
- [ ] Colors: green (< 60%), yellow (60-80%), red (> 80%)
- [ ] Creation modal: select category or "General", enter limit amount

**Story Points:** 8
**Status:** Not Started
**Phase:** 6 — Budgets and Goals

---

### US-0502: Financial Goals
**As a** user
**I want to** define savings goals with deadlines
**So that** I can work toward concrete savings objectives

**Acceptance Criteria:**
- [ ] `POST /api/v1/goals` creates goal: name, target_amount, deadline
- [ ] `GET /api/v1/goals` returns with current_amount, percentage, days_remaining
- [ ] `PATCH /api/v1/goals/{id}/contribute` adds amount to current_amount
- [ ] Goal card: name, progress bar, current/target amount, deadline
- [ ] "Contribute" button with amount input
- [ ] Completion animation when current_amount >= target_amount

**Story Points:** 5
**Status:** Not Started
**Phase:** 6 — Budgets and Goals

---

### US-0503: Detailed Goal Tracking
**As a** user
**I want to** see detailed progress of my goals
**So that** I know if I'm on track to meet them

**Acceptance Criteria:**
- [ ] Detail screen with contribution history (date, amount)
- [ ] Cumulative progress chart over time
- [ ] Projection: "At this pace you'll complete your goal on {date}"
- [ ] Alert if projection indicates it won't be met before deadline

**Story Points:** 5
**Status:** Not Started
**Phase:** 6 — Budgets and Goals

---

## Epic 6: AI Pipeline

**Goal:** User data is transformed into features, models are trained, and exported for inference.

### US-0701: Feature Extraction
**As an** ML system
**I want to** extract financial features from each user
**So that** prediction models can be fed

**Acceptance Criteria:**
- [ ] Python script extracts per user: total_spending_per_category_per_month, total_income_per_month, expense_income_ratio, transaction_frequency, income_variability, peak_spending_day_of_week, top_3_categories
- [ ] Output: CSV with one row per user per month
- [ ] Documentation of each feature and its calculation
- [ ] Executable as periodic job

**Story Points:** 8
**Status:** Not Started
**Phase:** 7 — ML Pipeline

---

### US-0702: Training Dataset
**As a** data scientist
**I want to** have a realistic synthetic dataset
**So that** I can train models when there isn't enough real data

**Acceptance Criteria:**
- [ ] Minimum 1000 simulated records based on Peruvian university student profiles
- [ ] Realistic distributions: income S/ 500-2000, spending concentrated in food (30-40%), transportation (15-25%)
- [ ] Monthly variability incorporated (semester start = more education spending)
- [ ] Documentation of variables, distributions, and assumptions

**Story Points:** 5
**Status:** Not Started
**Phase:** 7 — ML Pipeline

---

### US-0703: Model Training and Selection
**As a** data scientist
**I want to** evaluate multiple prediction models
**So that** I can select the most accurate for our use case

**Acceptance Criteria:**
- [ ] Models evaluated: Linear Regression, Random Forest, XGBoost, LSTM
- [ ] Metrics: MAE, RMSE, R², Accuracy (defined as 1 - |pred-actual|/actual)
- [ ] 5-fold cross-validation
- [ ] Target: predict next month's total spending with accuracy >= 80%
- [ ] Documentation of results and justification for selected model

**Story Points:** 13
**Status:** Not Started
**Phase:** 7 — ML Pipeline

---

## Epic 7: Predictions

**Goal:** The app anticipates future expenses and income based on history and patterns detected by AI.

### US-0801: Expense Prediction
**As a** user
**I want to** receive predictions of my next month's expenses
**So that** I can anticipate my financial situation

**Acceptance Criteria:**
- [ ] `GET /api/v1/predictions/expenses?period=next_month` invokes ML model
- [ ] Returns: predicted_total, predicted_by_category (array), confidence_interval, model_version
- [ ] Requires minimum 2-month history (returns 400 with explanatory message if insufficient)
- [ ] Average accuracy >= 80% measured retrospectively
- [ ] Screen shows prediction with confidence indicator (high/medium/low)

**Story Points:** 8
**Status:** Not Started
**Phase:** 8 — Predictions

---

### US-0802: Income Prediction
**As a** student
**I want to** receive predictions of my income
**So that** I can better plan my upcoming months

**Acceptance Criteria:**
- [ ] `GET /api/v1/predictions/income?period=next_month` projects income
- [ ] Considers source variability (fixed scholarship vs variable work)
- [ ] Returns: predicted_total, predicted_by_source, confidence_level
- [ ] Coherent projection based on historical data

**Story Points:** 5
**Status:** Not Started
**Phase:** 8 — Predictions

---

### US-0803: Spending Anomaly Detection
**As a** user
**I want to** receive alerts if my spending in a category increases
**So that** I can avoid financial imbalances

**Acceptance Criteria:**
- [ ] When recording transaction: if category spending exceeds >20% the average of last 3 months, generates alert
- [ ] Push notification: "Your spending in {category} this month is {x}% higher than your average"
- [ ] Only one alert per category per month (no spamming)
- [ ] Alert visible on dashboard and in notifications

**Story Points:** 5
**Status:** Not Started
**Phase:** 8 — Predictions

---

## Epic 8: Personalized Recommendations

**Goal:** AI generates actionable suggestions based on user data.

### US-0901: Recommendation Engine
**As a** student
**I want to** receive personalized recommendations
**So that** I can improve my financial decisions

**Acceptance Criteria:**
- [ ] `GET /api/v1/recommendations` generates 1-5 active recommendations
- [ ] Based on: spending patterns, predictions, budgets, goals
- [ ] Types: SAVINGS, BUDGET, GOAL
- [ ] Each recommendation with concrete message and suggested action
- [ ] Integrated into Dashboard as "Suggestions for you" section
- [ ] Cards with feedback button: "Helpful" / "Not relevant"

**Story Points:** 8
**Status:** Not Started
**Phase:** 9 — Recommendations

---

### US-0902: Feedback Tracking
**As a** system
**I want to** record whether the user accepts or rejects recommendations
**So that** I can measure effectiveness and improve future suggestions

**Acceptance Criteria:**
- [ ] `PATCH /api/v1/recommendations/{id}/feedback` with accepted: true/false
- [ ] Metric: acceptance_rate = accepted_true / total, target >= 60%
- [ ] Internal dashboard shows acceptance rate by type

**Story Points:** 3
**Status:** Not Started
**Phase:** 9 — Recommendations

---

## Epic 9: Financial Education

**Goal:** Users learn key financial concepts through content adapted to their level.

### US-1001: Educational Content Module
**As a** student
**I want to** access financial educational material
**So that** I can learn key personal finance concepts

**Acceptance Criteria:**
- [ ] `GET /api/v1/education/topics` returns topic list with user progress
- [ ] `GET /api/v1/education/topics/{id}` returns complete content
- [ ] `PATCH /api/v1/education/topics/{id}/complete` marks as viewed
- [ ] Seed topics: Personal budget, Savings, Credit/debt, Inflation, Interest rates, Basic investing, Responsible consumption, Digital wallets in Peru
- [ ] Content in readable mobile format (text + icons + practical Peruvian examples)
- [ ] Overall progress visible (completion bar)

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

## Epic 10: Gamification

**Goal:** Users stay motivated through challenges, badges, and visible progress.

### US-1002: Financial Challenge System
**As a** student
**I want to** complete financial mini-challenges
**So that** I can improve my habits through gamification

**Acceptance Criteria:**
- [ ] `GET /api/v1/challenges` returns challenges with user status (available/active/completed)
- [ ] `POST /api/v1/challenges/{id}/accept` accepts challenge
- [ ] Automatic verification based on criteria_json (e.g., "no_transactions_category_delivery_3_days")
- [ ] Seed challenges: "No delivery spending for 3 days", "Record expenses for 7 consecutive days", "Save S/20 this week", "Reduce entertainment by 10%"
- [ ] Screen with active challenges (progress), available (accept), completed (date)
- [ ] Animation on challenge completion

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

### US-1003: Badge System
**As a** user
**I want to** earn badges for achievements
**So that** I stay motivated and see my progress

**Acceptance Criteria:**
- [ ] `GET /api/v1/badges` returns all badges with status (earned/not)
- [ ] Automatic assignment on meeting criteria:
  - "First transaction" — record first transaction
  - "Consistency" — 7 consecutive days recording
  - "Goal achieved" — complete first savings goal
  - "Challenger" — complete 5 challenges
  - "Financial sage" — complete educational module 100%
  - "Predictor" — check predictions 3 times
  - "Budgeter" — create and respect budget for 1 month
- [ ] Badge grid: color if earned, gray if not
- [ ] Tap shows detail: name, description, criteria, date earned
- [ ] Push notification when unlocking new badge

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

## Epic 11: Notifications

**Goal:** Proactive alerts maintain engagement and prevent financial problems.

### US-1101: Push Notification Infrastructure
**As a** system
**I want to** send push notifications to user devices
**So that** I can communicate alerts and reminders in real time

**Acceptance Criteria:**
- [ ] Integration with Firebase Cloud Messaging (FCM)
- [ ] NotificationService with specific methods per type
- [ ] FCM token registered on login, updated on refresh
- [ ] Expired token handling (automatic re-registration)

**Story Points:** 5
**Status:** Not Started
**Phase:** 11 — Notifications

---

### US-1102: Budget Alert at 80%
**As a** student
**I want to** receive alerts when I'm approaching my budget limit
**So that** I can avoid exceeding it

**Acceptance Criteria:**
- [ ] Scheduled job (every hour) checks active budgets
- [ ] If current_spent / budget_limit >= 0.80 → sends notification
- [ ] Message: "Your {category} budget is at {x}%. You have S/{remaining} left"
- [ ] Only one notification per budget per period (no repeats)
- [ ] Configurable: user can disable this alert type

**Story Points:** 5
**Status:** Not Started
**Phase:** 11 — Notifications

---

### US-1103: Anomalous Spending Alert
**As a** user
**I want to** receive alerts if my spending in a category rises too much
**So that** I can act in time

**Acceptance Criteria:**
- [ ] Trigger when recording transaction
- [ ] If month's spending in category exceeds >20% the average of last 3 months → notification
- [ ] Message: "Your spending in {category} this month is {x}% higher than your average"
- [ ] Maximum one alert per category per month

**Story Points:** 3
**Status:** Not Started
**Phase:** 11 — Notifications

---

## Epic 12: Impact Evaluation

**Goal:** Quantitatively measure whether the app improves users' financial education.

### US-1201: Pre-Usage Survey
**As a** researcher
**I want to** measure the user's financial knowledge before usage
**So that** I can establish a baseline for comparison

**Acceptance Criteria:**
- [ ] Questionnaire of 15-20 questions about: budgeting, savings, inflation, credit, interest rates
- [ ] Based on validated instruments (Cordova-Buiza et al., 2022; SBS, 2022)
- [ ] Presented during onboarding or first week of usage
- [ ] Automatic score calculation (0-100)
- [ ] Screen: one question per view, progress bar, automatic partial save
- [ ] On completion: "Your current financial education level is {LOW/MEDIUM/HIGH}"

**Story Points:** 8
**Status:** Not Started
**Phase:** 12 — Evaluation

---

### US-1202: Post-Usage Survey
**As a** researcher
**I want to** measure financial knowledge after usage
**So that** I can calculate educational improvement

**Acceptance Criteria:**
- [ ] Same questionnaire (variant to avoid memorization) + SUS section
- [ ] Presented after 4-8 weeks of usage (notification inviting completion)
- [ ] On completion: visual comparison "You improved from {x} to {y} points ({z}% increase)"
- [ ] If improvement < 20%: suggestions for relevant educational content

**Story Points:** 8
**Status:** Not Started
**Phase:** 12 — Evaluation

---

### US-1203: Educational Improvement Calculation
**As a** researcher
**I want to** calculate the aggregate financial knowledge improvement
**So that** I can validate the research hypothesis

**Acceptance Criteria:**
- [ ] `GET /api/v1/surveys/comparison?user_id={id}` returns: pre_score, post_score, improvement_percentage, sus_score
- [ ] `GET /api/v1/surveys/aggregate` returns: average, median, standard deviation, N
- [ ] Global target: average improvement_percentage >= 20%
- [ ] Exportable to CSV for external statistical analysis

**Story Points:** 5
**Status:** Not Started
**Phase:** 12 — Evaluation

---

## Epic 13: Security and Compliance

**Goal:** Financial data protected per Law 29733 and international standards.

### US-1301: Data Encryption
**As a** user
**I want to** have my financial data encrypted
**So that** unauthorized access is prevented

**Acceptance Criteria:**
- [ ] TLS 1.3 on all API communications (mandatory HTTPS)
- [ ] Azure Database encryption at rest enabled
- [ ] Encrypted backups
- [ ] EncryptedSharedPreferences for local data on Android
- [ ] SQLCipher for local Room database

**Story Points:** 5
**Status:** Not Started
**Phase:** 13 — Security

---

### US-1303: Data Consent
**As a** user
**I want to** give my explicit consent for the use of my data
**So that** compliance with the Personal Data Protection Law is met

**Acceptance Criteria:**
- [ ] Consent screen on first use with clear privacy policy
- [ ] Checkbox: "I agree that my financial data will be processed to generate personalized reports and predictions"
- [ ] App cannot be used without consent
- [ ] Consent record: user_id, consent_given=true, consent_at=timestamp
- [ ] Option to revoke consent in settings (implies disabling AI)

**Story Points:** 3
**Status:** Not Started
**Phase:** 13 — Security

---

## Epic 14: Testing

**Goal:** Quality verified with unit, integration, ML, and usability tests.

### US-1401: Service Unit Tests
**As a** developer
**I want to** have unit tests for all services
**So that** business logic correctness is guaranteed

**Acceptance Criteria:**
- [ ] Tests for: TransactionService, BudgetService, GoalService, PredictionService, RecommendationService, SurveyService
- [ ] Mock of repositories and external dependencies
- [ ] Coverage target >= 80% on services
- [ ] Tests executable in < 30 seconds

**Story Points:** 8
**Status:** Not Started
**Phase:** 14 — Testing

---

### US-1403: ML Model Validation
**As a** developer
**I want to** validate the accuracy of prediction models
**So that** reliable predictions are guaranteed

**Acceptance Criteria:**
- [ ] Test verifying accuracy >= 80% on test dataset
- [ ] No overfitting: train vs test accuracy difference < 10%
- [ ] Coherent predictions: not negative, within reasonable ranges
- [ ] Documented metrics: accuracy, MAE, RMSE, confusion matrix
- [ ] Validation pipeline executable with `python ml/validate.py`

**Story Points:** 8
**Status:** Not Started
**Phase:** 14 — Testing

---

### US-1404: Usability Tests with Users
**As a** researcher
**I want to** evaluate usability with real users
**So that** I can measure if the app meets experience standards

**Acceptance Criteria:**
- [ ] Group of 30 university students from Metropolitan Lima
- [ ] 4-8 weeks of active usage
- [ ] SUS questionnaire upon completion
- [ ] Target: SUS score >= 4.0/5.0
- [ ] Documentation: completed tasks, errors found, average time, observations

**Story Points:** 13
**Status:** Not Started
**Phase:** 14 — Testing

---

## Epic 15: User Feedback

**Goal:** Pilot users can report bugs and suggestions for iteration.

### US-1501: In-App Feedback System
**As a** user
**I want to** easily send feedback about the app
**So that** I can report problems or suggest improvements

**Acceptance Criteria:**
- [ ] `POST /api/v1/feedback` accepts: type (BUG/SUGGESTION/GENERAL), message, screen_name, rating (1-5)
- [ ] Feedback button accessible from sidebar menu or FAB
- [ ] Modal with: type, message, optional rating
- [ ] Confirmation: "Thanks for your feedback. We'll review it soon"

**Story Points:** 3
**Status:** Not Started
**Phase:** 15 — Feedback

---

## Epic 16: Analytics

**Goal:** Usage metrics to understand behavior and improve the app.

### US-1502: Usage Event Logging
**As a** developer
**I want to** log key interaction events
**So that** I can analyze metrics and improve the solution

**Acceptance Criteria:**
- [ ] Events: record_transaction, view_report, view_prediction, accept_challenge, complete_educational_topic, check_recommendation
- [ ] Table analytics_events: user_id, event_type, metadata_json, timestamp
- [ ] Without affecting perceived performance (async logging)

**Story Points:** 3
**Status:** Not Started
**Phase:** 15 — Feedback

---

## Epic 17: Demo and Test Data

**Goal:** Realistic data and reproducible script for validation and presentation.

### US-1601: Demo Data Script
**As a** presenter
**I want to** have realistic test data
**So that** I can demonstrate the app with credible scenarios

**Acceptance Criteria:**
- [ ] 5 users with varied profiles (universities, income, different types)
- [ ] 200+ transactions per user distributed across 3 months
- [ ] Default categories populated
- [ ] 3 active budgets per user
- [ ] 2 goals per user (1 in progress, 1 completed)
- [ ] Pre-usage surveys completed
- [ ] Idempotent and documented script

**Story Points:** 5
**Status:** Not Started
**Phase:** 16 — Demo

---

## Epic 18: Infrastructure

**Goal:** Repository, database, and CI/CD correctly configured.

### US-1801: Repository and Project Structure
**As a** developer
**I want to** have a well-organized repository
**So that** I can work in a structured way

**Acceptance Criteria:**
- [ ] GitHub monorepo: /android, /backend, /ml, /docs
- [ ] .gitignore, README.md, CONTRIBUTING.md, LICENSE
- [ ] Branch protection: main (protected), develop, feature/*

**Story Points:** 2
**Status:** Not Started
**Phase:** 1 — Infrastructure

---

## Summary Statistics

**Total Epics:** 18
**Total User Stories:** 55
**Total Story Points:** 302

**By Phase:**
- **Phase 1-2:** Infra + Auth — 12 stories, 54 points
- **Phase 3-4:** Transactions + Categories — 8 stories, 33 points
- **Phase 5-6:** Reports + Budgets — 11 stories, 60 points
- **Phase 7-8:** ML + Predictions — 8 stories, 52 points
- **Phase 9-10:** Recommendations + Education — 8 stories, 48 points
- **Phase 11-12:** Notifications + Evaluation — 8 stories, 37 points
- **Phase 13-16:** Security + Testing + Demo — 10 stories, 47 points

**Status Overview:**
- Done: 0
- In Progress: 0
- Not Started: 55
- Blocked: 0

---

## How to Use This Document

**Before starting new work:**
1. Review the epic's goal and related stories
2. Verify acceptance criteria as definition of "done"
3. Review corresponding phase in [roadmap.md](./roadmap.md)
4. Update status to In Progress
5. Implement following standards
6. Update status to Done when all criteria are met

**During development:**
- Use story points for planning (1 point ~ 2-3 hours)
- Block stories if dependencies are missing
- Add notes for deviations from acceptance criteria
- Update cross-references if implementation differs

**For tracking:**
- Mark stories as complete immediately when criteria are met
- Weekly reviews: verify actual progress vs roadmap
- This document is the source of truth for what's done vs pending

---

**Related documents:**
- [mission.md](./mission.md) — Product vision and objectives
- [roadmap.md](./roadmap.md) — Execution plan by phases (16 phases)
