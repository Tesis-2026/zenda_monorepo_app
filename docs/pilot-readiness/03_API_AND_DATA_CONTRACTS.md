# Contratos API y datos

Inventario completo extraido con AST de TypeScript: [API_INVENTORY.md](API_INVENTORY.md), [api-inventory.json](api-inventory.json). Incluye 99 rutas, parametros, retornos declarados, 94 DTO y campos/relaciones de 29 modelos del cliente Prisma. Los tipos inferidos y respuestas `object` no constituyen OpenAPI de salida exhaustivo. Regenerar cliente si cambia schema antes de inventariar.

## Contratos principales

| Flujo | Contrato real | Persistencia / consumidor | Observacion |
|---|---|---|---|
| Registro | POST /api/auth/register; email,password,fullName,consentGiven=true | User, AuthChallenge / auth_api_service.dart | Devuelve requiresEmailVerification, NO tokens. HU-027 desactualizada. |
| Sesion | POST /api/auth/login y /refresh; JWT Bearer en recursos protegidos | RefreshToken, User.tokenVersion / ApiClient | Renovacion frontend compartida; no borrar tokens por fallo de red. |
| Perfil | GET/PUT/DELETE /api/users/me | User / profile_screen.dart | DELETE logico y sustitucion de identidad, no anonimiza todos los textos relacionados. |
| Movimientos | POST /transactions; type,amount,categoryId o newCategoryName,occurredAt; cuenta y presupuesto opcionales | Transaction / TransactionApiService | Decimales 2, instante ISO; presupuesto solo gasto, propietario y periodo validado al crear. |
| Historial | GET /transactions?from&to&type&categoryId&minAmount&maxAmount&take&skip | Transaction / lista y reportes | Flutter ahora pagina de 100 en 100. Orden servidor fecha+id. No snapshot: ediciones concurrentes durante paginacion aun pueden cambiar paginas. |
| Editar | PUT /transactions/:id | Transaction / edit_transaction_screen.dart | Conserva ID de categoria si el usuario no lo cambio; falta selector completo remoto en editor. |
| Cuentas | GET/POST /accounts; POST /accounts/transfers; GET /accounts/report | Account, Transaction | Transferencias no son gasto. Rechazo de divisas distintas sin conversion. |
| Resumen | GET /summary/day, /week, /month, /comparison, /progress | Agregados Transaction / reportes | Limites America/Lima UTC-05, fechas YYYY-MM-DD para el dia; balance en centavos. |
| Presupuesto | GET/POST/PATCH/DELETE /budgets | Budget, Transaction.budgetId | Monto usado se calcula por vinculo explicito, no automaticamente por categoria. |
| Metas | /goals y /goals/:id/contributions, /complete | SavingsGoal, GoalContribution | Aporte+incremento atomicos; completar no fabrica dinero. |
| OCR | POST /receipts/analyze multipart campo file; JPEG/PNG/PDF <=10MB | Borrador sin guardar gasto / Receipt API | MIME proporcionado por cliente, falta inspeccion de firma/contenido. Solo confirmacion posterior crea movimiento. |
| Chat | POST /ai/chat {message}; identidad del JWT | AiConversation/AiMessage / chat | reply/answer duplicados por compatibilidad, sources y metadata; historial no conserva toda metadata de fuentes. |
| Quiz | GET /education/topics/:id/quiz; POST .../quiz/submit {answers} | QuizQuestion / quiz_screen.dart | Feedback al final; SubmitQuizUseCase no escribe QuizAttempt. No usar como instrumento academico. |
| Investigacion | GET /surveys/pre,post,sus,satisfaction; POST .../response {answers: {id:string}} | Survey.questionsJson, SurveyResponse.answersJson | PRE/POST completos y opciones validas; SUS diez items y valores exactos 1..5. |
| Analitica | POST /analytics/events {eventType,metadata} | AnalyticsEvent / StudyTelemetryService | Filtra metadata y consentimiento actual. Nombre de evento aun requiere registro cerrado. |
| Dashboard | GET /research-dashboard y export.csv/json | Agregacion investigacion | Token obligatorio en todo entorno. Export existente contiene textos abiertos: NO considerarlo anonimo. Usar exportador limitado del diccionario. |

## Validacion y errores

ValidationPipe global: transform, whitelist, forbidNonWhitelisted. Guards JWT y controles de propietario en repositorios/casos de uso; los contratos mock no prueban aislamiento real de BD. 400 validacion; 401 sesion; 403 permisos/verificacion; 404 recurso/configuracion ausente; 409 duplicado o idempotencia pendiente; 413 archivo grande; 429 limite; 503 proveedor/configuracion. Error generico 500 no debe mostrar traza; logging distingue ahora HttpException de 500.

Idempotency-Key es opt-in para POST/PUT/PATCH autenticados. Se reserva fila unica (key,userId), statusCode=0 antes del handler y se espera persistencia de respuesta. Un fallo ambiguo conserva la reserva: NO reenviar con clave nueva sin conciliar el movimiento. No garantiza atomicidad entre la transaccion financiera y su respuesta ante caida del proceso. Validaciones fallidas tambien dejan reserva; corregir borrador requiere nueva operacion solo cuando se haya comprobado que no hubo escritura. Falta flujo explicito de conciliacion en movil.

## Datos y diferencias pendientes

- Prisma Decimal se transforma a number en DTO. Las reglas nuevas redondean centavos en reportes, no todo el sistema. Limites de precision y montos extremos requieren pruebas SQL.
- Transaction usa occurredAt como instante; periodo financiero Lima se centralizo en Insights, Budget y Account. Contexto del agente, predicciones y otros cron todavia requieren alinear sus periodos antes de afirmar consistencia global.
- Enum Flutter y catalogo de categorias remoto coexisten. Cache eliminada para no reutilizar categorias de otra sesion; catalogo filtrado por tipo. Persisten opciones inglesas/etiquetas mapeadas en distintas capas.
- Moneda de perfil es formato, no cotizacion FX. Prohibir mezclar monedas en totales o definir conversion requiere decision de producto.
- ApiClient ignora salidas desconocidas y conserva compatibilidad reply/answer. No hay generacion de Dart desde OpenAPI; contrastar inventario con parsing en core/services y core/models.
- Encuestas requieren seed. No confundir migraciones (estructura) con sembrado (contenido). No ejecutar el seed completo sobre produccion sin revisar que otros datos crea.
- Sin nuevas migraciones en este cambio. Las 30 migraciones existentes se inventarian por hash. No se verifico aplicacion ni rollback de todas en PostgreSQL real. Una reversibilidad de esquema no implica recuperar datos eliminados: requiere respaldo probado.

## Superficies adicionales

Swagger, health y dashboard no tienen por que ser consumidos por Flutter. Voz, OCR, cuentas y chat exceden el backlog original; documentados aqui pero pendientes de HU propias. Pantallas demo/mock no prueban contratos productivos. CI despliega main sin una puerta completa de pruebas/migraciones: incorporar aprobacion y verificacion de esquema antes del piloto.
