# Zenda — User Stories

**Project:** Zenda — AI-Powered Mobile Financial Management App for Peruvian University Students
**Source of truth:** `docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md` — 49 official user stories (US-001–US-049)
**BDD format:** Dado / Cuando / Entonces (translated from the Spanish source)
**Status Tracking:** Done | In Progress | Not Started | Blocked

> **Reference times:** CRUD/load operations ≤ 5 s · AI operations ≤ 10 s · validation/error criteria = binary result (no time)

---

## Thesis User Story Cross-Reference

| Thesis ID | Title | Dev ID(s) | Phase |
|-----------|-------|-----------|-------|
| US-001 | Record income manually | US-0201 | 3 |
| US-002 | Record expense manually | US-0202 | 3 |
| US-003 | Edit recorded transaction | US-0205 | 3 |
| US-004 | Delete transaction with confirmation | US-0206 | 3 |
| US-005 | Assign category when recording income | US-0201, US-0301 | 3–4 |
| US-006 | Assign/change category on expense | US-0202, US-0302 | 3–4 |
| US-007 | Daily expense summary with category breakdown | US-0403 | 5 |
| US-008 | Weekly summary grouped by day | US-0402 | 5 |
| US-009 | Monthly income/expense/balance totals | US-0401 | 5 |
| US-010 | Category expense chart (% and amount) | US-0405 | 5 |
| US-011 | Multi-month comparison chart | US-0404 | 5 |
| US-012 | Filter history by date range and type | US-0203 | 3 |
| US-013 | Export report as PDF and share | US-0406 | 5 |
| US-014 | Financial evolution indicator vs. prior months | US-0407 | 5 |
| US-015 | AI expense prediction next month | US-0801 | 8 |
| US-016 | AI anomaly alert when >20% above monthly average | US-0803, US-1103 | 8, 11 |
| US-017 | Personalized AI recommendations | US-0901 | 9 |
| US-018 | AI auto-categorization suggestion | US-0702 | 7 |
| US-019 | Define monthly budget by category | US-0501 | 6 |
| US-020 | Budget 80% threshold notification | US-1102 | 11 |
| US-021 | Create savings goal with deadline | US-0502 | 6 |
| US-022 | View goal progress detail | US-0503 | 6 |
| US-023 | Financial education modules | US-1001 | 10 |
| US-024 | View and accept financial mini-challenges | US-1002 | 10 |
| US-025 | Earn achievement badges | US-1003 | 10 |
| US-026 | Financial knowledge quiz with instant feedback | US-1004 | 10 |
| US-027 | Register with auto-login after sign-up | US-0101 | 2 |
| US-028 | Login with 15-min lockout after 3 failures | US-0102 | 2 |
| US-029 | Encrypted transmission and secure server storage | US-1301 | 13 |
| US-030 | Complete initial financial profile on first use | US-0105 | 2 |
| US-031 | Select currency and number format | US-0106 | 2 |
| US-032 | Guided onboarding screens on first launch | US-0105 | 2 |
| US-033 | Initial financial knowledge assessment | US-1201 | 12 |
| US-034 | Receive invitation for final assessment after 30 days | US-1202 | 12 |
| US-035 | Complete SUS usability questionnaire | US-1404 | 14 |
| US-036 | Submit in-app feedback and suggestions | US-1501 | 15 |
| US-037 | Automatic usage pattern logging for research | US-1502 | 15 |
| US-038 | Category breakdown in monthly summary | US-0401 | 5 |
| US-039 | Filter history by category and amount range | US-0203 | 3 |
| US-040 | Create custom category | US-0302 | 4 |
| US-041 | Rename or delete custom category | US-0302 | 4 |
| US-042 | View active budget summary with progress | US-0501 | 6 |
| US-043 | Edit or delete monthly budget limit | US-0504 | 6 |
| US-044 | Contribute amount to savings goal | US-0502 | 6 |
| US-045 | Mark goal as completed or delete it | US-0505 | 6 |
| US-046 | Auto-verify active challenge completion | US-1002 | 10 |
| US-047 | Complete final financial knowledge evaluation | US-1202 | 12 |
| US-048 | AI-personalized learning path | US-1006 | 10 |
| US-049 | AI-generated contextual financial questions | US-1007 | 10 |

---

## Epic 1: Authentication and User Management

**Goal:** Every user must register, authenticate, and configure their financial profile before accessing features.

### US-027: Register with auto-login after sign-up
**As a** new user
**I want to** register in the app with my name, email and password, and log in automatically after registration
**So that** I can access my financial data immediately after registering with my account protected from the first moment

**Acceptance Criteria:**
- [x] `POST /api/auth/register` accepts: email, password, fullName
- [x] Email validated with correct format, no duplicates
- [x] Password >= 12 characters with at least 1 uppercase, 1 lowercase, 1 number
- [x] Password hashed with bcrypt before storage
- [x] Account created with `profileCompleted = false`
- [x] Returns valid JWT token
- [x] Registration screen with real-time validation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a valid name, an unregistered email, and a password meeting requirements | Presses register | Account created, app auto-logs in and redirects to onboarding in < 5 seconds |
| 2 | User tries to register with an email that is already registered | Presses register | System shows message that email is already in use and suggests logging in instead |

**Story Points:** 5
**Status:** Done
**Phase:** 2 — Authentication

---

### US-028: Login with 15-min lockout after 3 failures
**As a** registered user
**I want to** log in with my email and password, with temporary lockout after three failed attempts
**So that** only I can access my personal financial information

**Acceptance Criteria:**
- [x] `POST /api/auth/login` accepts email and password
- [x] Correct credentials return JWT token
- [x] Incorrect credentials return 401 with generic message
- [x] Temporary lockout after 3 consecutive failed attempts (15 minutes)
- [x] JWT stored in flutter_secure_storage
- [x] Auto-login if valid JWT exists when opening app

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters correct email and password | Presses login | App validates credentials and redirects to main dashboard in < 5 seconds |
| 2 | User enters incorrect credentials three consecutive times | Third attempt fails | System locks access for 15 minutes, shows remaining time, and disables the button |

