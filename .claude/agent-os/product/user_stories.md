# WalletWise — Historias de Usuario

**Proyecto:** WalletWise — App Móvil de Gestión Financiera con IA para Universitarios  
**Duración:** 10.5 meses (Febrero — Diciembre 2026)  
**Presupuesto:** S/ 14,241  
**Status Tracking:** ✅ Completo | 🚧 En Progreso | ⏳ No Iniciado | 🔒 Bloqueado

---

## Épica 1: Autenticación y Gestión de Usuarios

**Goal:** Todo usuario debe registrarse, autenticarse y configurar su perfil financiero antes de acceder a funcionalidades.

### US-0101: Registro de Usuario
**Como** estudiante universitario  
**Quiero** registrarme con un método seguro  
**Para** proteger mis datos financieros personales

**Criterios de Aceptación:**
- [ ] `POST /api/v1/auth/register` acepta: email, password, name
- [ ] Email validado con formato correcto, no duplicado
- [ ] Password ≥ 8 caracteres con al menos 1 mayúscula, 1 minúscula, 1 número
- [ ] Password hasheado con bcrypt (cost factor 12) antes de almacenar
- [ ] Cuenta creada con `profile_completed = false`
- [ ] Retorna JWT token válido por 30 días
- [ ] Pantalla de registro con validación en tiempo real

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

### US-0102: Inicio de Sesión
**Como** usuario registrado  
**Quiero** iniciar sesión con mis credenciales  
**Para** acceder solo yo a mi información financiera

**Criterios de Aceptación:**
- [ ] `POST /api/v1/auth/login` acepta email y password
- [ ] Credenciales correctas retornan JWT token
- [ ] Credenciales incorrectas retornan 401 con mensaje genérico
- [ ] Bloqueo temporal tras 3 intentos fallidos consecutivos (15 minutos)
- [ ] JWT almacenado en EncryptedSharedPreferences (Android)
- [ ] Auto-login si JWT válido existe al abrir app

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

### US-0103: Middleware de Autenticación
**Como** sistema  
**Quiero** validar JWT en cada request autenticado  
**Para** garantizar que solo usuarios válidos acceden a la API

**Criterios de Aceptación:**
- [ ] Intercepta todas las rutas `/api/v1/*` excepto `/api/v1/auth/*`
- [ ] Extrae token del header `Authorization: Bearer {token}`
- [ ] Valida firma, expiración y estructura del JWT
- [ ] Carga `user_id` en request context para uso downstream
- [ ] Retorna 401 Unauthorized si token inválido, expirado o ausente
- [ ] Logging de intentos de acceso no autorizados

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

### US-0104: Recuperación de Contraseña
**Como** usuario  
**Quiero** recuperar mi cuenta si olvido mi contraseña  
**Para** no perder acceso a mi historial financiero

**Criterios de Aceptación:**
- [ ] `POST /api/v1/auth/forgot-password` acepta email
- [ ] Envía email con token de reset (expira en 1 hora)
- [ ] `POST /api/v1/auth/reset-password` acepta token + nueva contraseña
- [ ] Token invalidado tras uso (single-use)
- [ ] Pantalla de "Olvidé mi contraseña" con campo email
- [ ] Mensaje de confirmación: "Revisa tu correo electrónico"

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

### US-0105: Configuración de Perfil Inicial (Onboarding)
**Como** estudiante  
**Quiero** configurar mi perfil financiero al primer ingreso  
**Para** recibir recomendaciones adaptadas a mi situación

**Criterios de Aceptación:**
- [ ] Se presenta tras primer login exitoso (si `profile_completed = false`)
- [ ] Campos: edad, universidad, tipo de ingreso (beca/trabajo/familia/mixto), ingreso mensual promedio, moneda preferida (default PEN)
- [ ] Cada campo en pantalla individual con transición fluida
- [ ] Skip opcional con mensaje: "Completar tu perfil mejora las predicciones en un 40%"
- [ ] Al completar: `profile_completed = true`, `financial_literacy_level` asignado según respuestas
- [ ] Datos editables posteriormente en perfil

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

### US-0106: Edición de Perfil y Preferencias
**Como** usuario  
**Quiero** editar mi perfil y preferencias de la app  
**Para** mantener mi información actualizada y personalizar la experiencia

**Criterios de Aceptación:**
- [ ] `GET /api/v1/users/me` retorna perfil completo del usuario
- [ ] `PUT /api/v1/users/me` acepta campos editables: name, university, income_type, average_monthly_income, currency
- [ ] Pantalla de perfil con todos los campos editables
- [ ] Selector de moneda: PEN (default), USD
- [ ] Formato numérico: separador de miles (punto/coma)
- [ ] Cambios guardados con confirmación visual

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 2 — Autenticación

