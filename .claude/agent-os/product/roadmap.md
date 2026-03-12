# WalletWise MVP Roadmap — Plan de Ejecución por Fases

**Goal:** Una aplicación móvil funcional donde estudiantes universitarios registran transacciones, visualizan reportes, reciben predicciones de gasto con IA (≥ 80% precisión), completan retos educativos gamificados, y demuestran un incremento ≥ 20% en conocimiento financiero medido por encuesta pre/post uso. La app cumple estándares de usabilidad (SUS ≥ 4.0/5.0), seguridad (Ley 29733) y calidad (ISO 25010).

**Duración:** 10.5 meses (Febrero 2026 — Diciembre 2026)  
**Equipo:** 2 desarrolladores a tiempo parcial (20 hrs/semana c/u)  
**Presupuesto:** S/ 14,241 (gastos generales + bienes y subcontrata)

**Critical Path:** Infraestructura → Auth → Registro de Transacciones → Categorización → Reportes → Presupuestos → Pipeline ML → Predicciones → Recomendaciones → Educación/Gamificación → Notificaciones → Evaluación Pre/Post → Validación con Usuarios → Demo

---

## Fundamento Técnico

**Stack:**
- Frontend Móvil: Android nativo (Kotlin) — Android 9+ (API 28)
- Backend: Node.js/Express ó Spring Boot + PostgreSQL
- IA/ML: Python (Scikit-learn, TensorFlow Lite) — modelos exportados para inferencia móvil
- Cloud: Azure (servicios cloud, almacenamiento, APIs de IA)
- Autenticación: Firebase Auth (email/contraseña)
- Notificaciones: Firebase Cloud Messaging (FCM)
- CI/CD: GitHub Actions + Google Play Internal Testing

**Estándares:**
- ISO 25010: Calidad de producto software
- ISO 27001: Seguridad de la información
- IEEE 829: Documentación de pruebas
- WCAG 2.1 Nivel AA: Accesibilidad móvil
- Ley 29733: Protección de datos personales

---

## Fase 1: Infraestructura del Proyecto y Configuración Inicial

### 1A. Setup del Entorno de Desarrollo

> **Impacto: Crítico** — Sin infraestructura no hay desarrollo. Bloquea todas las fases siguientes.

