# Estado del Proyecto — Historias de Usuario para Entrega Final de Tesis

**Proyecto:** Zenda — App móvil de gestión financiera con IA para estudiantes universitarios peruanos  
**Fuente HU:** P202616_HU_y_Criterios_Aceptacion_V1.md · P202616_Product_Backlog_V1.md  
**Auditado:** 2026-04-29 · **Actualizado:** 2026-04-30 (7 HU parciales completadas)

---

## Resumen Ejecutivo

| Estado | Cantidad | % del total |
|--------|----------|-------------|
| ✅ Completado | 47 | 95.9% |
| ❌ Pendiente | 2 | 4.1% |
| **Total** | **49** | **100%** |

**Las 7 historias parciales fueron completadas el 2026-04-30.** Solo quedan 2 HU sin implementar (US-016, US-034) que requieren esfuerzo alto y no bloquean la entrega.  
Las 47 completadas tienen lógica real en backend y pantallas funcionales en frontend verificadas en código.

---

## ✅ Historias Completamente Implementadas (40)

> Criterios de aceptación satisfechos en backend (endpoints reales con lógica de negocio) y frontend (pantallas funcionales con validación).

| ID | Funcionalidad | Backend | Frontend |
|----|--------------|---------|----------|
| US-001 | Registrar ingresos con monto, fecha, categoría y descripción opcional | `POST /transactions` — real | `add_transaction_screen.dart` — validación, guardado, historial |
| US-002 | Registrar gastos con monto, fecha, categoría y nota opcional | `POST /transactions` — real | `add_transaction_screen.dart` — tipo EXPENSE funcional |
| US-003 | Editar monto, categoría, fecha o descripción de una transacción | `PUT /transactions/:id` — real | `edit_transaction_screen.dart` — validación completa |
| US-004 | Eliminar transacción con diálogo de confirmación | `DELETE /transactions/:id` — soft delete | `transaction_list_screen.dart` — Dismissible con confirmDismiss |
| US-005 | Asignar categoría a ingreso con sugerencia automática de IA | `POST /transactions/classify` — Azure OpenAI + fallback | `add_transaction_screen.dart` — chip de sugerencia con debounce 800ms |
| US-006 | Asignar o cambiar categoría a gasto con sugerencia de IA | `POST /transactions/classify` — real | `add_transaction_screen.dart` — misma lógica de sugerencia |
| US-007 | Ver total de gastos del día con desglose por categoría | `GET /summary/day` — agrega desde DB | Dashboard SummaryCard + pestaña Día en `reports_screen.dart` con `_CategoryBarChart` |
| US-009 | Ver total de ingresos, gastos y balance del mes seleccionado | `GET /summary/month` — agrega desde DB | `reports_screen.dart` pestaña Mes — muestra totalIncome, totalExpense, netBalance |
| US-010 | Visualizar gráfico de porcentaje y monto por categoría en un periodo | `GET /summary/month|week|day` — retorna topCategories | `reports_screen.dart` — `_CategoryBarChart` por periodo seleccionado |
| US-011 | Gráfico comparativo de ingresos, gastos y ahorro entre meses | `GET /summary/comparison` — multi-mes real | `reports_screen.dart` pestaña Comparar — selectores 2M/3M/6M con LineChart |
| US-012 | Filtrar historial por rango de fechas y tipo de transacción | `GET /transactions?from=&to=&type=` — soportado | `transaction_list_screen.dart` — chips tipo + preset fecha + hoja de filtros |
| US-013 | Exportar reporte mensual como PDF y compartir | `GET /reports/export/pdf` — genera PDF real | `reports_screen.dart` — botón exportar + SharePlus |
| US-015 | Consultar predicción de IA sobre gastos del próximo mes | `GET /predictions/expenses` — Azure OpenAI gpt-4o-mini + fallback media móvil | `predictions_screen.dart` — monto estimado, nivel de confianza, narrativa |
| US-017 | Recibir recomendaciones personalizadas de IA | `GET /recommendations` — Azure LLM + fallback basado en reglas | `recommendations_screen.dart` — tarjetas con feedback útil/no útil; acceso desde ZendaAiCard |
| US-018 | IA sugiere categoría automáticamente al analizar descripción/monto | `POST /transactions/classify` — real | `add_transaction_screen.dart` — `_AiSuggestionChip` aparece dinámicamente |
| US-019 | Definir límite de gasto mensual por categoría | `POST /budgets` — restricción única por categoría+periodo | `budget_screen.dart` — diálogo de creación con validación monto > 0 |
| US-020 | Notificación cuando gastos alcanzan el 80% del límite mensual | Cálculo de `percentageUsed` en `GET /budgets` — real | `add_transaction_screen.dart` — SnackBar ámbar con ícono de alerta tras guardar gasto |
| US-021 | Registrar meta de ahorro con nombre, monto objetivo y fecha límite | `POST /goals` — real | `goals_screen.dart` — diálogo con nombre, monto (>0), fecha futura |
| US-022 | Ver progreso, porcentaje, monto restante y días restantes de una meta | `GET /goals` — retorna currentAmount, targetAmount | `goal_detail_screen.dart` — porcentaje, proyección, días restantes |
| US-023 | Acceder a módulos de educación financiera | `GET /education/topics` + `GET /education/topics/:id` — contenido real en DB | `education_screen.dart` + `topic_detail_screen.dart` — lista con niveles y progreso |
| US-024 | Ver y aceptar mini-retos financieros | `GET /challenges` + `POST /challenges/:id/accept` — real | `challenges_screen.dart` — tarjetas con estado AVAILABLE/ACTIVE/COMPLETED y botones |
| US-025 | Recibir insignia al completar meta, reto o hito de uso | Auto-otorgamiento real: First Transaction, Consistency (7 días), Goal Achieved, Budgeter, Financial Sage, Challenger, Predictor | `badges_screen.dart` — grilla con insignias ganadas (color) y bloqueadas (escala de grises) |
| US-026 | Responder preguntas de reto de conocimiento con retroalimentación inmediata | `GET /education/topics/:id/quiz` + `POST /quiz/submit` — calificación real con correctAnswer en DB | `quiz_screen.dart` — feedback correcto/incorrecto por pregunta + puntaje final |
| US-027 | Registrarse con nombre, correo y contraseña; inicio de sesión automático | `POST /auth/register` — bcrypt + JWT + refresh token | `register_screen.dart` — validación completa, auto-redirección a onboarding |
| US-028 | Iniciar sesión con bloqueo de 15 minutos tras 3 intentos fallidos | `POST /auth/login` — lógica de bloqueo en backend tras 3 intentos | `login_screen.dart` — banner de cuenta con `Timer.periodic` en MM:SS, botón deshabilitado |
| US-029 | Datos transmitidos cifrados y almacenados de forma segura | HTTPS en producción; JWT obligatorio en endpoints protegidos (401 sin token) | `api_client.dart` — URL HTTPS producción, Bearer token en headers, almacenamiento seguro |
| US-030 | Completar perfil en primer uso (edad, universidad, situación económica) | `PUT /users/me` — persiste en DB | `profile_setup_screen.dart` — flujo multi-página con campos obligatorios |
| US-032 | Ver pantallas guiadas de bienvenida con opción de omitir | N/A | `onboarding_screen.dart` — botón "omitir" en cada página |
| US-033 | Responder evaluación inicial de conocimiento al abrir la app por primera vez | `POST /surveys/pre/response` — guarda score + fecha | Router redirect via `preSurveyProvider` → `/surveys/pre`; `markCompleted()` libera redirección |
| US-035 | Completar cuestionario de usabilidad SUS | `POST /surveys/post/response` — calcula mejora vs evaluación inicial | `survey_screen.dart` (isPre: false) — 10 preguntas, bloqueo sin responder todas |
| US-036 | Enviar comentarios y sugerencias desde la app | `POST /feedback` — persiste en DB con fecha + userId | `feedback_modal.dart` — accesible desde perfil, validación campo no vacío |
| US-038 | Ver desglose de gastos e ingresos por categoría en resumen mensual | `GET /summary/month` — retorna topCategories con monto y % | `reports_screen.dart` — `_CategoryBarChart` ordenada de mayor a menor |
| US-039 | Filtrar historial por categoría y rango de monto | `GET /transactions?categoryId=` — soportado | `transaction_list_screen.dart` — dropdown de categorías (API) + campos min/max; filtro de monto client-side |
| US-040 | Crear categoría personalizada | `POST /categories` — real | `category_management_screen.dart` — diálogo con validación nombre único |
| US-041 | Renombrar o eliminar categoría personalizada | `PUT /categories/:id` + `DELETE /categories/:id` soft delete | `category_management_screen.dart` — renombrar con ícono, eliminar con swipe + confirmación |
| US-042 | Ver resumen de todos los presupuestos activos con porcentaje de avance | `GET /budgets` — calcula currentSpent desde DB real | `budget_screen.dart` — tarjetas con barra de progreso, monto gastado / límite |
| US-043 | Editar límite de presupuesto o eliminarlo | `PUT /budgets/:id` + `DELETE /budgets/:id` — real | `budget_screen.dart` — diálogo de edición + confirmación de eliminación |
| US-044 | Registrar aporte hacia una meta de ahorro | `POST /goals/:id/contribute` — suma a currentAmount, verifica si alcanzó target | `goals_screen.dart` — diálogo de aporte con validación monto > 0 |
| US-045 | Marcar meta como completada o eliminarla | `POST /goals/:id/complete` (otorga insignia) + `DELETE /goals/:id` — real | `goal_detail_screen.dart` — botones completar y eliminar con diálogos de confirmación |
| US-047 | Completar evaluación final de conocimiento financiero | `POST /surveys/post/response` — vincula con evaluación inicial, calcula % de mejora | `survey_screen.dart` (isPre: false) — misma pantalla, bloquea envío con preguntas sin responder |

