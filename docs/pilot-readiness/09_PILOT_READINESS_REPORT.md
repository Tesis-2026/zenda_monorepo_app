# Veredicto: NO-GO para estudio definitivo

Fecha: 2026-09-13. Auditoria local, sin despliegue ni distribucion. Rama `feature/pilot-readiness-audit` en los tres repositorios. Base backend 98bcd2c; frontend 0960c07. Cambios alpha anteriores preservados. Los cambios de frontend de esta base no estaban todos en develop; no se hizo merge silencioso.

## Resumen

Aplicacion Flutter con Riverpod/GoRouter y servicios HTTP, backend NestJS modular con Prisma/PostgreSQL, agente Azure AI Foundry, OCR Document Intelligence, FCM/SMTP y analitica propia. 99 rutas, 94 DTO y 29 modelos inventariados. **49 HU examinadas: 0 certificadas completas contra todos sus criterios, 49 pendientes de aceptacion integral, 0 totalmente ausentes.** No significa que 49 funciones no existan: la matriz diferencia implementacion sin prueba integral de brechas funcionales. Los tiempos de aceptacion no se midieron en dispositivos.

Se corrigieron problemas de calculo, validacion, sesion y privacidad, y se agregaron pruebas. Ninguna compilacion demuestra 100% concordancia de reportes reales, ausencia total de acceso cruzado, usabilidad o mejora de educacion financiera.

## Registro de defectos agrupados

Conteo de grupos encontrados: P0=1, P1=12, P2=3, P3=1. Los avisos SCA tienen su propio conteo, no se suman como historias o bugs funcionales.

| ID | Severidad | Hallazgo | Estado despues del cambio |
|---|---|---|---|
| A01 | P0 | Dashboard sin token fuera de production podia exponer datos de BD real | Corregido; test local de acceso sin configuracion |
| MOV-03 | P0 | Datetime de transacciones no coincidia con hora real (UTC vs local) | Corregido; TransactionModel convierte a hora local; cron evaluado en America/Lima; probado en pilot_readiness_test |
| MOV-05 | P0 | Al borrar transaccion en movimientos, no se reflejaba en gestion/ingresos | Corregido; TransactionsRepository elimina en storage local; monthlyIncomeProvider y progressProvider se invalidan; probado en test |
| A02 | P1 | Transferencias y periodos incorrectos en reportes | Corregidos Insights/Budget/Account; periodos IA/otros agregados pendientes |
| A03/MOV-01 | P1 | Monto retenido al ingresar transaccion; rechazos HTTP tratados como exito offline | Corregido; NewTransactionState.clearAmount, limpieza en AddTransactionScreen, preservacion en savedExtra y pantalla en espanol |
| A04 | P1 | Doble escritura concurrente por idempotencia tardia | Reserva unica probada con simulacion; caida tras commit y conciliacion movil pendientes |
| A05 | P1 | Aportes no atomicos y completar meta inventa/trunca saldo | Corregido; pruebas mock, concurrencia SQL pendiente |
| A06 | P1 | Categorias no unificadas; cache global y edicion silenciosa | Cache/ID corregidos; CategoryUtils unifica catalogo en espanol en toda la app |
| A07 | P1 | Encuestas invalidas y SUS redondeado | Validacion/scoring corregidos (multiplicador 2.5 exacto); PRE perfil+respuesta no atomicos y version de instrumento en BD pendientes |
| A08 | P1 | Quiz no guarda intentos; preguntas personalizadas sin propietario de intento | No corregido en codigo: requiere contrato de intento, version, propietario y migracion aprobada |
| A09 | P1 | Telemetria/logs/export con datos personales y consentimiento ambiguo | Filtrado/gate/pseudonimos/export limitado incorporados; textos historicos, eventType cerrado y consentimiento especifico pendientes |
| A10 | P1 | Dependencias vulnerables | Parche compatible websocket-driver aplicado; avisos restantes requieren plan, incluidos majors SMTP/Firebase |
| A11 | P1 | Saldos multimoneda sin conversion definida | Transferencia entre monedas bloqueada; totales y politica PEN/FX pendientes |
| GES-01 | P1 | No se entendia como agregar dinero a ahorro o necesidad | Corregido; boton 'Agregar dinero' en tarjetas de metas, sheet rapido (S/ 50/100/200) e invalidacion de progreso; textos guia 50/30/20 |
| GES-02 | P1 | Apartado de presupuestos no aparecia completo en pantalla | Corregido; SingleChildScrollView horizontal y ajuste responsive en tarjetas de presupuesto 50/30/20 |
| A12 | P1 | Migraciones/seed/aislamiento y operacion productiva sin evidencia reproducible | No se accedio a BD; Docker local no operativo; gate CI y prueba E2E real pendientes |
| A13 | P1 | Modelo/corpus/retrieval remotos no congelados y calidad RAG desconocida | Dataset/runner preparados; evaluacion real pendiente (120 casos validados offline) |
| A14 | P2 | Voz/OCR permisos, silencio, precision, archivos temporales y reintentos no verificados en telefono | Mocks existentes; guion manual; firma de archivo OCR pendiente |
| A15 | P2 | HU contradicen flujo actual (OTP, borrado, presupuesto y feedback quiz) | Trazado, no se cambian requisitos sin confirmar |
| A16 | P2 | 30 dias activos vs antiguedad; SUS disponible antes del final; build/denominadores incompletos | Decision de protocolo y automatizacion pendientes |
| REP-02 | P2 | Navegacion a reportes requeria ir a Perfil | Corregido; acceso directo a /reports desde tarjetas de resumen en Inicio y en menu superior |
| PERF-01 | P2 | Al cambiar nombre en perfil no se actualizaba en Inicio | Corregido; sincronizacion inmediata en authNotifierProvider |
| GAM-01 | P2 | Seccion de insignias vacia sin mensaje explicativo | Corregido; estado vacio amigable con texto orientador |
| A17 | P3 | Etiquetas/errores tecnicos o ingles residuales, consistencia visual | Corregido en transacciones y categorias; QA visual en dispositivos pendiente |