**Story Points:** 5
**Status:** Done
**Phase:** 2 — Authentication

---

### US-030 / US-032: Initial financial profile and guided onboarding
**As a** student
**I want to** complete my profile the first time I use the app, indicating my age, university and basic economic situation, and see guided welcome screens on first launch with the option to skip them
**So that** the app adapts its recommendations to my real economic situation and I can quickly understand how to use it from day one

**Thesis IDs:** US-030 (initial financial profile), US-032 (guided onboarding screens)

**Acceptance Criteria:**
- [x] Presented after first successful login (if `profileCompleted = false`)
- [x] Fields: age, university, income type (scholarship/work/family/mixed), average monthly income, preferred currency (default PEN)
- [x] Each field on individual screen with smooth transition
- [x] ~~Optional skip available~~ — **removed by product decision (2026-05-31): profile completion is now mandatory** (no skip button; user must complete all steps)
- [x] On completion: `profileCompleted = true`
- [x] Data editable later in profile

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes the form with all required valid fields (US-030) | Presses save | Data stored and user accesses main screen in < 5 seconds |
| 2 | User tries to save with one or more required fields empty (US-030) | Presses save | System highlights missing fields and does not advance until all are completed |
| 3 | User navigates through all onboarding screens to the last one (US-032) | Finishes onboarding | User accesses main screen with active session |
| 4 | User is in the welcome flow and does not want to see it (US-032) | Presses skip | App jumps to main screen and does not show onboarding again |

**Story Points:** 5
**Status:** In Progress
**Phase:** 2 — Authentication

---

### US-031: Select currency and number format
**As a** registered user
**I want to** select the currency and number format in which amounts are displayed in the app
**So that** I can make correct financial decisions with information in the format familiar to my daily life

**Acceptance Criteria:**
- [x] `GET /api/users/me` returns complete user profile
- [x] `PUT /api/users/me` accepts editable fields: fullName, university, incomeType, averageMonthlyIncome, currency
- [x] Profile screen with all editable fields
- [x] Currency selector: PEN (default), USD
- [x] Number format: thousands separator (dot/comma)
- [x] Changes saved with visual confirmation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a different currency and number format from the current one | Saves changes | All amounts in the app update to the new format without needing to restart |
| 2 | User modifies the configuration but closes the app without saving | Reopens the app | Previous configuration is maintained without changes |

**Story Points:** 3
**Status:** Done
**Phase:** 2 — Authentication

---

## Epic 2: Transaction Recording

**Goal:** Students can record income and expenses simply and quickly, maintaining a clean and searchable history.

### US-001 / US-005: Record income manually and assign category
**As a** university student
**I want to** manually record my income with amount, date, category and optional description
**So that** I can keep a detailed record of my money sources and improve my financial management

**Thesis IDs:** US-001 (record income manually), US-005 (assign category when recording income)

**Acceptance Criteria:**
- [x] `POST /api/transactions` accepts: `type: INCOME`, `amount` (> 0), `categoryId`, `description` (optional), `occurredAt`
- [x] Validates that category exists and is of type INCOME
- [x] Creates transaction and returns with updated monthly balance
- [x] Screen with: type selector, numeric amount input, category selector, date picker (default today), description field
- [x] Confirmation message shown after recording

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is authenticated with all required fields completed (amount, category, date) | Presses save | Income registered in < 2 seconds, appears in history, and balance is updated |
| 2 | User leaves the amount field empty or enters a value equal to zero | Presses save | System shows an error message below the amount field and does not register the income |

**Story Points:** 5
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-002 / US-006: Record expense manually and assign category
**As a** university student
**I want to** manually record my expenses with amount, date, category and optional note
**So that** I can identify what I spend my money on and make more conscious decisions about my consumption

**Thesis IDs:** US-002 (record expense manually), US-006 (assign/change category on expense)

**Acceptance Criteria:**
- [x] Same endpoint `POST /api/transactions` with `type: EXPENSE`
- [x] Validates that category is of type EXPENSE
- [x] Updates balance by subtracting the amount
- [x] Appears in history sorted by date descending

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is on the new expense screen with valid amount, category and date | Presses save | Expense registered in < 2 seconds, appears in history, and balance is updated |
| 2 | User enters a negative amount or non-numeric characters | Presses save | System shows a validation error message and does not allow saving the expense |

**Story Points:** 5
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-012 / US-039: Filter history by date range, type, category and amount
**As a** registered user
**I want to** filter the transaction history by date range, transaction type, category and amount range
**So that** I can locate transactions from a specific period or type without reviewing the entire history

**Thesis IDs:** US-012 (filter by date range and type), US-039 (filter by category and amount range)

**Acceptance Criteria:**
- [x] `GET /api/transactions` with query params: `type`, `categoryId`, `dateFrom`, `dateTo`, `minAmount`, `maxAmount`, `search`, `page`, `limit`, `sort`
- [x] Returns paginated list with total results
- [x] Screen with collapsible filters: date range, category, type, amount range
- [x] Text search in description
- [x] Infinite scroll pagination

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User applies a filter by date range and/or transaction type (US-012) | System processes the filters | List shows only transactions matching the criteria in < 2 seconds |
| 2 | User applies filters that do not match any transaction (US-012) | System processes the filters | App shows empty state indicating no results were found |
| 3 | User applies a filter for a specific category (US-039) | System processes the filter | List shows only transactions of that category in < 2 seconds |
| 4 | User enters a minimum and maximum amount as a filter (US-039) | System processes the range | List shows only transactions within the defined range |

