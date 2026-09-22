# Auditoría e Implementación: Pre-Test de Educación Financiera (FINLIT_PRE_V1)

**Proyecto:** Zenda Monorepo App (Tesis UPC 2026)  
**Fecha de Implementación y Certificación:** 22 de Septiembre de 2026  
**Instrumento:** Cuestionario de Educación Financiera (`FINLIT_PRE_V1`)  
**Tipo de Evaluación:** `PRE`  
**Puntaje:** 0–12 puntos (1 punto por respuesta correcta)  
**Estado:** Certificado e Implementado en Backend y Frontend  

---

## 1. Resumen Ejecutivo de la Auditoría

Se auditó e implementó de forma integral el **Pre-Test de Educación Financiera** que se aplica a los usuarios al registrarse en Zenda antes de acceder a la operativa regular de la aplicación.

El pre-test constituye el instrumento cuantitativo de entrada para la investigación cuasiexperimental de tesis universitaria (UPC 2026), cuyo propósito es evaluar el impacto de la plataforma Zenda en el nivel de conocimientos y toma de decisiones financieras de estudiantes universitarios (18–24 años, Perú).

### Hallazgos Críticos Previos:
1. **Riesgo Ético y de Privacidad (PII):** Las respuestas previas se almacenaban vinculadas directamente al `userId` del usuario mediante un campo JSON `SurveyResponse.answersJson`. No existía seudonimización ni disociación entre la identidad del participante y sus datos de investigación.
2. **Instrumento Inexacto:** Existía un cuestionario previo de 10 preguntas arbitrarias con temas como la regla 50/30/20 o el uso de BCP Yape, con scoring 0–100%, divergente del banco de 12 preguntas estandarizadas por dominio.
3. **Filtro Frontend Vulnerable:** El cliente permitía omitir la encuesta (`_SurveySkipStore` en `SharedPreferences`), y mostraba las respuestas, puntajes y niveles obtenidos (`LOW`, `MEDIUM`, `HIGH`) al terminar el pre-test, lo cual sesgaba directamente cualquier medición longitudinal posterior (`POST`).
4. **Ausencia de Consentimiento Académico Informado:** No se solicitaba consentimiento explícito para fines científicos disociados antes de presentar el cuestionario.

### Solución Implementada:
- **Separación de Dominios:** Mapeo de identidad a través de `ResearchParticipant` (`researchParticipantId` UUID v4 aleatorio generado server-side). `FinancialLiteracyAssessment` y `FinancialLiteracyAnswer` no contienen `userId` ni datos de autenticación.
- **Banco de 12 Preguntas Oficial:** 12 preguntas oficiales en español cubriendo 7 dominios financieros (`PLANIFICACION`, `AHORRO`, `CONOCIMIENTO_FINANCIERO`, `INFLACION`, `RIESGO`, `CREDITO`, `SEGURIDAD_FINANCIERA`).
- **Scoring Estricto Server-Side:** La clave de respuestas (`correctAnswer`) y la ponderación (1 pt c/u, total 0–12) residen únicamente en el backend. El cliente nunca recibe las respuestas correctas ni durante el pre-test ni al finalizarlo.
- **Flujo No Omitible con Reanudación:** Flujo guiado con guardas en GoRouter, auto-guardado transaccional en estado `IN_PROGRESS`, e inmutabilidad tras el envío definitivo (`COMPLETED`).
- **Exportación Limpia de Investigación:** Endpoints seguros `GET /api/research-dashboard/export/financial-literacy.json` y `.csv` que exportan los datos de investigación sin realizar JOIN con la tabla `User`, omitiendo correo, nombres, DNI, tokens, IPs y deviceIds.

---

## 2. Diagnóstico Previo: Qué Existía vs. Qué Faltaba

