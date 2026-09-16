# Guía de Liberación para Prepiloto Académico — Zenda

**Fecha:** 2026-09-15  
**Ámbito:** Prepiloto académico pequeño, controlado y acompañado  
**Moneda y Huso Horario:** Soles Peruanos (`PEN` / `S/`), `America/Lima` (UTC-5)  
**Estado:** **GO PARA PREPILOTO ACOMPAÑADO**

---

## 1. Identificación del Bundle de Liberación

| Componente | Identificador / Hash | Detalle |
|---|---|---|
| **Root Monorepo** | Commit `feature/pilot-readiness-audit` | Herramientas de auditoría, smoke tests y documentación |
| **Backend API** | Commit `f144013` | NestJS 11, Prisma, guardias JWT, sanitización y telemetría |
| **Frontend Mobile** | Commit `a793c52` | Flutter 3.29.3, Riverpod, GoRouter, correcciones FR-01/02/03 |
| **APK Binario** | `app-prod-release.apk` | Build Flavor `prodRelease`, versionName `1.0.0`, versionCode `2` |
| **Ubicación APK** | `zenda_fronted_app/build/app/outputs/flutter-apk/app-prod-release.apk` | Tamaño: 63.3 MB |
| **SHA256 APK** | `a10f31e0298c49f68f61d356607e02742413b8b64519b4e8acb83bc1b93d753a` | Verificado con `Get-FileHash` y `aapt dump badging` |
| **Entorno Backend** | Azure Linux App Service | `https://zendaapilinuxtesis-hyb8dabvh2hpdgan.centralus-01.azurewebsites.net/api` |

---

## 2. Bloqueantes Concretos Corregidos y Verificados

| Código | Severidad | Hallazgo Original | Corrección Implementada | Verificación |
|---|---|---|---|---|
| **FR-01** | P1 | Cola offline global atribuía movimientos al usuario equivocado tras cambio de sesión en el mismo teléfono; refresh tardío 200/401 podía sobrescribir credenciales. | Propietario (`userId`) persistido en cada registro de la cola. Flush y reintento verifican que el token pertenezca al propietario del movimiento. Sesión tardía 200/401 no sobreescribe credenciales. | `test/final_review_session_test.dart` (pruebas de cambio de usuario, lookup concurrente y refresh tardío). |
| **FR-02** | P1 | 3 fallos consecutivos de sincronización eliminaban el registro pendiente silenciosamente perdiendo datos; mutaciones concurrentes sobrescribían la cola. | Tras 3 fallos se suspende el auto-reintento pero se preserva el registro de forma indefinida; se reactiva al reiniciar la app. Mutaciones de la cola serializadas con candado exclusivo. | `test/final_review_session_test.dart` (conservación, reactivación tras reinicio y flush concurrente). |
| **FR-03** | P1 | Al fallar `/summary/progress`, la pantalla mostraba gastos ficticios (S/ 1,240) y ahorro ficticio (S/ 760). Navegador de mes permitía desfasar el mes sin consultar el backend. | Eliminación de valores falsos; despliegue de estado de error visible con botón de reintento. Cabecera bloqueada al período real retornado por la API. | `test/final_review_session_test.dart` (widget test sin cifras inventadas y bloqueo de mes). |
| **A01** | P0 | Endpoint de investigación sin token fuera de entorno de producción. | Protección estricta con token obligatorio en todos los entornos. | `test/modules/pilot-readiness.e2e-spec.ts`. |
| **MOV-03** | P0 | Desfase de fechas UTC en registro de movimientos. | Conversión obligatoria a huso local `America/Lima` en `TransactionModel.fromApiJson`. | `test/pilot_readiness_test.dart`. |
| **MOV-05** | P0 | Borrado de movimiento no actualizaba resumen de gestión ni almacenamiento local. | `TransactionsRepository.deleteTransaction` elimina en almacenamiento local e invalida proveedores de resumen. | `test/pilot_readiness_test.dart`. |

---

## 3. Matriz de Cumplimiento de Precondiciones Técnicas y Operativas

| Precondición | Estado | Evidencia | Acciones Pendientes |
|---|---|---|---|
| **1. APK corregido y Backend alineado** | **CUMPLIDA** | APK con SHA256 `a10f31e0...` verificado; backend `f144013` verificado contra staging Azure (`/health` y `/ready` 200 OK, DB activa). | Ninguna técnica. No distribuir APKs antiguos sin este hash. |
| **2. Smoke test en entorno real** | **CUMPLIDA** | Ejecutado `node tools/prepilot-smoke.cjs` contra Azure staging: 7/7 pruebas superadas (salud, readiness, validación DTO 400, credenciales 401, guardias 401 en users/me, transactions y summary). | Si se desea ejecutar flujo mutacional completo (crear/editar/borrar transacciones y prueba de aislamiento), suministrar `SMOKE_TOKEN_A` y `SMOKE_TOKEN_B`. |
| **3. Consentimiento y privacidad de la cohorte** | **CUMPLIDA EN CÓDIGO** | Backend aplica `safeTelemetryMetadata` y consent gate; herramienta `export-pilot-metrics.cjs` exige clave de seudonimización HMAC-SHA256 >= 32 caracteres. | Operativo humano: Fernando debe recabar consentimientos informados de los participantes antes del registro. |

---

## 4. Instrucciones para el Operador (Fernando)

### A. Validación Previa al Prepiloto (Smoke Test)
Para validar la conectividad con el entorno Azure staging:
```powershell
node tools/prepilot-smoke.cjs
```

Para ejecutar el smoke test con dos cuentas sintéticas y verificar la mutación real:
```powershell
$env:SMOKE_TOKEN_A="<jwt_usuario_a>"
$env:SMOKE_TOKEN_B="<jwt_usuario_b>"
node tools/prepilot-smoke.cjs
```

### B. Distribución del APK Verificado
Para subir el APK verificado a Firebase App Distribution:
```powershell
firebase appdistribution:distribute zenda_fronted_app\build\app\outputs\flutter-apk\app-prod-release.apk `
  --app 1:143147353185:android:4e4cf351f410ce12c6d620 `
  --groups zenda-piloto-validacion `
  --release-notes "Zenda v1.0.0 (build 2) - Prepiloto Acompañado. Correcciones FR-01 (aislamiento multi-cuenta en cola offline), FR-02 (preservación de pendientes tras fallos) y FR-03 (eliminación de fallbacks ficticios en progreso)."
```

### C. Protocolo de Acompañamiento Durante la Sesión
1. **Inicio limpio:** Instalar el APK asegurando que no existan datos locales previos (o limpiar datos de la app en Ajustes de Android).
2. **Registro guiado:** El participante se registra con su correo personal y valida el código OTP de 6 dígitos recibido por correo.
3. **Moneda:** Operar exclusivamente con montos en Soles (`S/`).
4. **Resiliencia:** Si ocurre un corte de red durante el registro de un movimiento, observar que la tarjeta permanezca en cola sin duplicar envíos al reconectar.
