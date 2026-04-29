# Zenda — User Stories

**Project:** Zenda — AI-Powered Mobile Financial Management App for University Students
**Duration:** 10.5 months (February — December 2026)
**Budget:** S/ 14,241
**Status Tracking:** Done | In Progress | Not Started | Blocked

> **Thesis ID source of truth:** `docs/thesisDocs/P202616_Product_Backlog_V1.md` — 49 official user stories (US-001–US-049). This document uses development IDs (US-XXYY). See the cross-reference table below for the mapping.

---

## Thesis User Story Cross-Reference

| Thesis ID | Title | Dev ID(s) | Phase | Notes |
|-----------|-------|-----------|-------|-------|
| US-001 | Record income manually | US-0201 | 3 | |
| US-002 | Record expense manually | US-0202 | 3 | |
| US-003 | Edit recorded transaction | US-0205 | 3 | |
| US-004 | Delete transaction with confirmation | US-0206 | 3 | |
| US-005 | Assign category when recording income | US-0201, US-0301 | 3–4 | Category assignment is part of income recording |
| US-006 | Assign/change category on expense | US-0202, US-0302 | 3–4 | Category mandatory on save |
| US-007 | Daily expense summary with category breakdown | US-0403 | 5 | |
| US-008 | Weekly summary grouped by day | US-0402 | 5 | |
| US-009 | Monthly income/expense/balance totals | US-0401 | 5 | |
| US-010 | Category expense chart (% and amount) | US-0405 | 5 | |
| US-011 | Multi-month comparison chart | US-0404 | 5 | |
| US-012 | Filter history by date range and type | US-0203 | 3 | |
| US-013 | Export report as PDF and share | US-0406 | 5 | |
| US-014 | Financial evolution indicator vs. prior months | US-0407 | 5 | |
| US-015 | AI expense prediction next month | US-0801 | 8 | |
| US-016 | AI anomaly alert when >20% above monthly average | US-0803, US-1103 | 8, 11 | Covered in both AI and notifications epics |
| US-017 | Personalized AI recommendations | US-0901 | 9 | |
| US-018 | AI auto-categorization suggestion | US-0702 | 7 | |
| US-019 | Define monthly budget by category | US-0501 | 6 | |
| US-020 | Budget 80% threshold notification | US-1102 | 11 | |
| US-021 | Create savings goal with deadline | US-0502 | 6 | |
| US-022 | View goal progress detail | US-0503 | 6 | |
| US-023 | Financial education modules | US-1001 | 10 | |
| US-024 | View and accept financial mini-challenges | US-1002 | 10 | |
| US-025 | Earn achievement badges | US-1003 | 10 | |
| US-026 | Financial knowledge quiz with instant feedback | US-1004 | 10 | |
| US-027 | Register with auto-login after sign-up | US-0101 | 2 | |
| US-028 | Login with 15-min lockout after 3 failures | US-0102 | 2 | |
| US-029 | Encrypted transmission and secure server storage | US-1301 | 13 | |
| US-030 | Complete initial financial profile on first use | US-0105 | 2 | |
| US-031 | Select currency and number format | US-0106 | 2 | |
| US-032 | Guided onboarding screens on first launch | US-0105 | 2 | Combined with US-030 in US-0105 |
| US-033 | Initial financial knowledge assessment | US-1201 | 12 | |
| US-034 | Receive invitation for final assessment after 30 days | US-1202 | 12 | |
| US-035 | Complete SUS usability questionnaire | US-1404 | 14 | |
| US-036 | Submit in-app feedback and suggestions | US-1501 | 15 | |
| US-037 | Automatic usage pattern logging for research | US-1502 | 15 | |
| US-038 | Category breakdown in monthly summary | US-0401 (criteria) | 5 | BDD scenarios added to US-0401 |
| US-039 | Filter history by category and amount range | US-0203 (criteria) | 3 | BDD scenarios added to US-0203 |
| US-040 | Create custom category | US-0302 | 4 | |
| US-041 | Rename or delete custom category | US-0302 | 4 | |
| US-042 | View active budget summary with progress | US-0501 (criteria) | 6 | BDD scenarios added to US-0501 |
| US-043 | Edit or delete monthly budget limit | **US-0504** (new) | 6 | |
| US-044 | Contribute amount to savings goal | US-0502 (criteria) | 6 | BDD scenarios added to US-0502 |
| US-045 | Mark goal as completed or delete it | **US-0505** (new) | 6 | |
| US-046 | Auto-verify active challenge completion | US-1002 (criteria) | 10 | BDD scenarios added to US-1002 |
| US-047 | Complete final financial knowledge evaluation | US-1202 (criteria) | 12 | BDD scenarios added to US-1202 |
| US-048 | AI-personalized learning path | **US-1006** (new) | 10 | |
| US-049 | AI-generated contextual financial questions | **US-1007** (new) | 10 | |

> **Bold** dev IDs = new stories added in this document that did not exist before. Stories marked "(criteria)" are covered as acceptance criteria within the referenced dev story rather than as standalone stories.

---

## Epic 1: Authentication and User Management

**Goal:** Every user must register, authenticate, and configure their financial profile before accessing features.

### US-0101: User Registration
**As a** university student
**I want to** register with a secure method
**So that** my personal financial data is protected

**Thesis ID:** US-027

**Acceptance Criteria:**
- [x] `POST /api/auth/register` accepts: email, password, fullName
- [x] Email validated with correct format, no duplicates
- [x] Password >= 8 characters with at least 1 uppercase, 1 lowercase, 1 number
- [x] Password hashed with bcrypt (cost factor 12) before storage
- [x] Account created with `profileCompleted = false`
- [x] Returns valid JWT token for 30 days
- [x] Registration screen with real-time validation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a valid name, an unregistered email, and a password meeting requirements | Presses register | Account created, app auto-logs in and redirects to onboarding in < 5 seconds |
| 2 | User enters an email that is already registered | Presses register | System shows message that email is in use and suggests logging in instead |

**Story Points:** 5
**Status:** Done
**Phase:** 2 — Authentication

---

### US-0102: Login
**As a** registered user
**I want to** log in with my credentials
**So that** only I can access my financial information

**Thesis ID:** US-028

**Acceptance Criteria:**
- [x] `POST /api/auth/login` accepts email and password
- [x] Correct credentials return JWT token
- [x] Incorrect credentials return 401 with generic message
- [ ] Temporary lockout after 3 consecutive failed attempts (15 minutes)
- [x] JWT stored in flutter_secure_storage
- [x] Auto-login if valid JWT exists when opening app

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters correct email and password | Presses login | App validates credentials and redirects to main dashboard in < 5 seconds |
| 2 | User enters incorrect credentials three consecutive times | Third attempt fails | System locks access for 15 minutes, shows remaining time, disables the button |