**Story Points:** 5
**Status:** Done
**Phase:** 3 — Transaction Recording

---

### US-003: Edit recorded transaction
**As a** registered user
**I want to** edit the amount, category, date or description of a recorded transaction
**So that** I can correct capture errors without deleting the transaction, keeping my reports always accurate

**Acceptance Criteria:**
- [x] `PUT /api/transactions/{id}` accepts modifiable fields: amount, categoryId, description, occurredAt
- [x] Validates that transaction belongs to authenticated user (403 if not)
- [x] Balance and reports recalculated after edit
- [x] Tap on transaction opens pre-filled edit screen
- [x] Save changes button with confirmation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a transaction and modifies one or more fields with valid values | Presses save changes | Transaction updated and reports reflect the change in < 3 seconds |
| 2 | User clears the content of the amount field leaving it empty | Presses save changes | System shows a validation error and keeps the original value without modifying |

**Story Points:** 3
**Status:** Done
**Phase:** 3 — Transaction Recording

---

### US-004: Delete transaction with confirmation
**As a** registered user
**I want to** delete a transaction after confirming the action in a verification dialog
**So that** I can keep my history clean and free of incorrect records so that my reports are accurate

**Acceptance Criteria:**
- [x] `DELETE /api/transactions/{id}` performs soft delete (`deletedAt = NOW()`)
- [x] Validates ownership (403 if not belonging to user)
- [x] Confirmation dialog before deletion
- [x] Transaction disappears from history and reports

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User views a transaction in the history and presses delete | Confirms the action in the verification dialog | Transaction disappears from history, balance is recalculated, and reports are updated in < 5 seconds |
| 2 | User presses delete and the confirmation dialog appears | Presses cancel | Transaction remains in history without changes and balance stays the same |

**Story Points:** 2
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

## Epic 3: Categorization System

**Goal:** Transactions are organized by categories that feed reports, budgets, and predictions.

### US-005: Assign category when recording (default categories)
**As a** university student
**I want to** assign a category when recording income, choosing from existing categories or the AI's automatic suggestion
**So that** I can differentiate my income by origin and obtain accurate reports about my money sources

**Thesis IDs:** US-005 (assign category to income), US-006 (assign/change category on expense)

**Acceptance Criteria:**
- [x] Expense category seed: Food, Transportation, Education, Entertainment, Health, Housing, Utilities, Clothing, Other
- [x] Income category seed: Scholarship, Part-time work, Family, Freelance, Other
- [x] Each category with icon and assigned color
- [x] Available to all users without manual creation
- [x] Not deletable (system categories marked with type SYSTEM)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is recording an income and selects a category from the list (US-005) | Saves the income | Income associated with that category and correctly grouped in reports |
| 2 | User does not select any category when recording an expense (US-006) | Presses save | System shows a message indicating category is required and does not register the expense |

**Story Points:** 3
**Status:** Done
**Phase:** 4 — Categorization

---

### US-040 / US-041: Create, rename or delete custom category
**As a** registered user
**I want to** create a custom category to organize my transactions, and rename or delete it if I no longer use it
**So that** I can adapt the classification to my specific habits and keep my category list ordered and up to date

**Thesis IDs:** US-040 (create custom category), US-041 (rename or delete custom category)

**Acceptance Criteria:**
- [x] `POST /api/categories` creates category: name, type (INCOME/EXPENSE), icon, color
- [x] `GET /api/categories` returns default + user's custom categories
- [x] `PUT /api/categories/{id}` edits name/icon/color (ownership validated)
- [x] `DELETE /api/categories/{id}` deletes (custom only, error if has transactions)
- [x] Create new category option visible when recording transaction

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses category management and enters a unique name (US-040) | Presses save | Category created in < 5 seconds and available in the list to assign to new transactions |
| 2 | User enters a category name that already exists in the system (US-040) | Presses save | System shows an error message and does not create the duplicate |
| 3 | User selects a custom category and changes its name to a unique value (US-041) | Saves changes | New name applied in < 5 seconds and reflected in all previously associated transactions |
| 4 | User tries to delete a category that has associated transactions (US-041) | Confirms deletion | System shows a message asking to reassign transactions before deleting |

**Story Points:** 5
**Status:** Done
**Phase:** 4 — Categorization

---

## Epic 4: Financial Reports

**Goal:** Users visualize their financial habits with clear data and intuitive charts.

### US-009 / US-038: Monthly income/expense/balance totals with category breakdown
**As a** registered user
**I want to** see the total income, expenses and balance for the selected month, and the breakdown of expenses and income by category
**So that** I can evaluate my monthly financial health and identify which categories consume most of my monthly budget

**Thesis IDs:** US-009 (monthly totals), US-038 (category breakdown in monthly summary)

**Acceptance Criteria:**
- [x] `GET /api/insights/monthly?year={y}&month={m}` returns: totalIncome, totalExpenses, balance, breakdownByCategory, transactionCount
- [x] Screen with: total income, total expenses, balance
- [x] Pie chart of expenses by category with legend and percentages
- [x] Top expense categories with icons
- [x] Month selector

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions in the selected month (US-009) | Accesses monthly summary | App shows total income, expenses and balance in < 3 seconds |
| 2 | User selects a month without registered transactions (US-009) | Accesses monthly summary | App shows empty state with all totals at zero |
| 3 | User has categorized transactions in the selected month (US-038) | Accesses category breakdown | App shows amount and percentage of each category sorted highest to lowest in < 3 seconds |
| 4 | User selects a month without categorized transactions (US-038) | Accesses breakdown | App shows message indicating insufficient data |

**Story Points:** 8
**Status:** Done
**Phase:** 5 — Reports

---

### US-008: Weekly summary grouped by day
**As a** registered user
**I want to** see my expenses and income grouped by day within a selected week
**So that** I can identify which days I concentrate most spending and detect early spending trends