| Componente | Estado Previo | Deficiencias Encontradas | Estado Posterior a la Intervención |
|---|---|---|---|
| **Modelo de Datos** | Tabla `SurveyResponse` con `answersJson` vinculado a `userId` | Respuestas guardadas como blob JSON no tipado; acoplamiento directo a datos personales de usuario. | Modelos `ResearchParticipant`, `FinancialLiteracyAssessment` y `FinancialLiteracyAnswer` en PostgreSQL / Prisma. |
| **Identidad Seudónima** | Inexistente (`userId` expuesto en tablas de respuestas) | Riesgo de violación de privacidad en la exportación para tesis (Ley 29733). | `researchParticipantId` UUID v4 criptográficamente aleatorio generado en servidor, disociado de email o DNI. |
| **Banco de Preguntas** | 10 preguntas dispersas (rule 50/30/20, TEA, etc.) | No coincidía con el instrumento de investigación de 12 preguntas y 7 dominios. | Banco oficial de 12 preguntas implementado en backend y frontend como fallback estricto. |
| **Protección de Respuestas** | `SurveyResult` exponía score porcentual y feedback | Sesgo metodológico para la medición de impacto post-intervención. | Clave de respuestas eliminada de los endpoints públicos; pantalla neutral de finalización sin puntaje. |
| **Consentimiento Informado** | Inexistente en la encuesta previa | Incumplimiento de requisitos del comité de ética y tesis UPC. | Pantalla obligatoria de Consentimiento Informado Académico con registro de versión `FINLIT_CONSENT_V1`. |
| **Control de Omisión** | Botón "Omitir" visible en AppBar que marcaba skip en `SharedPreferences` | Los usuarios podían eludir el pre-test y acceder a la app sin ser evaluados. | Botón "Omitir" removido. `PopScope` bloquea salida; GoRouter exige `COMPLETED` antes de ingresar al Dashboard. |
| **Reanudación de Sesión** | Respuestas no enviadas se perdían al cerrar la app | Frustración de usuario si interrumpía la evaluación. | Endpoint `PUT /api/surveys/pre/save-progress` y auto-carga del estado `IN_PROGRESS`. |

---

## 3. Arquitectura y Modelo de Datos Implementado

### Diagrama de Separación de Dominios