**Story Points:** 5
**Status:** In Progress
**Phase:** 2 — Authentication

---

### US-0103: Authentication Middleware
**As a** system
**I want to** validate JWT on each authenticated request
**So that** only valid users access the API

**Acceptance Criteria:**
- [x] Intercepts all routes `/api/*` except `/api/auth/*`
- [x] Extracts token from `Authorization: Bearer {token}` header
- [x] Validates JWT signature, expiration, and structure
- [x] Loads `userId` into request context via `@UserId()` decorator
- [x] Returns 401 Unauthorized if token is invalid, expired, or absent
- [ ] Logging of unauthorized access attempts

**Story Points:** 3
**Status:** Done
**Phase:** 2 — Authentication

---

### US-0104: Password Recovery
**As a** user
**I want to** recover my account if I forget my password
**So that** I don't lose access to my financial history

**Acceptance Criteria:**
- [x] `POST /api/auth/forgot-password` accepts email
- [x] Sends email with reset token (expires in 1 hour)
- [x] `POST /api/auth/reset-password` accepts token + new password
- [x] Token invalidated after use (single-use)
- [x] "Forgot my password" screen with email field
- [x] Confirmation message: "Check your email"

**Story Points:** 3
**Status:** Done
**Phase:** 2 — Authentication

---

### US-0105: Initial Profile Setup (Onboarding)
**As a** student
**I want to** set up my financial profile on first login
**So that** I receive recommendations adapted to my situation

**Thesis IDs:** US-030 (initial financial profile), US-032 (guided onboarding screens)

**Acceptance Criteria:**
- [x] Presented after first successful login (if `profileCompleted = false`)
- [x] Fields: age, university, income type (scholarship/work/family/mixed), average monthly income, preferred currency (default PEN)
- [x] Each field on individual screen with smooth transition
- [x] Optional skip with message: "Completing your profile improves predictions by 40%"
- [ ] On completion: `profileCompleted = true`, `financialLiteracyLevel` assigned based on responses (backend integration pending)
- [x] Data editable later in profile

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes the form with all required fields valid (US-030) | Presses save | Data stored and user accesses main screen in < 5 seconds |
| 2 | User tries to save with one or more required fields empty (US-030) | Presses save | System highlights missing fields and blocks progress until all are filled |
| 3 | User navigates through all onboarding screens to the last one (US-032) | Finishes onboarding | User accesses main screen with active session |
| 4 | User does not want to see the onboarding (US-032) | Presses skip | App jumps to main screen and never shows onboarding again |

**Story Points:** 5
**Status:** In Progress
**Phase:** 2 — Authentication

---

### US-0106: Profile and Preferences Editing
**As a** user
**I want to** edit my profile and app preferences
**So that** my information stays up to date and the experience is personalized

**Thesis ID:** US-031

**Acceptance Criteria:**
- [x] `GET /api/users/me` returns complete user profile
- [x] `PUT /api/users/me` accepts editable fields: fullName, university, incomeType, averageMonthlyIncome, currency
- [x] Profile screen with all editable fields
- [x] Currency selector: PEN (default), USD
- [ ] Number format: thousands separator (dot/comma)
- [x] Changes saved with visual confirmation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a different currency and number format | Saves changes | All amounts in the app update to the new format without restarting |
| 2 | User modifies settings but closes the app without saving | Reopens the app | Previous configuration is maintained without changes |

**Story Points:** 3
**Status:** In Progress
**Phase:** 2 — Authentication

---

## Epic 2: Transaction Recording

**Goal:** Students can record income and expenses simply and quickly, maintaining a clean and searchable history.

### US-0201: Record Income
**As a** student
**I want to** manually record my income
**So that** I can track my money sources

**Thesis ID:** US-001

**Acceptance Criteria:**
- [x] `POST /api/transactions` accepts: `type: INCOME`, `amount` (> 0), `categoryId`, `description` (optional), `occurredAt`
- [x] Validates that category exists and is of type INCOME
- [x] Creates transaction and returns with updated monthly balance
- [x] Screen with: type selector (Income/Expense toggle), numeric amount input, category selector, date picker (default today), description field
- [x] Confirmation message: "Income of S/{amount} recorded"
- [ ] Balance on main screen updates immediately after recording (not yet synced in real-time)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is authenticated with all required fields filled (amount, category, date) | Presses save | Income registered in < 2 seconds, appears in history, balance updated |
| 2 | User leaves amount field empty or enters zero | Presses save | Error message shown under amount field, income not registered |

**Story Points:** 5
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-0202: Record Expense
**As a** student
**I want to** manually record my expenses
**So that** I know what I spend my money on

**Thesis ID:** US-002

**Acceptance Criteria:**
- [x] Same endpoint `POST /api/transactions` with `type: EXPENSE`
- [x] Validates that category is of type EXPENSE
- [x] Updates balance by subtracting the amount
- [x] Appears in history sorted by date descending
- [ ] If expense exceeds category average (>20%), triggers anomaly detection

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is on the new expense screen with valid amount, category, and date | Presses save | Expense registered in < 2 seconds, appears in history, balance updated |
| 2 | User enters a negative amount or non-numeric characters | Presses save | Validation error shown, saving not allowed |

**Story Points:** 5
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-0203: Transaction History with Filters
**As a** user
**I want to** apply advanced filters to my history
**So that** I can quickly find specific information

**Thesis IDs:** US-012 (filter by date range and type), US-039 (filter by category and amount range)

**Acceptance Criteria:**
- [x] `GET /api/transactions` with query params: `type`, `categoryId`, `dateFrom`, `dateTo`, `minAmount`, `maxAmount`, `search` (description), `page`, `limit`, `sort`
- [x] Returns paginated list with total results
- [x] Screen with collapsible filters: date range, category, type, amount range (frontend local-only)
- [x] Text search in description
- [x] Infinite scroll pagination
- [ ] Response time < 2 seconds with 1000+ transactions (not benchmarked)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User applies a filter by date range and/or transaction type (US-012) | System processes filters | List shows only matching transactions in < 2 seconds |
| 2 | Applied filters match no transactions (US-012) | System processes filters | App shows empty state indicating no results found |
| 3 | User applies a filter for a specific category (US-039) | System processes filter | List shows only transactions of that category in < 2 seconds |
| 4 | User enters a minimum and maximum amount as a filter (US-039) | System processes range | List shows only transactions within the defined range |