**Acceptance Criteria:**
- [x] `GET /api/insights/weekly?year={y}&week={w}` returns totals grouped by day
- [x] Totals correctly grouped by ISO week
- [x] Week selector with visible dates

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions on different days of a week | Selects that week | App shows income and expense totals correctly grouped per day in < 5 seconds |
| 2 | User selects a week without registered transactions | Accesses weekly summary | App shows message indicating no data for the selected period |

**Story Points:** 3
**Status:** Done
**Phase:** 5 — Reports

---

### US-007: Daily expense summary with category breakdown
**As a** university student
**I want to** see the total expenses of the current day with breakdown by category
**So that** I can monitor my daily habits in real time and detect if I am spending more than usual

**Acceptance Criteria:**
- [x] `GET /api/insights/daily?date={d}` returns: total spent for the day, breakdown by category, transaction list
- [x] Shows daily total in < 2 seconds
- [x] Visual calendar with spending indicator per day

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has expenses registered for the current day | Accesses the daily summary view | App shows today's total spent and breakdown by category in < 2 seconds |
| 2 | User has no expenses registered for the current day | Accesses the daily summary view | App shows empty state indicating there are no transactions for today |

**Story Points:** 3
**Status:** Done
**Phase:** 5 — Reports

---

### US-011: Multi-month comparison chart
**As a** university student
**I want to** see a comparative chart of income, expenses and savings between two or more months
**So that** I can analyze whether my financial habits are improving or worsening and adjust my behavior

**Acceptance Criteria:**
- [x] `GET /api/insights/comparison?months=N` returns data for last N months
- [x] Line chart with income, expense and balance evolution
- [x] Selector: 2, 3, 6 months comparison

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has data in at least two different months | Selects those months and requests comparison chart | App shows chart with income, expense and savings totals per month in < 5 seconds |
| 2 | User selects only one month for comparison | Tries to generate the chart | System indicates at least two months must be selected |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

### US-010: Category expense chart (% and amount)
**As a** university student
**I want to** visualize a chart of the percentage and amount spent by category in a selected period
**So that** I can visually understand which categories concentrate my spending and where I can reduce consumption

**Acceptance Criteria:**
- [x] Horizontal bar chart sorted by amount (highest to lowest)
- [x] Pie chart with percentages
- [x] Library: fl_chart
- [x] Tap on category shows transaction detail
- [x] Period selector: week, month, quarter

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has categorized expenses in the selected period | Accesses category chart | Chart shown in < 3 seconds with percentage and amount of each category |
| 2 | User has no expenses in the selected period | Accesses the chart | App shows message indicating insufficient data to generate the chart |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

### US-013: Export report as PDF and share
**As a** registered user
**I want to** export the period report as PDF with charts and breakdown, and share it from my phone
**So that** I can save a backup of my finances outside the app and share it with my advisor or for my thesis

**Acceptance Criteria:**
- [x] `GET /api/reports/export/pdf?year={y}&month={m}` generates PDF
- [x] PDF includes: header with period, numeric summary, category chart, detailed breakdown
- [x] Export PDF button on report screen
- [x] Allows sharing via phone apps

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is viewing a report with registered transactions | Presses export to PDF | App generates PDF with charts, totals and breakdown in < 5 seconds and opens the app selector to share it |
| 2 | User tries to export a report for a period without transactions | Presses export | System shows message indicating insufficient data to generate the report |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

### US-014: Financial evolution indicator vs. prior months
**As a** university student
**I want to** see a financial evolution indicator comparing my current habits with those of previous months
**So that** I can understand whether my financial habits are improving and have concrete evidence of my progress

**Acceptance Criteria:**
- [x] `GET /api/insights/progress` returns current vs previous month comparison: total expenses, total savings, net balance, top categories
- [x] Shows improvement or decline percentage per metric
- [x] Visual up/down indicator with color (green = improved, red = declined)
- [x] Requires minimum 2-month history

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions in at least two different months | Accesses financial evolution view | App shows comparison of income, expenses and balance with percentage variations and visual improvement or decline indicators |
| 2 | User has transactions in only one month | Accesses evolution view | App shows message indicating data from at least two months is needed |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

## Epic 5: Budgets and Goals

**Goal:** Users define spending limits and savings objectives with visual tracking.

### US-019 / US-042: Define and view monthly budget by category
**As a** university student
**I want to** define a monthly spending limit for a specific category, and see the summary of all my active budgets with their progress percentage
**So that** I can establish clear spending limits per area and monitor at a glance whether I am within my monthly spending limits

**Thesis IDs:** US-019 (define monthly budget), US-042 (view active budget summary with progress)

**Acceptance Criteria:**
- [x] `POST /api/budgets` creates budget: categoryId, amountLimit, month, year
- [x] `GET /api/budgets?month={m}&year={y}` returns with currentSpent and percentageUsed
- [x] Screen with budget list and visual progress bar
- [x] Creation modal: select category, enter limit amount

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a category and enters a valid limit amount greater than zero (US-019) | Presses save | Budget registered in < 2 seconds with a visible progress bar |
| 2 | User tries to save a budget with amount equal to zero or negative (US-019) | Presses save | System shows error indicating amount must be greater than zero |
| 3 | User has at least one active budget for the month (US-042) | Accesses budget section | App shows all budgets with category, limit, spent amount and progress bar in < 2 seconds |
| 4 | User has no budgets defined for the month (US-042) | Accesses budget section | App shows empty state inviting user to create their first budget |

**Story Points:** 8
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

### US-021 / US-044: Create savings goal and contribute
**As a** registered user
**I want to** register a savings goal with name, target amount in soles and deadline, and record economic contributions toward it
**So that** I can work in an organized way toward a concrete financial objective with a defined timeline and track my real savings progress

