# Estado del Proyecto — Historias de Usuario para Entrega Final de Tesis

**Proyecto:** Zenda — App móvil de gestión financiera con IA para estudiantes universitarios peruanos  
**Fuente HU:** P202616_HU_y_Criterios_Aceptacion_V1.md · P202616_Product_Backlog_V1.md  
**Auditado:** 2026-04-29 · Revisado con análisis estático de código (backend NestJS + frontend Flutter)

---

## Resumen Ejecutivo

| Estado | Cantidad | % del total |
|--------|----------|-------------|
| ✅ Completado | 40 | 81.6% |
| ⚠️ Parcial | 7 | 14.3% |
| ❌ Pendiente | 2 | 4.1% |
| **Total** | **49** | **100%** |

**Para la entrega final se requiere trabajar sobre 9 historias** (7 parciales + 2 pendientes).  
Las 40 completadas tienen lógica real en backend y pantallas funcionales en frontend verificadas en código.

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

## ⚠️ Historias Parcialmente Implementadas (7)

> La funcionalidad base existe pero uno o más criterios de aceptación no se cumplen completamente.

---

### US-008 — Vista semanal agrupada por día
**Criterio incumplido:** "muestra los totales de gastos e ingresos agrupados correctamente por **cada día**"  
**Estado actual:** La pestaña Semana en `reports_screen.dart` muestra los totales semanales consolidados, no un desglose día por día (Lun/Mar/Mié…).  
**Qué falta:**
- Modificar la respuesta de `GET /summary/week` para incluir un array de totales por día de la semana, o llamar a `GET /summary/day` 7 veces.
- Agregar un `BarChart` horizontal en la pestaña Semana que muestre ingresos/gastos por cada día.

---

### US-014 — Indicador de evolución financiera
**Criterio incumplido:** "variaciones porcentuales e indicadores visuales de mejora o retroceso"  
**Estado actual:** El gráfico comparativo en la pestaña Comparar muestra líneas de ingresos/gastos/balance entre meses pero sin porcentajes de cambio etiquetados. El endpoint `GET /summary/progress` existe y retorna `percentageChange`.  
**Qué falta:**
- Consumir `GET /summary/progress` en el frontend.
- Mostrar chips o badges con "↑ 12%" / "↓ 8%" junto a cada métrica comparada (ingresos, gastos, balance).

---

### US-031 — Seleccionar moneda y formato numérico
**Criterio incumplido:** "todos los montos de la app se actualizan al nuevo formato **sin necesidad de reiniciar**"  
**Estado actual:** El dropdown de moneda existe en `profile_screen.dart` pero la selección no propaga el cambio globalmente — los montos en otras pantallas siguen mostrando el formato hardcodeado `S/`.  
**Qué falta:**
- Crear un `currencyProvider` (Riverpod) que persista en SharedPreferences.
- Reemplazar los literals `'S/'` en todas las pantallas por el símbolo del provider.
- Guardar la selección del dropdown al perfil y releer al iniciar.

---

### US-037 — Registrar automáticamente patrones de uso
**Criterio incumplido:** "el sistema registra el tipo de evento y la marca de tiempo **en menos de 300 ms** sin generar demora perceptible" para **todas las acciones clave**  
**Estado actual:** El backend ya registra analytics en: registro/login de usuario, creación/eliminación de transacciones, y envío de feedback. No se registra: apertura de reportes, aceptación de retos, consulta de predicciones, visualización de módulos educativos.  
**Qué falta:**
- Llamar al endpoint de analytics (o usar fire-and-forget interno) en las acciones restantes: `context.push('/reports')`, `challenges/:id/accept`, `GET /predictions/expenses`, `education/topics/:id`.

---

### US-046 — Verificación automática de condiciones de mini-reto
**Criterio incumplido:** "el reto se marca como completado, se registra la fecha y **se muestra una notificación de logro al usuario**"  
**Estado actual:** El backend ejecuta `verify-challenges` de forma asíncrona cada vez que se crea una transacción. Las condiciones `daily_recording_streak` y `savings_goal_contribution` tienen lógica real. Las insignias se otorgan automáticamente. Pero el usuario no recibe ninguna señal en el frontend cuando un reto se autocompleta.  
**Qué falta:**
- Después de guardar una transacción, llamar a `GET /challenges` y comparar el estado previo vs nuevo.
- Si algún reto cambió a COMPLETED, mostrar un diálogo o SnackBar de celebración.