**Story Points:** 5
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-0204: Main Dashboard
**As a** student
**I want to** see a quick summary of my financial situation when opening the app
**So that** I have an instant snapshot of my status

**Acceptance Criteria:**
- [x] Main screen shows: current month balance (income - expenses), total monthly income, total monthly expenses
- [x] Last 5 transactions with category icon, amount, and date
- [x] FAB (Floating Action Button) "+" to add transaction
- [x] Pull-to-refresh to update data
- [ ] Full load in < 2 seconds (not benchmarked)
- [x] "Suggestions" section with latest AI recommendation (ZendaAiCard wired to GET /api/recommendations)

**Story Points:** 8
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

### US-0205: Edit Transaction
**As a** user
**I want to** edit recorded transactions
**So that** I can correct incorrect information

**Thesis ID:** US-003

**Acceptance Criteria:**
- [x] `PUT /api/transactions/{id}` accepts modifiable fields: amount, categoryId, description, occurredAt
- [x] Validates that transaction belongs to authenticated user (403 if not)
- [x] Transactions from another user return 403 Forbidden
- [x] Balance and reports recalculated after edit
- [x] Tap on transaction opens pre-filled edit screen
- [x] "Save changes" button with confirmation

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a transaction and modifies one or more fields with valid values | Presses save changes | Transaction updated and reports reflect the change in < 3 seconds |
| 2 | User clears the amount field leaving it empty | Presses save changes | System shows validation error and keeps original value without modifying |

**Story Points:** 3
**Status:** Done
**Phase:** 3 — Transaction Recording

---

### US-0206: Delete Transaction
**As a** user
**I want to** delete transactions
**So that** I maintain a clean history

**Thesis ID:** US-004

**Acceptance Criteria:**
- [x] `DELETE /api/transactions/{id}` performs soft delete (`deletedAt = NOW()`)
- [x] Validates ownership (403 if not belonging to user)
- [x] Confirmation dialog: "Are you sure? This action will remove the transaction from your reports"
- [x] Transaction disappears from history and reports
- [ ] Balance recalculated immediately (not yet synced in real-time)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User views a transaction in history and presses delete | Confirms the action in the verification dialog | Transaction removed from history, balance recalculated, reports updated in < 5 seconds |
| 2 | User presses delete and the confirmation dialog appears | Presses cancel | Transaction stays in history unchanged and balance remains the same |

**Story Points:** 2
**Status:** In Progress
**Phase:** 3 — Transaction Recording

---

## Epic 3: Categorization System

**Goal:** Transactions are organized by categories that feed reports, budgets, and predictions.

### US-0301: Default Categories
**As a** student
**I want to** have predefined expense and income categories
**So that** I can categorize my transactions without prior setup

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
| 1 | User is recording an income and selects a category from the list (US-005) | Saves the income | Income associated with that category, correctly grouped in reports |
| 2 | User tries to save an expense without selecting any category (US-006) | Presses save | System shows message that category is required and does not register the expense |

**Story Points:** 3
**Status:** Done
**Phase:** 4 — Categorization

---

### US-0302: Custom Categories
**As a** user
**I want to** create my own categories
**So that** I can organize my finances according to my specific needs

**Thesis IDs:** US-040 (create custom category), US-041 (rename or delete custom category)

**Acceptance Criteria:**
- [x] `POST /api/categories` creates category: name, type (INCOME/EXPENSE), icon, color
- [x] `GET /api/categories` returns default + user's custom categories
- [x] `PUT /api/categories/{id}` edits name/icon/color (ownership validated)
- [x] `DELETE /api/categories/{id}` deletes (custom only, error if has transactions)
- [x] "Create new category" option visible when recording transaction (+ chip in CategoryGrid)
- [x] Quick creation modal from AddTransactionScreen (name only; icon/color set via full CategoryManagementScreen)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses category management and enters a unique name (US-040) | Presses save | Category created in < 5 seconds, available in list for assignment to new transactions |
| 2 | User enters a category name that already exists (US-040) | Presses save | System shows error message and does not create the duplicate |
| 3 | User selects a custom category and changes its name to a unique value (US-041) | Saves changes | New name applied in < 5 seconds, reflected in all previously associated transactions |
| 4 | User tries to delete a category that has associated transactions (US-041) | Confirms deletion | System shows message asking to reassign transactions before deleting |

**Story Points:** 5
**Status:** Done
**Phase:** 4 — Categorization

---

## Epic 4: Financial Reports

**Goal:** Users visualize their financial habits with clear data and intuitive charts.

### US-0401: Monthly Summary
**As a** user
**I want to** see a monthly summary of my finances
**So that** I can evaluate my financial health for the month

**Thesis IDs:** US-009 (monthly income/expense/balance totals), US-038 (category breakdown in monthly summary)

**Acceptance Criteria:**
- [x] `GET /api/insights/monthly?year={y}&month={m}` returns: totalIncome, totalExpenses, balance, breakdownByCategory (array with name, amount, percentage), transactionCount
- [x] Screen with: total income (green), total expenses (red), balance (green/red depending on sign)
- [x] Pie chart of expenses by category with legend and percentages (fl_chart)
- [x] Top 3 expense categories with icons
- [x] Month selector (← previous / next →)
- [ ] Response time < 2 seconds (not benchmarked)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions in the selected month (US-009) | Accesses monthly summary | App shows total income, expenses, and balance in < 3 seconds |
| 2 | User selects a month without registered transactions (US-009) | Accesses monthly summary | App shows empty state with all totals at zero |
| 3 | User has categorized transactions in the selected month (US-038) | Accesses category breakdown | App shows amount and percentage per category sorted highest to lowest in < 3 seconds |
| 4 | User selects a month without categorized transactions (US-038) | Accesses breakdown | App shows message indicating insufficient data |

**Story Points:** 8
**Status:** Done
**Phase:** 5 — Reports

---

### US-0402: Weekly Summary
**As a** user
**I want to** see a weekly summary
**So that** I can identify early trends in my spending

**Thesis ID:** US-008

**Acceptance Criteria:**
- [x] `GET /api/insights/weekly?year={y}&week={w}` returns same structure as monthly
- [x] Totals correctly grouped by ISO week
- [x] Week selector with visible dates (Mon-Sun)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions on different days of a week | Selects that week | App shows income and expense totals grouped correctly per day in < 5 seconds |
| 2 | User selects a week without registered transactions | Accesses weekly summary | App shows message indicating no data for the selected period |

**Story Points:** 3
**Status:** Done
**Phase:** 5 — Reports