**Thesis IDs:** US-021 (create savings goal), US-044 (contribute to savings goal)

**Acceptance Criteria:**
- [x] `POST /api/goals` creates goal: name, targetAmount, deadline
- [x] `GET /api/goals` returns with currentAmount, percentage, daysRemaining
- [x] `POST /api/goals/{id}/contribute` adds amount to currentAmount
- [x] Goal card: name, progress bar, current/target amount, deadline
- [x] Contribute button with amount input

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a valid name, an amount greater than zero and a future deadline (US-021) | Presses save | Goal appears in active goals list with zero progress in < 5 seconds |
| 2 | User tries to save a goal with a past or equal-to-current deadline date (US-021) | Presses save | System shows error indicating the deadline must be a future date |
| 3 | User accesses the detail of an active goal and enters a contribution amount greater than zero (US-044) | Presses save contribution | Contribution registered in < 5 seconds and goal progress updated with the new accumulated amount |
| 4 | User tries to register a contribution with amount equal to zero or negative (US-044) | Presses save | System shows error indicating the contribution amount must be greater than zero |

**Story Points:** 5
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

### US-022: View goal progress detail
**As a** registered user
**I want to** see the saved amount, progress percentage, remaining amount and days remaining of an active goal
**So that** I know where I stand regarding my goal and evaluate whether I am at the pace needed to reach it

**Acceptance Criteria:**
- [x] Detail screen with contribution history (date, amount)
- [x] Cumulative progress chart over time
- [x] Projection: at current pace, estimated completion date

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has an active goal with at least one registered contribution | Accesses goal detail | App shows progress percentage, saved amount, remaining amount and days to deadline in < 5 seconds |
| 2 | User accesses detail of a goal with no contributions | Views the screen | App shows 0% progress, full amount as pending, and days remaining calculated from current date |

**Story Points:** 5
**Status:** Done
**Phase:** 6 — Budgets and Goals

---

### US-043: Edit or delete monthly budget limit
**As a** registered user
**I want to** edit the limit of an existing monthly budget or delete it
**So that** I can adjust my spending objectives when my financial priorities change

**Acceptance Criteria:**
- [x] `PUT /api/budgets/{id}` accepts updated amountLimit (must be > 0, ownership validated)
- [x] After editing, progress bar recalculates based on current spent amount
- [x] `DELETE /api/budgets/{id}` removes the budget (ownership validated)
- [x] After deletion, no more 80% alerts generated for that category in that period
- [x] Confirmation dialog required before deletion

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an active budget and modifies its limit with a value greater than zero | Saves changes | New limit applied in < 5 seconds and the progress bar recalculates with current accumulated spend |
| 2 | User selects an active budget and confirms its deletion | System processes the request | Budget disappears from the panel and no more alerts are generated for that category |

**Story Points:** 3
**Status:** Done
**Phase:** 6 — Budgets and Goals

---

### US-045: Mark goal as completed or delete it
**As a** registered user
**I want to** mark a savings goal as completed or delete it if I no longer want to follow it
**So that** I can keep my goals list updated and focus on the objectives that remain relevant

**Acceptance Criteria:**
- [x] Goal can be manually marked as completed (`PUT /api/goals/:id/complete`)
- [ ] Completed goals move to a completed section with finish date displayed
- [x] Goal can be deleted (active or completed) with ownership validated
- [x] Deleting a goal removes all associated contributions from the record
- [ ] Confirmation dialog required before mark-complete action

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has reached the target amount of an active goal and marks it as completed | Confirms the action | Goal moves to completed section with finish date recorded in < 5 seconds |
| 2 | User decides to abandon an active goal and confirms its deletion | System processes the request | Goal disappears from active list and all its contributions are removed from the record |

**Story Points:** 3
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

## Epic 6: AI Auto-Categorization

**Goal:** The AI analyzes transaction descriptions and amounts to suggest the most appropriate category automatically.

### US-018: AI auto-categorization suggestion
**As a** university student
**I want to** have the AI automatically suggest the category of a transaction by analyzing its description or amount
**So that** I can reduce recording time and avoid manual categorization errors, keeping my reports organized

**Acceptance Criteria:**
- [x] When recording a transaction, description and amount are sent for category inference
- [x] Returns suggested categoryId with confidence level
- [x] Pre-selects the suggested category in the transaction form (user can override)
- [x] Falls back gracefully if API is unavailable or confidence < 60%

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a recognizable description when recording a transaction | System analyzes the text | App suggests most appropriate category in < 10 seconds with option to accept or change it, achieving correct classification rate above 80% for recognizable texts |
| 2 | User enters a very short or ambiguous description | System tries to classify the transaction | App does not force any category and allows user to select manually |

**Story Points:** 5
**Status:** Done
**Phase:** 7 — AI Integration

---

## Epic 7: Predictions

**Goal:** The app anticipates future expenses based on history and patterns detected by AI.

### US-015: AI expense prediction next month
**As a** registered user
**I want to** consult the AI prediction of my expenses for next month with breakdown by category and confidence level
**So that** I can anticipate my next month's expenses and plan to not run out of funds on critical dates

**Acceptance Criteria:**
- [x] `GET /api/predictions/expenses?period=next_month` calls AI API
- [x] Returns: predicted_total, predicted_by_category, confidence_level
- [x] Requires minimum 2-month history
- [x] Screen shows prediction with confidence indicator (only shown if confidence >= 60%)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has at least two months of expense history | Requests next-month prediction | App shows estimated amount, breakdown by category and confidence level in < 10 seconds, visible only if confidence is equal to or above 60% |
| 2 | User has less than two months of history | Tries to view prediction | App shows message indicating more history is needed to generate a reliable prediction |

**Story Points:** 8
**Status:** In Progress
**Phase:** 8 — Predictions

---