---

## Épica 2: Registro de Transacciones

**Goal:** Los estudiantes pueden registrar ingresos y gastos de forma simple y rápida, manteniendo un historial limpio y consultable.

### US-0201: Registrar Ingreso
**Como** estudiante  
**Quiero** registrar mis ingresos manualmente  
**Para** llevar control de mis fuentes de dinero

**Criterios de Aceptación:**
- [ ] `POST /api/v1/transactions` acepta: `type: INGRESO`, `amount` (> 0), `category_id`, `description` (opcional), `date`
- [ ] Valida que categoría exista y sea de tipo INGRESO
- [ ] Crea transacción y retorna con balance actualizado del mes
- [ ] Pantalla con: selector tipo (toggle Ingreso/Gasto), input monto numérico, selector categoría, date picker (default hoy), campo descripción
- [ ] Mensaje de confirmación: "Ingreso de S/{monto} registrado"
- [ ] Balance en pantalla principal se actualiza inmediatamente

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

### US-0202: Registrar Gasto
**Como** estudiante  
**Quiero** registrar mis gastos manualmente  
**Para** saber en qué gasto mi dinero

**Criterios de Aceptación:**
- [ ] Mismo endpoint `POST /api/v1/transactions` con `type: GASTO`
- [ ] Valida que categoría sea de tipo GASTO
- [ ] Actualiza balance restando el monto
- [ ] Aparece en historial ordenado por fecha descendente
- [ ] Si gasto excede promedio de categoría (>20%), trigger de detección de anomalía

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

### US-0203: Historial de Transacciones con Filtros
**Como** usuario  
**Quiero** aplicar filtros avanzados a mi historial  
**Para** buscar información específica rápidamente

**Criterios de Aceptación:**
- [ ] `GET /api/v1/transactions` con query params: `type`, `category_id`, `date_from`, `date_to`, `min_amount`, `max_amount`, `search` (descripción), `page`, `limit`, `sort`
- [ ] Retorna lista paginada con total de resultados
- [ ] Pantalla con filtros desplegables: rango de fechas, categoría, tipo, rango de monto
- [ ] Búsqueda por texto en descripción
- [ ] Paginación infinita (scroll)
- [ ] Response time < 2 segundos con 1000+ transacciones

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

### US-0204: Dashboard Principal
**Como** estudiante  
**Quiero** ver un resumen rápido de mi situación financiera al abrir la app  
**Para** tener una foto instantánea de mi estado

**Criterios de Aceptación:**
- [ ] Pantalla principal muestra: balance del mes actual (ingresos - gastos), total ingresos del mes, total gastos del mes
- [ ] Últimas 5 transacciones con icono de categoría, monto y fecha
- [ ] FAB (Floating Action Button) "+" para agregar transacción
- [ ] Pull-to-refresh para actualizar datos
- [ ] Carga completa en < 2 segundos
- [ ] Sección "Sugerencias" con última recomendación de IA (si disponible)

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

### US-0205: Editar Transacción
**Como** usuario  
**Quiero** editar transacciones registradas  
**Para** corregir información incorrecta

**Criterios de Aceptación:**
- [ ] `PUT /api/v1/transactions/{id}` acepta campos modificables: amount, category_id, description, date
- [ ] Valida que transacción pertenezca al usuario autenticado (403 si no)
- [ ] Transacciones de otro usuario retornan 403 Forbidden
- [ ] Balance y reportes se recalculan tras edición
- [ ] Tap en transacción abre pantalla de edición pre-rellenada
- [ ] Botón "Guardar cambios" con confirmación

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

### US-0206: Eliminar Transacción
**Como** usuario  
**Quiero** eliminar transacciones  
**Para** mantener un historial limpio

**Criterios de Aceptación:**
- [ ] `DELETE /api/v1/transactions/{id}` realiza soft delete (`deleted_at = NOW()`)
- [ ] Valida ownership (403 si no pertenece al usuario)
- [ ] Diálogo de confirmación: "¿Estás seguro? Esta acción eliminará la transacción de tus reportes"
- [ ] Transacción desaparece del historial y reportes
- [ ] Balance se recalcula inmediatamente

**Story Points:** 2  
**Status:** ⏳ No Iniciado  
**Fase:** 3 — Registro de Transacciones

---

## Épica 3: Sistema de Categorización

**Goal:** Las transacciones se organizan por categorías que alimentan reportes, presupuestos y predicciones.

### US-0301: Categorías Predeterminadas
**Como** estudiante  
**Quiero** tener categorías predefinidas de gastos e ingresos  
**Para** categorizar mis transacciones sin configuración previa

