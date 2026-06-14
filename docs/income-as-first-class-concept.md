# Diseño — "Ingresos" como concepto propio (Opción A)

> Estado: **IMPLEMENTADO (modelo A1 — saldo neto).**
> Origen: discusión de diseño — el registro de ingresos no debería "engordar" un
> presupuesto (que es un límite de gasto). El ingreso debe ser un concepto fijo y
> separado.

## Estado de implementación

- Modelo elegido: **A1 (saldo neto)** — no hay bolsa de dinero; el presupuesto es
  un límite de gasto puro; el ingreso se trata aparte.
- Backend: `create-transaction` ignora `budgetId` cuando `type = INCOME`;
  `BudgetEntity`/repositorio/DTO ya no exponen `incomeAdded` (el presupuesto =
  `amountLimit`). Tests `test:e2e` 77/77.
- Frontend: campo de presupuesto oculto en alta de ingresos; `Budget.total =
  amountLimit`; nueva sección **Ingresos** (`features/income/income_screen.dart`)
  como 4ª sub-pestaña de Gestión (total del mes + lista de movimientos de ingreso);
  ruta `?tab=income`.
- Pendiente opcional (no implementado): breakdown `incomeByCategory` en el summary,
  visual 50/30/20 en el dashboard, script que nullee `budgetId` en ingresos viejos.

## 1. Problema

Hoy un presupuesto es un **límite mensual de gasto** (`available = límite − gastado`,
alerta al ≥80%). Al registrar un ingreso, el frontend obligaba a elegir un
presupuesto al que el ingreso "se suma", inflando ese límite
(`dashboard_providers.dart:78` → `total += b.total; // base limit + income assigned to the pot`).

Eso (a) mezcla "dinero que entra" con "límite de gasto", (b) fuerza una elección
arbitraria, y (c) rompe la regla 50/30/20 (un ingreso debería repartirse, no caer
en un solo sobre).

## 2. Objetivo

- El **ingreso** se registra solo con su **fuente** (Beca, Trabajo, Familia,
  Freelance, Otro) y su monto/fecha. **No** se vincula a un presupuesto.
- Existe un lugar fijo **"Ingresos"** (sección/pantalla) que muestra el total del
  mes y el detalle por fuente.
- Los **presupuestos** vuelven a ser solo límites de gasto.
- El dashboard relaciona Ingresos vs. Gastos vs. Ahorro (saldo neto), que es el
  marco correcto para enseñar 50/30/20.

## 3. Estado actual (lo que ya existe — no se reconstruye)

- Backend ya agrega `totalIncome` por periodo (suma de `type = INCOME`) en
  `insights` (`prisma-insights.repository.ts`), expuesto en day/week/month summary.
- El dashboard ya muestra una tarjeta "Ingresos del mes" (`dashboard_screen.dart`
  `_SummaryCards`, `s.totalIncome`).
- El quick fix ya aplicado: el presupuesto es **opcional para ingresos** (campo
  oculto en el alta; el backend ya aceptaba `budgetId` nulo).

## 4. Cambios — Backend

| Cambio | Detalle |
|--------|---------|
| Guard de coherencia | En `create/update-transaction`: si `type = INCOME` y llega `budgetId`, ignorarlo (forzar `null`) o rechazar con 400. Recomendado: ignorarlo silenciosamente para no romper clientes viejos. |
| Endpoint de ingresos | **No se crea uno nuevo.** Se reutiliza `GET /transactions?type=INCOME` (el filtro `type` ya existe) para el detalle, y `GET /summary/month` para el total. |
| Agregado por fuente (opcional) | Si se quiere "Ingresos por fuente (categoría)" en una sola llamada, añadir un breakdown `incomeByCategory` al summary mensual (mismo patrón que el breakdown de gastos). |

## 5. Cambios — Frontend

| Cambio | Detalle |
|--------|---------|
| Sección "Ingresos" | Nueva vista fija: total del mes (de `monthSummary.totalIncome`) + lista de ingresos del mes agrupada por fuente. Ubicación propuesta: nueva sub-pestaña en **Gestión** (junto a Progreso/Presupuestos/Metas), o card dedicada en el dashboard que abre el detalle. |
| Alta de ingreso | Ya sin campo presupuesto (quick fix hecho). Mantener fuente (categoría de ingreso) obligatoria. |
| Decoupling del pote | Quitar de `dashboard_providers.dart` la lógica `base limit + income assigned to the pot`. Los presupuestos muestran solo su límite. |
| Dashboard | Reforzar la relación Ingresos − Gastos = **Saldo neto** del mes (ya hay `netBalance` en el summary). Opcional: visual 50/30/20 (cuánto del ingreso va a necesidades/gustos/ahorro). |

## 6. Decisión abierta (requiere tu elección)

Al desacoplar el ingreso del presupuesto, "el dinero total = suma de presupuestos"
deja de sostenerse (el ingreso ya no aterriza en ningún sobre). Dos modelos:

- **A1 — Saldo neto (ELEGIDO):** no hay "bolsa" de dinero. La app muestra
  `Ingresos − Gastos = Saldo neto` del mes. Los presupuestos son metas/límites de
  gasto. Es lo más fácil y lo más cercano a 50/30/20 como *guía*, no como billetera.
- **A2 — Bolsa "por asignar" (descartado):** se reintroducía un único saldo
  derivado ("disponible por asignar" = ingresos − asignado a presupuestos −
  gastado). Más fiel al sobre-presupuesto, pero más complejo y rozaba lo que se
  quitó con "sin cuentas".

## 7. Migración / compatibilidad

- Transacciones de ingreso existentes con `budgetId`: dejarlas como están (el dato
  no estorba) o un script que ponga `budgetId = null` en `type = INCOME`. Bajo
  riesgo; recomendado nullear para consistencia.
- Sin cambios de esquema obligatorios (la relación tx→budget ya es nullable).

## 8. Alcance sugerido (fases)

1. Backend: guard de coherencia (ignorar `budgetId` en ingresos) + (opcional)
   breakdown `incomeByCategory`.
2. Frontend: quitar el income del cálculo del pote; sección "Ingresos" (total +
   lista por fuente).
3. Dashboard: saldo neto reforzado; (opcional) visual 50/30/20.
4. Docs de fase + specs.

## 9. Fuera de alcance (por ahora)

- Distribución automática del ingreso 50/30/20 (eso es la Opción B).
- Reintroducir cuentas/bancos.