### US-016: AI anomaly alert when >20% above monthly average
**As a** registered user
**I want to** receive an AI alert when my expenses in a category exceed 20% of my monthly historical average
**So that** I can detect unusual expenses in time that may compromise my budget before they become hard to correct

**Acceptance Criteria:**
- [x] Trigger when recording transaction — if category spending exceeds >20% average of last 3 months, generates alert
- [x] In-app notification with message indicating the unusual increase
- [ ] Maximum one alert per category per month

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User registers a transaction that makes monthly spending in a category exceed 20% above the historical average | Transaction is recorded | App automatically sends a notification alerting of the unusual increase in < 10 seconds |
| 2 | User registers a transaction that does not exceed the 20% threshold in any category | Transaction is recorded | System generates no alert and registration completes normally |

**Story Points:** 5
**Status:** Done
**Phase:** 8 — Predictions

---

## Epic 8: Personalized Recommendations

**Goal:** AI generates actionable suggestions based on user data.

### US-017: Personalized AI recommendations
**As a** university student
**I want to** receive personalized AI recommendations based on my financial history, goals and active budgets
**So that** I can make smarter financial decisions with concrete suggestions adapted to my real situation

**Acceptance Criteria:**
- [x] `GET /api/recommendations` generates 1-5 active recommendations
- [x] Based on: spending patterns, predictions, budgets, goals
- [x] Each recommendation with concrete message and suggested action
- [x] Integrated into Dashboard
- [x] Cards with feedback button

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has at least one month of history and at least one active goal or budget | Accesses recommendations section | App shows between 1 and 5 suggestions in Spanish adapted to their financial situation in no more than 10 seconds |
| 2 | User has no spending history or active goals | Accesses recommendations section | App shows message indicating more data is needed to generate recommendations |

**Story Points:** 8
**Status:** Done
**Phase:** 9 — Recommendations

---

## Epic 9: Financial Education

**Goal:** Users learn key financial concepts through content adapted to their level.

### US-023: Financial education modules
**As a** university student
**I want to** access financial education modules with practical content adapted to Peruvian university students
**So that** I can progressively improve my understanding of personal finance and make more informed decisions

**Acceptance Criteria:**
- [x] `GET /api/education/topics` returns topic list with user progress
- [x] `GET /api/education/topics/{id}` returns complete content
- [x] `PATCH /api/education/topics/{id}/complete` marks as viewed
- [x] Content in readable mobile format with practical Peruvian examples
- [x] Overall progress visible

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an available financial education module | Opens it | App shows complete topic content in < 5 seconds with practical information adapted to Peruvian university students |
| 2 | User completes reading a module | Closes module or navigates to another section | System records the module as viewed and distinguishes it visually from unread ones |

**Story Points:** 8
**Status:** Done
**Phase:** 10 — Education and Gamification

---

### US-026: Financial knowledge quiz with instant feedback
**As a** university student
**I want to** answer financial knowledge challenge questions and receive immediate feedback after each answer
**So that** I can actively learn personal finance within the app through the practice of key concepts

**Acceptance Criteria:**
- [x] `GET /api/education/topics/:id/quiz` returns randomized questions from the topic pool
- [x] `POST /api/education/topics/:id/quiz/submit` returns score, correctCount, totalCount, and per-question feedback
- [x] Multiple-choice questions with immediate feedback after submission
- [x] Batch feedback shown after submitting all answers: correct/incorrect per question with correct answer revealed

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an answer in a knowledge challenge | Confirms their answer | App shows in < 2 seconds whether it is correct or incorrect with a brief explanation of the concept |
| 2 | User answers all challenge questions | Presses finish | App shows score expressed as a percentage, saves it in history, and marks the challenge as completed |

**Story Points:** 8
**Status:** Done
**Phase:** 10 — Education and Gamification

---

### US-048: AI-personalized learning path
**As a** university student
**I want to** receive a learning path ordered by AI according to my spending patterns and financial areas with the most room for improvement
**So that** I can focus my learning on the most relevant topics for my real situation and improve my financial literacy faster

**Acceptance Criteria:**
- [ ] `GET /api/education/learning-path` returns modules ordered by relevance for the user's financial situation
- [ ] AI analyzes user's spending history, budgets and goals to determine priority topics
- [ ] Each module includes a brief explanation of why it is prioritized for this user
- [ ] If insufficient history, returns modules in default order indicating path will personalize with more usage

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transaction history and at least one active budget or goal | Accesses financial education section | AI shows modules ordered from most to least relevant in < 10 seconds, each with a brief explanation of why it is a priority |
| 2 | User does not have sufficient transaction history to personalize the path | Accesses financial education section | App shows modules in default order and indicates the path will personalize as more transactions are recorded |

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

### US-049: AI-generated contextual financial questions
**As a** university student
**I want to** answer financial knowledge questions generated by AI based on my spending habits and areas where I have room for improvement
**So that** I can practice financial concepts directly related to my real behavior and learn more effectively

**Acceptance Criteria:**
- [ ] `GET /api/education/quizzes/contextual` returns questions generated by AI based on user's financial patterns
- [ ] Questions relate to categories where the user overspends, unmet budgets, or savings gaps
- [ ] If insufficient history, returns generic fundamental finance questions with a note
- [ ] Distinct from US-1004 static quizzes: questions change based on the user's latest financial data

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has history with at least one high-spending category or exceeded budget | Accesses a financial knowledge challenge | AI generates questions related to their most relevant financial habits in < 10 seconds |
| 2 | User does not have sufficient history for personalization | Accesses a knowledge challenge | App shows generic questions about fundamental concepts and indicates they will personalize with more usage |

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

## Epic 10: Gamification

**Goal:** Users stay motivated through challenges, badges, and visible progress.