```
[ DOMINIO DE AUTENTICACIÓN / USUARIOS ]
┌──────────────────────────────────────┐
│ User                                 │
│  - id: UUID (PK)                     │
│  - email: String                     │
│  - fullName: String                  │
│  - passwordHash: String              │
│  - profileCompleted: Boolean         │
│  - financialLiteracyLevel: Enum      │
└──────────────────┬───────────────────┘
                   │
                   ▼ (1:1 Relación de Aislamiento)
┌──────────────────────────────────────┐
│ ResearchParticipant                  │
│  - id: UUID (PK)                     │
│  - userId: UUID (FK Unique)          │
│  - researchParticipantId: UUID (UQ)  │ <── Identificador aleatorio (v4)
│  - createdAt: Timestamp              │
└──────────────────┬───────────────────┘
                   │
                   ▼ (1:N Vinculación Seudónima sin JOIN a User)
[ DOMINIO DE INVESTIGACIÓN / LITERACY DATA ]
┌─────────────────────────────────────────────────────────────┐
│ FinancialLiteracyAssessment                                 │
│  - id: UUID (PK)                                            │
│  - researchParticipantId: UUID (FK)                         │
│  - assessmentType: 'PRE' | 'POST'                           │
│  - questionnaireVersion: 'FINLIT_PRE_V1'                    │
│  - status: 'IN_PROGRESS' | 'COMPLETED'                      │
│  - totalScore: Int (0–12, null mientras IN_PROGRESS)        │
│  - maxScore: Int (12)                                       │
│  - consentGiven: Boolean                                    │
│  - consentVersion: 'FINLIT_CONSENT_V1'                      │
│  - consentAt: Timestamp                                     │
│  - startedAt: Timestamp                                     │
│  - completedAt: Timestamp (null mientras IN_PROGRESS)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼ (1:12 Respuestas por Evaluación)
┌─────────────────────────────────────────────────────────────┐
│ FinancialLiteracyAnswer                                     │
│  - id: UUID (PK)                                            │
│  - assessmentId: UUID (FK)                                  │
│  - questionId: 'Q1'..'Q12'                                  │
│  - domain: String ('PLANIFICACION', 'AHORRO', etc.)         │
│  - selectedOption: 'A' | 'B' | 'C' | 'D'                    │
│  - isCorrect: Boolean (calculado server-side)               │
│  - score: Int (0 o 1)                                       │
│  - answeredAt: Timestamp                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Estrategia de Seudonimización y Ética de Investigación

1. **Generación Criptográfica en Servidor:**
   `researchParticipantId` es generado utilizando `randomUUID()` (`crypto.randomUUID()` de Node.js). No es predecible ni deriva de variables personales (DNI, email, nombres, teléfono o fecha de registro).
2. **Imposibilidad de Inferencia:**
   A partir del `researchParticipantId` exportado para el análisis estadístico en R/SPSS/Python, es imposible deducir la identidad del alumno o su correo UPC.
3. **Protección contra Spoofing de Identidad:**
   El endpoint no acepta que el cliente proporcione un `researchParticipantId` arbitrario. El servidor obtiene el `userId` desde el JWT verificado criptográficamente, consulta la tabla de correspondencia `ResearchParticipant`, y graba bajo ese identificador seudónimo.
4. **Dataset de Exportación Libre de PII:**
   La consulta exportadora (`exportPseudonymizedResearchDataset`) realiza lecturas únicamente sobre `FinancialLiteracyAssessment` y `FinancialLiteracyAnswer`. No realiza JOIN con la tabla `User`. Quedan excluidos:
   - Nombres y apellidos
   - Correos electrónicos
   - Contraseñas o hashes
   - Tokens de autenticación y refresh tokens
   - Direcciones IP y deviceIds
   - Cuentas bancarias o transacciones personales

---

## 5. Banco de 12 Preguntas Oficiales (`FINLIT_PRE_V1`)

| Código | Dominio Metodológico | Pregunta Oficial | Opciones Disponibles | Clave Servidor |
|---|---|---|---|:---:|
| **Q1** | `PLANIFICACION` | ¿Cuál es la principal finalidad de elaborar un presupuesto personal? | A: Registrar únicamente las deudas.<br>**B: Planificar y controlar ingresos y gastos.**<br>C: Aumentar automáticamente los ingresos.<br>D: Evitar utilizar productos financieros. | **B** |
| **Q2** | `AHORRO` | ¿Cuál es el principal objetivo de contar con un fondo de emergencia? | A: Financiar compras impulsivas.<br>**B: Tener dinero disponible para gastos imprevistos.**<br>C: Obtener mayores líneas de crédito.<br>D: Reemplazar todos los seguros. | **B** |
| **Q3** | `PLANIFICACION` | Si una persona tiene recursos limitados, ¿qué debería priorizar primero? | **A: Gastos esenciales como alimentación, vivienda y transporte.**<br>B: Entretenimiento.<br>C: Compras por promociones.<br>D: Productos que desea aunque no necesite. | **A** |
| **Q4** | `PLANIFICACION` | ¿Cuál de los siguientes es normalmente un gasto variable? | A: Una cuota mensual fija de alquiler.<br>B: Una pensión mensual con monto fijo.<br>**C: El gasto mensual en entretenimiento.**<br>D: Una cuota fija de un préstamo. | **C** |
| **Q5** | `CONOCIMIENTO_FINANCIERO` | Si depositas S/ 100 en una cuenta que paga 10 % de interés anual y no retiras dinero, ¿cuánto tendrás aproximadamente después de un año? | A: S/ 100<br>B: S/ 105<br>**C: S/ 110**<br>D: S/ 120 | **C** |
| **Q6** | `INFLACION` | Si tus ingresos se mantienen iguales pero los precios aumentan debido a la inflación, ¿qué ocurre con tu poder adquisitivo? | A: Aumenta.<br>**B: Disminuye.**<br>C: Permanece necesariamente igual.<br>D: Se duplica. | **B** |
| **Q7** | `RIESGO` | ¿Qué estrategia generalmente ayuda a reducir el riesgo al invertir? | A: Colocar todo el dinero en una sola inversión.<br>B: Pedir dinero prestado para invertir más.<br>**C: Distribuir el dinero entre diferentes alternativas de inversión.**<br>D: Elegir únicamente la inversión que tuvo mayor rentabilidad el mes anterior. | **C** |
| **Q8** | `CREDITO` | Si deseas comparar dos préstamos similares, ¿qué indicador permite conocer mejor el costo total del crédito en Perú? | A: El monto de la primera cuota.<br>**B: La TCEA.**<br>C: El número de publicidad del banco.<br>D: El límite disponible de la tarjeta. | **B** |
| **Q9** | `CREDITO` | ¿Qué puede ocurrir si una persona paga repetidamente sus créditos después de la fecha de vencimiento? | A: La deuda desaparece progresivamente.<br>**B: Puede generar intereses, penalidades y afectar su historial crediticio.**<br>C: El banco aumenta automáticamente sus ahorros.<br>D: No ocurre nada mientras pague algún monto. | **B** |
| **Q10** | `CREDITO` | Antes de solicitar un préstamo, ¿qué debería evaluar principalmente una persona? | A: Solamente cuánto dinero le ofrecen.<br>**B: Sus ingresos, gastos, deudas existentes y capacidad para pagar las cuotas.**<br>C: Únicamente el número de cuotas.<br>D: Si otras personas también solicitaron el mismo préstamo. | **B** |
| **Q11** | `SEGURIDAD_FINANCIERA` | Si recibes un mensaje que aparenta ser de una entidad financiera solicitando tu clave, CVV o código de verificación, ¿qué deberías hacer? | A: Compartir los datos si el mensaje parece urgente.<br>B: Compartir únicamente el código de verificación.<br>**C: No compartirlos y verificar la comunicación mediante los canales oficiales.**<br>D: Responder solicitando más información personal del remitente. | **C** |
| **Q12** | `AHORRO` | ¿Cuál de las siguientes prácticas favorece mejor el cumplimiento de una meta de ahorro? | A: Ahorrar únicamente cuando sobra dinero de manera ocasional.<br>**B: Definir una meta, un monto y un plazo, y separar dinero periódicamente.**<br>C: Utilizar crédito cada vez que no alcance el dinero.<br>D: Posponer indefinidamente el ahorro hasta tener mayores ingresos. | **B** |

---

## 6. Mecanismo de Scoring Server-Side y Seguridad

1. **Estructura del Payload hacia el Frontend:**
   El endpoint `GET /api/surveys/pre` utiliza `getPublicFinancialLiteracyQuestions()`, el cual proyecta estrictamente:
   ```json
   {
     "questionId": "Q1",
     "order": 1,
     "domain": "PLANIFICACION",
     "questionText": "¿Cuál es la principal finalidad de elaborar un presupuesto personal?",
     "options": [
       { "id": "A", "text": "Registrar únicamente las deudas." },
       { "id": "B", "text": "Planificar y controlar ingresos y gastos." },
       { "id": "C", "text": "Aumentar automáticamente los ingresos." },
       { "id": "D", "text": "Evitar utilizar productos financieros." }
     ]
   }
   ```
   *La clave `correctAnswer` y los ponderadores no existen en la interfaz pública ni en el bundle compilado de Flutter.*
2. **Cálculo de Puntaje en Backend:**
   Al invocar `POST /api/surveys/pre/response`:
   - El backend evalúa cada respuesta contra la constante privada `FINANCIAL_LITERACY_QUESTIONS`.
   - Se asigna `isCorrect = true` y `score = 1` si coincide con la clave; `isCorrect = false` y `score = 0` en caso contrario.
   - `totalScore` es la suma directa (rango: 0 a 12 puntos).
3. **Respuesta al Cliente sin Filtración de Resultados:**
   ```json
   {
     "completed": true,
     "message": "Evaluación inicial completada. Gracias por participar.",
     "assessmentType": "PRE",
     "questionnaireVersion": "FINLIT_PRE_V1",
     "completedAt": "2026-09-22T15:20:00.000Z"
   }
   ```
   *No se devuelve el puntaje ni las respuestas correctas al cliente móvil.*

---

## 7. Endpoints de Backend Implementados y Contratos

| Método | Endpoint | Auth | Descripción |
|---|---|:---:|---|
| `GET` | `/api/surveys/pre` | JWT | Retorna las 12 preguntas sin respuestas correctas, versión `FINLIT_PRE_V1` y texto de consentimiento. |
| `GET` | `/api/surveys/pre/status` | JWT | Retorna el estado actual (`NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`), consentimiento y respuestas guardadas. |
| `POST` | `/api/surveys/pre/start` | JWT | Registra el consentimiento académico (`FINLIT_CONSENT_V1`) e inicia la evaluación en estado `IN_PROGRESS`. |
| `PUT` | `/api/surveys/pre/save-progress` | JWT | Guarda respuestas parciales en estado `IN_PROGRESS` para permitir reanudación posterior. |
| `POST` | `/api/surveys/pre/response` | JWT | Envío definitivo atómico de las 12 respuestas. Calcula score (0–12), bloquea evaluación a `COMPLETED`. Retorna 409 si ya fue completada. |
| `GET` | `/api/research-dashboard/export/financial-literacy.json` | Token Admin | Exportación completa del dataset académico en JSON seudonimizado. |
| `GET` | `/api/research-dashboard/export/financial-literacy.csv` | Token Admin | Exportación tabular en CSV para análisis estadístico (R, SPSS, Python). |

---

## 8. Flujo Frontend, UX/UI, Consentimiento y Reanudación

1. **Pantalla de Consentimiento Informado:**
   - Si `consentGiven == false`, se presenta la vista de consentimiento académico explicando la confidencialidad, el procesamiento seudónimo y la importancia metodológica.
   - Casilla de verificación: `[ ] He leído la información y acepto participar en la evaluación.`
   - Botón `Comenzar evaluación` habilitado únicamente tras marcar la casilla.
2. **Presentación de Preguntas y Navegación:**
   - Indicador superior: `Pregunta X de 12`, barra de progreso lineal continua y chips circulares con el número de pregunta (1..12).
   - Badge con el dominio en español (`Planificación`, `Ahorro`, `Conocimiento Financiero`, `Inflación`, `Riesgo`, `Crédito`, `Seguridad Financiera`).
   - 4 tarjetas de opciones legibles (A, B, C, D) con estado seleccionado visualmente en verde Zenda (`#10B981`).
   - Botones `Anterior` y `Siguiente`.
   - Botón `Finalizar evaluación` disponible en la pregunta 12, deshabilitado con mensaje de advertencia hasta que las 12 preguntas tengan respuesta.