**Criterios de Aceptación:**
- [ ] Categorías de gasto seed: Alimentación, Transporte, Educación, Entretenimiento, Salud, Vivienda, Servicios, Vestimenta, Otros
- [ ] Categorías de ingreso seed: Beca, Trabajo parcial, Familia, Freelance, Otros
- [ ] Cada categoría con icono Material Design y color asignado
- [ ] Disponibles para todos los usuarios sin creación manual
- [ ] No eliminables ni editables (son del sistema)

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 4 — Categorización

---

### US-0302: Categorías Personalizadas
**Como** usuario  
**Quiero** crear mis propias categorías  
**Para** organizar mis finanzas según mis necesidades específicas

**Criterios de Aceptación:**
- [ ] `POST /api/v1/categories` crea categoría: name, type (INGRESO/GASTO), icon, color
- [ ] `GET /api/v1/categories` retorna default + custom del usuario
- [ ] `PUT /api/v1/categories/{id}` edita nombre/icono/color (solo custom)
- [ ] `DELETE /api/v1/categories/{id}` elimina (solo custom, error si tiene transacciones)
- [ ] Opción "Crear nueva categoría" visible al registrar transacción
- [ ] Modal de creación rápida: nombre, selección de icono, selección de color

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 4 — Categorización

---

## Épica 4: Reportes Financieros

**Goal:** Los usuarios visualizan sus hábitos financieros con datos claros y gráficos intuitivos.

### US-0401: Resumen Mensual
**Como** usuario  
**Quiero** ver un resumen mensual de mis finanzas  
**Para** evaluar mi salud financiera del mes

**Criterios de Aceptación:**
- [ ] `GET /api/v1/reports/monthly?year={y}&month={m}` retorna: total_income, total_expenses, balance, breakdown_by_category (array con name, amount, percentage), transaction_count
- [ ] Pantalla con: total ingresos (verde), total gastos (rojo), balance (verde/rojo según signo)
- [ ] Gráfico circular de gastos por categoría con leyenda y porcentajes
- [ ] Top 3 categorías de gasto con iconos
- [ ] Selector de mes (← anterior / siguiente →)
- [ ] Response time < 2 segundos

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

### US-0402: Resumen Semanal
**Como** usuario  
**Quiero** ver un resumen semanal  
**Para** identificar tendencias tempranas en mis gastos

**Criterios de Aceptación:**
- [ ] `GET /api/v1/reports/weekly?year={y}&week={w}` retorna misma estructura que mensual
- [ ] Totales agrupados correctamente por semana ISO
- [ ] Selector de semana con fechas visibles (Lun-Dom)

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

### US-0403: Resumen Diario
**Como** estudiante  
**Quiero** ver un resumen diario de gastos  
**Para** monitorizar mis hábitos financieros día a día

**Criterios de Aceptación:**
- [ ] `GET /api/v1/reports/daily?date={d}` retorna: total gastado del día, desglose por categoría, lista de transacciones
- [ ] Muestra total del día en < 2 segundos
- [ ] Calendario visual con indicador de gasto por día (color según intensidad)

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

### US-0404: Comparativa Mensual
**Como** estudiante  
**Quiero** ver gráficos comparativos por mes  
**Para** analizar la evolución de mis gastos y ahorros en el tiempo

**Criterios de Aceptación:**
- [ ] `GET /api/v1/reports/comparison?months=3` retorna datos de últimos N meses
- [ ] Gráfico de líneas con evolución de ingresos, gastos y balance
- [ ] Selector: 2, 3, 4, 6 meses de comparación
- [ ] Visualización clara de tendencias (subida/bajada)

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

### US-0405: Gráficos por Categoría
**Como** estudiante  
**Quiero** ver gráficos de gastos por categoría  
**Para** entender visualmente en qué gasto más

**Criterios de Aceptación:**
- [ ] Gráfico de barras horizontal ordenado por monto (mayor a menor)
- [ ] Gráfico circular alternativo con porcentajes
- [ ] Tap en categoría muestra detalle de transacciones de esa categoría
- [ ] Selector de periodo: semana, mes, trimestre
- [ ] Librería: MPAndroidChart

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

### US-0406: Exportación a PDF
**Como** usuario  
**Quiero** exportar mis reportes en PDF  
**Para** compartir o guardar mis datos financieros

**Criterios de Aceptación:**
- [ ] `GET /api/v1/reports/export/pdf?year={y}&month={m}` genera PDF
- [ ] PDF incluye: encabezado con periodo, resumen numérico, gráfico de categorías, desglose detallado
- [ ] Botón "Exportar PDF" en pantalla de reporte
- [ ] Permite compartir via apps del teléfono (share intent)
- [ ] URL de descarga temporal (24 horas)

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 5 — Reportes