---

### US-0403: Daily Summary
**As a** student
**I want to** see a daily expense summary
**So that** I can monitor my financial habits day by day

**Thesis ID:** US-007

**Acceptance Criteria:**
- [x] `GET /api/insights/daily?date={d}` returns: total spent for the day, breakdown by category, transaction list
- [x] Shows daily total in < 2 seconds
- [ ] Visual calendar with spending indicator per day (color by intensity) — not yet implemented

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has expenses registered for the current day | Accesses daily summary view | App shows today's total spent and breakdown by category in < 2 seconds |
| 2 | User has no expenses registered for the current day | Accesses daily summary view | App shows empty state indicating no transactions for today |

**Story Points:** 3
**Status:** In Progress
**Phase:** 5 — Reports

---

### US-0404: Monthly Comparison
**As a** student
**I want to** see comparative charts by month
**So that** I can analyze the evolution of my spending and savings over time

**Thesis ID:** US-011

**Acceptance Criteria:**
- [x] `GET /api/insights/comparison?months=3` returns data for last N months
- [x] Line chart with income, expense, and balance evolution
- [x] Selector: 2, 3, 6 months comparison
- [x] Clear visualization of trends (up/down)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has data in at least two different months | Selects those months and requests comparison chart | App shows chart with income, expense, and savings totals per month in < 5 seconds |
| 2 | User selects only one month for comparison | Tries to generate the chart | System indicates at least two months must be selected |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

### US-0405: Charts by Category
**As a** student
**I want to** see expense charts by category
**So that** I can visually understand what I spend most on

**Thesis ID:** US-010

**Acceptance Criteria:**
- [x] Horizontal bar chart sorted by amount (highest to lowest)
- [x] Alternative pie chart with percentages (BudgetPieChart on dashboard + ReportsScreen)
- [x] Library: fl_chart
- [ ] Tap on category shows detail of transactions in that category
- [ ] Period selector: week, month, quarter

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has categorized expenses in the selected period | Accesses category chart | Chart shown in < 3 seconds with percentage and amount of each category |
| 2 | User has no expenses in the selected period | Accesses the chart | App shows message indicating insufficient data to generate the chart |

**Story Points:** 5
**Status:** In Progress
**Phase:** 5 — Reports

---

### US-0406: PDF Export
**As a** user
**I want to** export my reports as PDF
**So that** I can share or save my financial data

**Thesis ID:** US-013

**Acceptance Criteria:**
- [x] `GET /api/reports/export/pdf?year={y}&month={m}` generates PDF
- [x] PDF includes: header with period, numeric summary, category chart, detailed breakdown
- [x] "Export PDF" button on report screen
- [x] Allows sharing via phone apps (share intent via share_plus)
- [x] Temporary download URL (24 hours)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User is viewing a report with registered transactions | Presses export to PDF | App generates PDF with charts, totals, and breakdown in < 5 seconds and opens the share sheet |
| 2 | User tries to export a report for a period without transactions | Presses export | System shows message indicating insufficient data for generating the report |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

### US-0407: Financial Progress Indicator
**As a** student
**I want to** see a financial evolution indicator comparing my current habits with previous months, showing whether I reduced expenses, increased savings, or improved my balance
**So that** I can understand whether my financial behavior is improving thanks to the app and have concrete evidence of my progress over time

**Thesis ID:** US-014

**Acceptance Criteria:**
- [x] `GET /api/insights/progress` returns current vs previous month comparison: total expenses, total savings, net balance, top categories
- [x] Shows improvement or decline percentage per metric
- [x] Visual up/down indicator with color (green = improved, red = declined) per metric
- [x] Requires minimum 2-month history (returns informative empty state if insufficient)
- [x] Accessible from reports screen (ProgressScreen at /progress, linked from ProfileScreen)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transactions in at least two different months | Accesses financial evolution view | App shows income/expense/balance comparison with % variation and visual up/down indicators |
| 2 | User has transactions in only one month | Accesses evolution view | App shows message indicating data from at least two months is needed |

**Story Points:** 5
**Status:** Done
**Phase:** 5 — Reports

---

## Epic 5: Budgets and Goals

**Goal:** Users define spending limits and savings objectives with visual tracking.

### US-0501: Budget Management
**As a** student
**I want to** define monthly budgets by category
**So that** I can control my spending and not exceed limits

**Thesis IDs:** US-019 (define monthly budget), US-042 (view active budget summary with progress)

**Acceptance Criteria:**
- [x] `POST /api/budgets` creates budget: categoryId (null = global), amountLimit, month, year
- [x] `GET /api/budgets?month={m}&year={y}` returns with currentSpent and percentageUsed
- [x] Screen with budget list and visual progress bar
- [ ] Colors: green (< 60%), yellow (60–80%), red (> 80%) — **code uses green <70% / yellow 70–90% / red >90% (mismatch)**
- [x] Creation modal: select category, enter limit amount

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects a category and enters a valid limit amount > 0 (US-019) | Presses save | Budget registered in < 2 seconds with a visible progress bar |
| 2 | User tries to save a budget with amount equal to zero or negative (US-019) | Presses save | System shows error indicating amount must be greater than zero |
| 3 | User has at least one active budget for the month (US-042) | Accesses budget section | App shows all budgets with category, limit, spent amount, and progress bar in < 2 seconds |
| 4 | User has no budgets defined for the month (US-042) | Accesses budget section | App shows empty state inviting user to create their first budget |

**Story Points:** 8
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

### US-0502: Financial Goals
**As a** user
**I want to** define savings goals with deadlines
**So that** I can work toward concrete savings objectives

**Thesis IDs:** US-021 (create savings goal), US-044 (contribute to savings goal)

**Acceptance Criteria:**
- [x] `POST /api/goals` creates goal: name, targetAmount, deadline
- [x] `GET /api/goals` returns with currentAmount, percentage, daysRemaining
- [x] `POST /api/goals/{id}/contribute` adds amount to currentAmount
- [x] Goal card: name, progress bar, current/target amount, deadline (date picker added in creation dialog)
- [x] "Contribute" button with amount input
- [ ] Completion animation when currentAmount >= targetAmount

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a valid name, amount > 0, and a future deadline (US-021) | Presses save | Goal appears in active goals list at 0% progress in < 5 seconds |
| 2 | User tries to save a goal with a past or current deadline date (US-021) | Presses save | System shows error indicating the deadline must be a future date |
| 3 | User accesses an active goal's detail and enters a contribution amount > 0 (US-044) | Presses save contribution | Contribution registered in < 5 seconds and goal progress updated with new accumulated amount |
| 4 | User tries to register a contribution with amount equal to or less than zero (US-044) | Presses save | System shows error indicating contribution amount must be greater than zero |