3. **Auto-Guardado y Reanudación:**
   - Al marcar cada respuesta, se envía un `PUT /api/surveys/pre/save-progress` en segundo plano.
   - Si el usuario sale de la aplicación, al volver se cargan sus respuestas previas y se ubica automáticamente en la primera pregunta pendiente.
4. **Protección contra Abandono u Omisión:**
   - Se eliminó cualquier botón de "Omitir".
   - Si el usuario presiona el botón "Atrás" del sistema Android, un diálogo modal aclara que la evaluación es obligatoria para la investigación y que su progreso está a salvo.
5. **Pantalla de Confirmación Neutral:**
   - Tras enviar con éxito, se despliega la pantalla neutral de confirmación:
     - Ícono de verificación verde.
     - Título: *Evaluación inicial completada*.
     - Subtítulo: *Gracias por participar. Tus respuestas han sido registradas de forma segura y seudónima para la investigación académica.*
     - Resumen: Pre-test (`FINLIT_PRE_V1`), 12 de 12 respondidas, Estado completado y bloqueado.
     - Botón `Continuar a Zenda` que redirige a `/profile-setup` o `/dashboard`.

---

## 9. Evidencia de Integridad y Atomicidad Transaccional

La función `submitAssessment` en `financial-literacy-assessment.service.ts` ejecuta todas las mutaciones dentro de una transacción `prisma.$transaction`:

1. Validación estricta de cantidad: `answerKeys.length === 12`.
2. Validación de pertenencia: cada `questionId` debe pertenecer a `FINLIT_PRE_V1`.
3. Validación de opciones: cada `selectedOption` debe ser `'A' | 'B' | 'C' | 'D'` según las opciones válidas de la pregunta.
4. Cálculo de puntuación en memoria del servidor.
5. Transacción atómica de base de datos:
   - `tx.financialLiteracyAssessment.update`: asigna `status = COMPLETED`, `totalScore`, `completedAt`.
   - Bucle `tx.financialLiteracyAnswer.upsert`: persiste las 12 respuestas con `isCorrect` y `score`.
   - `tx.user.update`: actualiza `financialLiteracyLevel` (`LOW` < 5, `MEDIUM` 5–8, `HIGH` >= 9).
   - `tx.surveyResponse.upsert`: doble escritura para compatibilidad con dashboards legados.

*Si cualquier paso falla, la transacción realiza rollback completo, garantizando que jamás existan evaluaciones en estado `COMPLETED` con menos de 12 respuestas o sin puntuación.*

---

## 10. Evidencia de las 18 Pruebas Obligatorias (Backend E2E)

Ejecutadas con `npx jest --config ./test/jest-e2e.json -- test/modules/financial-literacy-pretest.e2e-spec.ts`:

```
PASS test/modules/financial-literacy-pretest.e2e-spec.ts (12.96 s)
  Financial Literacy Pre-Test (US-1201 / FINLIT_PRE_V1) — 18 Pruebas Obligatorias
    √ 1. Nuevo usuario obtiene researchParticipantId (UUID v4 válido generado server-side) (158 ms)
    √ 2. Dos usuarios nunca reciben el mismo researchParticipantId (84 ms)
    √ 3. researchParticipantId no contiene información derivada del email ni nombre (69 ms)
    √ 4. PRE puede iniciarse una única vez (rechaza iniciar si ya está COMPLETED) (85 ms)
    √ 5. PRE IN_PROGRESS puede reanudarse conservando respuestas previas (81 ms)
    √ 6. PRE COMPLETED no puede volver a modificarse (67 ms)
    √ 7. No se puede completar con menos de 12 respuestas (64 ms)
    √ 8. No se puede duplicar una respuesta (cada pregunta se almacena una sola vez por evaluación) (49 ms)
    √ 9. No se aceptan questionIds inexistentes (64 ms)
    √ 10. Backend calcula correctamente score 0–12 (94 ms)
    √ 11. El frontend nunca recibe correctAnswer (210 ms)
    √ 12. Un usuario no puede enviar respuestas utilizando el identificador de otro (174 ms)
    √ 13. La exportación de investigación no contiene email (163 ms)
    √ 14. La exportación no contiene nombre (175 ms)
    √ 15. La exportación no contiene tokens (97 ms)
    √ 16. La exportación no contiene IP/deviceId (97 ms)
    √ 17. PRE y POST pueden coexistir para el mismo participantId (85 ms)
    √ 18. El POST nunca modifica los registros PRE (86 ms)

Test Suites: 1 passed, 1 total
Tests:       18 passed, 18 total
Snapshots:   0 total
Time:        13.738 s
```

---

## 11. Evidencia de Base de Datos (7 Criterios Obligatorios)

Ejecutado con `npx ts-node scripts/validate-financial-literacy-db.ts`:

```
================================================================
ZENDA — VALIDACIÓN DE BASE DE DATOS Y ARQUITECTURA (PRISMA DMMF)
================================================================

[MODELO 1] ResearchParticipant
  Campos: id (String), userId (String), researchParticipantId (String), createdAt (DateTime), user (User), assessments (FinancialLiteracyAssessment)
  -> Contiene researchParticipantId: SÍ (PASS)
  -> Contiene userId: SÍ (PASS - Mapeo de identidad exclusivo)

[MODELO 2] FinancialLiteracyAssessment
  Campos: id (String), researchParticipantId (String), assessmentType (AssessmentType), questionnaireVersion (String), status (AssessmentStatus), totalScore (Int), maxScore (Int), consentGiven (Boolean), consentVersion (String), consentAt (DateTime), startedAt (DateTime), completedAt (DateTime), createdAt (DateTime), updatedAt (DateTime), participant (ResearchParticipant), answers (FinancialLiteracyAnswer)
  -> ¿userId presente en FinancialLiteracyAssessment? NO (PASS - Separación estricta sin PII)
  -> ¿researchParticipantId presente? SÍ (PASS - Enlace seudónimo)

[MODELO 3] FinancialLiteracyAnswer
  Campos: id (String), assessmentId (String), questionId (String), domain (String), selectedOption (String), isCorrect (Boolean), score (Int), answeredAt (DateTime), assessment (FinancialLiteracyAssessment)
  -> ¿userId presente en FinancialLiteracyAnswer? NO (PASS - Separación estricta)
  -> ¿assessmentId presente? SÍ (PASS)

[RESTRICCIONES DE INTEGRIDAD]
  Unique Compound Keys en FinancialLiteracyAssessment: [ [ 'researchParticipantId', 'assessmentType', 'questionnaireVersion' ] ]
  Unique Compound Keys en FinancialLiteracyAnswer:     [ [ 'assessmentId', 'questionId' ] ]

[BANCO DE PREGUNTAS Y SCORING]
  Total preguntas: 12
  Q#  | Dominio                 | Clave Servidor | Puntaje
  ----+-------------------------+----------------+--------
  Q1  | PLANIFICACION           | B              | 1 pt
  Q2  | AHORRO                  | B              | 1 pt
  Q3  | PLANIFICACION           | A              | 1 pt
  Q4  | PLANIFICACION           | C              | 1 pt
  Q5  | CONOCIMIENTO_FINANCIERO | C              | 1 pt
  Q6  | INFLACION               | B              | 1 pt
  Q7  | RIESGO                  | C              | 1 pt
  Q8  | CREDITO                 | B              | 1 pt
  Q9  | CREDITO                 | B              | 1 pt
  Q10 | CREDITO                 | B              | 1 pt
  Q11 | SEGURIDAD_FINANCIERA    | C              | 1 pt
  Q12 | AHORRO                  | B              | 1 pt

================================================================
VERIFICACIÓN DE LOS 7 CRITERIOS OBLIGATORIOS
================================================================
1. ResearchParticipant con researchParticipantId (UUID v4 aleatorio server-side): PASS
2. userId NO aparece en FinancialLiteracyAssessment:                             PASS (Solo researchParticipantId)
3. userId NO aparece en FinancialLiteracyAnswer:                                 PASS (Solo assessmentId)
4. assessmentType = PRE (enum AssessmentType):                                   PASS
5. questionnaireVersion = FINLIT_PRE_V1:                                         PASS
6. Exactamente 12 respuestas asociadas requeridas:                               PASS (12 preguntas)
7. totalScore calculado correctamente en servidor (0–12):                        PASS (Puntaje Máximo = 12)
================================================================
EVIDENCIA DE BASE DE DATOS: 7/7 CRITERIOS VERIFICADOS EXITOSAMENTE
================================================================
```

---

## 12. Readiness para la Posterior Medición POST-TEST

La arquitectura implementada prepara completamente el terreno metodológico para la medición `POST`:

1. **Clave Compuesta Única:**
   `@@unique([researchParticipantId, assessmentType, questionnaireVersion])` permite registrar exactamente una evaluación `PRE` y una evaluación `POST` por participante bajo la misma versión `FINLIT_PRE_V1`.
