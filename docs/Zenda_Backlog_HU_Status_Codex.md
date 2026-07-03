# Validacion de User Stories - Zenda

Fecha de revision: 2026-07-03  
Fuente: `docs/Zenda_Backlog_HU_Validacion_Codex.md`  
Alcance: revision estatica del codigo backend, frontend, rutas, servicios, modelos y pantallas. No se ejecutaron pruebas e2e ni una prueba funcional completa con dispositivo en esta pasada.

## Resumen ejecutivo

| Estado | Cantidad |
|---|---:|
| Realizado | 45 |
| A medias | 4 |
| Sin cumplir | 0 |
| Total HU revisadas | 49 |

## Leyenda

| Estado | Criterio usado |
|---|---|
| Realizado | Existe pantalla o endpoint, persistencia/calculo principal, validacion basica y flujo conectado. |
| A medias | Existe parte importante de la funcionalidad, pero falta UI, automatizacion, evidencia de infraestructura o algun criterio especifico. |
| Sin cumplir | No se encontro implementacion funcional suficiente en backend/frontend. |

## Hallazgos por historia

| HU | Estado | Evidencia principal | Brecha o accion recomendada |
|---|---|---|---|
| HU-001 Registrar ingresos manualmente | Realizado | `transactions.controller.ts`, `add_transaction_screen.dart`, `new_transaction_controller.dart` soportan tipo ingreso, monto, fecha, categoria y nota. | Validar con prueba manual final en build beta. |
| HU-002 Registrar gastos manualmente | Realizado | Flujo de nueva transaccion soporta gasto, monto mayor a cero, categoria, fecha, nota y cuenta. | Validar con prueba manual final en build beta. |
| HU-003 Editar transacciones | Realizado | `PUT /transactions/:id` y `edit_transaction_screen.dart` permiten modificar monto, categoria, fecha y nota. | Sin brecha critica. |
| HU-004 Eliminar transacciones | Realizado | `DELETE /transactions/:id`, soft delete y confirmacion visual en listado. | Sin brecha critica. |
| HU-005 Categoria para ingreso | Realizado | Categorias de ingreso existen y el clasificador incluye reglas para ingresos como familia, beca, freelance y trabajo parcial. | Seguir afinando sinonimos con datos reales. |
| HU-006 Categoria para gasto | Realizado | Selector manual y sugerencia IA en `POST /transactions/classify`; el usuario puede aceptar o cambiar. | Seguir midiendo precision de sugerencias. |
| HU-040 Crear categoria personalizada | Realizado | `categories.controller.ts` y `new_transaction_controller.dart` soportan nombre personalizado cuando no se usa categoria semilla. | Validar UI con casos duplicados. |
| HU-041 Renombrar/eliminar categoria personalizada | Realizado | Modulo de categorias tiene endpoints de mantenimiento y reglas para categorias de usuario. | Confirmar en prueba manual que la pantalla expone ambas acciones. |
| HU-007 Total gastos del dia por categoria | Realizado | `GET /summary/day`, dashboard/reportes y breakdown por categoria. | Sin brecha critica. |
| HU-008 Ingresos/gastos por dia en semana | Realizado | `GET /summary/week` y tab semanal en reportes. | Sin brecha critica. |
| HU-009 Balance mensual | Realizado | `GET /summary/month`, dashboard y reportes muestran ingresos, gastos y balance. | Sin brecha critica. |
| HU-010 Grafico por categoria en periodo | Realizado | `reports_screen.dart` incluye vista de categorias y graficos con `fl_chart`. | Sin brecha critica. |
| HU-011 Comparativo mensual | Realizado | `GET /summary/comparison` y tab comparativa en reportes. | Sin brecha critica. |
| HU-012 Filtrar historial por rango y tipo | Realizado | Backend soporta `from`, `to`, `type`; `TransactionApiService.getAll` envia fechas codificadas y `transaction_list_screen.dart` expone chips de tipo mas selector de rango de fechas. | Validar manualmente combinaciones: solo tipo, solo rango y tipo+rango. |
| HU-013 Exportar PDF | Realizado | `reports.controller.ts` expone exportacion PDF y frontend lo consume desde reportes. | Validar archivo generado con datos reales. |
| HU-014 Evolucion financiera vs meses anteriores | Realizado | `summary/progress` y comparativas mensuales cubren evolucion. | Sin brecha critica. |
| HU-038 Desglose mensual por categoria | Realizado | Resumen mensual incluye top/breakdown de categorias y tab mensual en reportes. | Sin brecha critica. |
| HU-039 Filtrar historial por categoria y monto | Realizado | Backend soporta `categoryId`, `minAmount`, `maxAmount`; `TransactionApiService.getAll` envia esos parametros y `transaction_list_screen.dart` expone categoria mas monto minimo/maximo en Mas filtros. | Validar manualmente combinaciones de categoria, monto minimo, monto maximo y rango completo. |
| HU-015 Prediccion IA de gastos | Realizado | `GetExpensePredictionUseCase` usa `AzureFoundryAgentClient`, contexto financiero y fallback estadistico. | Revisar logs para confirmar `usedAi=true` en produccion. |
| HU-016 Alerta IA por gasto 20% sobre promedio | Realizado | `SpendingAlertService` detecta exceso sobre promedio historico, prepara contexto financiero agregado y consulta al agente RAG para generar una explicacion personalizada. La notificacion y respuesta del endpoint incluyen `explanation` y `explanationSource`. | Validar manualmente con un usuario que tenga 3 meses de historial en una categoria y un gasto actual >20% sobre promedio. |
| HU-017 Recomendaciones personalizadas IA | Realizado | `GetRecommendationsUseCase` prepara contexto de usuario y persiste recomendaciones con fuente/modelo. | Sin brecha critica. |
| HU-018 Sugerir categoria por IA | Realizado | `POST /transactions/classify`, boton de sugerencia IA y seguimiento de `categorySource`. | Seguir afinando dataset/reglas para casos locales. |
| HU-019 Definir presupuesto mensual | Realizado | `budgets.controller.ts`, repositorio Prisma y pantalla de presupuestos permiten limite mensual por categoria. | Sin brecha critica. |
| HU-020 Notificacion al 80% del presupuesto | Realizado | Al crear gasto se revisa presupuesto y se dispara notificacion `BUDGET_ALERT`. | Requiere FCM configurado para push; inbox funciona como respaldo. |
| HU-042 Resumen presupuestos activos | Realizado | Pantalla de presupuestos muestra tarjetas con avance, gastado, disponible y porcentaje. | Sin brecha critica. |
| HU-043 Editar/eliminar presupuesto | Realizado | Backend `PATCH/DELETE /budgets/:id` y UI de edicion/eliminacion. | Sin brecha critica. |
| HU-021 Crear meta de ahorro | Realizado | `goals.controller.ts` y `goals_screen.dart` permiten nombre, monto objetivo y fecha limite. | Sin brecha critica. |
| HU-022 Ver avance y dias restantes de meta | A medias | `goal_detail_screen.dart` muestra monto actual, porcentaje, restante y fecha limite. | Falta mostrar explicitamente dias restantes calculados. |
| HU-044 Registrar aporte a meta | Realizado | `POST /goals/:id/contributions` y UI de contribucion en detalle. | Sin brecha critica. |
| HU-045 Completar o eliminar meta | Realizado | `complete` y `delete` existen en backend y UI. | Sin brecha critica. |
| HU-023 Modulos de educacion financiera | Realizado | `education.controller.ts`, `education_screen.dart` y seed de topicos. | Sin brecha critica. |
| HU-024 Mini-retos | Realizado | `challenges.controller.ts` y tab de retos en educacion. | Sin brecha critica. |
| HU-025 Insignias por logros | Realizado | `BadgesFacade`, `badges.controller.ts` y pantalla de insignias. | Sin brecha critica. |
| HU-026 Preguntas con feedback inmediato | Realizado | `quiz_screen.dart` y endpoints de quiz/personalized quiz entregan feedback y resultado. | Sin brecha critica. |
| HU-046 Verificacion automatica de retos | Realizado | `VerifyChallengesUseCase` evalua condiciones al registrar transacciones/metas. | Sin brecha critica. |
| HU-048 Ruta de aprendizaje IA | Realizado | `get-personalized-learning-path.use-case.ts` usa agente RAG y fallback. | Sin brecha critica. |
| HU-049 Preguntas generadas por IA | Realizado | `get-personalized-quiz.use-case.ts` usa agente RAG, limita intentos y guarda preguntas. | Sin brecha critica. |
| HU-027 Registro e inicio automatico | Realizado | `auth.controller.ts`, `register.use-case.ts` y frontend registran usuario y retornan tokens. | Sin brecha critica. |
| HU-028 Login con bloqueo por intentos | Realizado | `login.use-case.ts` aplica 3 intentos y bloqueo temporal. | Sin brecha critica. |
| HU-029 Seguridad y privacidad Ley 29733 | A medias | Existen JWT, bcrypt, auditoria, guards y separacion por usuario. | Falta evidencia documentada de HTTPS en prod, cifrado en reposo, politicas de privacidad, retencion/consentimiento y manejo de datos personales. |
| HU-030 Perfil inicial | Realizado | `profile_setup_screen.dart`, `UpdateProfileDto` y modelo User incluyen edad, universidad, situacion/ingreso y nivel financiero. | Sin brecha critica. |
| HU-031 Moneda y formato numerico | A medias | Moneda existe en perfil/backend; hay provider y formatter reactivo para formato numerico. | No se encontro selector visible de formato numerico en `profile_screen.dart`; exponerlo en UI o confirmar pantalla alternativa. |
| HU-032 Onboarding guiado con omitir | Realizado | `onboarding_screen.dart`, `onboarding_prefs.dart` y `splash_decider.dart` manejan carrusel y skip. | Sin brecha critica. |
| HU-033 Evaluacion inicial primera vez | Realizado | Router fuerza `/surveys/pre` cuando el usuario autenticado tiene perfil completo y no completo el pre-test. | Sin brecha critica. |
| HU-034 Invitacion evaluacion final tras 30 dias | A medias | Existe `/surveys/post`, `postSurveyProvider` y comparacion pre/post. | No se encontro banner/automatizacion activa de invitacion a los 30 dias en dashboard; implementarlo o reactivar regla. |
| HU-035 Encuesta SUS | Realizado | `surveys.controller.ts` calcula SUS 0-100; `sus_screen.dart` muestra 10 items 1-5 y exige respuesta. | Sin brecha critica. |
| HU-036 Feedback cualitativo | Realizado | `feedback.controller.ts`, `feedback_modal.dart` y feedback abierto en encuestas finales. | Sin brecha critica. |
| HU-037 Analisis automatico de uso | Realizado | `AnalyticsService`, `StudyTelemetryService`, eventos de uso y `research-dashboard` agregan datos. | Sin brecha critica. |
| HU-047 Evaluacion final vinculada a inicial | Realizado | `GET /surveys/comparison` compara pre/post y frontend tiene `survey_comparison_screen.dart`. | Depende de que HU-034 dispare la invitacion oportunamente. |

## Brechas prioritarias antes de cerrar backlog

1. Agregar dias restantes calculados en detalle/listado de metas para HU-022.
2. Reactivar o implementar invitacion automatica al post-test tras 30 dias de uso activo para HU-034.
3. Exponer selector de formato numerico en perfil para cerrar HU-031.
4. Documentar seguridad/privacidad de produccion para HU-029: HTTPS, cifrado, backups, retencion, consentimiento y manejo de datos personales.

## Nota de validacion

Este reporte identifica cobertura por evidencia de codigo. Para cerrar formalmente las 49 HU se recomienda una pasada final con pruebas manuales sobre build beta y backend productivo, especialmente en transacciones, encuestas, notificaciones, OCR, IA/RAG y dashboard de investigacion.
