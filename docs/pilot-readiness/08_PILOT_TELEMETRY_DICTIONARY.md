# Diccionario de telemetria del piloto

## Estado y privacidad

Hay AnalyticsEvent en PostgreSQL, eventos Flutter, Firebase Analytics/Crashlytics y dashboard. Se implemento filtro de metadata y consentimiento activo backend, inicio de Firebase deshabilitado, ID Firebase derivado con SHA256 y un exportador offline restringido. Esto es SEUDONIMIZACION, no anonimato irreversible ni certificacion legal. User.consentGiven corresponde al consentimiento de la app: falta decision y pantalla separada si el protocolo exige consentimiento de investigacion/analitica voluntario.

Los eventos operacionales mantienen FK userId; no se exporta directamente. Investigacion (SurveyResponse, Feedback, evaluacion de respuesta IA) es un conjunto distinto de telemetria tecnica. No copiar respuestas, notas ni importes a eventos. El exportador requiere filas consentidas y una clave HMAC externa para producir participant_id estable; controlar acceso a correspondencia, clave y datos origen. El hash Firebase no es el mismo HMAC del exportador: no cruzarlos sin procedimiento aprobado.

Campos comunes propuestos: participant_id, event_type, timestamp UTC, session_id aleatorio, task_id aleatorio, app/build/version, schema_version, duration_ms, outcome/code enumerado. Estado actual: exportador incluye participante, tipo, fecha, duracion y schema_version; session/task/build por evento TODAVIA no integrados completamente. No asumir que beta_distribution_id sobrevivira al filtro nuevo: definir lista de builds aprobados antes de habilitarlo.

| Evento | Proposito/campos no sensibles | Implementacion |
|---|---|---|
| app_session_started | Uso diario; fecha, source enumerada | Existe Flutter/backend |
| app_session_ended | Duracion de sesion | Propuesto; lifecycle no garantiza evento final |
| task_started | Denominador de tareas; tipo de tarea y task_id | Propuesto |
| task_completed | Tasa exito y duracion | Propuesto; eventos de dominio ya dan parte del numerador |
| task_abandoned | Abandono; motivo enumerado | Propuesto; inferir timeout de tarea con regla fija |
| functional_error | Error recuperable; code/outcome enumerados | Propuesto; no texto de excepcion |
| record_transaction / transaction_created | Uso registro; tipo, fuente, has_account/has_budget | Backend y Flutter; NO sumarlos como dos registros |
| screen_view / view_report | Consulta de reportes; pantalla enumerada | screen_view existe; tarea reporte dedicada pendiente |
| create_budget | Uso presupuesto; exito | Existe; se descartan nombre/importe/categoryId |
| receipt_analyzed | Uso OCR; latencia, estado, MIME enumerado | Medicion dedicada pendiente |
| ocr_field_corrected | Precision operacional aproximada; nombre de campo, cambio booleano | Pendiente; NO guardar valor antes/despues |
| chat_message_sent | Uso asistente; modo/latencia/fuentes contadas | Evento existe; latencia/tokens incompletos |
| quiz_started | Intento educativo, no PRE/POST | Pendiente session de intento |
| submit_quiz | Finalizacion educativa; score y total | Evento existe, no sustituye QuizAttempt persistido |
| help_requested | Necesidad de ayuda por tarea | Propuesto |
| endpoint_completed | Latencia tecnica, ruta plantilla/status | Logger HTTP existente; export persistente pendiente |
| ai_completed | Latencia IA, version/modelo/tokens | Propuesto; no derivar calidad de usedRag |
| app_crashed | Sesiones sin cierre inesperado | Crashlytics condicionado a consentimiento; error reducido a tipo, sin texto/stack sensible |
| sus_submitted | Finalizacion instrumento | Existe; puntajes oficiales en SurveyResponse, no duplicar analisis desde eventos |

## Datos prohibidos

Nombre, correo, telefono, DNI, JWT/refresh/OTP, claves, IP/UA como analitica, texto de transaccion/chat, saldo/importe exacto, nombres de metas/categorias personales, boletas/imagenes, URL con parametros, free text de errores y respuestas abiertas. Los filtros no son garantia frente a toda codificacion intencional de PII en campos numericos: acceso y reglas del instrumento siguen siendo necesarios. Nombre eventType aun acepta cadenas validadas por regex, requiere registro cerrado antes del estudio.

## Exportacion

El dashboard existente ofrece CSV/JSON pero incluye respuestas abiertas y grupos pequenos: NO es export anonimo para publicar. No compartir su token ni links con token. Para metricas limitadas usar una extraccion consentida autorizada fuera del repositorio:

```powershell
# Preparar PILOT_PSEUDONYM_KEY en el entorno seguro, no pegarla en comandos registrados.
node tools/export-pilot-metrics.cjs PRIVATE_INPUT.json PRIVATE_OUTPUT_PREFIX
node --test tools/pilot-tools.test.cjs
```

Entrada JSON: lista de {userId, consentGiven, deletedAt, eventType, createdAt, metadata}. Solo metadata.duration_ms/latency_ms se exporta. Salida no sobrescribe archivos existentes y descarta tipos no autorizados. Herramienta NO consulta BD y NO verifica la autenticidad del flag: extraccion bajo control del investigador/operador. Se probo con datos sinteticos, no con la BD productiva.

## Analisis que aun no puede afirmarse

90% de tareas sin ayuda necesita denominador de tareas iniciadas y observacion de ayuda; 98% crash-free necesita definicion de sesion, SDK operativo y ventana temporal. Usuarios con opt-out no equivalen a usuarios inactivos. Un mismo evento cliente y servidor no son dos acciones. Sesion por resume no equivale a dia activo. Notificaciones entregadas no equivalen a aprendizaje. Reportar faltantes, consentimiento, abandonos y cohorte/build; no imputar cero a fallos de medicion.