---

## Épica 5: Presupuestos y Metas

**Goal:** Los usuarios definen límites de gasto y objetivos de ahorro con seguimiento visual.

### US-0501: Gestión de Presupuestos
**Como** estudiante  
**Quiero** definir presupuestos mensuales por categoría  
**Para** controlar mis gastos y no excederme

**Criterios de Aceptación:**
- [ ] `POST /api/v1/budgets` crea presupuesto: category_id (null = global), amount_limit, month, year
- [ ] `GET /api/v1/budgets?month={m}&year={y}` retorna con current_spent y percentage_used
- [ ] Pantalla con lista de presupuestos y barra de progreso visual
- [ ] Colores: verde (< 60%), amarillo (60-80%), rojo (> 80%)
- [ ] Modal de creación: seleccionar categoría o "General", ingresar monto límite

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 6 — Presupuestos y Metas

---

### US-0502: Metas Financieras
**Como** usuario  
**Quiero** definir metas de ahorro con plazo  
**Para** trabajar en objetivos concretos de ahorro

**Criterios de Aceptación:**
- [ ] `POST /api/v1/goals` crea meta: name, target_amount, deadline
- [ ] `GET /api/v1/goals` retorna con current_amount, percentage, days_remaining
- [ ] `PATCH /api/v1/goals/{id}/contribute` suma monto a current_amount
- [ ] Card de meta: nombre, barra de progreso, monto actual/objetivo, fecha límite
- [ ] Botón "Abonar" con input de monto
- [ ] Animación de completado cuando current_amount ≥ target_amount

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 6 — Presupuestos y Metas

---

### US-0503: Seguimiento Detallado de Metas
**Como** usuario  
**Quiero** ver el detalle de progreso de mis metas  
**Para** saber si voy a cumplirlas a tiempo

**Criterios de Aceptación:**
- [ ] Pantalla de detalle con historial de abonos (fecha, monto)
- [ ] Gráfico de progreso acumulado en el tiempo
- [ ] Proyección: "A este ritmo completarás tu meta el {fecha}"
- [ ] Alerta si la proyección indica que no se cumplirá antes del deadline

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 6 — Presupuestos y Metas

---

## Épica 6: Pipeline de IA

**Goal:** Los datos del usuario se transforman en features, se entrenan modelos y se exportan para inferencia.

### US-0701: Extracción de Features
**Como** sistema de ML  
**Quiero** extraer features financieras de cada usuario  
**Para** alimentar los modelos de predicción

**Criterios de Aceptación:**
- [ ] Script Python extrae por usuario: gasto_total_por_categoria_por_mes, ingreso_total_por_mes, ratio_gasto_ingreso, frecuencia_transacciones, variabilidad_ingresos, dia_semana_pico_gasto, top_3_categorias
- [ ] Output: CSV con una fila por usuario por mes
- [ ] Documentación de cada feature y su cálculo
- [ ] Ejecutable como job periódico

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 7 — Pipeline ML

---

### US-0702: Dataset de Entrenamiento
**Como** data scientist  
**Quiero** un dataset sintético realista  
**Para** entrenar modelos cuando no hay suficientes datos reales

**Criterios de Aceptación:**
- [ ] Mínimo 1000 registros simulados basados en perfiles de estudiantes universitarios peruanos
- [ ] Distribuciones realistas: ingresos S/ 500-2000, gastos concentrados en alimentación (30-40%), transporte (15-25%)
- [ ] Variabilidad mensual incorporada (inicio de ciclo = más gastos en educación)
- [ ] Documentación de variables, distribuciones y supuestos

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 7 — Pipeline ML

---

### US-0703: Entrenamiento y Selección de Modelo
**Como** data scientist  
**Quiero** evaluar múltiples modelos de predicción  
**Para** seleccionar el más preciso para nuestro caso

**Criterios de Aceptación:**
- [ ] Modelos evaluados: Linear Regression, Random Forest, XGBoost, LSTM
- [ ] Métricas: MAE, RMSE, R², Accuracy (definida como 1 - |pred-real|/real)
- [ ] Validación cruzada 5-fold
- [ ] Target: predecir gasto total del próximo mes con accuracy ≥ 80%
- [ ] Documentación de resultados y justificación de modelo seleccionado

**Story Points:** 13  
**Status:** ⏳ No Iniciado  
**Fase:** 7 — Pipeline ML

---

## Épica 7: Predicciones

**Goal:** La app anticipa gastos e ingresos futuros basándose en historial y patrones detectados por IA.

