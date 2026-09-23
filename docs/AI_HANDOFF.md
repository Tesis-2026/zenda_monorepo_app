# AI Handoff

## Corrección de navegación y envío del pre-test — 2026-09-22

- **Objetivo actual:** Corregir la navegación regresiva/índices negativos del pre-test y el rechazo `answers must be an object` al guardar o finalizar.
- **Trabajo completado:**
  1. Corregido `Siguiente` para incrementar el índice y añadidos límites defensivos para impedir preguntas fuera del rango `1..12`.
  2. La posición de reanudación se calcula una sola vez; volver a una pregunta respondida ya no provoca un salto automático hacia adelante durante cada reconstrucción de la pantalla.
  3. `savePreProgress` y `submitPre` envían `answers` como objeto `{ questionId: optionId }`, según el contrato `Record<string, string>` del backend.
  4. El conteo de completitud considera únicamente IDs pertenecientes al cuestionario vigente.
  5. Añadidas regresiones para el cuerpo HTTP y el flujo reanudar → anterior → siguiente.
- **Archivos modificados:** `zenda_fronted_app/lib/core/services/education_api_service.dart`, `zenda_fronted_app/lib/features/surveys/survey_screen.dart`, `zenda_fronted_app/test/financial_literacy_pretest_test.dart`, `docs/AI_HANDOFF.md`.
- **Pruebas ejecutadas:** `flutter test test/financial_literacy_pretest_test.dart` (6/6), `flutter test` (31/31), `flutter analyze` (0 problemas), `flutter build apk --debug --flavor prod` (exitoso; `build/app/outputs/flutter-apk/app-prod-debug.apk`), `git diff --check` (sin errores).
- **Release Assets (Build 4):**
  - **APK:** `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk`
  - **Version:** `1.0.0` (versionCode `4`, build flavor `prodRelease`)
  - **SHA256:** `E154B0A8AFEC89C3029BC1DEFCCABF422956D06D417BD1002854927F8E1F4779` (63.3 MB)
  - **Firebase App Distribution:** Subido y distribuido al grupo `zenda-piloto-validacion` (Release ID `2t79eshb99tfg`).
  - **Console URL:** `https://console.firebase.google.com/project/zenda-flutter-mobile-app/appdistribution/app/android:com.zenda.zenda_fronted/releases/2t79eshb99tfg`
  - **Tester URL:** `https://appdistribution.firebase.google.com/testerapps/1:143147353185:android:4e4cf351f410ce12c6d620/releases/2t79eshb99tfg`
- **Trabajo restante:**
  - Despliegue del backend en Azure Web App (commit con endpoints `FINLIT_PRE_V1`).
  - Aplicar migración de base de datos en staging (`npx prisma migrate deploy`).
  - Validación del flujo completo por los testers del grupo con la nueva versión Build 4.
- **Decisión importante:** Se incrementó el número de compilación a `1.0.0+4` en `pubspec.yaml` para asegurar la entrega de la actualización a los testers en Firebase App Distribution.
- **Siguiente paso recomendado:** Confirmar la recepción de la actualización en los dispositivos del grupo `zenda-piloto-validacion` y verificar que el pre-test se complete sin errores.

## Financial Literacy Pre-Test (FINLIT_PRE_V1) Implementation & Audit — 2026-09-22