### US-024 / US-046: View, accept and auto-verify financial challenges
**As a** university student
**I want to** see and accept available financial mini-challenges, and have the app automatically verify whether I met the conditions of an active challenge
**So that** I can improve my financial habits through concrete challenges and receive recognition for my achievements without reporting them manually

**Thesis IDs:** US-024 (view and accept challenges), US-046 (auto-verify challenge completion)

**Acceptance Criteria:**
- [x] `GET /api/challenges` returns challenges with user status (available/active/completed)
- [x] `POST /api/challenges/{id}/accept` accepts challenge
- [x] Automatic verification based on criteria — verifies daily recording streak and savings goal contributions
- [x] Seed challenges available
- [x] Screen with active challenges (progress), available (accept), completed (date)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses challenges section and selects an available one (US-024) | Confirms acceptance | Challenge moves to active status showing deadline and conditions in < 5 seconds |
| 2 | User already has an active challenge of the same type (US-024) | Tries to accept it again | System informs that the challenge is already active and does not allow duplication |
| 3 | User has an active challenge and their actions in the app fulfill the conditions within the deadline (US-046) | System runs verification | Challenge marked as completed, date recorded, and achievement notification shown to user |
| 4 | User has an active challenge whose deadline passes without meeting conditions (US-046) | System detects the expiration date | Challenge moves to expired section and becomes available to accept again |

**Story Points:** 8
**Status:** In Progress
**Phase:** 10 — Education and Gamification

---

### US-025: Earn achievement badges
**As a** registered user
**I want to** receive a badge in my profile upon completing a goal, finishing a challenge or reaching a usage milestone
**So that** I feel recognized for my progress and stay motivated to keep using the app

**Acceptance Criteria:**
- [x] `GET /api/badges` returns all badges with status (earned/not)
- [x] Automatic assignment on meeting criteria
- [x] Badge grid: color if earned, gray if not
- [x] Tap shows detail: name, description, criteria, date earned

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes a goal, a challenge or reaches a defined usage milestone | System verifies fulfillment | Badge automatically assigned and appears in the achievements section of the profile |
| 2 | User already has an assigned badge and meets the same criterion again | System verifies | No duplicate badge generated and original record is maintained |

**Story Points:** 8
**Status:** In Progress
**Phase:** 10 — Education and Gamification

---

## Epic 11: Notifications

**Goal:** Proactive alerts maintain engagement and prevent financial problems.

### US-020: Budget 80% threshold notification
**As a** university student
**I want to** receive an automatic notification when my expenses in a category reach 80% of the defined monthly limit
**So that** I can act in advance before exceeding my budget and avoid ending the month with a deficit

**Acceptance Criteria:**
- [x] If current_spent / budget_limit >= 0.80 → sends notification
- [x] Message indicating user is close to exceeding the budget with remaining amount
- [x] Configurable: user can disable this alert type

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has a defined budget and accumulated spending reaches 80% of the limit | Transaction registered that crosses that threshold | App sends a notification in < 5 seconds indicating they are close to exceeding the budget |
| 2 | User has no budget defined for the category | Records expenses of any amount | No alerts are generated and the app shows a shortcut to configure budgets |

**Story Points:** 5
**Status:** Done
**Phase:** 11 — Notifications

---

### US-016: AI anomaly alert (spending alert)
**As a** registered user
**I want to** receive an AI alert when my expenses in a category exceed 20% of my historical monthly average
**So that** I can detect unusual spending in time that may compromise my budget

**Acceptance Criteria:**
- [x] Trigger when recording transaction — if category spending exceeds >20% average of last 3 months, generates alert
- [x] In-app notification: "Your spending in {category} this month is {x}% higher than your average"
- [ ] Maximum one alert per category per month

**Story Points:** 3
**Status:** Done
**Phase:** 11 — Notifications

---

## Epic 12: Impact Evaluation

**Goal:** Quantitatively measure whether the app improves users' financial education.

### US-033: Initial financial knowledge assessment
**As a** university student
**I want to** answer the initial financial knowledge assessment when I open the app for the first time
**So that** a measurable baseline of financial education is established to compare with my results at the end of using Zenda

**Acceptance Criteria:**
- [x] `POST /api/surveys/pre/response` endpoint exists with authentication
- [x] Presented during onboarding or first week of usage
- [x] Automatic score calculation using correct answers
- [x] Screen: one question per view, progress bar, partial save

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes onboarding and answers all initial assessment questions | Presses finish | Answers stored with date in < 3 seconds and user is redirected to the main dashboard |
| 2 | User tries to advance without answering the current question | Presses next | System indicates the question must be answered before continuing |

**Story Points:** 8
**Status:** In Progress
**Phase:** 12 — Evaluation

---

### US-034 / US-047: Final financial knowledge assessment
**As a** university student
**I want to** receive the invitation for the final knowledge assessment after 30 days of active use, and complete it when I receive the invitation
**So that** I am reminded to complete the final assessment to measure my financial evolution and measure how much my knowledge improved thanks to using Zenda

**Thesis IDs:** US-034 (invitation after 30 days), US-047 (complete final evaluation)

**Acceptance Criteria:**
- [x] `POST /api/surveys/post/response` endpoint exists
- [x] Same questionnaire (variant to avoid memorization) with real scoring
- [x] Non-intrusive invitation shown after 30 days of use
- [x] Invitation persists until evaluation is completed or pilot period ends
- [x] On completion: visual comparison showing pre-score, post-score and improvement

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has completed 30 days of active use and has not yet answered the final evaluation (US-034) | Accesses main screen | App shows non-intrusive invitation to complete the final evaluation |
| 2 | User dismisses the invitation without completing the evaluation (US-034) | Returns to app in following days | Invitation reappears until evaluation is completed or pilot period ends |
| 3 | User accesses to complete the final evaluation (US-047) | Answers all questions and presses finish | Answers stored linked to initial evaluation in < 5 seconds, allowing improvement percentage to be calculated |
| 4 | User tries to submit with unanswered questions (US-047) | Presses finish | System highlights pending questions and blocks submission until all are completed |