2. **Inmutabilidad Cruzada:**
   Completar el `POST` no sobrescribe ni modifica el `PRE` (demostrado en la prueba e2e #18).
3. **Métrica Longitudinal:**
   Al disponer de ambos registros seudónimos vinculados al mismo `researchParticipantId`, el análisis cuantitativo de la tesis puede calcular:
   $$\Delta \text{Score} = \text{Score}_{\text{POST}} - \text{Score}_{\text{PRE}}$$
   así como el desglose por dominio (`Planificación`, `Ahorro`, `Crédito`, etc.) sin comprometer la identidad de los estudiantes.

---

## 13. Matriz de Trazabilidad Metodológica

| Dominio | Preguntas | Variable de Investigación | Indicador de Medición |
|---|---|---|---|
| **Planificación Financiera** | Q1, Q3, Q4 | Capacidad de presupuestación y priorización de gastos | Puntaje en dominio Planificación (0 a 3 pts) |
| **Hábito y Fondo de Ahorro** | Q2, Q12 | Conocimiento de reserva ante contingencias y metas | Puntaje en dominio Ahorro (0 a 2 pts) |
| **Cálculo Financiero Básico** | Q5 | Comprensión del interés simple / retorno de capital | Puntaje en Conocimiento Financiero (0 a 1 pt) |
| **Poder Adquisitivo y Macroeconomía** | Q6 | Efecto de la inflación en el consumo personal | Puntaje en Inflación (0 a 1 pt) |
| **Gestión de Riesgo** | Q7 | Concepto de diversificación vs concentración | Puntaje en Riesgo (0 a 1 pt) |
| **Uso Responsable del Crédito** | Q8, Q9, Q10 | Costo total del crédito (TCEA), mora y endeudamiento | Puntaje en Crédito (0 a 3 pts) |
| **Ciberseguridad y Prevención de Fraude** | Q11 | Protección de credenciales y canales bancarios | Puntaje en Seguridad Financiera (0 a 1 pt) |
| **TOTAL** | **12 Preguntas** | **Nivel Global de Educación Financiera** | **Puntaje Total (0 a 12 pts)** |

---

## 14. Archivos Modificados y Creados

### Backend (`zenda_backend_app`)
- **Modificado:** `prisma/schema.prisma` (Enums `AssessmentType`, `AssessmentStatus`; modelos `ResearchParticipant`, `FinancialLiteracyAssessment`, `FinancialLiteracyAnswer`).
- **Creado:** `prisma/migrations/20260922120000_add_research_participant_and_financial_literacy_assessment/migration.sql`.
- **Creado:** `src/modules/surveys/domain/financial-literacy-questions.ts` (Banco de 12 preguntas, dominios, consent text, interfaces y scoring).
- **Creado:** `src/modules/surveys/interface/dto/start-financial-literacy.dto.ts`.
- **Creado:** `src/modules/surveys/interface/dto/save-financial-literacy-progress.dto.ts`.
- **Creado:** `src/modules/surveys/interface/dto/submit-financial-literacy.dto.ts`.
- **Creado:** `src/modules/surveys/application/financial-literacy-assessment.service.ts` (Lógica de negocio, seudonimización, validación atómica, exportación).
- **Modificado:** `src/modules/surveys/interface/surveys.controller.ts` (Endpoints `/surveys/pre`, `/surveys/pre/status`, `/surveys/pre/start`, `/surveys/pre/save-progress`, `/surveys/pre/response`).
- **Modificado:** `src/modules/surveys/surveys.module.ts`.
- **Modificado:** `src/modules/research-dashboard/interface/research-dashboard.controller.ts` y `.module.ts` (Endpoints de exportación `.json` y `.csv`).
- **Creado:** `scripts/validate-financial-literacy-db.ts` (Script de verificación de los 7 criterios de base de datos).
- **Creado:** `test/modules/financial-literacy-pretest.e2e-spec.ts` (18 pruebas obligatorias).
- **Modificado:** `test/modules/surveys.e2e-spec.ts` (9 pruebas compatibles).

### Frontend (`zenda_fronted_app`)
- **Modificado:** `lib/core/services/education_api_service.dart` (`SurveyOption`, `SurveyQuestion` retrocompatible con parsing estructurado de opciones, `FinancialLiteracyStatus`, métodos `getPreStatus`, `startPre`, `savePreProgress`, `submitPre`).
- **Modificado:** `lib/providers/pre_survey_provider.dart` (Eliminación de skip store; verificación contra backend).
- **Modificado:** `lib/features/surveys/survey_screen.dart` (Flujo completo: consentimiento informado, banco de 12 preguntas, auto-guardado, eliminación de skip, bloqueo pop scope, pantalla neutral sin scores).
- **Creado:** `test/financial_literacy_pretest_test.dart` (4 pruebas unitarias de modelos, status y seguridad).

### Documentación y Monorepo
- **Creado:** `docs/pilot-readiness/FINANCIAL_LITERACY_PRETEST.md` (Este documento).
- **Modificado:** `docs/AI_HANDOFF.md`.
