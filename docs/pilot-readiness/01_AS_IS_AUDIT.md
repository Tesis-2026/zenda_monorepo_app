# Auditoria AS-IS de Zenda

Fecha: 2026-09-13. Diagnostico inicial registrado ANTES de modificar codigo.
Alcance: copia local de los tres repositorios; ninguna consulta a datos de participantes ni modificacion de secretos o produccion.

## Versiones examinadas

- Backend: `98bcd2c`, procedente de `feature/pilot-alpha-bugfixes`; los arreglos anteriores tambien estan en las referencias locales de develop/main.
- Flutter: `0960c07`, procedente de `feature/pilot-alpha-bugfixes`; incluye arreglos que la referencia local de develop (`eac2388`) todavia no contiene.
- Rama de trabajo en los tres repositorios: `feature/pilot-readiness-audit`.
- Se conserva `docs/bugs-pilot.md`, archivo preexistente no seguido por Git.
- Fuente de requisitos: `docs/Zenda_Backlog_HU_Validacion_Codex.md`, contrastada con `docs/thesisDocs/` y feedback alpha.

## Arquitectura observada

Flutter/Riverpod/GoRouter consume REST mediante ApiClient. Combina datos remotos con almacenamiento seguro local y colas de sincronizacion. NestJS 11 expone `/api`, valida DTO con class-validator y usa Prisma/PostgreSQL. Hay modulos con puertos/repositorios y otros servicios con Prisma directo. JWT propio con refresh, OTP por SMTP, bloqueo e invalidacion por tokenVersion. Azure Foundry ejecuta chat, quizzes y otras tareas; Document Intelligence extrae borradores OCR. FCM envia notificaciones; Firebase Analytics/Crashlytics/Remote Config complementan AnalyticsEvent y el dashboard HTML del backend.

El informe anterior declara 49 HU realizadas mediante inspeccion estatica y reconoce que no ejecuto E2E. Esa declaracion NO equivale a aceptar criterios funcionales ni a autorizar el estudio definitivo.

## Inventario inicial

Estados AS-IS; las correcciones y resultados posteriores se registran en 04 y 05.

| Modulo | HU relacionada | Frontend | Backend | Base de datos | Pruebas | Estado | Riesgo | Evidencia |
|---|---|---|---|---|---|---|---|---|
| Autenticacion/perfil | 027-032 | Registro, OTP, login, perfil, biometria | Auth, Users, JWT, SMTP | User, RefreshToken, AuthChallenge | Contratos con mocks; aun no ejecutados | Parcial | Registro del test antiguo espera tokens antes de verificar correo | `test/modules/auth.e2e-spec.ts`, `auth.controller.ts` |
| Transacciones | 001-006,012,039 | Alta/edicion/lista y cola local | CRUD con validacion y filtros | Transaction, Account | Contratos con mocks | Inconsistente | El estado nullable no limpia monto; captura cualquier error como offline; concurrencia de reintentos | `new_transaction_controller.dart`, `idempotency.interceptor.ts` |
| Categorias | 005,006,018,040,041 | Mezcla enum, nombre y catalogo API | Catalogo sistema/usuario | Category | Contratos | Parcial | Cache estatica por nombre; edicion pierde categoria personalizada | `transaction_api_service.dart` |
| Voz | extension transacciones | speech_to_text, borrador editable | Parser/reglas y agente | Transaction al confirmar | Mocks de parser | Parcial | Permisos/silencio necesitan dispositivo; errores localizados en alpha | `voice_transaction_service.dart` |
| OCR | extension transacciones | image_picker, borrador editable | Multipart y Document Intelligence | Sin tabla de boletas | Mocks OCR | Parcial | Sin evidencia de precision por campo ni prueba real Azure | `docs/receipt-ocr.md` |
| Reportes | 007-014,038 | Graficos/resumen/exportacion | Insights y PDF | Agregados Transaction | Contratos; no BD real | Inconsistente | Desglose diario suma TRANSFER como gasto; dias UTC y periodos dependientes del servidor | `prisma-insights.repository.ts` |
| Presupuestos | 019,020,042,043 | Gestion y limites por categoria | Budgets/alertas | Budget, Transaction | Contratos | Parcial | Periodos, suma de gasto vinculado vs categoria y refresco requieren comprobacion | `prisma-budgets.repository.ts` |
| Metas | 021,022,044,045 | Lista, detalle, aportes | Goals | SavingsGoal, GoalContribution | Contratos | Parcial | Persistencia concurrente y regla de aportes/eliminacion por comprobar | `goals.controller.ts` |
| IA/RAG | 015-018,048,049 | Chat, predicciones, quizzes | Agente y fallback estadistico | Prediction, Recommendation, AiConversation/AiMessage | Mocks locales | Parcial | Configuracion de agente, retrieval y corpus remotos sin snapshot | `azure-foundry-agent.client.ts` |
| Educacion | 023-026,046,048,049 | Temas, quiz, aprendizaje | Education | EducationalTopic, QuizQuestion, QuizAttempt, progreso | Contratos | Parcial | Feedback inmediato vs avance de un clic; respuestas expuestas por verificar | `quiz_screen.dart` |
| Investigacion | 033-037,047 | PRE/POST/SUS/satisfaccion | Surveys/dashboard | Survey, SurveyResponse, Feedback | Contratos | Parcial | Instrumentos sin version explicita; umbrales por dias activos no demostrados | `docs/research-pilot-data.md` |
| Telemetria | 037 | Firebase + eventos backend | AnalyticsService, dashboard | AnalyticsEvent, AuditLog | Contratos | Inconsistente | Metadata arbitraria; Firebase se habilita antes de consentimiento; export incluye texto libre | `study_analytics_service.dart`, `analytics.service.ts` |
| Privacidad/operacion | 029 | Secure storage, consentimiento | Anonimizacion, guards, logs | Soft delete y auditoria | Sin evidencia operativa | Parcial | Logs incluyen mensajes de error/correo; dashboard sin token fuera de production; retencion sin plazo | `email.service.ts`, `research-dashboard.controller.ts` |

## Hallazgos iniciales que orientan las correcciones

1. P1: transferencias incluidas como gastos diarios y periodos que cambian entre Windows y Linux/UTC.
2. P1: estado del formulario conserva el monto anterior o acepta el anterior al vaciar el campo; errores HTTP definitivos tratados como guardado offline.
3. P1: idempotencia por respuesta no impide dos escrituras simultaneas y persiste la respuesta sin esperar.
4. P1: telemetria sin lista permitida de campos y logs con datos directos o contenido arbitrario de excepciones.
5. P1: faltan evidencias de BD/migraciones reales, privacidad completa, aislamiento efectivo y reproducibilidad del agente para aprobar el estudio.
6. P2: el informe historico no distingue cobertura por codigo de evidencia ejecutada; HU y flujos han cambiado (OTP, encuesta omisible, feedback quiz).

## Limites y decisiones

No se presupone acceso a infraestructura productiva, calidad de respuestas de Azure, TLS/backups, consentimiento academico suficiente ni porcentajes de uso. No se cambiara el contenido del agente/corpus ni instrumentos sin versionar. Los cambios que alteren requisitos se documentaran como decisiones pendientes. La evidencia de ejecucion y veredicto final se completan despues de las pruebas, sin sustituir este AS-IS.