---

## ✅ Historias Completadas en Sprint 2026-04-30 (antes parciales)

> Estas 7 historias estaban parcialmente implementadas y fueron completadas el 2026-04-30.

| ID | Funcionalidad | Completado |
|----|--------------|-----------|
| US-008 | Vista semanal agrupada por día | Backend: `getDailyBreakdown()` en `PrismaInsightsRepository`; `WeekSummaryResult.dailyBreakdown[]`. Frontend: `_DailyBarChart` con barras agrupadas Lun-Dom en `reports_screen.dart` |
| US-014 | Indicador de evolución financiera (% chips) | Frontend: `_progressProvider` consume `GET /summary/progress`; `_ProgressChips` muestra chips de gastos/ahorros/balance en pestaña Comparar |
| US-031 | Moneda global propagada desde perfil | Frontend: `currencyProvider` Riverpod en `lib/providers/currency_provider.dart` — lee `user.currency` del `authNotifierProvider` y retorna símbolo (`S/`, `$`, `€`, etc.) |
| US-037 | Analytics para todas las acciones clave | Backend: `AnalyticsService.track()` añadido en `PredictionsController.expenses()` (`view_prediction`) y `EducationController.detail()` (`view_topic`) |
| US-046 | Notificación al auto-completar mini-reto | Backend: `VerifyChallengesUseCase.execute()` retorna `string[]` de nombres. `CreateTransactionUseCase` propaga `newlyCompletedChallenges` en respuesta. Frontend: `TransactionApiService.create()` retorna `List<String>` directo sin polling; diálogo de celebración ya existente en `add_transaction_screen.dart` |
| US-048 | Ruta de aprendizaje — módulo recomendado | Frontend: `education_screen.dart` detecta primer tema incompleto y muestra chip "Recomendado" con color índigo |
| US-049 | Quiz personalizado generado por IA | Backend: `GET /education/quiz/personalized` + `POST /education/quiz/personalized/submit` en `PersonalizedQuizController`; `GetPersonalizedQuizUseCase` construye `SpendingContext` (3 meses, perfil de usuario) y llama `ai.generatePersonalizedQuiz()`; límite 5/día via `analyticsEvent`. Frontend: `PersonalizedQuizScreen` + botón en `education_screen.dart` + ruta `/education/quiz/personalized` |