- [ ] `P0` `infra` `backend` -- **Configuración del repositorio Git** -- Crear repositorio monorepo en GitHub con estructura: `/android` (app móvil), `/backend` (API REST), `/ml` (modelos de IA), `/docs` (documentación). Incluir `.gitignore`, `README.md`, `CONTRIBUTING.md`, `LICENSE`. Configurar branch protection: `main` (protegido), `develop` (integración), `feature/*` (desarrollo). Refs: [US-1801](./user_stories.md#US-1801)

- [ ] `P0` `infra` `backend` -- **Configuración de base de datos PostgreSQL** -- Provisionar instancia PostgreSQL en Azure. Crear schema inicial con tablas: `users`, `transactions`, `categories`, `budgets`, `goals`, `educational_content`, `challenges`, `badges`, `user_badges`, `predictions`, `recommendations`, `surveys`, `survey_responses`, `notification_preferences`, `analytics_events`, `audit_logs`, `feedback`. Incluir índices, foreign keys, check constraints, enums. Script: `database/schema.sql`. Refs: [US-1802](./user_stories.md#US-1802)

- [ ] `P0` `infra` `android` -- **Proyecto Android base** -- Crear proyecto Android Studio con Kotlin, minSdkVersion 28 (Android 9). Configurar: MVVM architecture, Room (SQLite local), Retrofit (HTTP client), Hilt (dependency injection), Navigation Component, Material Design 3. Estructura de paquetes: `ui/`, `data/`, `domain/`, `di/`, `utils/`. Refs: [US-1803](./user_stories.md#US-1803)

- [ ] `P0` `infra` `backend` -- **API REST base** -- Configurar servidor backend con endpoints health-check: `GET /api/v1/health` retorna `{ status: "ok", version: "1.0.0" }`. Configurar CORS, rate limiting global, logging, error handling centralizado. Documentar con OpenAPI/Swagger. Refs: [US-1804](./user_stories.md#US-1804)

- [ ] `P1` `infra` -- **Configuración de CI/CD** -- GitHub Actions workflow: lint → test → build en cada PR. Deployment automático a Azure (backend) y Google Play Internal Testing (APK) en merge a `main`. Refs: Best practices

- [ ] `P1` `infra` -- **Variables de entorno y secretos** -- Crear `.env.example` con todas las variables requeridas. Configurar GitHub Secrets para CI/CD. Documentar en `SETUP.md`. Refs: Security best practices

---

### 1B. Diseño de Base de Datos y Modelo de Datos

> **Impacto: Crítico** — El schema define la estructura de toda la aplicación.

- [ ] `P0` `backend` `database` -- **Schema de usuarios** -- Tabla `users`: `id` (UUID PK), `email` (UNIQUE NOT NULL), `password_hash` (TEXT NOT NULL), `name` (VARCHAR 100), `age` (INT), `university` (VARCHAR 200), `income_type` (ENUM: BECA, TRABAJO_PARCIAL, FAMILIA, MIXTO), `average_monthly_income` (DECIMAL), `financial_literacy_level` (ENUM: BAJO, MEDIO, ALTO), `profile_completed` (BOOLEAN DEFAULT false), `currency` (VARCHAR 3 DEFAULT 'PEN'), `consent_given` (BOOLEAN DEFAULT false), `consent_at` (TIMESTAMP), `created_at` (TIMESTAMP), `updated_at` (TIMESTAMP). Refs: [US-0101](./user_stories.md#US-0101)

- [ ] `P0` `backend` `database` -- **Schema de transacciones** -- Tabla `transactions`: `id` (UUID PK), `user_id` (FK → users), `type` (ENUM: INGRESO, GASTO), `amount` (DECIMAL NOT NULL CHECK > 0), `category_id` (FK → categories), `description` (TEXT), `date` (DATE NOT NULL), `deleted_at` (TIMESTAMP nullable), `created_at` (TIMESTAMP), `updated_at` (TIMESTAMP). Índices: `(user_id, date)`, `(user_id, category_id)`, `(user_id, type, date)`. Refs: [US-0201](./user_stories.md#US-0201)

- [ ] `P0` `backend` `database` -- **Schema de categorías, presupuestos, metas** -- Tablas `categories`, `budgets`, `goals` según especificación en Fase 4 y 6. Foreign keys con ON DELETE CASCADE donde corresponda. Check constraints para enums. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P1` `backend` `database` -- **Schema de gamificación, IA y evaluación** -- Tablas: `educational_content`, `challenges`, `badges`, `user_badges`, `predictions`, `recommendations`, `surveys`, `survey_responses`, `analytics_events`, `audit_logs`, `feedback`. Refs: [US-0901](./user_stories.md#US-0901)

---

## Fase 2: Autenticación y Gestión de Usuarios

> **Impacto: Crítico** — Sin autenticación no hay acceso a la app. Bloquea todas las funciones de usuario.

- [ ] `P0` `backend` `security` -- **Endpoint de registro** -- `POST /api/v1/auth/register` acepta `email`, `password`, `name`. Valida email formato correcto, password ≥ 8 caracteres con mayúscula, minúscula y número. Crea usuario con status activo. Retorna JWT token. Hasheo con bcrypt (cost factor 12). Refs: [US-0101](./user_stories.md#US-0101)

- [ ] `P0` `backend` `security` -- **Endpoint de login** -- `POST /api/v1/auth/login` acepta `email`, `password`. Valida credenciales. Retorna JWT (expira en 30 días). Bloqueo temporal tras 3 intentos fallidos (lockout 15 min). Refs: [US-0102](./user_stories.md#US-0102)

- [ ] `P0` `backend` `security` -- **Middleware de autenticación JWT** -- Intercepta rutas `/api/v1/*` (excepto `/auth/*`). Valida firma, expiración. Carga `user_id` en request context. Retorna 401 si inválido. Refs: [US-0103](./user_stories.md#US-0103)

- [ ] `P0` `android` `ui` -- **Pantallas de registro y login** -- Formularios con validación en tiempo real. Loading states. Manejo de errores. JWT almacenado en EncryptedSharedPreferences. Refs: [US-0101](./user_stories.md#US-0101), [US-0102](./user_stories.md#US-0102)

- [ ] `P1` `backend` -- **Recuperación de contraseña** -- `POST /api/v1/auth/forgot-password` envía email con token de reset (1h expiry). `POST /api/v1/auth/reset-password` acepta token + nueva contraseña. Refs: [US-0104](./user_stories.md#US-0104)

- [ ] `P1` `android` `ui` -- **Onboarding de perfil inicial** -- Tras primer login: edad, universidad, tipo de ingreso, ingreso promedio, moneda. Guarda `profile_completed = true`. Skip opcional con mensaje de importancia. Refs: [US-0105](./user_stories.md#US-0105)

- [ ] `P1` `android` `ui` -- **Edición de perfil** -- Permite editar datos personales, moneda, formato numérico. Refs: [US-0106](./user_stories.md#US-0106)

---

## Fase 3: Registro de Transacciones (Core Feature)

> **Impacto: Crítico** — Es la acción principal de la app. Sin transacciones no hay datos para nada más.

- [ ] `P0` `backend` `api` -- **CRUD de transacciones** -- `POST /api/v1/transactions` (crear), `GET /api/v1/transactions` (listar con filtros y paginación), `GET /api/v1/transactions/{id}` (detalle), `PUT /api/v1/transactions/{id}` (editar), `DELETE /api/v1/transactions/{id}` (soft delete). Validación de ownership. Balance actualizado en cada operación. Refs: [US-0201](./user_stories.md#US-0201) a [US-0206](./user_stories.md#US-0206)

- [ ] `P0` `android` `ui` -- **Pantalla de registro de transacción** -- Selector tipo (Ingreso/Gasto), input monto numérico, selector de categoría (grid), date picker (default hoy), descripción opcional. Botón "Guardar". Mensaje de confirmación. Refs: [US-0201](./user_stories.md#US-0201)

- [ ] `P0` `android` `ui` -- **Dashboard principal** -- Balance actual del mes, últimas 5 transacciones, FAB "+" para agregar. Pull-to-refresh. Carga en < 2 seg. Refs: [US-0204](./user_stories.md#US-0204)

- [ ] `P1` `android` `ui` -- **Historial con filtros** -- Lista completa de transacciones. Filtros: fechas, categoría, tipo, monto. Búsqueda por descripción. Paginación infinita. Refs: [US-0203](./user_stories.md#US-0203)

- [ ] `P2` `android` `ui` -- **Edición y eliminación** -- Tap en transacción abre detalle editable. Botón eliminar con confirmación. Actualización inmediata de balance y reportes. Refs: [US-0205](./user_stories.md#US-0205), [US-0206](./user_stories.md#US-0206)

---

## Fase 4: Sistema de Categorización

> **Impacto: Alto** — Base para reportes, predicciones y presupuestos.

- [ ] `P0` `backend` -- **Categorías predeterminadas (seed)** -- Gastos: Alimentación, Transporte, Educación, Entretenimiento, Salud, Vivienda, Servicios, Vestimenta, Otros. Ingresos: Beca, Trabajo parcial, Familia, Freelance, Otros. Con iconos y colores asignados. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P0` `backend` `api` -- **CRUD de categorías custom** -- Crear, listar, editar, eliminar categorías personalizadas. Validar que no se eliminen categorías con transacciones. Refs: [US-0302](./user_stories.md#US-0302)

- [ ] `P0` `android` `ui` -- **Selector de categoría** -- Grid con iconos/colores. Opción "Crear nueva". Modal de creación rápida. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P1` `android` `ui` -- **Gestión de categorías** -- Pantalla de administración de categorías personalizadas. Refs: [US-0302](./user_stories.md#US-0302)

---

## Fase 5: Reportes Financieros y Visualización

> **Impacto: Alto** — Visibilidad sobre hábitos financieros. Prerequisito para que predicciones tengan contexto.

- [ ] `P0` `backend` `api` -- **Endpoints de reportes** -- Resumen mensual, semanal, diario. Comparativa multi-mes. Cada uno retorna totales, desglose por categoría con porcentajes. Response < 2 seg. Refs: [US-0401](./user_stories.md#US-0401) a [US-0404](./user_stories.md#US-0404)

- [ ] `P0` `android` `ui` -- **Pantalla de resumen mensual** -- Total ingresos/gastos/balance, gráfico circular por categoría, top 3 categorías. Selector de mes. Refs: [US-0401](./user_stories.md#US-0401)

- [ ] `P1` `android` `ui` -- **Gráficos interactivos** -- Barras por categoría, líneas comparativas por mes. Librería MPAndroidChart. Tap para detalle. Refs: [US-0405](./user_stories.md#US-0405)

- [ ] `P2` `backend` `api` -- **Exportación a PDF** -- Genera PDF con resumen completo. URL de descarga temporal (24h). Refs: [US-0406](./user_stories.md#US-0406)

---

## Fase 6: Gestión de Presupuestos y Metas Financieras

> **Impacto: Alto** — Prerequisito para alertas inteligentes. Las metas dan propósito al ahorro.

- [ ] `P0` `backend` `api` -- **CRUD de presupuestos** -- Crear presupuesto por categoría o global. Listar con `current_spent` y `percentage_used`. Editar y eliminar. Refs: [US-0501](./user_stories.md#US-0501)

- [ ] `P0` `android` `ui` -- **Pantalla de presupuestos** -- Lista con barras de progreso (verde/amarillo/rojo). Creación modal. Refs: [US-0501](./user_stories.md#US-0501)

- [ ] `P1` `backend` `api` -- **CRUD de metas financieras** -- Crear meta con nombre, monto objetivo, deadline. Listar con progreso. Abonar a meta. Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P1` `android` `ui` -- **Pantalla de metas** -- Cards con progreso, botón abonar, animación de completado. Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P2` `android` `ui` -- **Detalle de meta** -- Historial de abonos, gráfico de progreso, proyección de cumplimiento. Refs: [US-0503](./user_stories.md#US-0503)

---

## Fase 7: Pipeline de IA — Recolección y Preparación de Datos

> **Impacto: Crítico** — Sin datos preparados no hay modelo. Puente entre app transaccional y app inteligente.

- [ ] `P0` `ml` `backend` -- **Pipeline de extracción de features** -- Script Python que extrae features por usuario: gasto por categoría por mes, ratio gasto/ingreso, frecuencia, variabilidad. Output CSV. Refs: [US-0701](./user_stories.md#US-0701)

- [ ] `P0` `ml` -- **Dataset de entrenamiento** -- Dataset sintético basado en perfiles estudiantiles peruanos. Mínimo 1000 registros con distribuciones realistas. Documentar variables y supuestos. Refs: [US-0702](./user_stories.md#US-0702)

- [ ] `P0` `ml` -- **Selección y entrenamiento de modelo** -- Evaluar: Linear Regression, Random Forest, XGBoost, LSTM. Métricas: MAE, RMSE, R². Validación cruzada 5-fold. Target: predecir gasto del próximo mes ≥ 80% accuracy. Refs: [US-0703](./user_stories.md#US-0703)

- [ ] `P1` `ml` -- **Exportación para inferencia** -- TFLite para on-device o endpoint API. Documentar entrada/salida del modelo. Refs: [US-0704](./user_stories.md#US-0704)

- [ ] `P1` `ml` -- **Pipeline de re-entrenamiento** -- Script mensual que re-entrena con datos nuevos. Solo despliega si mejora accuracy. Refs: [US-0705](./user_stories.md#US-0705)

---

## Fase 8: Predicciones con IA

> **Impacto: Crítico** — Diferenciador principal. Convierte la app de reactiva a proactiva.

- [ ] `P0` `backend` `ml` `api` -- **Predicción de gastos** -- `GET /api/v1/predictions/expenses?period=next_month` retorna predicción total y por categoría con intervalo de confianza. Requiere ≥ 2 meses de historial. Precisión ≥ 80%. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P0` `backend` `ml` `api` -- **Predicción de ingresos** -- `GET /api/v1/predictions/income?period=next_month` proyecta ingresos considerando variabilidad de fuentes. Refs: [US-0802](./user_stories.md#US-0802)

- [ ] `P0` `android` `ui` -- **Pantalla de predicciones** -- Predicción mensual, desglose por categoría, balance proyectado, indicador de confianza. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P1` `backend` `ml` -- **Detección de anomalías** -- Si gasto en categoría supera >20% promedio histórico, genera alerta. Refs: [US-0803](./user_stories.md#US-0803)

- [ ] `P1` `backend` -- **Registro de accuracy real** -- Al completarse periodo, comparar predicho vs real. Calcular accuracy retrospectiva. Refs: [US-0804](./user_stories.md#US-0804)

---

## Fase 9: Recomendaciones Personalizadas

> **Impacto: Alto** — Cierra el ciclo: datos → análisis → acción concreta.

- [ ] `P0` `backend` `ml` `api` -- **Motor de recomendaciones** -- `GET /api/v1/recommendations` genera 1-5 recomendaciones basadas en patrones, predicciones, presupuestos y metas. Tipos: AHORRO, PRESUPUESTO, META. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P0` `android` `ui` -- **Sección de recomendaciones** -- Cards con mensaje, acción sugerida, botón feedback ("Útil"/"No relevante"). Integrada en Dashboard. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P1` `backend` -- **Tracking de aceptación** -- Endpoint de feedback. Métrica: tasa de aceptación target ≥ 60%. Refs: [US-0902](./user_stories.md#US-0902)

- [ ] `P2` `backend` `ml` -- **Mejora con feedback** -- Motor ajusta prioridad según feedback histórico del usuario. Refs: [US-0903](./user_stories.md#US-0903)

---

## Fase 10: Módulo Educativo y Gamificación

> **Impacto: Alto** — Diferenciador clave. Necesario para demostrar incremento ≥ 20% en conocimiento.

- [ ] `P0` `backend` `api` -- **Contenido educativo** -- CRUD de temas con progreso del usuario. Seed: Presupuesto personal, Ahorro, Crédito/deuda, Inflación, Tasas de interés, Inversión básica, Consumo responsable, Billeteras digitales en Perú. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `android` `ui` -- **Módulo educativo** -- Lista de temas con dificultad y estado. Contenido en formato móvil legible. Marca como completado. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `backend` `api` -- **Sistema de retos** -- CRUD de retos con verificación automática. Seed: "No delivery por 3 días", "Registra gastos 7 días seguidos", "Ahorra S/20 esta semana". Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P0` `android` `ui` -- **Pantalla de retos** -- Retos activos con progreso, disponibles con botón aceptar, completados con fecha. Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P1` `backend` `api` -- **Sistema de insignias** -- Asignación automática por criterios: "Primera transacción", "7 días seguidos", "Meta cumplida", "5 retos completados", "Módulo 100%". Refs: [US-1003](./user_stories.md#US-1003)

- [ ] `P1` `android` `ui` -- **Pantalla de insignias** -- Grid con insignias (color si obtenida, gris si no). Detalle con criterio. Refs: [US-1003](./user_stories.md#US-1003)

---

## Fase 11: Notificaciones y Alertas

> **Impacto: Medio-Alto** — Mantienen engagement y previenen problemas financieros.

- [ ] `P0` `backend` `notifications` -- **Servicio de push notifications** -- Integración con FCM. Métodos para: alerta presupuesto, gasto anómalo, predicción, recordatorio de reto. Refs: [US-1101](./user_stories.md#US-1101)

- [ ] `P0` `backend` -- **Alerta de presupuesto al 80%** -- Job horario que verifica presupuestos. Notifica una vez por presupuesto por periodo. Refs: [US-1102](./user_stories.md#US-1102)

- [ ] `P0` `backend` -- **Alerta de gasto excesivo** -- Trigger al registrar transacción. Si categoría supera >20% promedio últimos 3 meses, notifica. Refs: [US-1103](./user_stories.md#US-1103)

- [ ] `P1` `android` `ui` -- **Preferencias de notificaciones** -- Toggles para cada tipo. Hora de recordatorio diario configurable. Refs: [US-1104](./user_stories.md#US-1104)

- [ ] `P2` `backend` -- **Recordatorio de registro diario** -- Si no registró transacción hoy, envía recordatorio a hora configurada. Refs: [US-1105](./user_stories.md#US-1105)

---

## Fase 12: Evaluación Pre/Post Uso (Medición de Impacto)

> **Impacto: Crítico** — Sin evaluación no se demuestra el OE4. Valida objetivo educativo.

- [ ] `P0` `backend` `api` -- **Encuesta pre-uso** -- Cuestionario de 15-20 preguntas de conocimiento financiero (instrumentos validados). Cálculo de score 0-100. Presentar en onboarding. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P0` `backend` `api` -- **Encuesta post-uso** -- Mismo cuestionario (variante) + SUS. Presentar tras 4-8 semanas. Refs: [US-1202](./user_stories.md#US-1202)

- [ ] `P0` `backend` `api` -- **Cálculo de incremento** -- Comparación pre/post individual y agregada. Target: improvement ≥ 20%. Refs: [US-1203](./user_stories.md#US-1203)

- [ ] `P0` `android` `ui` -- **Pantallas de encuesta** -- Preguntas de opción múltiple, una por pantalla, progress bar. Score al finalizar con interpretación. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P1` `backend` -- **Cuestionario SUS integrado** -- 10 preguntas estándar. Cálculo automático 0-100. Refs: [US-1204](./user_stories.md#US-1204)

---

## Fase 13: Seguridad, Privacidad y Compliance

> **Impacto: Crítico** — Sin seguridad, el manejo de datos financieros viola la ley.

- [ ] `P0` `backend` `security` -- **Cifrado en tránsito y reposo** -- TLS obligatorio. Azure encryption at rest. Backup encriptado. Refs: [US-1301](./user_stories.md#US-1301)

- [ ] `P0` `android` `security` -- **Almacenamiento seguro** -- EncryptedSharedPreferences, SQLCipher para Room, ProGuard habilitado. Refs: [US-1302](./user_stories.md#US-1302)

- [ ] `P0` `backend` `security` -- **Consentimiento Ley 29733** -- Pantalla de consentimiento explícito. Registro en BD con timestamp. Refs: [US-1303](./user_stories.md#US-1303)

- [ ] `P1` `backend` -- **Rate limiting** -- 100 req/min por usuario, 10 req/min para auth. Refs: [US-1304](./user_stories.md#US-1304)

- [ ] `P1` `backend` -- **Auditoría de acceso** -- Log de acciones sensibles en `audit_logs`. Refs: [US-1305](./user_stories.md#US-1305)

- [ ] `P2` `backend` -- **Derecho de eliminación** -- `DELETE /api/v1/account` eliminación completa con 30 días de gracia. Refs: [US-1306](./user_stories.md#US-1306)

---

## Fase 14: Testing y Calidad

> **Impacto: Crítico** — Sin pruebas no hay confianza. Requerido por ISO 25010.

- [ ] `P0` `backend` `testing` -- **Tests unitarios** -- Servicios principales. Cobertura ≥ 80%. Refs: [US-1401](./user_stories.md#US-1401)

- [ ] `P0` `backend` `testing` -- **Tests de integración** -- Pipeline completo: registro → login → transacción → reporte → predicción. Refs: [US-1402](./user_stories.md#US-1402)

- [ ] `P0` `ml` `testing` -- **Validación de modelos** -- Precisión ≥ 80%, no overfitting, predicciones coherentes. Refs: [US-1403](./user_stories.md#US-1403)

- [ ] `P0` `android` `testing` -- **Tests de usabilidad** -- 30 estudiantes, 4-8 semanas, SUS ≥ 4.0/5.0. Refs: [US-1404](./user_stories.md#US-1404)

- [ ] `P1` `backend` `testing` -- **Tests de seguridad** -- JWT, ownership, SQL injection, XSS, rate limiting. Refs: [US-1405](./user_stories.md#US-1405)

- [ ] `P1` `android` `testing` -- **Tests de rendimiento** -- Dashboard < 2s, transacción < 3s, predicciones < 5s. Refs: [US-1406](./user_stories.md#US-1406)

- [ ] `P2` `android` `testing` -- **Tests de compatibilidad** -- Android 9, 11, 13, 14. Resoluciones 720p-1440p. Refs: [US-1407](./user_stories.md#US-1407)

---

## Fase 15: Feedback y Mejora Continua

> **Impacto: Medio** — Permite iterar antes de liberación final.

- [ ] `P0` `backend` `api` -- **Endpoint de feedback** -- Tipo (BUG/SUGERENCIA/GENERAL), mensaje, screen, rating. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P0` `android` `ui` -- **Botón de feedback** -- Accesible desde cualquier pantalla. Modal con formulario. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P1` `backend` -- **Analytics de eventos** -- Log de acciones clave sin afectar rendimiento. Refs: [US-1502](./user_stories.md#US-1502)

- [ ] `P1` `backend` -- **Dashboard interno de métricas** -- Usuarios activos, transacciones/día, scores pre/post, tasa de aceptación. Refs: [US-1503](./user_stories.md#US-1503)

---

## Fase 16: Demo Readiness y Documentación

> **Impacto: Crítico** — La validación requiere datos realistas y escenario reproducible.

- [ ] `P0` `database` -- **Script de datos de prueba** -- 5 usuarios variados, 200+ transacciones por usuario (3 meses), presupuestos, metas, encuestas pre-uso. Refs: [US-1601](./user_stories.md#US-1601)

- [ ] `P0` `docs` -- **Guía de instalación** -- Paso a paso: clonar, BD, variables, backend, APK. Refs: [US-1602](./user_stories.md#US-1602)

- [ ] `P0` `docs` -- **Script de demo** -- 15-20 min: registro → onboarding → encuesta → transacciones → reporte → presupuesto → predicción → recomendación → reto → insignias. Refs: [US-1603](./user_stories.md#US-1603)

- [ ] `P1` `docs` -- **Documentación técnica** -- Diagrama de contexto, componentes, BD, flujo de IA, decisiones técnicas. Refs: [US-1604](./user_stories.md#US-1604)

---

## Cronograma Global

| Fase | Nombre | Sprint(s) | Duración | Estado |
|------|--------|-----------|----------|--------|
| 1 | Infraestructura y Setup | Sprint 1 | 3 semanas | ⏳ |
| 2 | Autenticación y Usuarios | Sprint 1-2 | 3 semanas | ⏳ |
| 3 | Registro de Transacciones | Sprint 2-3 | 4 semanas | ⏳ |
| 4 | Categorización | Sprint 3 | 2 semanas | ⏳ |
| 5 | Reportes y Visualización | Sprint 4-5 | 4 semanas | ⏳ |
| 6 | Presupuestos y Metas | Sprint 5-6 | 3 semanas | ⏳ |
| 7 | Pipeline ML (Datos) | Sprint 6-7 | 4 semanas | ⏳ |
| 8 | Predicciones con IA | Sprint 7-8 | 4 semanas | ⏳ |
| 9 | Recomendaciones | Sprint 8-9 | 3 semanas | ⏳ |
| 10 | Educación y Gamificación | Sprint 9-10 | 4 semanas | ⏳ |
| 11 | Notificaciones | Sprint 10 | 2 semanas | ⏳ |
| 12 | Evaluación Pre/Post | Sprint 11 | 3 semanas | ⏳ |
| 13 | Seguridad y Compliance | Sprint 11-12 | 3 semanas | ⏳ |
| 14 | Testing y Calidad | Sprint 12-13 | 3 semanas | ⏳ |
| 15 | Feedback y Analytics | Sprint 13 | 2 semanas | ⏳ |
| 16 | Demo Readiness | Sprint 14 | 2 semanas | ⏳ |

---

## Mitigación de Riesgos

| Riesgo | Prob. | Impacto | Mitigación | Owner |
|--------|-------|---------|-----------|-------|
| **Fallos integración cloud IA** | Media | Alto | Modelos locales TFLite como respaldo | Fernando |
| **Retrasos complejidad ML** | Alta | Alto | Sprints cortos, prototipado rápido, priorización MVP | Fernando |
| **Disponibilidad equipo** | Media | Medio | Horarios fijos, backup plan, monitoreo carga | Ambos |
| **Vulnerabilidades datos** | Media | Alto | Cifrado e2e, auditorías seguridad, cumplimiento LGPD | Paolo |
| **Baja precisión modelos** | Media | Alto | Validación cruzada, data augmentation | Fernando |
| **Cambios en requisitos** | Alta | Medio | Proceso formal de cambios | Ambos |
| **Data insuficiente** | Baja | Alto | Datos sintéticos, colaboración con universidades | Fernando |
| **Baja adopción** | Media | Medio | Pruebas piloto tempranas, gamificación | Paolo |
| **Costos cloud** | Baja | Medio | Alertas de uso, optimización Azure | Paolo |
| **Obsolescencia librerías** | Baja | Media | Actualización continua | Fernando |

---

## Métricas de Éxito (Post-Demo)

| Métrica | Target | Actual |
|---------|--------|--------|
| **Precisión predicciones** | ≥ 80% | ___ |
| **Incremento conocimiento** | ≥ 20% | ___ |
| **Puntuación SUS** | ≥ 4.0/5.0 | ___ |
| **Tasa errores críticos** | < 1% | ___ |
| **Cobertura tests** | Servicios 80%+ | ___ |
| **Usuarios piloto** | ≥ 30 | ___ |
| **Encuestas completadas** | ≥ 100 pares | ___ |
| **Duración demo** | 15-20 min | ___ |

---

**Ver también:**
- [mission.md](./mission.md) — Visión y objetivos del producto
- [user_stories.md](./user_stories.md) — Historias de usuario detalladas (18 épicas)