**Story Points:** 5
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

### US-0503: Detailed Goal Tracking
**As a** user
**I want to** see detailed progress of my goals
**So that** I know if I'm on track to meet them

**Thesis ID:** US-022

**Acceptance Criteria:**
- [x] Detail screen with contribution history (date, amount)
- [x] Cumulative progress chart over time (fl_chart line chart)
- [x] Projection: "At this pace you'll complete your goal on {date}"
- [x] Alert if projection indicates it won't be met before deadline

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has an active goal with at least one registered contribution | Accesses goal detail | App shows progress %, saved amount, remaining amount, and days to deadline in < 5 seconds |
| 2 | User accesses detail of a goal with no contributions | Views the screen | App shows 0% progress, full amount as pending, and days remaining calculated from current date |

**Story Points:** 5
**Status:** Done
**Phase:** 6 — Budgets and Goals

---

### US-0504: Edit or Delete Monthly Budget
**As a** registered user
**I want to** edit the limit of an existing monthly budget or delete it
**So that** I can adjust my spending objectives when my financial priorities change

**Thesis ID:** US-043

**Acceptance Criteria:**
- [x] `PUT /api/budgets/{id}` accepts updated amountLimit (must be > 0, ownership validated)
- [x] After editing, progress bar recalculates based on current spent amount
- [x] `DELETE /api/budgets/{id}` removes the budget (ownership validated)
- [x] After deletion, no more 80% alerts generated for that category in that period
- [x] Confirmation dialog required before deletion

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an active budget and enters a new valid limit > 0 | Saves changes | New limit applied in < 5 seconds and progress bar recalculates with current spend |
| 2 | User selects an active budget and confirms deletion | System processes request | Budget disappears from panel and no more alerts generated for that category |

**Story Points:** 3
**Status:** Done
**Phase:** 6 — Budgets and Goals

---

### US-0505: Mark Goal as Completed or Delete
**As a** registered user
**I want to** mark a savings goal as completed or delete it if I no longer want to follow it
**So that** I can keep my goals list updated and focus on currently relevant objectives

**Thesis ID:** US-045

**Acceptance Criteria:**
- [x] Goal can be manually marked as completed (FilledButton.icon on active goal cards → `PUT /api/goals/:id/complete`)
- [ ] Completed goals move to a "completed" section with finish date displayed
- [x] Goal can be deleted (active or completed) with ownership validated
- [x] Deleting a goal removes all associated contributions from the record
- [ ] Confirmation dialog required before mark-complete action (delete has confirmation, mark-complete does not yet)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has reached the target amount of an active goal and marks it as completed | Confirms the action | Goal moves to completed section with finish date recorded in < 5 seconds |
| 2 | User decides to abandon an active goal and confirms deletion | System processes request | Goal disappears from active list and all its contributions are removed from the record |

**Story Points:** 3
**Status:** In Progress
**Phase:** 6 — Budgets and Goals

---

## Epic 6: AI Integration

**Goal:** The backend connects to the external Azure AI API to enable predictions, anomaly detection, and personalized recommendations.

### US-0701: Azure AI API Integration
**As a** developer
**I want to** connect the backend to the Azure AI external API
**So that** AI-powered features (predictions, recommendations, anomaly detection) are available to users

**Acceptance Criteria:**
- [x] `AzureFoundryProvider` in `src/infra/ai/` calls the deployed Azure AI endpoint
- [x] Config via `AZURE_AI_ENDPOINT` + `AZURE_AI_KEY` env vars
- [x] Input: structured spending context (last 3 months per category)
- [x] Output: `{ predictedTotal, predictedByCategory, confidenceLevel, advice }`
- [x] Error handling: timeout, invalid response, API quota exceeded (graceful fallback)
- [ ] Integration documented in `docs/ai-integration.md`

**Story Points:** 8
**Status:** Done
**Phase:** 7 — AI Integration

---

### US-0702: AI Auto-Categorization
**As a** student
**I want to** have the AI analyze the description or amount of a transaction I am recording and automatically suggest the most appropriate category
**So that** I can reduce the time and effort of manual categorization, avoid classification errors, and keep my reports consistently organized without relying solely on memory

**Thesis ID:** US-018

**Acceptance Criteria:**
- [ ] When recording a transaction, description and amount are sent to Azure AI API for category inference
- [ ] Returns suggested categoryId with confidence level
- [ ] Pre-selects the suggested category in the transaction form (user can override at any time)
- [ ] Falls back gracefully (no suggestion shown) if API is unavailable or confidence < 60%
- [ ] Suggestion logged for accuracy tracking; target >= 80% accuracy retrospectively

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User enters a recognizable description when recording a transaction | System analyzes the text | App suggests most appropriate category in < 10 seconds with option to accept or change; accuracy > 80% for recognizable texts |
| 2 | User enters a very short or ambiguous description | System tries to classify | App does not force any category and allows user to select manually |

**Story Points:** 5
**Status:** Not Started
**Phase:** 7 — AI Integration

---

## Epic 7: Predictions

**Goal:** The app anticipates future expenses and income based on history and patterns detected by AI.

### US-0801: Expense Prediction
**As a** user
**I want to** receive predictions of my next month's expenses
**So that** I can anticipate my financial situation

**Thesis ID:** US-015

**Acceptance Criteria:**
- [x] `GET /api/predictions/expenses?period=next_month` calls Azure AI external API
- [x] Returns: predicted_total, predicted_by_category (array), confidence_level, api_version
- [x] Requires minimum 2-month history (returns 400 with explanatory message if insufficient)
- [ ] Average accuracy >= 80% measured retrospectively (accuracy tracking not yet implemented)
- [x] Screen shows prediction with confidence indicator (high/medium/low)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has at least two months of expense history | Requests next-month prediction | App shows estimated amount, breakdown by category, and confidence level in < 10 seconds (only shown if confidence >= 60%) |
| 2 | User has less than two months of history | Tries to view prediction | App shows message indicating more history is needed for a reliable prediction |

**Story Points:** 8
**Status:** In Progress
**Phase:** 8 — Predictions

---

### US-0803: Spending Anomaly Detection
**As a** user
**I want to** receive alerts if my spending in a category increases
**So that** I can avoid financial imbalances

**Thesis ID:** US-016