### US-0801: Predicción de Gastos
**Como** usuario  
**Quiero** recibir predicciones de mis gastos del próximo mes  
**Para** anticipar mi situación financiera

**Criterios de Aceptación:**
- [ ] `GET /api/v1/predictions/expenses?period=next_month` invoca modelo ML
- [ ] Retorna: predicted_total, predicted_by_category (array), confidence_interval, model_version
- [ ] Requiere historial mínimo de 2 meses (retorna 400 con mensaje explicativo si insuficiente)
- [ ] Precisión promedio ≥ 80% medida retrospectivamente
- [ ] Pantalla muestra predicción con indicador de confianza (alta/media/baja)

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 8 — Predicciones

---

### US-0802: Predicción de Ingresos
**Como** estudiante  
**Quiero** recibir predicciones de mis ingresos  
**Para** planificar mejor mis próximos meses

**Criterios de Aceptación:**
- [ ] `GET /api/v1/predictions/income?period=next_month` proyecta ingresos
- [ ] Considera variabilidad de fuentes (beca fija vs trabajo variable)
- [ ] Retorna: predicted_total, predicted_by_source, confidence_level
- [ ] Proyección coherente basada en datos históricos

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 8 — Predicciones

---

### US-0803: Detección de Anomalías de Gasto
**Como** usuario  
**Quiero** recibir alertas si aumento mis gastos en una categoría  
**Para** evitar desbalances financieros

**Criterios de Aceptación:**
- [ ] Al registrar transacción: si gasto en categoría supera >20% el promedio de últimos 3 meses, genera alerta
- [ ] Notificación push: "Tu gasto en {categoría} este mes es {x}% mayor que tu promedio"
- [ ] Solo una alerta por categoría por mes (no spammear)
- [ ] Alerta visible en dashboard y en notificaciones

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 8 — Predicciones

---

## Épica 8: Recomendaciones Personalizadas

**Goal:** La IA genera sugerencias accionables basadas en datos del usuario.

### US-0901: Motor de Recomendaciones
**Como** estudiante  
**Quiero** recibir recomendaciones personalizadas  
**Para** mejorar mis decisiones financieras

**Criterios de Aceptación:**
- [ ] `GET /api/v1/recommendations` genera 1-5 recomendaciones activas
- [ ] Basadas en: patrones de gasto, predicciones, presupuestos, metas
- [ ] Tipos: AHORRO, PRESUPUESTO, META
- [ ] Cada recomendación con mensaje concreto y acción sugerida
- [ ] Integrada en Dashboard como sección "Sugerencias para ti"
- [ ] Cards con botón feedback: "Útil" / "No relevante"

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 9 — Recomendaciones

---

### US-0902: Tracking de Feedback
**Como** sistema  
**Quiero** registrar si el usuario acepta o rechaza recomendaciones  
**Para** medir efectividad y mejorar futuras sugerencias

**Criterios de Aceptación:**
- [ ] `PATCH /api/v1/recommendations/{id}/feedback` con accepted: true/false
- [ ] Métrica: tasa_aceptacion = accepted_true / total, target ≥ 60%
- [ ] Dashboard interno muestra tasa de aceptación por tipo

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 9 — Recomendaciones

---

## Épica 9: Educación Financiera

**Goal:** Los usuarios aprenden conceptos financieros clave a través de contenido adaptado a su nivel.

### US-1001: Módulo de Contenido Educativo
**Como** estudiante  
**Quiero** acceder a material educativo financiero  
**Para** aprender conceptos clave de finanzas personales

**Criterios de Aceptación:**
- [ ] `GET /api/v1/education/topics` retorna lista de temas con progreso del usuario
- [ ] `GET /api/v1/education/topics/{id}` retorna contenido completo
- [ ] `PATCH /api/v1/education/topics/{id}/complete` marca como visto
- [ ] Temas seed: Presupuesto personal, Ahorro, Crédito/deuda, Inflación, Tasas de interés, Inversión básica, Consumo responsable, Billeteras digitales en Perú
- [ ] Contenido en formato móvil legible (texto + iconos + ejemplos prácticos peruanos)
- [ ] Progreso general visible (barra de completado)

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 10 — Educación y Gamificación

---

## Épica 10: Gamificación

**Goal:** Los usuarios se mantienen motivados mediante retos, insignias y progreso visible.

### US-1002: Sistema de Retos Financieros
**Como** estudiante  
**Quiero** completar mini-retos financieros  
**Para** mejorar mis hábitos mediante gamificación