---

### US-048 — Ruta de aprendizaje ordenada por IA
**Criterio incumplido:** "la IA muestra los módulos **ordenados de más a menos relevante** para su situación, con una breve explicación de por qué cada módulo es prioritario"  
**Estado actual:** `GET /education/topics` retorna los temas en orden de DB. No existe lógica de ordenamiento por IA. La pantalla `education_screen.dart` muestra los temas tal como los recibe.  
**Qué falta (opción pragmática para tesis):**
- En el backend, agregar lógica de priorización simple: si el usuario tiene gastos altos en una categoría, poner primero el módulo relacionado.
- O en el frontend, mostrar una etiqueta "Recomendado para ti" en el primer módulo y ordenar por relevancia local usando el historial de transacciones disponible.

---

### US-049 — Preguntas de quiz generadas por IA según hábitos de gasto
**Criterio incumplido:** "la IA genera preguntas relacionadas con sus **hábitos financieros más relevantes**"  
**Estado actual:** `GET /education/topics/:id/quiz` retorna preguntas estáticas almacenadas en DB por tema. Las preguntas no varían según el perfil de gasto del usuario.  
**Qué falta (opción pragmática para tesis):**
- Crear un endpoint `GET /education/quiz/personalized` que llame a Azure OpenAI con contexto de las categorías donde el usuario más gasta, y genere 3-5 preguntas dinámicas.
- O mostrar en el quiz el módulo que más aplica a los gastos del usuario como el primero disponible (fallback aceptable del criterio SC2).

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

### Prioridad Alta (bloquea criterios de aceptación claros)

| # | Historia | Esfuerzo | Impacto |
|---|---------|----------|---------|
| 1 | **US-008** Vista semanal por día | Medio | Alto — el evaluador puede verificar visualmente |
| 2 | **US-014** Indicadores % de evolución | Bajo | Alto — endpoint ya existe, solo falta UI |
| 3 | **US-034** Banner invitación 30 días | Medio | Alto — clave para el piloto de tesis |
| 4 | **US-046** Notificación reto auto-completado | Bajo | Medio — el backend ya funciona, solo falta el SnackBar |

### Prioridad Media (mejora la demostración pero tiene fallback)

| # | Historia | Esfuerzo | Impacto |
|---|---------|----------|---------|
| 5 | **US-031** Persistencia de moneda global | Medio | Medio — visible en demo |
| 6 | **US-048** Orden de módulos educativos | Medio | Medio — criterio SC2 (fallback) ya satisfecho |
| 7 | **US-049** Quiz contextualizado | Alto | Bajo — SC2 ya satisfecho con preguntas genéricas |

### Prioridad Baja (complejidad alta, impacto tesis moderado)

| # | Historia | Esfuerzo | Impacto |
|---|---------|----------|---------|
| 8 | **US-016** Detección de anomalías | Muy Alto | Bajo — no visible en demo de 30 min |
| 9 | **US-037** Analytics en todas las acciones | Medio | Bajo — datos para investigador, no para usuario |

---

## Notas Técnicas

- **Azure OpenAI:** Las funciones de IA (predicciones, recomendaciones, clasificación) usan Azure OpenAI `gpt-4o-mini`. Si no está configurada la variable de entorno `AZURE_OPENAI_*`, el sistema cae a fallbacks estadísticos/basados en reglas — la app sigue funcionando.
- **Insignias auto-otorgadas:** First Transaction, Consistency (7 días consecutivos), Goal Achieved, Budgeter, Financial Sage, Challenger, Predictor — todas tienen lógica real de trigger en el backend.
- **Seguridad:** HTTPS en producción, JWT con refresh tokens, bcrypt para contraseñas, soft deletes en todas las entidades, 401 en endpoints protegidos sin token.
- **Encuesta pre/post:** Ambas están conectadas en DB — el endpoint de comparación calcula automáticamente el `improvementPercentage` entre la evaluación inicial y la final.

---

*Última actualización: 2026-04-29*
