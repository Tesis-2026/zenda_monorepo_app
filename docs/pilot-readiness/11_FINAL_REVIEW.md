# Revisión final de prepiloto — 2026-09-15

## Alcance y versión

Revisión incremental de los commits root `bde880a` (y checkpoint `c8aa812`), backend `f144013` y frontend `8b26160`. Los tres árboles estaban limpios al inicio. Se reutilizó la auditoría anterior y se contrastaron los cambios de seguridad, transacciones, categorías, reportes, autenticación, fechas, idempotencia y telemetría. No es una nueva certificación de las 49 HU ni del estudio definitivo.

## Bloqueantes concretos corregidos

| ID | Nivel | Reproducción / consecuencia | Corrección y prueba |
|---|---|---|---|
| FR-01 | P1 | A deja un movimiento offline sin cuenta explícita, cierra sesión y B entra en el mismo dispositivo: la cola global podía enviarlo como B. Las recomendaciones persistían en un proveedor global. Una respuesta tardía de refresh podía reinstalar o borrar credenciales tras cambiar de cuenta. | Propietario persistido en pendientes; envío y reenvío tras refresh verifican el propietario del token usado. Cachés de movimientos/recomendaciones dependen del usuario; logout limpia el formulario. Refresh obsoleto no modifica la nueva sesión. Pruebas de cambio de cuenta, cambio durante lookup, refresh tardío 200/401 y reenvío 401. |
| FR-02 | P1 | Cuatro activaciones de sincronización con fallos eliminaban el pendiente sin confirmación del servidor. Dos mutaciones simultáneas de la cola podían sobrescribirse. | Tras tres fallos se suspende el reintento automático y se conserva la entrada; reiniciar permite reintentar. Serialización de escrituras y exclusión de flush concurrentes. Pruebas de conservación, recuperación y encolado/flush concurrentes. |
| FR-03 | P1 | Al fallar `/summary/progress`, Gestión mostraba gastos S/ 1,240 y ahorro S/ 760 ficticios. Las flechas cambiaban el mes mostrado sin consultar otro periodo. | Error visible con reintento; cabecera limitada al periodo actual que devuelve el contrato existente. Pruebas de widget: no aparecen cifras ficticias, reintentar consulta otra vez y no se puede rotular el resultado como otro mes. |

P0 confirmados abiertos: **0**. P1 confirmados abiertos en el código corregido dentro del alcance de prepiloto descrito abajo: **0**. Los tres grupos anteriores siguen afectando al APK anterior si se utiliza sin estas correcciones.

## P2 y límites de alcance relevantes

- Cola: no hay pantalla de conciliación. Entradas antiguas sin `userId` se conservan sin transmitir; no se puede inferir su propietario. Reintentos que resuelven un catálogo modificado pueden producir conflicto de hash; una caída entre escritura y respuesta conserva una reserva pendiente en backend. No se certifica entrega exactamente una vez ni recuperación automática integral. El facilitador debe conciliar antes de volver a registrar un movimiento ambiguo.
- Categorías: la edición conserva la categoría personalizada existente, pero el selector de edición sigue basado en el enum local. Traducción de etiquetas no equivale a un catálogo remoto completo en todos los selectores/PDF.
- La caché local usa identificadores temporales que no se reconcilian con el ID del servidor; borrar por ID del servidor puede dejar un registro local. Los resúmenes/ingresos/progreso consultan backend. No certificar la caché como libro financiero ni su borrado integral con el test unitario anterior.
- Trazabilidad de intentos de quiz, equivalencia/versionado de instrumentos PRE/POST/SUS y calidad RAG quedan pendientes para investigación. No usar el prepiloto como evidencia académica definitiva.
- `eventType` de telemetría continúa abierto; quedan política de consentimiento específico y revisión de datos históricos/retención. El filtrado de metadata y el gate de consentimiento existentes no prueban la configuración remota.
- El alcance es PEN y dispositivos en America/Lima. La política multimoneda, validaciones de moneda/tipo en edición y periodos de otros agregados IA/gamificación no quedan certificados.

## Evidencia y límites

Ver la adenda de revisión final en `05_TEST_EVIDENCE.md`: Flutter 25/25 (9 regresiones nuevas), análisis sin incidencias y backend focalizado 46/46 en 6 suites. Las pruebas HTTP de backend sustituyen Prisma y algunos guards/servicios por mocks. No equivalen a PostgreSQL ni a aislamiento productivo bajo concurrencia.

La evidencia histórica contiene discrepancias: Flutter/Dart 3.29.3/3.7.2 frente a 3.41.6/3.11.4; el reporte dice sin distribución mientras el handoff registra Firebase; la descripción SQLite no corresponde al harness Prisma mock inspeccionado; varias suites enumeradas no existen como archivos separados. Esta revisión usa resultados observados y no amplía esas afirmaciones.

## Dictamen

**CONDITIONAL GO para prepiloto pequeño, acompañado, en PEN/America/Lima**, condicionado a:

1. Usar un APK que incluya estas correcciones y un backend desplegado identificado como `f144013` o equivalente verificado. Registrar su versión/hash. El release Firebase previo no contiene este parche.
2. Antes de recoger datos personales, ejecutar smoke en el entorno real con dos cuentas sintéticas: alta/verificación/login, acceso cruzado, crear/editar/borrar movimiento, concordancia de saldo/reporte y aporte concurrente/idempotencia. Confirmar migraciones/seed y recuperación operativa.
3. Confirmar consentimiento y tratamiento de datos de la cohorte, incluyendo telemetría/IA. Empezar con cuentas nuevas, conciliar pendientes legacy y observar cualquier fallo de red; no recrear con nueva clave un movimiento de resultado ambiguo.

No se verificaron despliegue, PostgreSQL, SMTP/FCM, permisos de Android, comportamiento nativo de almacenamiento, configuración/retención de Firebase/Azure ni calidad RAG online. Una condición incumplida impide iniciar ese prepiloto con datos reales. El estudio definitivo mantiene su evaluación separada.

## Archivos y entrega

APK corregido compilado localmente: `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk`, build solicitado 2, 63.3 MB. SHA256 `a10f31e0298c49f68f61d356607e02742413b8b64519b4e8acb83bc1b93d753a`. Compilación release exit 0 en 401.9 s. No distribuido.

Frontend: `api_client.dart`, `pending_transaction_queue.dart`, `sync_service.dart`, `transaction_api_service.dart`, `mock_services.dart`, `auth_controller.dart`, `dashboard_providers.dart`, `new_transaction_controller.dart`, `progress_screen.dart` y `test/final_review_session_test.dart`.

Root: esta revisión, adenda en evidencia, enlace en reporte y handoff. Sin cambios de código backend, migraciones, dependencias, commits ni distribución en esta revisión. El manifiesto anterior describe el checkpoint anterior; el parche final queda como diff revisable sobre los hashes indicados.