**Criterios de Aceptación:**
- [ ] `GET /api/v1/challenges` retorna retos con estado del usuario (disponible/activo/completado)
- [ ] `POST /api/v1/challenges/{id}/accept` acepta reto
- [ ] Verificación automática basada en criteria_json (e.g., "no_transactions_category_delivery_3_days")
- [ ] Retos seed: "No gastes en delivery por 3 días", "Registra gastos 7 días seguidos", "Ahorra S/20 esta semana", "Reduce entretenimiento un 10%"
- [ ] Pantalla con retos activos (progreso), disponibles (aceptar), completados (fecha)
- [ ] Animación al completar reto

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 10 — Educación y Gamificación

---

### US-1003: Sistema de Insignias
**Como** usuario  
**Quiero** ganar insignias por logros  
**Para** mantenerme motivado y ver mi progreso

**Criterios de Aceptación:**
- [ ] `GET /api/v1/badges` retorna todas las insignias con estado (obtenida/no)
- [ ] Asignación automática al cumplir criterios:
  - "Primera transacción" — registrar primera transacción
  - "Constancia" — 7 días seguidos registrando
  - "Meta cumplida" — completar primera meta de ahorro
  - "Retador" — completar 5 retos
  - "Sabio financiero" — completar módulo educativo 100%
  - "Predictor" — consultar predicciones 3 veces
  - "Presupuestador" — crear y respetar presupuesto por 1 mes
- [ ] Grid de insignias: color si obtenida, gris si no
- [ ] Tap muestra detalle: nombre, descripción, criterio, fecha de obtención
- [ ] Notificación push al desbloquear insignia nueva

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 10 — Educación y Gamificación

---

## Épica 11: Notificaciones

**Goal:** Las alertas proactivas mantienen engagement y previenen problemas financieros.

### US-1101: Infraestructura de Notificaciones Push
**Como** sistema  
**Quiero** enviar notificaciones push al dispositivo del usuario  
**Para** comunicar alertas y recordatorios en tiempo real

**Criterios de Aceptación:**
- [ ] Integración con Firebase Cloud Messaging (FCM)
- [ ] Servicio NotificationService con métodos específicos por tipo
- [ ] Token FCM registrado al login, actualizado al refresh
- [ ] Manejo de tokens expirados (re-registro automático)

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 11 — Notificaciones

---

### US-1102: Alerta de Presupuesto al 80%
**Como** estudiante  
**Quiero** recibir alertas cuando me acerque a mi límite presupuestal  
**Para** evitar sobrepasarlo

**Criterios de Aceptación:**
- [ ] Job scheduled (cada hora) verifica presupuestos activos
- [ ] Si current_spent / budget_limit ≥ 0.80 → envía notificación
- [ ] Mensaje: "Tu presupuesto de {categoría} está al {x}%. Te quedan S/{restante}"
- [ ] Solo una notificación por presupuesto por periodo (no repetir)
- [ ] Configurable: el usuario puede desactivar este tipo de alerta

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 11 — Notificaciones

---

### US-1103: Alerta de Gasto Anómalo
**Como** usuario  
**Quiero** recibir alertas si mis gastos en una categoría suben demasiado  
**Para** actuar a tiempo

**Criterios de Aceptación:**
- [ ] Trigger al registrar transacción
- [ ] Si gasto del mes en categoría supera >20% el promedio de últimos 3 meses → notificación
- [ ] Mensaje: "Tu gasto en {categoría} este mes es {x}% mayor que tu promedio"
- [ ] Máximo una alerta por categoría por mes

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 11 — Notificaciones

---

## Épica 12: Evaluación de Impacto

**Goal:** Medir cuantitativamente si la app mejora la educación financiera del usuario.

### US-1201: Encuesta Pre-Uso
**Como** investigador  
**Quiero** medir el conocimiento financiero del usuario antes del uso  
**Para** establecer una línea base de comparación

**Criterios de Aceptación:**
- [ ] Cuestionario de 15-20 preguntas sobre: presupuesto, ahorro, inflación, crédito, tasas de interés
- [ ] Basado en instrumentos validados (Cordova-Buiza et al., 2022; SBS, 2022)
- [ ] Se presenta durante onboarding o primera semana de uso
- [ ] Cálculo automático de score (0-100)
- [ ] Pantalla: una pregunta por vista, progress bar, guardado parcial automático
- [ ] Al finalizar: "Tu nivel actual de educación financiera es {BAJO/MEDIO/ALTO}"

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 12 — Evaluación

---

### US-1202: Encuesta Post-Uso
**Como** investigador  
**Quiero** medir el conocimiento financiero después del uso  
**Para** calcular el incremento educativo

