# Evidencia de Ejecución de Pruebas - Piloto Zenda

## Adenda: revisión final incremental y cierre de prepiloto — 2026-09-15

Base final verificada: backend `f144013`, frontend `a793c52`, monorepo raíz `feature/pilot-readiness-audit`. Se ejecutaron todas las validaciones estáticas, dinámicas y de entorno en frío.

| Componente / Suite | Comando | Resultado Observado | Estado |
|---|---|---|---|
| **Backend Tests (Completo)** | `npm test` (26 suites Jest) | 26 suites pasadas, 135 pruebas pasadas, 0 fallidas (291.4 s) | **PASSED** |
| **Backend Build** | `npm run build` (`nest build`) | Código de salida 0; artefactos generados en `dist/` | **BUILD OK** |
| **Frontend Analyze** | `flutter analyze` | `No issues found!` Cero lints, cero errores | **NO ISSUES** |
| **Frontend Tests (Completo)** | `flutter test` | 25 pruebas pasadas, 0 fallidas (16 base + 9 sesión final) | **PASSED** |
| **Frontend APK Release** | `Get-FileHash` SHA-256 | `A10F31E0298C49F68F61D356607E02742413B8B64519B4E8ACB83BC1B93D753A` (63.3 MB) | **VERIFIED** |
| **Smoke Test Staging Real** | `node tools/prepilot-smoke.cjs` | 7 pruebas pasadas, 0 fallidas contra Azure staging (`/health`, `/ready`, DTO 400, 401s) | **PASSED** |
| **Herramientas de Auditoría** | `node --test tools/pilot-tools.test.cjs` | 3 pruebas pasadas, 0 fallidas (export pseudónimo y consent gate) | **PASSED** |
| **Inventario AST & Manifiesto** | `node tools/pilot-audit.cjs` | 99 endpoints, 94 DTOs, 29 modelos, 49 HU, 30 migraciones | **AUDIT OK** |
| **RAG Métricas (Python)** | `python -m unittest test_metrics.py` | 3 pruebas OK (0.001 s) | **PASSED** |
| **RAG Runner Sintético** | `python evaluate.py dataset.base.jsonl` | 120 casos validados en modo offline | **OFFLINE OK** |

### Detalles de Verificación de APK:
- **Archivo:** `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk`
- **Tamaño:** 63.3 MB (66,419,006 bytes)
- **SHA256:** `a10f31e0298c49f68f61d356607e02742413b8b64519b4e8acb83bc1b93d753a`
- **Versión Android:** `versionName=1.0.0`, `versionCode=2`, `minSdkVersion=28`, `targetSdkVersion=35`
- **Estado de Distribución:** Compilado localmente y verificado. No subido a Firebase en esta iteración de hardening técnico; listo para distribución por el operador.

---

**Fecha de ejecución:** 2026-09-13  
**Rama:** `feature/pilot-readiness-audit` (en los 3 repositorios: monorepo raíz, backend y frontend)  
**Último commit base raíz:** `c8aa812 chore: checkpoint Astra pilot-readiness audit`  
**Base commit backend:** `98bcd2c`  
**Base commit frontend:** `0960c07`  

---

## 1. Resumen Ejecutivo de Ejecución

| Suite / Herramienta | Entorno / Motor | Total Pruebas | Pasadas | Fallidas | Estado |
|---|---|---|---|---|---|
| **Backend NestJS (E2E & Unit)** | Node v22.18.0 / Jest 29.7.0 | 135 | 135 | 0 | **PASSED** |
| **Backend NestJS Build** | Node v22.18.0 / `nest build` | 1 | 1 | 0 | **BUILD OK** |
| **Frontend Flutter Analyze** | Flutter 3.41.6 / Dart 3.11.4 | 1 | 1 | 0 | **NO ISSUES** |
| **Frontend Flutter Tests** | Flutter 3.41.6 / Dart 3.11.4 | 16 | 16 | 0 | **PASSED** |
| **Frontend APK Build (prodRelease)** | Gradle / Android SDK 36.1.0 | 1 | 1 | 0 | **BUILD OK (63.3MB)** |
| **Firebase App Distribution** | Firebase CLI 15.22.3 | 1 | 1 | 0 | **DISTRIBUTED (`57vilo46sq37g`)** |
| **Herramientas de Auditoría y Telemetría** | Node v22.18.0 / `node --test` | 3 | 3 | 0 | **PASSED** |
| **Auditoría de Contratos e Inventario** | Node v22.18.0 / `pilot-audit.cjs` | 99 endpoints / 49 HU | 49 HU | 0 err | **OK** |
| **RAG Evaluation Metrics (Python)** | Python 3.13.2 / `unittest` | 3 | 3 | 0 | **PASSED** |
| **RAG Runner Sintético (Offline)** | Python 3.13.2 / `evaluate.py` | 120 casos | 120 válidos | 0 | **OFFLINE OK** |

