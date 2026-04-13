# Mission

Zenda's mission is to provide **intelligent financial education infrastructure for university students** — enabling students in Metropolitan Lima to record, understand, and predict their financial behavior through a mobile application powered by artificial intelligence.

---

## The Problem

Financial education in Peru is alarmingly low, especially among young university students. The figures are compelling: only 16% of young people aged 18-24 reach a high level of financial literacy (SBS, 2022). 49% are at a medium level. 35% remain at a minimal level. This is not an academic problem — it is a problem that destroys opportunities.

### University Financial Management Fails Because:

1. **Income is unstable**
   - Partial scholarships, informal jobs, sporadic family support
   - There is no "fixed salary" to plan around
   - Sources change every academic semester

2. **Existing tools don't understand the context**
   - Mint, YNAB assume stable income in dollars
   - Yape and Plin only process payments, they don't educate
   - Banking apps have no educational or predictive component

3. **The cost of financial ignorance is devastating**
   - Financial stress = leading cause of university dropout in LATAM (UNESCO, 2022)
   - Consumer credit among young people grew 18% in three years without educational support (BCRP, 2023)
   - Only 57% of Peruvian adults have a bank account, less than 15% access digital services

4. **There is no intelligent feedback**
   - Nobody tells the student they spend 40% more on delivery than last month
   - Nobody predicts they'll run out of money at the end of the month
   - Banking "alerts" are generic and reactive, not predictive or personalized

---

## The Opportunity

Artificial intelligence and machine learning technologies have matured to the point where it is possible to:

- Automatically classify spending patterns by category
- Predict future expenses based on personal history
- Generate personalized savings and budget recommendations
- Adapt educational content to the user's profile and level

**The gap:** There is no mobile application that integrates personal financial management, intelligent AI-powered prediction, and gamified financial education, designed for the economic context of Peruvian university students.

Current applications (Mint, YNAB, Yape, banking apps) **have no concept of:**