**Criterios de Aceptación:**
- [ ] Mismo cuestionario (variante para evitar memorización) + sección SUS
- [ ] Se presenta tras 4-8 semanas de uso (notificación invitando a completar)
- [ ] Al finalizar: comparativa visual "Mejoraste de {x} a {y} puntos ({z}% de incremento)"
- [ ] Si improvement < 20%: sugerencias de contenido educativo relevante

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 12 — Evaluación

---

### US-1203: Cálculo de Incremento Educativo
**Como** investigador  
**Quiero** calcular el incremento agregado de conocimiento financiero  
**Para** validar la hipótesis de la investigación

**Criterios de Aceptación:**
- [ ] `GET /api/v1/surveys/comparison?user_id={id}` retorna: pre_score, post_score, improvement_percentage, sus_score
- [ ] `GET /api/v1/surveys/aggregate` retorna: promedio, mediana, desviación estándar, N
- [ ] Target global: improvement_percentage promedio ≥ 20%
- [ ] Exportable a CSV para análisis estadístico externo

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 12 — Evaluación

---

## Épica 13: Seguridad y Compliance

**Goal:** Datos financieros protegidos según Ley 29733 y estándares internacionales.

### US-1301: Cifrado de Datos
**Como** usuario  
**Quiero** que mis datos financieros estén cifrados  
**Para** evitar accesos no autorizados

**Criterios de Aceptación:**
- [ ] TLS 1.3 en todas las comunicaciones API (HTTPS obligatorio)
- [ ] Azure Database encryption at rest habilitado
- [ ] Backups encriptados
- [ ] EncryptedSharedPreferences para datos locales en Android
- [ ] SQLCipher para Room database local

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 13 — Seguridad

---

### US-1303: Consentimiento de Datos
**Como** usuario  
**Quiero** dar mi consentimiento explícito para el uso de mis datos  
**Para** cumplir con la Ley de Protección de Datos Personales

**Criterios de Aceptación:**
- [ ] Pantalla de consentimiento al primer uso con política de privacidad clara
- [ ] Checkbox: "Acepto que mis datos financieros sean procesados para generar reportes y predicciones personalizadas"
- [ ] No se puede usar la app sin consentimiento
- [ ] Registro de consentimiento: user_id, consent_given=true, consent_at=timestamp
- [ ] Opción de revocar consentimiento en configuración (implica desactivar IA)

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 13 — Seguridad

---

## Épica 14: Testing

**Goal:** Calidad verificada con pruebas unitarias, integración, ML y usabilidad.

### US-1401: Tests Unitarios de Servicios
**Como** desarrollador  
**Quiero** tests unitarios para todos los servicios  
**Para** garantizar que la lógica de negocio es correcta

**Criterios de Aceptación:**
- [ ] Tests para: TransactionService, BudgetService, GoalService, PredictionService, RecommendationService, SurveyService
- [ ] Mock de repositorios y dependencias externas
- [ ] Cobertura target ≥ 80% en servicios
- [ ] Tests ejecutables en < 30 segundos

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 14 — Testing

---

### US-1403: Validación de Modelos ML
**Como** desarrollador  
**Quiero** validar la precisión de los modelos de predicción  
**Para** garantizar predicciones confiables

**Criterios de Aceptación:**
- [ ] Test que verifica accuracy ≥ 80% en dataset de test
- [ ] No overfitting: diferencia train vs test accuracy < 10%
- [ ] Predicciones coherentes: no negativas, dentro de rangos razonables
- [ ] Métricas documentadas: accuracy, MAE, RMSE, confusion matrix
- [ ] Pipeline de validación ejecutable con `python ml/validate.py`

**Story Points:** 8  
**Status:** ⏳ No Iniciado  
**Fase:** 14 — Testing

---

### US-1404: Tests de Usabilidad con Usuarios
**Como** investigador  
**Quiero** evaluar la usabilidad con usuarios reales  
**Para** medir si la app cumple estándares de experiencia

**Criterios de Aceptación:**
- [ ] Grupo de 30 estudiantes universitarios de Lima Metropolitana
- [ ] 4-8 semanas de uso activo
- [ ] Cuestionario SUS al finalizar
- [ ] Target: puntuación SUS ≥ 4.0/5.0
- [ ] Documentación: tareas completadas, errores encontrados, tiempo promedio, observaciones

**Story Points:** 13  
**Status:** ⏳ No Iniciado  
**Fase:** 14 — Testing

---

## Épica 15: Feedback del Usuario

**Goal:** Los usuarios piloto pueden reportar bugs y sugerencias para iterar.

### US-1501: Sistema de Feedback In-App
**Como** usuario  
**Quiero** enviar feedback sobre la app fácilmente  
**Para** reportar problemas o sugerir mejoras