- **Current objective:** Audit and properly implement the Financial Literacy Pre-Test (`FINLIT_PRE_V1`) for new user registrations in Zenda, ensuring full separation between authentication and academic research identity, server-side scoring, atomic submission, informed consent, and elimination of pre-test skipping.
- **Work completed in this session:**
  1. **Audited Legacy Survey:** Identified lack of pseudonymization (answers stored as JSON linked to `userId`), outdated 10-question bank with percentage score, client-side skip bypass, and exposure of scores/answers at completion.
  2. **Database & Models (`zenda_backend_app/prisma/schema.prisma`):**
     - Added enums `AssessmentType` (`PRE`, `POST`) and `AssessmentStatus` (`IN_PROGRESS`, `COMPLETED`).
     - Implemented `ResearchParticipant` with server-generated cryptographically random UUID v4 `researchParticipantId`.
     - Implemented `FinancialLiteracyAssessment` (strictly without `userId`, compound unique key `[researchParticipantId, assessmentType, questionnaireVersion]`).
     - Implemented `FinancialLiteracyAnswer` (strictly without `userId`, compound unique key `[assessmentId, questionId]`).
     - Created migration `20260922120000_add_research_participant_and_financial_literacy_assessment`.
  3. **Backend Service & Controller:**
     - Created `src/modules/surveys/domain/financial-literacy-questions.ts`: Defines official 12 questions bank across 7 domains (`PLANIFICACION`, `AHORRO`, `CONOCIMIENTO_FINANCIERO`, `INFLACION`, `RIESGO`, `CREDITO`, `SEGURIDAD_FINANCIERA`), server scoring (0–12), and `getPublicFinancialLiteracyQuestions()` stripping `correctAnswer`.
     - Created DTOs: `StartFinancialLiteracyDto`, `SaveFinancialLiteracyProgressDto`, `SubmitFinancialLiteracyDto`.
     - Created `FinancialLiteracyAssessmentService`: Manages pseudonymization, informed consent (`FINLIT_CONSENT_V1`), auto-save draft, atomic `$transaction` submission, server-side score calculation, backwards compatibility dual-write, and pseudonymized dataset export.
     - Updated `SurveysController`: Added `GET /api/surveys/pre`, `GET /api/surveys/pre/status`, `POST /api/surveys/pre/start`, `PUT /api/surveys/pre/save-progress`, `POST /api/surveys/pre/response`.
     - Updated `ResearchDashboardController`: Added `GET /api/research-dashboard/export/financial-literacy.json` and `.csv`.
  4. **Frontend Implementation (`zenda_fronted_app`):**
     - Updated `lib/core/services/education_api_service.dart`: Added `SurveyOption`, structured parsing in `SurveyQuestion`, `FinancialLiteracyStatus`, and API methods `getPreStatus`, `startPre`, `savePreProgress`, `submitPre`.
     - Updated `lib/providers/pre_survey_provider.dart`: Removed `_SurveySkipStore` for pre-survey; verified `preSurveyDone` strictly against backend `getPreStatus().isCompleted`.
     - Updated `lib/features/surveys/survey_screen.dart`:
       - Added Academic Informed Consent view with checkbox and start button.
       - Implemented 12 questions in Spanish with domain badges, A-D radio options, progress bar and question indicator.
       - Integrated background auto-save via `savePreProgress`.
       - Removed Skip button and protected against pop/back.
       - Enforced all 12 questions answered before submission.
       - Added neutral academic confirmation view without exposing scores or answers.
  5. **Verification & Testing:**
     - Backend: 18/18 tests passed in `test/modules/financial-literacy-pretest.e2e-spec.ts`. All 27 backend test suites passed (152/152 tests).
     - Frontend: 29/29 tests passed in `flutter test` (including new `test/financial_literacy_pretest_test.dart`). `flutter analyze` clean with 0 issues.
     - Database: `npx ts-node scripts/validate-financial-literacy-db.ts` verified 7/7 criteria.
  6. **Documentation:** Created comprehensive `docs/pilot-readiness/FINANCIAL_LITERACY_PRETEST.md` covering all 14 required sections.
- **Files modified/created:**
  - Backend: `prisma/schema.prisma`, `prisma/migrations/20260922120000_...`, `src/modules/surveys/domain/financial-literacy-questions.ts`, `src/modules/surveys/application/financial-literacy-assessment.service.ts`, `src/modules/surveys/interface/surveys.controller.ts`, DTOs, tests, validation script.
  - Frontend: `lib/core/services/education_api_service.dart`, `lib/providers/pre_survey_provider.dart`, `lib/features/surveys/survey_screen.dart`, `test/financial_literacy_pretest_test.dart`.
  - Monorepo: `docs/pilot-readiness/FINANCIAL_LITERACY_PRETEST.md`, `docs/AI_HANDOFF.md`.
- **Release Assets (Build 3):**
  - **APK:** `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk`
  - **Version:** `1.0.0` (versionCode `3`, build flavor `prodRelease`)
  - **SHA256:** `D253EAB71E5077F4F3C89742ED3D6F2EEC35C5B9298E56612C3634BC8653F6CD` (63.3 MB)
  - **Firebase App Distribution:** Uploaded and distributed to group `zenda-piloto-validacion` (Release ID `62ruc5uush4v8`).
  - **Console URL:** `https://console.firebase.google.com/project/zenda-flutter-mobile-app/appdistribution/app/android:com.zenda.zenda_fronted/releases/62ruc5uush4v8`
  - **Tester URL:** `https://appdistribution.firebase.google.com/testerapps/1:143147353185:android:4e4cf351f410ce12c6d620/releases/62ruc5uush4v8`
