---
name: pre-work-audit
description: Mandatory health check before and after any backend or frontend code
  change. Runs TypeScript compilation, Dart analysis, and structural checks to ensure
  the project is error-free before proceeding. Use at the start and end of every
  implementation task.
metadata:
  category: assistant
  tags:
  - audit
  - health-check
  - typescript
  - flutter
  - pre-flight
  status: ready
  version: 1
---

# Principles

- Never start implementing a task without first verifying the project compiles cleanly
- Never mark a task as done without confirming the project still compiles after changes
- If the pre-audit fails, fix the existing errors before introducing new code
- If the post-audit fails, fix the regression before moving on — do not leave the project in a broken state

# Workflow

## When to Run

Run the full audit in these situations:
- **Before** starting any task that modifies backend files (`zenda_backend_app/`)
- **Before** starting any task that modifies frontend files (`zenda_fronted_app/`)
- **After** completing any implementation task
- **Before** creating a PR or committing

## Pre-Work Audit (Before Starting)

### Step 1 — Identify which layer(s) will be touched

Read the task description and determine:
- Backend only → run backend audit
- Frontend only → run frontend audit
- Both → run both

### Step 2 — Backend Audit (if touching backend)

Run the TypeScript compiler in no-emit mode to check for type errors:

```bash
cd zenda_backend_app && npx tsc --noEmit
```

If this fails:
1. Read all reported errors carefully
2. Fix every error before writing any new code
3. Re-run until clean
4. Only then proceed with the task

Also verify the Prisma schema is valid if schema changes are involved:

```bash
cd zenda_backend_app && npx prisma validate
```

### Step 3 — Frontend Audit (if touching frontend)

Run Dart static analysis:

```bash
cd zenda_fronted_app && flutter analyze
```

If this fails:
1. Read all reported issues (errors block compilation; warnings should be reviewed)
2. Fix all errors before writing new code
3. Warnings that are pre-existing and unrelated to the task may be noted but not blocked on
4. Re-run until errors are zero

### Step 4 — Report Audit Result

Before proceeding, clearly state one of:

```
✓ Pre-audit passed — backend compiles clean, no TypeScript errors.
✓ Pre-audit passed — frontend analyzes clean, no Dart errors.
✗ Pre-audit found N error(s) — fixing before proceeding.
```

---

## Post-Work Audit (After Finishing)

### Step 1 — Re-run the same checks as pre-audit for the layer(s) touched

```bash
# Backend
cd zenda_backend_app && npx tsc --noEmit

# Frontend
cd zenda_fronted_app && flutter analyze
```

### Step 2 — Verify no regressions

Compare result against pre-audit:
- Same errors as before → no regression introduced (pre-existing issues)
- New errors → regression introduced by this task — fix before marking done

### Step 3 — Report Post-Audit Result

```
✓ Post-audit passed — no new errors introduced. Task complete.
✗ Post-audit found regression — N new error(s) introduced. Fixing now.
```

---

## Audit Scope Reference

| Layer | Command | Catches |
|-------|---------|---------|
| Backend | `npx tsc --noEmit` | Type errors, missing imports, wrong signatures |
| Backend | `npx prisma validate` | Invalid schema, broken relations, bad types |
| Frontend | `flutter analyze` | Dart type errors, null safety, deprecated APIs, unused imports |

## Anti-Patterns

- Starting a task without a pre-audit and discovering pre-existing errors mid-way through
- Mixing pre-existing errors with task-introduced errors making it unclear what broke
- Marking a task complete while the project has a broken build
- Running only a partial audit (e.g., skipping frontend when a backend change also updates a shared contract)