**Criterios de Aceptación:**
- [ ] `POST /api/v1/feedback` acepta: type (BUG/SUGERENCIA/GENERAL), message, screen_name, rating (1-5)
- [ ] Botón de feedback accesible desde menú lateral o FAB
- [ ] Modal con: tipo, mensaje, rating opcional
- [ ] Confirmación: "Gracias por tu feedback. Lo revisaremos pronto"

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 15 — Feedback

---

## Épica 16: Analytics

**Goal:** Métricas de uso para entender comportamiento y mejorar la app.

### US-1502: Registro de Eventos de Uso
**Como** desarrollador  
**Quiero** registrar eventos clave de interacción  
**Para** analizar métricas y mejorar la solución

**Criterios de Aceptación:**
- [ ] Eventos: registro_transaccion, vista_reporte, vista_prediccion, aceptacion_reto, completar_tema_educativo, consulta_recomendacion
- [ ] Tabla analytics_events: user_id, event_type, metadata_json, timestamp
- [ ] Sin afectar rendimiento percibido (async logging)

**Story Points:** 3  
**Status:** ⏳ No Iniciado  
**Fase:** 15 — Feedback

---

## Épica 17: Demo y Datos de Prueba

**Goal:** Datos realistas y script reproducible para validación y presentación.

### US-1601: Script de Datos Demo
**Como** presentador  
**Quiero** datos de prueba realistas  
**Para** demostrar la app con escenarios creíbles

**Criterios de Aceptación:**
- [ ] 5 usuarios con perfiles variados (universidades, ingresos, tipos distintos)
- [ ] 200+ transacciones por usuario distribuidas en 3 meses
- [ ] Categorías predeterminadas pobladas
- [ ] 3 presupuestos activos por usuario
- [ ] 2 metas por usuario (1 en progreso, 1 completada)
- [ ] Encuestas pre-uso completadas
- [ ] Script idempotente y documentado

**Story Points:** 5  
**Status:** ⏳ No Iniciado  
**Fase:** 16 — Demo

---

## Épica 18: Infraestructura

**Goal:** Repositorio, base de datos y CI/CD configurados correctamente.

### US-1801: Repositorio y Estructura de Proyecto
**Como** desarrollador  
**Quiero** un repositorio bien organizado  
**Para** trabajar de forma estructurada

**Criterios de Aceptación:**
- [ ] Monorepo GitHub: /android, /backend, /ml, /docs
- [ ] .gitignore, README.md, CONTRIBUTING.md, LICENSE
- [ ] Branch protection: main (protegido), develop, feature/*

**Story Points:** 2  
**Status:** ⏳ No Iniciado  
**Fase:** 1 — Infraestructura

---

## Estadísticas Resumen

**Total Épicas:** 18  
**Total Historias de Usuario:** 55  
**Total Story Points:** 302

**Por Fase:**
- **Fase 1-2:** Infra + Auth — 12 historias, 54 points
- **Fase 3-4:** Transacciones + Categorías — 8 historias, 33 points
- **Fase 5-6:** Reportes + Presupuestos — 11 historias, 60 points
- **Fase 7-8:** ML + Predicciones — 8 historias, 52 points
- **Fase 9-10:** Recomendaciones + Educación — 8 historias, 48 points
- **Fase 11-12:** Notificaciones + Evaluación — 8 historias, 37 points
- **Fase 13-16:** Seguridad + Testing + Demo — 10 historias, 47 points

**Status Overview:**
- ✅ Completo: 0
- 🚧 En Progreso: 0
- ⏳ No Iniciado: 55
- 🔒 Bloqueado: 0

---

## Cómo Usar Este Documento

**Antes de iniciar trabajo nuevo:**
1. Revisar el objetivo de la épica y las historias relacionadas
2. Verificar criterios de aceptación como definición de "done"
3. Revisar fase correspondiente en [roadmap.md](./roadmap.md)
4. Actualizar status a 🚧 En Progreso
5. Implementar siguiendo estándares
6. Actualizar status a ✅ Completo cuando todos los criterios se cumplan

**Durante el desarrollo:**
- Usar story points para planificación (1 punto ≈ 2-3 horas)
- Bloquear historias si hay dependencias faltantes
- Agregar notas para desviaciones de criterios de aceptación
- Actualizar referencias cruzadas si la implementación difiere

**Para seguimiento:**
- Marcar historias como completas inmediatamente al cumplir criterios
- Revisiones semanales: verificar avance real vs roadmap
- Este documento es la fuente de verdad de qué está hecho vs pendiente

---

**Documentos relacionados:**
- [mission.md](./mission.md) — Visión y objetivos del producto
- [roadmap.md](./roadmap.md) — Plan de ejecución por fases (16 fases)