- **Remaining work:**
  - Automated deployment of backend commit `a83e1a1` via GitHub Actions on Azure Web App.
  - Run database migration on live staging environment (`npx prisma migrate deploy`).
  - Participant cohort execution with Build 3 during onboarding.
- **Important decisions:**
  - Maintained legacy `SurveyResponse` dual-write so existing comparison and analytics logic continues working seamlessly without breaking changes.
  - Re-submission after `COMPLETED` returns HTTP 409 `ASSESSMENT_ALREADY_COMPLETED` and is blocked.
- **Recommended next step:**
  - Verify that the testers in `zenda-piloto-validacion` receive the update in Firebase App Tester app.

## Remote sync & release candidate deployment closure — 2026-09-16

- **Current objective:** Synchronize verified pre-pilot release candidates to GitHub remotes across all three repositories, re-verify live Azure staging health/security guards, and prepare operational execution for the accompanied academic pre-pilot.
- **Work completed in this session:**
  1. **Live Staging Smoke Re-verification:** Executed `node tools/prepilot-smoke.cjs` against live Azure staging (`https://zendaapilinuxtesis-hyb8dabvh2hpdgan.centralus-01.azurewebsites.net/api`). 7/7 tests passed: Health 200 OK, DB readiness 200 OK, malformed login 400 rejection, invalid credentials 401 rejection, and strict 401 authentication guards on `/users/me`, `/transactions`, and `/summary/month`.
  2. **Remote Push to `origin/main`:** Pushed all local commits to GitHub remotes across all 3 repositories:
     - `zenda_monorepo_app`: `9e27d2b..6bd169e` (`main -> main`)
     - `zenda_backend_app`: `46dd08e..dd122c5` (`main -> main`)
     - `zenda_fronted_app`: `df666af..b2f3cac` (`main -> main`)
  3. **Repository Status:** All 3 repositories are clean and up to date with `origin/main`.
- **Release Assets:**
  - **APK:** `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk`
  - **Version:** `1.0.0` (versionCode `2`, build flavor `prodRelease`)
  - **SHA256:** `a10f31e0298c49f68f61d356607e02742413b8b64519b4e8acb83bc1b93d753a` (63.3 MB)
- **Final Verdict:** **GO PARA PREPILOTO ACOMPAÑADO (PEN / America/Lima)**.
- **Recommended next steps for human operator (Fernando):**
  1. Distribute verified APK to Firebase App Distribution:
     ```powershell
     firebase appdistribution:distribute zenda_fronted_app\build\app\outputs\flutter-apk\app-prod-release.apk `
       --app 1:143147353185:android:4e4cf351f410ce12c6d620 `
       --groups zenda-piloto-validacion `
       --release-notes "Zenda v1.0.0 (build 2) - Prepiloto Acompañado. Correcciones FR-01, FR-02 y FR-03."
     ```
  2. Collect cohort participant informed consent prior to account creation.
  3. Execute authenticated smoke test flow with two test accounts:
     ```powershell
     $env:SMOKE_TOKEN_A="<jwt_usuario_a>"
     $env:SMOKE_TOKEN_B="<jwt_usuario_b>"
     node tools/prepilot-smoke.cjs
     ```

## Pre-pilot readiness closure — 2026-09-15

- **Current objective:** Complete prepilot readiness validation for a small, accompanied academic prepilot (PEN / `America/Lima`), resolve all technically solvable preconditions, execute full test batteries across all layers, and seal the release candidates in the 3 repositories.
- **Work completed in this session:**
  1. **Frontend Hardening & Commit:** Committed all review fixes in `zenda_fronted_app` at commit `a793c52` (`fix: harden Flutter app for pilot readiness`). Resolves FR-01 (offline queue user ownership & cache isolation), FR-02 (preservation of offline writes after retries exhausted, concurrency serialization), FR-03 (elimination of fake financial progress fallback, visible error retry, locked month selector), and new regression suite `test/final_review_session_test.dart`.
  2. **Backend Hardening & Verification:** Backend clean at commit `f144013` (`fix: harden backend for pilot readiness`). Executed full 26 Jest suites (135/135 tests passed) and full TypeScript compilation (`nest build` exit 0).
  3. **Frontend Analysis & Tests:** `flutter analyze` clean with 0 issues; `flutter test` 25/25 tests passed.
  4. **Release Candidate APK Verification:** Independently verified SHA256 of `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk` (`a10f31e0298c49f68f61d356607e02742413b8b64519b4e8acb83bc1b93d753a`, 63.3 MB, `versionCode=2`).
  5. **Pre-pilot Smoke Tooling:** Created `tools/prepilot-smoke.cjs` and executed against live Azure staging (`https://zendaapilinuxtesis-hyb8dabvh2hpdgan.centralus-01.azurewebsites.net/api`). 7/7 tests passed (health, database readiness, bad request validation, invalid credentials rejection, and strict 401 guards on `/users/me`, `/transactions`, `/summary/month`).
  6. **Root & RAG Tools:** Ran `pilot-tools.test.cjs` (3/3 passed), `pilot-audit.cjs` (99 routes, 94 DTOs, 29 models, 49 HUs), `test_metrics.py` (3/3 passed), and `evaluate.py` (120 synthetic cases validated offline).
  7. **Documentation:** Created `docs/pilot-readiness/PRE_PILOT_RELEASE.md` with complete operational instructions for Fernando. Updated `05_TEST_EVIDENCE.md`, `09_PILOT_READINESS_REPORT.md`, and `CHANGED_FILES.md`.