**Acceptance Criteria:**
- [ ] When recording transaction: if category spending exceeds >20% the average of last 3 months, generates alert
- [ ] Push notification: "Your spending in {category} this month is {x}% higher than your average"
- [ ] Only one alert per category per month (no spamming)
- [ ] Alert visible on dashboard and in notifications

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User registers a transaction that makes monthly spending exceed 20% above historical average for that category | Transaction is recorded | App automatically sends notification alerting of the unusual increase in < 10 seconds |
| 2 | User registers a transaction that does not exceed the 20% threshold in any category | Transaction is recorded | No alert is generated and registration completes normally |

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

**Thesis ID:** US-017

**Acceptance Criteria:**
- [x] `GET /api/recommendations` generates 1-5 active recommendations
- [x] Based on: spending patterns, predictions, budgets, goals
- [x] Types: SAVINGS, BUDGET, GOAL
- [x] Each recommendation with concrete message and suggested action
- [x] Integrated into Dashboard via ZendaAiCard (wired to GET /api/recommendations)
- [x] Cards with feedback button: "Helpful" / "Not relevant" (RecommendationsScreen)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has at least one month of history and at least one active goal or budget | Accesses recommendations section | App shows 1–5 suggestions in Spanish adapted to their financial situation in < 10 seconds |
| 2 | User has no spending history or active goals | Accesses recommendations section | App shows message indicating more data is needed to generate recommendations |

**Story Points:** 8
**Status:** Done
**Phase:** 9 — Recommendations

---

### US-0902: Feedback Tracking
**As a** system
**I want to** record whether the user accepts or rejects recommendations
**So that** I can measure effectiveness and improve future suggestions

**Acceptance Criteria:**
- [x] `POST /api/recommendations/{id}/feedback` with accepted: true/false
- [x] Metric: acceptance_rate = accepted_true / total, target >= 60%
- [ ] Internal dashboard shows acceptance rate by type

**Story Points:** 3
**Status:** In Progress
**Phase:** 9 — Recommendations

---

## Epic 9: Financial Education

**Goal:** Users learn key financial concepts through content adapted to their level.

### US-1001: Educational Content Module
**As a** student
**I want to** access financial educational material
**So that** I can learn key personal finance concepts

**Thesis ID:** US-023

**Acceptance Criteria:**
- [x] `GET /api/education/topics` returns topic list with user progress
- [x] `GET /api/education/topics/{id}` returns complete content
- [x] `PATCH /api/education/topics/{id}/complete` marks as viewed
- [x] Seed topics: Personal budget, Savings, Credit/debt, Inflation, Interest rates, Basic investing, Responsible consumption, Digital wallets in Peru
- [x] Content in readable mobile format (text + icons + practical Peruvian examples)
- [x] Overall progress visible (completion bar)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an available financial education module | Opens it | App shows complete topic content in < 5 seconds with practical information |
| 2 | User completes reading a module | Closes module or navigates away | System records module as viewed and distinguishes it visually from unread modules |

**Story Points:** 8
**Status:** Done
**Phase:** 10 — Education and Gamification

---

### US-1004: Financial Knowledge Quizzes
**As a** student
**I want to** complete financial knowledge quizzes with practical questions about budgeting, savings, debt, and interest, and receive immediate feedback after each answer
**So that** I can learn personal finance concepts actively and progressively within the app, improving my financial decision-making through deliberate practice of key concepts

**Thesis ID:** US-026

**Acceptance Criteria:**
- [ ] `GET /api/education/quizzes` returns available quiz sets grouped by topic
- [ ] `POST /api/education/quizzes/{id}/answer` submits answer and returns: correct/incorrect, explanation, and correct answer
- [ ] Minimum 5 multiple-choice questions per topic
- [ ] Immediate feedback with explanation shown after each answer
- [ ] Score and attempt history tracked per user per quiz
- [ ] Quiz progress integrated with overall educational content completion bar

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User selects an answer in a knowledge challenge | Confirms their answer | App shows in < 2 seconds whether correct or incorrect with a brief concept explanation |
| 2 | User answers all challenge questions | Presses finish | App shows score as a percentage, saves in history, and marks challenge as completed |

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

### US-1006: AI-Personalized Learning Path
**As a** university student
**I want to** receive an AI-ordered learning path based on my spending patterns and financial areas with the most room for improvement
**So that** I can focus my learning on the most relevant topics for my real situation and improve my financial literacy faster

**Thesis ID:** US-048

**Acceptance Criteria:**
- [ ] `GET /api/education/learning-path` returns modules ordered by relevance for the user's financial situation
- [ ] Azure AI analyzes user's spending history, budgets, and goals to determine priority topics
- [ ] Each module in the path includes a brief explanation of why it is prioritized for this user
- [ ] Requires at least one active budget or goal plus transaction history for personalization
- [ ] If insufficient history, returns modules in default order with a note that path will personalize with more usage
- [ ] Learning path regenerated as user's financial behavior evolves

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has transaction history and at least one active budget or goal | Accesses financial education section | AI shows modules ordered from most to least relevant in < 10 seconds, each with a brief explanation of its priority |
| 2 | User does not have sufficient transaction history for personalization | Accesses financial education section | App shows modules in default order and indicates path will personalize as more transactions are recorded |

**Story Points:** 8
**Status:** Not Started
**Phase:** 10 — Education and Gamification

---

### US-1007: AI-Generated Contextual Financial Questions
**As a** university student
**I want to** answer financial knowledge questions generated by AI based on my spending habits and areas where I have room for improvement
**So that** I can practice financial concepts directly related to my real behavior and learn more effectively

**Thesis ID:** US-049

**Acceptance Criteria:**
- [ ] `GET /api/education/quizzes/contextual` returns questions generated by Azure AI based on user's financial patterns
- [ ] Questions relate to categories where the user overspends, unmet budgets, or savings gaps
- [ ] Requires at least one category with elevated spending or exceeded budget for personalization
- [ ] If insufficient history, returns generic fundamental finance questions with a note
- [ ] Questions generated in Spanish, adapted to Peruvian university student context
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

### US-1002: Financial Challenge System
**As a** student
**I want to** complete financial mini-challenges
**So that** I can improve my habits through gamification

**Thesis IDs:** US-024 (view and accept challenges), US-046 (auto-verify challenge completion)