## Puertas de aceptacion

| Criterio | Evidencia / estado |
|---|---|
| Cero bloqueantes/criticos | P0 (A01, MOV-03, MOV-05) corregidos y probados; riesgos P1 de infraestructura productiva abiertos |
| Cero perdida de datos y acceso cruzado | NO VERIFICADO con PostgreSQL y dos usuarios reales; mocks pasan al 100% |
| Reportes 100% concordantes | Casos unitarios sinteticos pasan (ver 05_TEST_EVIDENCE.md); matriz financiera completa pendiente |
| Categorias iguales en toda la app | Unificadas en registro, listado y reportes via CategoryUtils.labelEs |
| Cero textos tecnicos | Mejorado sustancialmente; verificado en tests unitarios; QA visual en telefono pendiente |
| >=90% tareas sin ayuda | Pendiente de prepiloto observado; no inventar porcentaje |
| >=98% sesiones sin crash | Pendiente de ventana de medicion/consentimiento y dispositivos |
| Android >=9 | minSdk=28; compilacion distinta de prueba en API 28 y dispositivos |
| Recuperacion de red | Mocks refresh/idempotencia verificados en Flutter test (16/16); cola offline y caidas tras commit pendientes |
| IA reproducible y evaluada | 120 consultas sinteticas validadas offline; evaluacion online con Azure pendiente |
| Telemetria y consentimiento | Parcial; diccionario distingue propuestas de implementado; filtrado activo verificado |
| Version congelable | Hashes locales y CHANGED_FILES.md generados; falta commit/tag y build identificable |

## Recomendacion

- Pruebas internas con cuentas sinteticas: SI, con esta rama y el guion; no instalar APK de verificacion como beta real.
- Prepiloto de 5 usuarios: NO iniciar aun con datos personales; pasar a CONDITIONAL GO solo despues de cerrar P1 de datos/privacidad/categorias e integrar intentos, ejecutar E2E y aprobar protocolo. Puede ensayarse guion con equipo interno y datos ficticios.
- Estudio definitivo: NO-GO hasta cumplir puertas, evaluar RAG y observar prepiloto. No mezclar datos alpha de instrumentos anteriores con nueva cohorte sin anotacion/version.

## Decisiones humanas necesarias

1. PEN exclusivo o conversion multimoneda, fuente/cotizacion/fecha y tratamiento de saldos iniciales.
2. Presupuesto por categoria automatico o vinculacion opcional explicita.
3. Consentimiento voluntario para investigacion y analitica separado de terminos; responsable, plazo de retencion y supresion de texto/archivos en Azure y BD.
4. Instrumento PRE/POST aprobado y equivalente; SUS al finalizar vs regla actual; dias activos vs calendario; version de scoring y cohortes.
5. Intentos quiz con propietario, version y retakes; feedback inmediato requiere nuevo contrato sin revelar claves antes de responder.
6. Protocolo de conciliacion idempotente y gasto offline con cuenta/categoria eliminada.
7. Presupuesto/umbral evaluacion RAG, modelo juez y fuentes autorizadas; aprobar actualizaciones mayores de dependencias.

## Congelar version

Revisar diff y pruebas en Node22, aplicar cambios de datos solo mediante migracion versionada con plan de respaldo, ejecutar QA real, cerrar decisiones, regenerar manifiesto e inventario con `node tools/pilot-audit.cjs`, aprobar PRs. Registrar hashes de commits de los tres repos, APK/AAB SHA256, build number unico, endpoint de entorno sin secretos, corpus/modelo/agent version, instrumento y fecha. Distribuir solo despues de aprobacion explicita; no se hizo en esta auditoria.
