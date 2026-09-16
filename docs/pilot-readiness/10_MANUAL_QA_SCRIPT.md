# Guion QA manual antes del prepiloto

Ejecutores: Fernando y Paolo. Estado de TODOS los pasos: PENDIENTE; este archivo no acredita ejecucion. Usar dos cuentas ficticias A/B, base AISLADA, SMTP de prueba, Android API28 y otro telefono reciente. No ejecutar pruebas de borrado/carga contra participantes. Anotar commit, build, API, TZ del servidor/telefono, paso, esperado, observado, duracion monotona, requestId, evidencia sin PII y resultado. Nunca grabar tokens.

## Preparacion

1. Confirmar entorno de pruebas y ausencia de datos productivos; aplicar migraciones y seed revisado. Guardar prueba de rollback/restauracion en base desechable, no resetear produccion.
2. Identificar version de APK y URL. Para USB local: `adb devices`, `adb reverse tcp:3000 tcp:3000`, `adb reverse --list`; ejecutar flavor dev con API_BASE_URL=http://127.0.0.1:3000/api. Si Firebase dev no esta configurado, no confundir fallo de compilacion con fallo funcional.
3. Ejecutar matriz con servidor TZ UTC y America/Lima. API a medianoche Lima debe producir el mismo periodo. No cambiar reloj de produccion.

## Flujo extremo a extremo

| Paso | Accion | Resultado esperado y evidencia |
|---|---|---|
| 01 | Registrar A con consentimiento, verificar OTP y entrar | Registro sin tokens antes de OTP; correo recibido; OTP incorrecto/expirado rechazado; un solo usuario |
| 02 | Login, fallo de clave tres veces con B sintetico | Bloqueo 15min; sin datos del usuario en error; login valido solo verificado |
| 03 | Completar perfil y PRE | Preguntas del instrumento aprobado; no revela respuestas correctas; envio incompleto bloqueado; envio unico persistido |
| 04 | Registrar ingreso S/1000 y gasto S/51.25 hoy | Saldo movimientos 948.75; gasto/ingreso historial y reportes coinciden. Medir SLA sin excluir lectura secundaria |
| 05 | Abrir nuevo gasto, escribir 51 y borrar; probar -5,0,5.001,NaN | No reutiliza monto anterior; no guarda invalido; formato decimal correcto |
| 06 | Crear categoria personal Materiales; registrar y editar solo nota | Categoria conserva mismo ID/nombre, no se transforma en Otro; aparece en reportes y filtros |
| 07 | Editar gasto a 50.99 y eliminar ingreso con confirmacion/cancelacion | Saldo 949.01 tras editar; cancelar no altera; borrar ingreso => -50.99. Gestion y resumen se refrescan |
| 08 | Registrar ingresos/gastos en ultimo minuto de junio y primero de julio Lima | Junio/julio correctos con backend UTC; semanal/dia/PDF consistentes |
| 09 | Superar 100 movimientos sinteticos; combinar tipo, fecha, categoria y min/max | No pierde movimientos desde el 101; vacios comprensibles; filtros presentes en cada pagina |
| 10 | Crear presupuesto mensual y gasto vinculado de 80% | Avance correcto sin incluir transferencias; usuario B/otro mes no pueden usarse como presupuesto. Registrar resultado de gasto no vinculado segun decision pendiente |
| 11 | Crear meta 100; aporte 10; intentar completar; aportes concurrentes 20+30 | Completar prematuro rechazado; ledger y total 60; sin perdida por concurrencia; no inventar fondos |
| 12 | Crear banco/efectivo y transferir 20 | Disminuye una cuenta/aumenta otra; gasto/ingreso no cambian; diferente moneda rechazada |
| 13 | Foto boleta legible y OCR; corregir total/fecha antes de guardar | Borrador editable, no transaccion antes de confirmar; permiso denegado/archivo grande/formato invalido/error Azure con alternativa manual |
| 14 | Voz: silencio, permiso denegado, frase con ayer y cuenta | Estado visible; error comprensible; borrador confirmado; no guardado automatico ni duplicado |
| 15 | Consultar agente con datos sinteticos y pregunta fuera de alcance | Respuesta educativa breve; fuentes trazables; no claves/PII ni promesa de ganancias; medir latencia y tokens desde Azure |
| 16 | Quiz: un clic por respuesta, ultimo clic repetido, perder red | Una accion por pregunta; feedback, score y progreso. Registrar fallo si no hay intento persistido; no simular aprobacion |
| 17 | Cerrar y reabrir; login A y luego B | Persistencia de A; cero datos/categorias/colas de A en B; biometria no evita validacion de sesion revocada |
| 18 | Pedir IDs de A usando token B en cada modulo | 403/404; sin devolver datos ni alterar filas. Cubrir transaccion/presupuesto/meta/cuenta/chat/feedback/quiz personalizado |
| 19 | Expirar access token con dos pantallas solicitando; cortar red | Una renovacion; red no borra sesion. Misma clave idempotente despues de refresh |
| 20 | Doble tap y cortar red despues de commit financiero | Una escritura; reserva/cola conciliables. Si requiere clave nueva a ciegas, REPROBADO |
| 21 | POST/SUS/satisfaccion incompletos, doble envio, offline | Sin respuestas parciales almacenadas; SUS 97.5 caso de control; version/fecha unicas; reintento no cambia cohorte |
| 22 | Consentimiento desactivado, activar y salir de sesion | Sin eventos previos ni IDs crudos en Firebase; export sin PII/texto; no registrar token en logs |
| 23 | Borrar cuenta sintetica y reutilizar token/refresh | Acceso revocado; identificar texto residual como pendiente, no afirmar anonimato absoluto |
| 24 | Notificacion por gasto y recordatorio 21:30 Lima en entorno de prueba | Inbox/push sin duplicados, permisos Android, background/foreground; medir entrega real independiente de registro |

## Precision OCR por campo

Corpus consentido o sintetico, fotos legibles/borrosas/parciales, tabla por receipt_case_id y campo (comercio, fecha, total, moneda). Guardar correcto/incorrecto/ausente, confianza disponible, corregido booleano, duracion; no valores de boleta ni imagen en telemetria. Separar precision entre campos extraidos y cobertura sobre campos presentes en referencia. Las correcciones humanas no prueban exactitud del modelo por si solas.

## Registro de resultados

Reprobar ante perdida/duplicacion, acceso cruzado, totales incorrectos o captura sin consentimiento. Adjuntar evidencia redaccion anonimizada. Los porcentajes de tareas y crash-free se calculan solo despues con denominador definido; estos 24 pasos no sustituyen evaluacion SUS ni impacto pre/post.