**Acceptance Criteria:**
- [x] `GET /api/challenges` returns challenges with user status (available/active/completed)
- [x] `POST /api/challenges/{id}/accept` accepts challenge
- [x] `POST /api/challenges/{id}/complete` manual completion (Flutter "Mark completed" button)
- [ ] Automatic verification based on criteria_json (no cron job / event hook wired)
- [x] Seed challenges: "No delivery spending for 3 days", "Record expenses for 7 consecutive days", "Save S/20 this week", "Reduce entertainment by 10%"
- [x] Screen with active challenges (progress), available (accept), completed (date)
- [ ] Animation on challenge completion

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses challenges section and selects an available one (US-024) | Confirms acceptance | Challenge moves to active status showing deadline and conditions in < 5 seconds |
| 2 | User already has an active challenge of the same type (US-024) | Tries to accept it again | System informs that challenge is already active and prevents duplication |
| 3 | User has an active challenge and their app actions fulfill the conditions within the deadline (US-046) | System runs verification | Challenge marked as completed, date recorded, achievement notification shown to user |
| 4 | User has an active challenge whose deadline passes without meeting conditions (US-046) | System detects expiration | Challenge moves to expired section and becomes available to accept again |

**Story Points:** 8
**Status:** In Progress
**Phase:** 10 — Education and Gamification

---

### US-1003: Badge System
**As a** user
**I want to** earn badges for achievements
**So that** I stay motivated and see my progress

**Thesis ID:** US-025

**Acceptance Criteria:**
- [x] `GET /api/badges` returns all badges with status (earned/not)
- [ ] Automatic assignment on meeting criteria — `awardIfNotEarned()` is never triggered by events:
  - "First transaction" — record first transaction
  - "Consistency" — 7 consecutive days recording
  - "Goal achieved" — complete first savings goal
  - "Challenger" — complete 5 challenges
  - "Financial sage" — complete educational module 100%
  - "Predictor" — check predictions 3 times
  - "Budgeter" — create and respect budget for 1 month
- [x] Badge grid: color if earned, gray if not
- [x] Tap shows detail: name, description, criteria, date earned
- [ ] Push notification when unlocking new badge

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes a goal, challenge, or defined usage milestone | System verifies fulfillment | Badge automatically assigned and appears in achievements section of the profile |
| 2 | User has already earned a badge and meets the same criterion again | System verifies | No duplicate badge generated, original record maintained |

**Story Points:** 8
**Status:** In Progress
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

**Thesis ID:** US-020

**Acceptance Criteria:**
- [ ] Scheduled job (every hour) checks active budgets
- [ ] If current_spent / budget_limit >= 0.80 → sends notification
- [ ] Message: "Your {category} budget is at {x}%. You have S/{remaining} left"
- [ ] Only one notification per budget per period (no repeats)
- [ ] Configurable: user can disable this alert type

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has a defined budget and accumulated spending reaches 80% of the limit | Transaction registered that crosses the threshold | App sends notification in < 5 seconds indicating they are close to exceeding the budget |
| 2 | User has no budget defined for the category | Records expenses of any amount | No alerts generated and app shows shortcut to configure budgets |

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

**Thesis ID:** US-033

**Acceptance Criteria:**
- [x] `POST /api/surveys/pre/response` endpoint exists
- [ ] Questionnaire of 15-20 questions about budgeting, savings, inflation, credit, interest rates — **content (questions + correct answers) not yet provided**
- [ ] Based on validated instruments (Cordova-Buiza et al., 2022; SBS, 2022)
- [x] Presented during onboarding or first week of usage (accessible from ProfileScreen → Surveys)
- [ ] Automatic score calculation (0-100) — placeholder scoring (answeredQuestions / total × 100)
- [x] Screen: one question per view, progress bar, automatic partial save
- [ ] On completion: "Your current financial education level is {LOW/MEDIUM/HIGH}" (blocked on real correct-answer scoring)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User completes onboarding and answers all initial assessment questions | Presses finish | Answers stored with date in < 3 seconds, user redirected to main dashboard |
| 2 | User tries to advance without answering the current question | Presses next | System indicates question must be answered before continuing |

**Story Points:** 8
**Status:** In Progress
**Phase:** 12 — Evaluation

---

### US-1202: Post-Usage Survey
**As a** researcher
**I want to** measure financial knowledge after usage
**So that** I can calculate educational improvement

**Thesis IDs:** US-034 (invitation after 30 days), US-047 (complete final evaluation)

**Acceptance Criteria:**
- [x] `POST /api/surveys/post/response` endpoint exists
- [x] Same questionnaire (variant to avoid memorization) + SUS section
- [ ] Presented after 4-8 weeks of usage (notification inviting completion — FCM not wired)
- [ ] On completion: visual comparison "You improved from {x} to {y} points ({z}% increase)" — blocked on real scoring
- [ ] If improvement < 20%: suggestions for relevant educational content

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User has completed 30 days of active use and has not yet answered the final evaluation (US-034) | Accesses main screen | App shows non-intrusive invitation to complete the final evaluation |
| 2 | User dismisses the invitation without completing the evaluation (US-034) | Returns to app in following days | Invitation reappears until evaluation is completed or pilot period ends |
| 3 | User accesses to complete the final evaluation (US-047) | Answers all questions and presses finish | Answers stored linked to initial evaluation in < 5 seconds, allowing improvement % to be calculated |
| 4 | User tries to submit with unanswered questions (US-047) | Presses finish | System highlights pending questions and blocks submission until all are completed |

**Story Points:** 8
**Status:** In Progress
**Phase:** 12 — Evaluation

---

### US-1203: Educational Improvement Calculation
**As a** researcher
**I want to** calculate the aggregate financial knowledge improvement
**So that** I can validate the research hypothesis

**Acceptance Criteria:**
- [x] `GET /api/surveys/comparison` returns: pre_score, post_score, improvement_percentage, sus_score (per-user)
- [x] `GET /api/surveys/aggregate` returns: average, median, standard deviation, N
- [ ] Global target: average improvement_percentage >= 20% (thesis validation — pending real questions)
- [ ] Exportable to CSV for external statistical analysis

**Story Points:** 5
**Status:** Done
**Phase:** 12 — Evaluation

---

## Epic 13: Security and Compliance

**Goal:** Financial data protected per Law 29733 and international standards.

### US-1301: Data Encryption
**As a** user
**I want to** have my financial data encrypted
**So that** unauthorized access is prevented

**Thesis ID:** US-029

**Acceptance Criteria:**
- [ ] TLS 1.3 on all API communications (mandatory HTTPS)
- [ ] Azure Database encryption at rest enabled
- [ ] Encrypted backups
- [x] flutter_secure_storage for sensitive local data (JWT tokens)
- [ ] Encrypted local database (not yet implemented)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | App makes a request to the server | Data is transmitted | Communication occurs exclusively via HTTPS with TLS and data is stored encrypted on the server |
| 2 | Request made to protected endpoints without a valid or expired JWT token | Server receives request | Server responds with 401 without exposing sensitive information |

