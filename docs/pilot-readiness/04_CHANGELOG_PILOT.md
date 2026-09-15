# Cambios del piloto

Fecha 2026-09-13. Rama `feature/pilot-readiness-audit` en raiz, backend y frontend. Sin commit, push, merge, distribucion ni acceso a datos productivos. Se preservan commits alpha previos y el archivo de feedback del usuario. Inventario exacto de archivos: [CHANGED_FILES.md](CHANGED_FILES.md); diff Git es la evidencia de cada linea.

| Problema / causa | Solucion aplicada y archivos principales | Regresion / limite |
|---|---|---|
| Reportes cambiaban de fecha segun TZ del servidor | shared/finance/financial-period.ts; casos de uso Insights, summary.controller, Account y Budgets usan limites Lima | Fecha invalida, bisiesto, fin de mes, semana ISO. No todas las agregaciones IA estan migradas. |
| Transferencias sumadas como gasto diario | prisma-insights.repository.ts filtra INCOME/EXPENSE y suma centavos | 51.01 ingreso, 0.10+0.20 gastos, 500 transferencia => gasto 0.30. |
| Categorias historicas se perdian / consulta sin ambito | Lookup de categorias en resumen conserva etiquetas historicas bajo propietario/sistema | Consulta con scope y fallback Sin categoria. |
| Referencias de presupuesto/sugerencia no verificadas al crear | create-transaction y budgets.facade validan propietario/periodo; cuenta-moneda y categoria-tipo | Compilacion y contratos; falta prueba de penetracion y matriz completa real. |
| Mezcla de divisas en transferencias | accounts.service rechaza transferencia entre monedas distintas | Requiere QA real; no se implemento FX. |
| Modificar transferencia mediante PUT la convertia en gasto | update-transaction rechaza ese flujo | Documentado; editor especifico pendiente. |
| Aportes concurrentes perdian incrementos | puerto ISavingsGoalRepository y PrismaGoalsRepository ejecutan incremento+ledger en transaccion | Mock comprueba operaciones; concurrencia real/rollback PostgreSQL pendiente. |
| Completar meta inventaba saldo o truncaba sobreaporte | complete-goal comprueba objetivo; repositorio no reemplaza currentAmount | Regresion de meta insuficiente; ledger preservado. |
| Duplicados entre lookup y respuesta | IdempotencyService.claim con insert unico, interceptor espera cache final | Simulacion concurrente, hash, replay y dos usuarios. Reservas ambiguas requieren conciliacion. |
| Monto borrado retenia valor anterior; negativos se convertian en positivos | NewTransactionState.clearAmount y parser estricto; guard isSaving | 51, 51.25, coma decimal, borrado, negativos, NaN, Infinity, mas de dos decimales. |
| Error HTTP tratado como guardado offline | Controller encola solo SocketException/Timeout/http.ClientException; persistencia local despues de aceptacion o encolado | Filtro implementado; prueba completa de controlador con cola pendiente. Lectura secundaria de presupuestos no convierte exito en duplicado. |
| Refresh simultaneo y red cortada cerraban sesion | ApiClient comparte Future; conserva credenciales ante red; reenvio POST conserva Idempotency-Key | Mocks HTTP cubren tres casos. |
| Historial limitado a primeras 100 filas | TransactionApiService pagina con mismos filtros; orden servidor estable | Mock de 101 filas. Snapshot concurrente pendiente. |
| Cache global y edicion cambiaban categoria sin pedirlo | Catalogo recargado por sesion/tipo; editor conserva existingCategoryId y usa mapper compartido; mock adaptado | Lectura/analisis estatico; falta catalogo completo en editor y prueba de widgets. |
| Encuestas incompletas y SUS redondeado | surveys.controller valida ids, tipos, opciones; SUS exacto 2.5 | Respuestas invalidas y SUS 97.5. Ver registro de version; no recalcula datos historicos. |
| Analitica antes de consentimiento / datos arbitrarios | AnalyticsService consulta consentimiento activo; listas permitidas metadata; Firebase inicia deshabilitado y activa por consentimiento; ID hash | Pruebas de filtro y opt-out backend; consentimiento separado de investigacion aun pendiente. |
| Logs y borrado conservaban identificadores directos innecesarios | HTTP sin userId/mensajes crudos, filtro sin query ni stack; Email sin destinatario; audit de borrado sin copia de nombre/correo | Prueba de URL malformada y borrado. Otras trazas de IA/auditoria aun sensibles. |
| Dashboard abierto localmente con BD potencialmente productiva | Token obligatorio en todo entorno y comparacion constante; escape formula CSV | Test sin token/config; encabezado preferible a URL. |
| OTP usa Math.random | register usa crypto.randomInt | Contrato registro; resto del ciclo OTP requiere revision adicional. |
| Dependencia con aviso critico | package-lock: websocket-driver 0.7.4 -> 0.7.5, unico paquete cambiado | Repetir auditoria; no actualizar automaticamente majors SMTP/Firebase. |
| Pruebas antiguas no representaban OTP/borrado | auth/users/surveys fixtures alineados, SMTP/FCM sustituidos por mocks, entorno de prueba controlado | No debilita seguridad productiva. |
| Falta evidencia reproducible | tools/pilot-audit.cjs, evaluacion RAG, exportador limitado y diez informes | 120 casos sin respuestas; 3 pruebas Node del tooling. |
| MOV-01: Monto retenido al registrar transaccion | add_transaction_screen.dart limpia controllers y preserva monto en savedExtra; transaction_saved_screen.dart en espanol | Validado en test unitario y UI. |
| MOV-03: Datetime de transacciones desfasado (UTC vs local) | TransactionModel.fromApiJson convierte a .toLocal(); notifications-schedule.service evalua limites en America/Lima | Validado con prueba unitaria en pilot_readiness_test.dart. |
| MOV-05: Eliminacion de transaccion no refrescaba gestion/ingresos | TransactionsRepository.deleteTransaction elimina en KV local; invalidacion de monthlyIncomeProvider y progressProvider en delete y save | Validado con prueba unitaria en pilot_readiness_test.dart. |
| GES-01: No se entendia como agregar dinero a ahorro/necesidades | _GoalCard incluye boton 'Agregar dinero' y sheet de aporte rapido; management_screen clarifica distribucion 50/30/20 | Validado en UI y compilacion Flutter. |
| REP-02: Navegacion a reportes requeria ir a Perfil | Acceso directo a /reports desde tarjetas de resumen en Inicio y en UserMenuButton | Validado en UI y navegacion. |
| PERF-01: Nombre de usuario no se actualizaba en Inicio | profile_screen.dart actualiza authNotifierProvider con nuevo nombre al guardar | Sincronizacion de estado global inmediata. |
| GAM-01: Seccion de insignias vacia sin explicacion | badges_screen.dart muestra banner explicativo cuando no hay insignias obtenidas | Estado vacio con texto guia amigable. |

No se modificaron secretos, preguntas del instrumento, prompts, modelo ni corpus. La correccion de scoring/validacion tiene registro previo y hash posterior en version-manifest.json. No se aplicaron cambios funcionales ambiguos como acumular todos los gastos automaticamente en cada presupuesto o convertir monedas.