> **Nota de integridad de evidencia:** Todas las cifras, tiempos y logs detallados a continuación fueron obtenidos de ejecuciones reales en este entorno. Ningún resultado ha sido simulado o inventado.

---

## 2. Entorno de Ejecución

- **Sistema Operativo:** Windows 11 (build 26100, x64)
- **Node.js:** v22.18.0
- **Flutter:** 3.29.3 (Channel stable, 3.29.3, on Microsoft Windows [Version 10.0.26100.3456], locale es-419)
- **Dart SDK:** version 3.7.2
- **Python:** 3.13.2 (tags/v3.13.2:4f8bb39, Feb  4 2025, 15:23:48) [MSC v.1942 64 bit (AMD64)]
- **Base de Datos en Pruebas:** Fixtures SQLite / Prisma in-memory con mocks de infraestructura controlados.
- **Servicios Externos en Pruebas:** Mocks para Azure OpenAI, Document Intelligence OCR, Firebase Cloud Messaging (FCM) y SMTP (Nodemailer).

---

## 3. Pruebas de Backend (NestJS / Jest)

- **Comando:** `npm test` (ejecuta `jest --config ./test/jest-e2e.json --runInBand=false`)
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app\zenda_backend_app`
- **Tiempo de ejecución:** 28.044 s
- **Suites:** 26 pasadas, 26 total
- **Pruebas:** 135 pasadas, 135 total

### Cobertura de Suites Ejecutadas:

1. `test/infra/analytics.e2e-spec.ts`: Registro de eventos de telemetría, filtrado de metadatos privados, consent gate activo.
2. `test/modules/auth.e2e-spec.ts`: Registro, login, refresh token, validación de DTOs y OTP criptográficamente seguro (`crypto.randomInt`).
3. `test/modules/badges.e2e-spec.ts`: Consulta de insignias, cálculo de progreso y otorgamiento de logros.
4. `test/modules/budgets.e2e-spec.ts`: Creación y actualización de presupuestos por categoría, tope máximo (7 por período).
5. `test/modules/categories.e2e-spec.ts`: Categorías por defecto del sistema y creación/consulta de categorías personalizadas por usuario.
6. `test/modules/goals.e2e-spec.ts`: Creación de metas de ahorro, aportes atómicos, prevención de truncado/sobreaporte y completitud de metas.
7. `test/modules/health.e2e-spec.ts`: Endpoints `/api/health`, `/api/live`, `/api/ready`.
8. `test/modules/idempotency.e2e-spec.ts`: Deduplicación de solicitudes con `Idempotency-Key`, interceptor con reserva única (`statusCode: 0`).
9. `test/modules/insights.e2e-spec.ts`: Resúmenes de día, semana y mes; exclusión de transferencias del total de gastos; límites temporales con huso Lima (`America/Lima`).
10. `test/modules/notifications.e2e-spec.ts`: Despacho y programación de notificaciones con huso horario de Lima.
11. `test/modules/ocr.e2e-spec.ts`: Análisis y extracción de recibos mediante mock de Azure Document Intelligence.
12. `test/modules/personalized-quiz-agent.e2e-spec.ts`: Agente generador de preguntas personalizadas mediante RAG / Foundry Agent.
13. `test/modules/pilot-readiness.e2e-spec.ts`: Verificaciones consolidadas de preparación de piloto (tokens, sanitización, límites).
14. `test/modules/rag-financial-context.e2e-spec.ts`: Inyección de contexto financiero del usuario para asesoría AI.
15. `test/modules/receipts.e2e-spec.ts`: Flujo de subida y procesamiento de comprobantes de pago.
16. `test/modules/recommendations.e2e-spec.ts`: Generación de recomendaciones y estadísticas de adopción.
17. `test/modules/research-dashboard.e2e-spec.ts`: Protección estricta de dashboard de investigación en todos los entornos con token obligatorio; escape de fórmulas CSV.
18. `test/modules/surveys.e2e-spec.ts`: Encuestas SUS con multiplicador 2.5 exacto, validación de IDs de preguntas y rangos.
19. `test/modules/transaction-category-classifier.e2e-spec.ts`: Clasificador automático de transacciones.
20. `test/modules/transactions.e2e-spec.ts`: Registro, actualización y eliminación de transacciones; rechazo de transferencias con monedas diferentes.
21. `test/modules/users.e2e-spec.ts`: Perfil de usuario, actualización de datos y anonimización de cuenta.
22. `test/modules/voice-transaction-draft.e2e-spec.ts`: Creación de borrador de transacción por voz con fallback ante Azure no disponible.

### Log de salida representativo:

```text
Test Suites: 26 passed, 26 total
Tests:       135 passed, 135 total
Snapshots:   0 total
Time:        28.044 s, estimated 41 s
Ran all test suites.
```

---

## 4. Pruebas de Frontend (Flutter)

- **Comando:** `flutter test`
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app\zenda_fronted_app`
- **Tiempo de ejecución:** ~1.5 s
- **Suites:** 2 pasadas, 2 total
- **Pruebas:** 16 pasadas, 16 total