- **Student economic context** (variable income, multiple sources, academic cycles)
- **Personalized prediction** (how much will I spend on transportation next week?)
- **Adaptive education** (content that adjusts to the user's financial level)
- **Motivational gamification** (challenges, badges, visible progress)

**This is not an accounting app. It is financial education infrastructure for a digital generation.**

---

## Target Users

### Primary: University Students in Metropolitan Lima

- **Students with partial scholarships** who supplement income with informal work
- **Part-time working students** who need to balance academic and personal expenses
- **Dependent students** relying on family support who need to manage resources
- **Early-semester students** with no prior experience in financial management

### Typical User Profile:

| Attribute | Value |
|-----------|-------|
| **Age** | 18-24 years |
| **Device** | Android 9+ smartphone |
| **Monthly income** | S/ 500 - S/ 2,000 (variable) |
| **Income sources** | 2-3 (family, part-time work, scholarship) |
| **Financial literacy level** | Medium or low |
| **Digital familiarity** | High (Yape, social media, delivery apps) |

### Development Team:

| Role | Name | Responsibilities |
|------|------|-----------------|
| Mobile Developer + Data Analyst | Quispe Condori, Fernando Daniel | App development and AI model integration |
| Mobile Developer + QA | Guillen Luna, Paolo Cesar | App development, environment management, and testing |
| Advisor | Rojas Sihuay, Diego | Technical and methodological review |

---

## The Solution

Zenda is a personal financial management mobile application that incorporates artificial intelligence to offer university students in Metropolitan Lima a tool that records, analyzes, predicts, and educates — all adapted to their real economic context.

### Core Primitives:

1. **Transaction Recording (Income/Expense Tracking)**
   - Manual income and expense recording with categorization
   - Complete history with advanced filters
   - Edit and delete with real-time report updates

2. **Reports and Visualization Engine**
   - Daily, weekly, and monthly summaries
   - Charts by category (bar, pie)
   - Monthly comparisons with visual trends
   - PDF export

3. **Artificial Intelligence Pipeline**
   - Future expense prediction (target accuracy >= 80%)
   - Anomalous spending pattern detection
   - Automatic transaction classification
   - Personalized recommendations based on historical data

4. **Budget and Goals Engine**
   - Monthly budget definition by category
   - Proactive alerts at 80% of the limit
   - Financial goal tracking with visible progress

5. **Gamified Educational Module**
   - Financial content adapted to the user's level
   - Mini financial challenges with rewards
   - Badge system for achievements
   - Pre/post usage evaluation to measure impact

6. **Intelligent Notification System**
   - Excessive spending alerts by category (>20% above average)
   - Budget approaching limit alerts
   - Proactive predictions of risk situations

---

## Success Criteria

Zenda succeeds when:

1. **Students actively record their transactions**
   - Daily usage rate >= 50% of active users
   - Average of >= 3 transactions recorded per user per week
   - 30-day retention >= 40%

2. **Predictions are reliable**
   - Average expense prediction accuracy >= 80%
   - Models are trained with real data from pilot users
   - Recommendations have an acceptance rate >= 60%

3. **Educational impact is demonstrated**
   - >= 20% increase in financial knowledge (measured by pre/post usage survey)
   - Usability score >= 4.0/5.0 on SUS scale
   - Users report subjective improvement in expense control

4. **The app is secure and reliable**
   - Financial data encrypted in transit and at rest
   - Compliance with Law 29733 on Personal Data Protection
   - Zero financial data loss in pilot tests

---

## Non-Goals (For the MVP)

- **Real banking integration:** MVP does not connect with real banking systems
- **iOS:** Android only in the initial version
- **Multiple languages:** Spanish is the primary language; English UI strings are included for localization infrastructure (EN/ES via Flutter gen-l10n) but the product targets Spanish-speaking users only
- **Self-hosted servers:** Cloud services (Azure) will be used
- **Credit scoring system:** No credit score is generated
- **E-commerce integration:** Does not connect with online stores
- **Automatic financial oracle resolution:** Economic indicators are updated manually

---

## Core Philosophy

### AI Suggests, The User Decides

The ML model can:
- Analyze historical spending patterns
- Generate future expense predictions
- Recommend budget adjustments

But the decision to act **always belongs to the student**. The AI never executes transactions or automatically modifies budgets. It is an **intelligence layer** that amplifies the user's decision-making capacity, not replaces it.

### Education Over Automation

We prioritize:
- **Understanding** over convenience (the user understands why they spend more on transportation)
- **Habits** over tools (the user develops daily recording discipline)
- **Autonomy** over dependence (the user learns to budget, not just follow suggestions)

This is not a financial assistant that thinks for you. It is **educational infrastructure that teaches you to think financially**.

---

## Positioning

**Zenda is to financial education what Duolingo is to language learning:**

- Duolingo doesn't teach grammar like a textbook — it teaches through daily gamified practice
- Zenda doesn't give you a finance course — it teaches through real money management with AI guidance

**We are not building another expense app.**

We are building **the tool that turns the act of recording expenses into a personalized and measurable financial learning process**.

---

## SDG Alignment

| SDG | Relationship |
|-----|-------------|
| **SDG 8: Decent Work and Economic Growth** | Strengthens financial competencies for responsible economic participation |
| **SDG 4: Quality Education** | Incorporates innovative technology-based educational components |

---

## Success Metrics (Post-MVP)

| Metric | Target | Description |
|--------|--------|-------------|
| **Daily Recording Rate** | >= 50% | % of users who record at least one transaction per day |
| **Predictive Accuracy** | >= 80% | Accuracy of the expense prediction model |
| **Educational Improvement** | >= 20% | Pre/post difference in financial knowledge survey |
| **SUS Score** | >= 4.0/5.0 | Usability measured by System Usability Scale |
| **Acceptance Rate** | >= 60% | % of recommendations the user implements or values |
| **30-Day Retention** | >= 40% | % of active users after one month |
| **Challenges Completed** | >= 3/month | Average financial mini-challenges completed per user |
| **Critical Error Rate** | < 1% | Financial operations with critical errors |

---

## Long-Term Vision (Beyond MVP)

- **Real banking integration:** Connection with Peruvian bank APIs and digital wallets
- **Real-time indicators:** BCRP/INEI APIs for inflation, exchange rates
- **Audience expansion:** Households, entrepreneurs, non-university audiences
- **User reputation:** Goal completion history, habit scoring
- **Inter-institutional:** Agreements with universities for student welfare programs
- **Institutional dashboards:** Aggregated (anonymized) reports for universities
- **Community:** Forums and savings groups among students

**But first, we must demonstrate the MVP: the app measurably improves students' financial management and education.**

---

**Related documents:**
- [roadmap.md](./roadmap.md) — Execution plan by phases (14 phases)
- [user_stories.md](./user_stories.md) — Detailed user stories (18 epics)
- [tech-stack.md](./tech-stack.md) — Technical architecture