**Story Points:** 8
**Status:** Done
**Phase:** 12 — Evaluation

---

## Epic 13: Security and Compliance

**Goal:** Financial data protected per Law 29733 and international standards.

### US-029: Encrypted transmission and secure server storage
**As a** registered user
**I want to** have my personal and financial data transmitted encrypted and stored securely on the server
**So that** I have certainty that my personal and financial information is protected, in compliance with Law 29733 on Personal Data Protection of Peru

**Acceptance Criteria:**
- [ ] TLS on all API communications (mandatory HTTPS)
- [ ] Data stored encrypted on server
- [x] flutter_secure_storage for sensitive local data (JWT tokens)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | App makes a request to the server | Data is transmitted | Communication occurs exclusively via HTTPS with TLS and data is stored encrypted on the server |
| 2 | A request is made to protected endpoints without a valid JWT token or with an expired one | Server receives the request | Server responds with error 401 without exposing sensitive information |

**Story Points:** 5
**Status:** Not Started
**Phase:** 13 — Security

---

## Epic 14: Testing

**Goal:** Quality verified with usability tests with real users.

### US-035: Complete SUS usability questionnaire
**As a** pilot study participant
**I want to** complete the SUS usability questionnaire from the app at the end of the test period
**So that** I can contribute with my experience evaluation to the app's validation and the objective measurement of its usability

**Acceptance Criteria:**
- [x] SUS questionnaire accessible from the app at end of pilot period
- [x] 10 questions with Likert scale responses
- [x] System calculates SUS score on scale 0 to 100
- [x] Submission blocked if questions are unanswered

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses the usability evaluation at the end of the pilot period and answers all 10 SUS questions | Presses submit | Answers stored in < 5 seconds and system calculates SUS score on a scale of 0 to 100 |
| 2 | User tries to submit the questionnaire with unanswered questions | Presses submit | System highlights pending questions and does not allow submission |

**Story Points:** 13
**Status:** Not Started
**Phase:** 14 — Testing

---

## Epic 15: User Feedback and Analytics

**Goal:** Pilot users can report bugs and suggestions; usage metrics support research conclusions.

### US-036: Submit in-app feedback and suggestions
**As a** university student
**I want to** send my comments and suggestions about the app from a dedicated section
**So that** I can contribute direct evidence to the app's improvement process so that future versions are more useful

**Acceptance Criteria:**
- [x] `POST /api/feedback` accepts: type, message, optional rating
- [x] Feedback accessible from profile
- [x] Confirmation shown after submission

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User writes a comment with at least one character | Presses send | Comment stored with date and user identifier in < 5 seconds, and app shows a confirmation |
| 2 | User writes no comment | Presses send | System shows message indicating the field cannot be empty |

**Story Points:** 3
**Status:** Done
**Phase:** 15 — Feedback

---

### US-037: Automatic usage pattern logging for research
**As a** researcher
**I want to** analyze the usage patterns automatically recorded in the app for each user
**So that** I can identify which features are most used and support research conclusions with data

**Acceptance Criteria:**
- [x] Events logged: login, register, record_transaction, delete_transaction, create_goal, contribute_goal, complete_goal, accept_challenge, complete_challenge, complete_topic, create_budget, submit_feedback
- [x] `AnalyticsEvent` model: userId, eventType, metadataJson, createdAt
- [x] Async logging — does not block use-case response path

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User performs a key action such as recording a transaction, consulting a report or accepting a challenge | Executes the action | System records the event type and timestamp in < 300 milliseconds without generating any perceptible delay |
| 2 | A failure occurs when recording an event due to connectivity or internal error | Logging fails | Error captured silently without interrupting the user's action and system retries on the next synchronization |

**Story Points:** 3
**Status:** In Progress
**Phase:** 15 — Feedback

---

## Summary Statistics

**Total User Stories:** 49 (matching the 49 official thesis user stories US-001–US-049)
**Total Story Points:** 282

**Status Overview:**
- Done: 24
- In Progress: 12
- Not Started: 13
- Blocked: 0

**Done:** US-027, US-028, US-031, US-012 / US-039, US-003, US-005, US-040 / US-041, US-009 / US-038, US-008, US-007, US-011, US-010, US-013, US-014, US-022, US-043, US-018, US-016, US-017, US-023, US-026, US-020, US-016 (alert), US-034 / US-047, US-036

**In Progress:** US-030 / US-032, US-001 / US-005, US-002 / US-006, US-004, US-019 / US-042, US-021 / US-044, US-045, US-015, US-024 / US-046, US-025, US-033, US-037

**Not Started:** US-048, US-049, US-029, US-035

---

## How to Use This Document

**Before starting new work:**
1. Check the **Thesis ID** on the story and the cross-reference table to align with official thesis requirements
2. Verify acceptance criteria and BDD scenarios as definition of "done"
3. Review corresponding phase in [roadmap.md](./roadmap.md)
4. Update status to In Progress
5. Implement following standards
6. Update status to Done when all criteria are met

**Related documents:**
- [mission.md](./mission.md) — Product vision and objectives
- [roadmap.md](./roadmap.md) — Execution plan by phases
- [docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md](../../../docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md) — **Source of truth: full BDD acceptance criteria in Spanish (Dado/Cuando/Entonces)**
- [docs/thesisDocs/P202616_Product_Backlog_V1.md](../../../docs/thesisDocs/P202616_Product_Backlog_V1.md) — Official thesis product backlog (49 HUs, sprint assignments)
- [docs/thesisDocs/P202616_Epicas_HU_V1.md](../../../docs/thesisDocs/P202616_Epicas_HU_V1.md) — Official epic-to-HU mapping