- **Files modified/created:**
  - Backend: 37 files in commit `f144013`.
  - Frontend: 10 files in commit `a793c52`.
  - Root: `tools/prepilot-smoke.cjs`, `docs/pilot-readiness/PRE_PILOT_RELEASE.md`, `docs/pilot-readiness/11_FINAL_REVIEW.md`, `docs/pilot-readiness/05_TEST_EVIDENCE.md`, `docs/pilot-readiness/09_PILOT_READINESS_REPORT.md`, `docs/pilot-readiness/CHANGED_FILES.md`, `docs/AI_HANDOFF.md`.
- **Final Verdict:** **GO PARA PREPILOTO ACOMPAÑADO (PEN / America/Lima)**.

## Current objective

Complete the Zenda pilot-readiness audit, verify and contrast Astra's claims against source code, fix verified defects prioritizing P0/P1/P2, generate real test evidence in `docs/pilot-readiness/05_TEST_EVIDENCE.md`, and determine an honest readiness verdict.

## Current branch

`feature/pilot-readiness-audit` (across root monorepo, `zenda_backend_app`, and `zenda_fronted_app`).

## Work completed in this session

1. **Verification & Code Contrast of Astra's Claims:**
   - Identified multi-repository structure: root monorepo (`zenda_monorepo_app`), backend (`zenda_backend_app`), and frontend (`zenda_fronted_app`).
   - Verified which claims were already implemented in code:
     - A01 (P0 token enforcement in research dashboard in all environments): Implemented & tested.
     - A02 (P1 Lima boundaries in `financial-period.ts`, exclusion of transfers): Implemented & tested.
     - A04 (P1 idempotency reservation before handler execution): Implemented & tested.
     - A05 (P1 atomic goal contributions & validation): Implemented & tested.
     - A06 (P1 global cache removed; category mapping): Implemented & tested.
     - A07 (P1 SUS calculation 2.5 multiplier and survey validation): Implemented & tested.
     - A09 (P1 telemetry filter and pseudonym export): Implemented & tested.
     - A10 (P1 websocket-driver bumped): Implemented.
     - A11 (P1 currency mismatch rejection in transfers): Implemented.
   - Identified claims that were ONLY documented or partially addressed:
     - A08 (P1 SubmitQuizUseCase saving to `QuizAttempt` table): Only documented (requires schema migration and product decision).
     - Daily reminder cron in `notifications-schedule.service.ts` was still using local time (fixed below).
     - MOV-03 / MOV-05: Transacciones usaban UTC sin convertir a hora local en frontend, y borrado de movimientos no invalidaba gestión ni almacenamiento local (fixed below).
     - GES-01: No había botón directo para aportar a metas en pantalla de Metas/Gestión (fixed below).
     - MOV-01: `savedExtra` recibía 0.0 debido a `clearAmount` temprano y pantalla de confirmación mostraba inglés (fixed below).
     - REP-02: Acceso a reportes requería navegar a Perfil (fixed below).
     - PERF-01: Nombre de usuario editado no se reflejaba en Inicio (fixed below).
     - GAM-01: Insignias vacías sin mensaje orientador (fixed below).