**Story Points:** 5
**Status:** Not Started
**Phase:** 13 — Security

---

### US-1303: Data Consent
**As a** user
**I want to** give my explicit consent for the use of my data
**So that** compliance with the Personal Data Protection Law is met

**Acceptance Criteria:**
- [x] Consent screen on first use with clear privacy policy
- [x] Checkbox: "I agree that my financial data will be processed to generate personalized reports and predictions"
- [x] App cannot be used without consent
- [x] Consent record: userId, consentGiven=true, consentAt=timestamp
- [ ] Option to revoke consent in settings (implies disabling AI)

**Story Points:** 3
**Status:** In Progress
**Phase:** 13 — Security

---

## Epic 14: Testing

**Goal:** Quality verified with unit, integration, AI integration, and usability tests.

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

### US-1403: AI API Integration Validation
**As a** developer
**I want to** validate the responses from the Azure AI external API
**So that** predictions and recommendations returned to users are reliable and coherent

**Acceptance Criteria:**
- [ ] Integration test verifying API response accuracy >= 80% against historical data
- [ ] Coherent predictions: not negative, within reasonable ranges for PEN amounts
- [ ] Documented response schema validation
- [ ] Fallback behavior tested: timeout, API unavailable, malformed response

**Story Points:** 8
**Status:** Not Started
**Phase:** 14 — Testing

---

### US-1404: Usability Tests with Users
**As a** researcher
**I want to** evaluate usability with real users
**So that** I can measure if the app meets experience standards

**Thesis ID:** US-035

**Acceptance Criteria:**
- [ ] Group of 30 university students from Metropolitan Lima
- [ ] 4-8 weeks of active usage
- [ ] SUS questionnaire upon completion
- [ ] Target: SUS score >= 4.0/5.0
- [ ] Documentation: completed tasks, errors found, average time, observations

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User accesses the usability evaluation at end of pilot period and answers all 10 SUS questions | Presses submit | Answers stored in < 5 seconds, system calculates SUS score on scale of 0 to 100 |
| 2 | User tries to submit the questionnaire with unanswered questions | Presses submit | System highlights pending questions and does not allow submission |

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

**Thesis ID:** US-036

**Acceptance Criteria:**
- [x] `POST /api/feedback` accepts: type (BUG/SUGGESTION/GENERAL), message, screen_name, rating (1-5)
- [x] Feedback button accessible from ProfileScreen → Support → Send feedback
- [x] Modal with: type, message, optional rating
- [x] Confirmation: "Thanks for your feedback. We'll review it soon"

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User writes a comment with at least one character | Presses send | Comment stored with date and user ID in < 5 seconds, app shows confirmation |
| 2 | User writes no comment | Presses send | System shows message indicating the field cannot be empty |

**Story Points:** 3
**Status:** Done
**Phase:** 15 — Feedback

---

## Epic 16: Analytics

**Goal:** Usage metrics to understand behavior and improve the app.

### US-1502: Usage Event Logging
**As a** developer
**I want to** log key interaction events
**So that** I can analyze metrics and improve the solution

**Thesis ID:** US-037

**Acceptance Criteria:**
- [ ] Events: record_transaction, view_report, view_prediction, accept_challenge, complete_educational_topic, check_recommendation
- [ ] Table analytics_events: user_id, event_type, metadata_json, timestamp
- [ ] Without affecting perceived performance (async logging)

**BDD Scenarios:**

| # | Given | When | Then |
|---|-------|------|------|
| 1 | User performs a key action (record transaction, view report, accept challenge) | Action executed | System records event type and timestamp in < 300ms without any perceptible delay |
| 2 | A logging failure occurs due to connectivity or internal error | Logging fails | Error captured silently without interrupting user's action, system retries on next sync |

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
- [x] GitHub monorepo: /zenda_fronted_app (Flutter), /zenda_backend_app (NestJS), /docs
- [x] .gitignore, README.md
- [x] Branch structure: main (protected), develop, feature/*, chore/*

**Story Points:** 2
**Status:** Done
**Phase:** 1 — Infrastructure

---

## Summary Statistics

**Total Epics:** 18
**Total User Stories:** 61
**Total Story Points:** 343

**By Phase:**
- **Phase 1–2:** Infra + Auth — 12 stories, 54 points
- **Phase 3–4:** Transactions + Categories — 8 stories, 33 points
- **Phase 5–6:** Reports + Budgets — 15 stories, 85 points (+2 new stories, +6 pts vs prior)
- **Phase 7–8:** AI Integration + Predictions — 8 stories, 56 points
- **Phase 9–10:** Recommendations + Education — 12 stories, 80 points (+2 new stories, +16 pts vs prior)
- **Phase 11–12:** Notifications + Evaluation — 8 stories, 37 points
- **Phase 13–16:** Security + Testing + Demo — 10 stories, 47 points

**Thesis Coverage:** 49 official thesis user stories (US-001–US-049) mapped. See cross-reference table above.

**Status Overview (updated 2026-04-29):**
- Done: 19 (US-1801, US-0101, US-0103, US-0104, US-0205, US-0301, US-0302, US-0401, US-0402, US-0404, US-0406, US-0407, US-0503, US-0504, US-0701, US-0901, US-1001, US-1203, US-1501)
- In Progress: 20 (US-0102, US-0105, US-0106, US-0201, US-0202, US-0203, US-0204, US-0206, US-0403, US-0405, US-0501, US-0502, US-0505, US-0801, US-0902, US-1002, US-1003, US-1201, US-1202, US-1303)
- Not Started: 22
- Blocked: 0

---

## How to Use This Document

**Before starting new work:**
1. Review the epic's goal and related stories
2. Check the **Thesis ID** on the story and the cross-reference table to align with official thesis requirements
3. Verify acceptance criteria and BDD scenarios as definition of "done"
4. Review corresponding phase in [roadmap.md](./roadmap.md)
5. Update status to In Progress
6. Implement following standards
7. Update status to Done when all criteria are met

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
- [docs/thesisDocs/P202616_Product_Backlog_V1.md](../../../docs/thesisDocs/P202616_Product_Backlog_V1.md) — Official thesis product backlog (49 HUs, sprint assignments, hours)
- [docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md](../../../docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md) — Full BDD acceptance criteria in Spanish (Dado/Cuando/Entonces)
- [docs/thesisDocs/P202616_Epicas_HU_V1.md](../../../docs/thesisDocs/P202616_Epicas_HU_V1.md) — Official epic-to-HU mapping (10 epics)