---

## ❌ Historias No Implementadas (2)

> No existe implementación en backend ni en frontend.

---

### US-016 — Alerta de IA al superar 20% del promedio histórico mensual
**Criterio:** "la app envía automáticamente una notificación alertando del aumento inusual en menos de 10 segundos" tras registrar una transacción que supera el 20% del promedio histórico en esa categoría.  
**Estado actual:** No existe ningún módulo, endpoint, ni lógica de detección de anomalías. Solo existe `NotificationType.ANOMALY_ALERT` en el schema de Prisma como enum vacío.  
**Para implementar:**
1. **Backend:** Nuevo use-case `CheckAnomalyUseCase` que, tras crear una transacción, calcula el promedio de los últimos 3 meses para esa categoría y compara con el gasto actual del mes. Si supera el 20%, guarda una notificación.
2. **Frontend:** Después de guardar una transacción (igual que el alerta de presupuesto), llamar a un endpoint de notificaciones y mostrar SnackBar rojo si hay anomalía.  
**Esfuerzo estimado:** Alto — requiere nueva lógica en backend y frontend.

---

### US-034 — Invitación a evaluación final tras 30 días de uso activo
**Criterio:** "la app muestra de forma no intrusiva la invitación para completar la evaluación final" cuando el usuario lleva 30 días de uso activo y aún no respondió la evaluación post.  
**Estado actual:** No existe ningún contador de días activos ni lógica de invitación. El post-survey existe y funciona, pero nadie lo invoca automáticamente.  
**Para implementar:**
1. **Backend:** Agregar campo `firstLoginAt` (ya existe `createdAt` en User) y endpoint `GET /users/me/pilot-status` que retorne `{ daysActive, postSurveyDone }`.
2. **Frontend:** En `SplashDecider` o `DashboardScreen.initState()`, llamar al endpoint y mostrar un banner persistente (no modal) si `daysActive >= 30 && !postSurveyDone`.  
**Esfuerzo estimado:** Medio — backend es simple, frontend requiere banner persistente con dismiss + storage.

