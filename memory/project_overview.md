---
name: Project Overview
description: Zenda monorepo overview — NestJS backend + Flutter frontend, thesis project for Peruvian university students
type: project
---

Zenda is an AI-powered mobile finance app (thesis project) for Peruvian university students (18-24). Monorepo at `C:\Users\paolo\OneDrive\Desktop\Tesis2026\`.

**Repos:**
- `zenda_backend_app/` — NestJS 11, Prisma ORM, PostgreSQL 15, JWT auth. Runs on `http://localhost:3000`. Swagger at `/api/docs`.
- `zenda_fronted_app/` — Flutter 3.10+, Riverpod 3, GoRouter 17, fl_chart. (folder name has intentional typo — keep as-is)

**Current branch:** `develop` (main is `main`)

**Completed phases (per roadmap):**
- Phase 1a: Backend scaffolding (NestJS, Prisma, JWT auth, 6 feature modules)
- Phase 1b: Full Prisma schema (19+ models, 9+ enums, seed data)
- Phase 2: Flutter frontend foundation (auth, onboarding, dashboard, transactions, profile, i18n EN+ES)
- Phase 3: Transaction recording (GET/:id + PUT/:id, TransactionListScreen, fire-and-forget sync)
- Phase 4: Categorization (PUT /api/categories/:id, CategoryManagementScreen)
- Phase 5: Reports (monthly insights aggregation, ReportsScreen with pie chart + PDF export)
- Phase 6: Budgets and goals (BudgetsModule, GoalsModule, BudgetScreen, GoalsScreen, GoalDetailScreen)

**Backend has grown well beyond the 6-phase scope** — additional modules exist for: predictions, recommendations, education, badges, challenges, surveys, analytics, notifications, AI chat.

**Why:** Understanding the full project scope helps avoid re-implementing things that already exist and helps prioritize next steps.

**How to apply:** Before suggesting implementations, check whether a backend module or Flutter feature already exists. The backend is likely further ahead than the Flutter frontend.