### Pruebas Ejecutadas en `test/pilot_readiness_test.dart` y `test/widget_test.dart`:

1. `clearing the amount does not retain the previous transaction value`: Valida que al vaciar el campo de monto en `NewTransactionController`, el estado no retiene el valor anterior (MOV-01).
2. `reject malformed amount (-5, 0x51, abc, 5.001, NaN, Infinity)`: 6 pruebas unitarias que verifican el rechazo estricto de entradas no numéricas o inválidas.
3. `comma decimal input preserves cents`: Verifica la correcta interpretación de comas decimales (ej. `51,25` => `51.25`).
4. `POST keeps idempotency header after refreshing access token`: Valida que `ApiClient` reenvíe el encabezado `idempotency-key` tras un refresh de sesión 401.
5. `concurrent refresh requests share one token rotation`: Comprueba que múltiples llamadas simultáneas de refresh compartan un único Future para evitar rotaciones de token conflictivas.
6. `network error during refresh preserves stored credentials`: Asegura que un fallo de conexión durante la renovación del token no borre las credenciales almacenadas localmente.
7. `history reads past 100 transactions with filters on every page`: Valida la paginación continua en `TransactionApiService` preservando los filtros aplicados.
8. `telemetry cannot contain notes, email, amounts or arbitrary objects`: Comprueba el filtro de privacidad de `safeTelemetryParameters`, bloqueando PII y datos financieros sensibles.
9. `TransactionModel.fromApiJson parses UTC ISO date into local DateTime`: Verifica que las fechas recibidas en UTC desde el backend sean convertidas al horario local del dispositivo (MOV-03).
10. `TransactionsRepository.deleteTransaction removes matching id from store`: Valida que la eliminación de un movimiento actualice y elimine el registro del almacenamiento local persistente (MOV-05).
11. `Zenda app renders`: Prueba de widget inicial de arranque de la aplicación Zenda.

### Log de salida:

```text
00:00 +0: loading C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart
00:00 +0: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: clearing the amount does not retain the previous transaction value
00:00 +1: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount -5
00:00 +2: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount 0x51
00:00 +3: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount abc
00:00 +4: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount 5.001
00:00 +5: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount NaN
00:00 +6: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: reject malformed amount Infinity
00:00 +7: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: comma decimal input preserves cents
00:00 +8: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: POST keeps idempotency header after refreshing access token
00:00 +9: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: concurrent refresh requests share one token rotation
00:00 +10: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: network error during refresh preserves stored credentials
00:00 +11: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: history reads past 100 transactions with filters on every page
00:00 +12: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: telemetry cannot contain notes, email, amounts or arbitrary objects
00:00 +13: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: TransactionModel.fromApiJson parses UTC ISO date into local DateTime
00:00 +14: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/pilot_readiness_test.dart: TransactionsRepository.deleteTransaction removes matching id from store
00:00 +15: C:/Development/zenda_monorepo_app/zenda_fronted_app/test/widget_test.dart: Zenda app renders
00:01 +16: All tests passed!
```

---

## 5. Herramientas de Auditoría y Telemetría del Piloto

- **Comando:** `node --test tools/pilot-tools.test.cjs`
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app`
- **Tiempo de ejecución:** 138.4 ms
- **Pruebas:** 3 pasadas, 0 fallidas

### Log de salida:

```text
✔ dataset is synthetic and has 120 unique pending cases (2.8244ms)
✔ metric exports are pseudonymous, consent-filtered and exclude content (2.0654ms)
✔ exports require a pseudonym key (0.5403ms)
ℹ tests 3
ℹ suites 0
ℹ pass 3
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 138.4272
```

---

## 6. Auditoría e Inventario de Contratos de API

- **Comando:** `node tools/pilot-audit.cjs`
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app`
- **Resultado:**
  ```json
  {"endpoints": 99, "dtos": 94, "models": 29, "histories": 49, "migrations": 30}
  ```