---

## Plan de Cierre para Entrega Final

### Pendiente (2 HU no implementadas)

| # | Historia | Esfuerzo | Notas |
|---|---------|----------|-------|
| 1 | **US-016** Detección de anomalías | Muy Alto | Requiere nuevo módulo + notifications push — no bloquea demo |
| 2 | **US-034** Banner invitación 30 días | Medio | Requiere endpoint `pilot-status` + banner persistente en dashboard |

---

## Notas Técnicas

- **Azure OpenAI:** Las funciones de IA (predicciones, recomendaciones, clasificación) usan Azure OpenAI `gpt-4o-mini`. Si no está configurada la variable de entorno `AZURE_OPENAI_*`, el sistema cae a fallbacks estadísticos/basados en reglas — la app sigue funcionando.
- **Insignias auto-otorgadas:** First Transaction, Consistency (7 días consecutivos), Goal Achieved, Budgeter, Financial Sage, Challenger, Predictor — todas tienen lógica real de trigger en el backend.
- **Seguridad:** HTTPS en producción, JWT con refresh tokens, bcrypt para contraseñas, soft deletes en todas las entidades, 401 en endpoints protegidos sin token.
- **Encuesta pre/post:** Ambas están conectadas en DB — el endpoint de comparación calcula automáticamente el `improvementPercentage` entre la evaluación inicial y la final.

---

*Última actualización: 2026-04-30 — Sprint de cierre: 7 HU parciales completadas*