2. **Code Corrections Applied:**
   - **MOV-03 (P0 - Local Timezone):**
     - `zenda_fronted_app/lib/core/models/transaction.dart`: Converted timestamp from ISO UTC string to local device time (`.toLocal()`), supported resilient numeric/string amount parsing.
     - `zenda_backend_app/src/modules/notifications/schedule/notifications-schedule.service.ts`: Updated `runDailyReminder()` to compute day boundaries and current time in `America/Lima` (UTC-05:00) using `financialDayBounds` and `financialDateKey`.
   - **MOV-05 (P0 - Transaction Deletion Consistency):**
     - `zenda_fronted_app/lib/core/services/transactions_repository.dart`: Added `deleteTransaction(String id)` removing item from persistent storage.
     - `zenda_fronted_app/lib/features/income/income_screen.dart`: Made `monthlyIncomeProvider` public.
     - `zenda_fronted_app/lib/features/progress/progress_screen.dart`: Made `progressProvider` public.
     - `zenda_fronted_app/lib/features/transactions/transaction_list_screen.dart`: Deleted transaction from local repository and invalidated `monthlyIncomeProvider` and `progressProvider` on delete.
     - `zenda_fronted_app/lib/features/transactions/controllers/new_transaction_controller.dart`: Invalidated `monthlyIncomeProvider` and `progressProvider` on save.
   - **MOV-01 (P1 - Amount Retained / Extra Amount):**
     - `zenda_fronted_app/lib/features/transactions/add_transaction_screen.dart`: Corrected `savedExtra['amount']` to preserve valid amount before clearing, cleared text controllers.
     - `zenda_fronted_app/lib/features/transactions/transaction_saved_screen.dart`: Translated date formats and category names to Spanish via `CategoryUtils.labelEs`.
   - **GES-01 (P1 - Adding Money to Savings Goals):**
     - `zenda_fronted_app/lib/features/goals/goals_screen.dart`: Added explicit "Agregar dinero" action button to `_GoalCard`, modal sheet with quick-pick chips (S/ 50, S/ 100, S/ 200), and invalidated `progressProvider` to reflect savings in 50/30/20.
     - `zenda_fronted_app/lib/features/management/management_screen.dart`: Clarified hint text explaining how needs (50%) and savings (20%) are managed.
   - **REP-02 (P2 - Direct Access to Reports):**
     - `zenda_fronted_app/lib/core/widgets/user_menu_button.dart`: Added "Reportes" popup menu item and routing (`context.push('/reports')`).
     - `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart`: Made summary cards ("Ingresos del mes" y "Gastos del mes") clickable with `context.push('/reports')` and visual forward affordances.
   - **PERF-01 (P2 - User Name Sync on Edit Profile):**
     - `zenda_fronted_app/lib/features/profile/profile_screen.dart`: Captured updated user and notified `authNotifierProvider`, instantly updating the greeting on Inicio.
   - **GAM-01 (P2 - Friendly Empty State in Badges):**
     - `zenda_fronted_app/lib/features/badges/badges_screen.dart`: Added empty state banner when no badges are unlocked.

3. **Creation of Obligatory Test Evidence Artifact:**
   - Created `docs/pilot-readiness/05_TEST_EVIDENCE.md` with complete and genuine logs of all test runs.

4. **Documentation & Manifest Updates:**
   - Updated `docs/pilot-readiness/04_CHANGELOG_PILOT.md` with all resolved defects.
   - Updated `docs/pilot-readiness/09_PILOT_READINESS_REPORT.md` reflecting current defect statuses and doors.
   - Regenerated `CHANGED_FILES.md`, `API_INVENTORY.md`, and `version-manifest.json` using `tools/pilot-audit.cjs`.

---

## Tests executed & results

1. **Backend NestJS:** `npm test` (`jest --config ./test/jest-e2e.json`)
   - **Result:** `Test Suites: 26 passed, 26 total`; `Tests: 135 passed, 135 total`; `Time: 28.044 s`.