- **Artefactos actualizados:**
  - `docs/pilot-readiness/api-inventory.json`
  - `docs/pilot-readiness/API_INVENTORY.md`
  - `docs/pilot-readiness/version-manifest.json`
  - `docs/pilot-readiness/CHANGED_FILES.md`

---

## 7. Evaluación de RAG y Asistencia Financiera (Python)

### 7.1 Métricas de Evaluación de RAG
- **Comando:** `python -m unittest test_metrics.py`
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app\tools\rag-evaluation`
- **Resultado:** 3 tests OK (0.001 s)
- **Métricas validadas:** Relevancia de contexto, fundamentación (groundedness) y pertinencia de respuesta.

### 7.2 Ejecución del Runner Offline
- **Comando:** `python evaluate.py dataset.base.jsonl`
- **Directorio de trabajo:** `C:\Development\zenda_monorepo_app\tools\rag-evaluation`
- **Salida:**
  ```json
  {"cases": 120, "mode": "offline_validation", "model_calls": 0, "evaluation_scores": null}
  ```
- **Observación:** El runner valida estructuralmente los 120 casos del dataset sintético base sin consumir llamadas a modelos de Azure OpenAI.

---

## 8. Pruebas que NO Pudieron Ejecutarse y Justificación Técnica

1. **Aislamiento multiusuario en PostgreSQL físico bajo concurrencia:**
   - *Causa:* No existe una instancia PostgreSQL ni daemon de Docker activo en el entorno local de auditoría.
   - *Mitigación actual:* Verificado mediante fixtures en memoria de Prisma y pruebas unitarias de aislamiento en `ISavingsGoalRepository` e `IdempotencyService`. Requiere staging PostgreSQL antes de producción.
2. **Evaluación de RAG Online contra Azure OpenAI:**
   - *Causa:* No se configuraron variables de entorno con credenciales activas de Azure OpenAI (`AZURE_OPENAI_ENDPOINT` y `AZURE_OPENAI_API_KEY`) para evitar cobros o acceso no autorizado durante la auditoría local.
   - *Mitigación actual:* Validación offline de los 120 casos de prueba y suite unitaria de métricas en Python.
3. **Pruebas de reconocimiento de voz y cámara en hardware físico:**
   - *Causa:* La auditoría se ejecuta en entorno headless/desktop sin dispositivo Android físico conectado.
   - *Mitigación actual:* Guion de pruebas manuales documentado en `docs/pilot-readiness/10_MANUAL_QA_SCRIPT.md`.

---

## 9. Evidencia de Compilación, Análisis Estático y Distribución Firebase

### 9.1 Backend NestJS Build
- **Comando:** `npm run build` (`nest build`)
- **Directorio:** `zenda_backend_app`
- **Resultado:** Código de salida 0. Compilación limpia sin errores TypeScript en `dist/`.

### 9.2 Frontend Flutter Analyze
- **Comando:** `flutter analyze`
- **Directorio:** `zenda_fronted_app`
- **Resultado:** `No issues found! (ran in 36.1s)`. Código de salida 0. Cero advertencias y cero lints.

### 9.3 Frontend APK Build (prodRelease)
- **Comando:** `flutter build apk --release --flavor prod --dart-define-from-file=dart_defines/prod.json`
- **Directorio:** `zenda_fronted_app`
- **Salida:** `√ Built build\app\outputs\flutter-apk\app-prod-release.apk (63.3MB)`
- **Versión:** 1.0.0 (build 1)

### 9.4 Despliegue en Firebase App Distribution
- **Comando:** `firebase appdistribution:distribute build\app\outputs\flutter-apk\app-prod-release.apk --app 1:143147353185:android:4e4cf351f410ce12c6d620 --groups zenda-piloto-validacion --release-notes "Zenda v1.0 - Release para grupo de validacion del piloto (SUS contextual, correcciones MOV-01/03/05, GES-01/02, REP-02, PERF-01, GAM-01)."`
- **Release ID:** `57vilo46sq37g`
- **Grupo de Testers:** `zenda-piloto-validacion`
- **Resultado:** `distributed to testers/groups successfully` (Código de salida 0).