2. **Frontend Flutter:** `flutter test`
   - **Result:** `2 suites passed, 16 passed, 0 failed`; `Time: ~1.5 s`.
   - Included 2 new regression tests for local timezone parsing and local repository deletion.
3. **Audit & Telemetry Tooling:** `node --test tools/pilot-tools.test.cjs`
   - **Result:** `3 passed, 0 failed`; `duration_ms: 138.4`.
4. **Contract Auditor:** `node tools/pilot-audit.cjs`
   - **Result:** `{"endpoints":99,"dtos":94,"models":29,"histories":49,"migrations":30}` (Exited with code 0).
5. **Python RAG Evaluation Tools:**
   - `python -m unittest test_metrics.py`: `3 tests OK (0.001s)`.
   - `python evaluate.py dataset.base.jsonl`: `{"cases": 120, "mode": "offline_validation", "model_calls": 0, "evaluation_scores": null}`.

---

## Files modified in this session

### Monorepo Root:
- `docs/AI_HANDOFF.md`
- `docs/pilot-readiness/04_CHANGELOG_PILOT.md`
- `docs/pilot-readiness/05_TEST_EVIDENCE.md` (new)
- `docs/pilot-readiness/09_PILOT_READINESS_REPORT.md`
- `docs/pilot-readiness/API_INVENTORY.md`
- `docs/pilot-readiness/CHANGED_FILES.md`
- `docs/pilot-readiness/api-inventory.json`
- `docs/pilot-readiness/version-manifest.json`

### Backend (`zenda_backend_app`):
- `src/modules/notifications/schedule/notifications-schedule.service.ts`

### Frontend (`zenda_fronted_app`):
- `lib/core/models/transaction.dart`
- `lib/core/services/transactions_repository.dart`
- `lib/core/widgets/user_menu_button.dart`
- `lib/features/badges/badges_screen.dart`
- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/goals/goals_screen.dart`
- `lib/features/income/income_screen.dart`
- `lib/features/management/management_screen.dart`
- `lib/features/profile/profile_screen.dart`
- `lib/features/progress/progress_screen.dart`
- `lib/features/transactions/add_transaction_screen.dart`
- `lib/features/transactions/controllers/new_transaction_controller.dart`
- `lib/features/transactions/transaction_list_screen.dart`
- `lib/features/transactions/transaction_saved_screen.dart`
- `test/pilot_readiness_test.dart`

---

## Important decisions

1. **Verdict:**
   - **CONDITIONAL GO for internal synthetic test prepilot**: The application code is stable, compiles cleanly, has 135/135 passing backend tests and 16/16 passing frontend tests, and core functional bugs (MOV-01, MOV-03, MOV-05, GES-01, REP-02, PERF-01, GAM-01) are resolved.
   - **NO-GO for definitive academic pilot with human subjects**: Cannot be declared until real PostgreSQL multi-user concurrency is validated on staging, and online Azure OpenAI evaluation is executed.
2. **Timezone Handling:** Explicitly enforce `America/Lima` (`UTC-05:00`) for all financial period calculations and reminder crons to prevent 5-hour boundary shifts on cloud servers.
3. **No Speculative Schema Changes:** Did not force an unapproved database migration for A08 (`QuizAttempt`); documented as a pending architectural decision.

---

## Firebase App Distribution Deployment

- **Date / Time:** 2026-09-14
- **Version:** 1.0.0 (build 1)
- **Flavor:** `prod` (`prodRelease`)
- **App ID:** `1:143147353185:android:4e4cf351f410ce12c6d620` (com.zenda.zenda_fronted)
- **Release ID:** `57vilo46sq37g`
- **Tester Group:** `zenda-piloto-validacion`
- **Release Notes:** Zenda v1.0 - Release para grupo de validacion del piloto (SUS contextual, correcciones MOV-01/03/05, GES-01/02, REP-02, PERF-01, GAM-01).
- **Tester Access Link:** `https://appdistribution.firebase.google.com/testerapps/1:143147353185:android:4e4cf351f410ce12c6d620/releases/57vilo46sq37g?utm_source=firebase-tools`
- **Console Link:** `https://console.firebase.google.com/project/zenda-flutter-mobile-app/appdistribution/app/android:com.zenda.zenda_fronted/releases/57vilo46sq37g?utm_source=firebase-tools`
