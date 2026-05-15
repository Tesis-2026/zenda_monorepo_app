# Observaciones de Arquitectura

Revisión del modelo C4 de Zenda (`docs/zenda.dsl`). Cada sección corresponde a un nivel del diagrama, con las observaciones detectadas y su acción de mejora propuesta.

> Fuente: `docs/Observaciones Arquitectura (2).xlsx`

---

## Contexto

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | El actor "Developer" no corresponde al nivel de Contexto C4 | Eliminar el actor Developer del diagrama de contexto y dejar solo actores de negocio |
| 2 | Firebase Cloud Messaging tiene formato visual inconsistente | Usar el mismo estilo visual de los demás sistemas externos |
| 3 | El texto "not yet implemented" no debería aparecer en arquitectura C4 | Eliminar referencias al estado de implementación del sistema |
| 4 | Algunas relaciones visuales se cruzan y generan ruido | Reorganizar posiciones para evitar flechas diagonales y cruces innecesarios |
| 5 | La descripción de Azure AI Foundry es muy extensa y funcional | Simplificar la descripción enfocándola al rol arquitectónico del servicio |
| 6 | Algunas relaciones tienen demasiado texto funcional | Reducir texto en flechas y dejar solo la interacción principal |
| 7 | La relación con Firebase no deja claro quién inicia las notificaciones | Mostrar claramente que Zenda System dispara eventos hacia Firebase |

---

## Contenedores

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | Azure AI Foundry parece conectado directamente a la base de datos | Mostrar que toda interacción con IA es orquestada exclusivamente por Zenda API |
| 2 | Firebase Cloud Messaging mantiene formato inconsistente | Usar el mismo estilo visual de los demás sistemas externos |
| 3 | El texto "not implemented" no debe aparecer en arquitectura C4 | Eliminar referencias al estado de implementación |
| 4 | El actor "Developer" no aporta valor arquitectónico en el diagrama de contenedores | Eliminar el actor Developer del diagrama |
| 5 | La base de datos tiene demasiado detalle para nivel Container C4 | Simplificar descripción dejando solo información general del dominio |
| 6 | No existe una abstracción clara para los servicios de IA | Modelar la IA como servicio externo consumido por la API |
| 7 | El layout horizontal genera lectura extensa y ruido visual | Reorganizar elementos en distribución más compacta y vertical |
| 8 | Algunas relaciones se cruzan y dificultan la lectura | Reubicar Firebase y Email Provider para minimizar cruces |
| 9 | Las relaciones contienen demasiado texto funcional | Simplificar etiquetas dejando solo protocolo y acción principal |

---

## Componentes

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | El diagrama tiene demasiadas relaciones y cruces visuales | Reducir flechas mostrando solo dependencias principales entre componentes |
| 2 | La base de datos aparece conectada a casi todos los módulos | Simplificar relaciones hacia la BD para evitar sensación de alto acoplamiento |
| 3 | Algunos componentes mezclan lógica de negocio y detalles técnicos | Mantener foco arquitectónico y reducir detalles internos de implementación |
| 4 | AzureFoundryProvider concentra demasiadas responsabilidades | Separar responsabilidades de IA (provider, prompts, orchestration) o simplificar descripción |
| 5 | El layout horizontal hace difícil la lectura | Reorganizar componentes en bloques funcionales más compactos |
| 6 | Existe mezcla entre infraestructura y componentes de dominio | Reducir referencias técnicas como ORM, prompts o nodemailer dentro del C4 |
| 7 | El módulo Education no deja claro su comportamiento respecto a IA | Especificar si consume IA directamente o si reutiliza recomendaciones/contenido generado |
| 8 | Las conexiones hacia Azure AI generan ruido visual | Centralizar las llamadas IA mediante un único gateway visualmente más claro |
| 9 | No se evidencian claramente capacidades transversales de seguridad | Incluir seguridad transversal de forma resumida (JWT, authorization, throttling) |
| 10 | Algunos módulos parecen servicios de dominio y otros componentes técnicos | Homogeneizar el nivel de abstracción usado en todos los componentes |

---

## Esquema de Datos

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | No se visualizan claramente las cardinalidades entre entidades | Agregar cardinalidades (1:N, N:M, opcionalidad) en las relaciones |
| 2 | El modelo no contempla entidades para chat o conversaciones IA | ✅ **Resuelto** (2026-05-14) — Se agregaron las entidades `ai_conversations` y `ai_messages` (modelos Prisma + enums, capa DDD en el módulo `recommendations`, endpoints `GET /ai/chat/active`, `POST /ai/chat`, `POST /ai/chat/close`, y ERD actualizado). Persistencia de chat con continuidad por sesión y cierre en logout. |
| 3 | Existe inconsistencia entre arquitectura y persistencia de auditoría | Incorporar tablas de `audit_logs` o `activity_logs` |
| 4 | El módulo de educación financiera no está suficientemente representado | Agregar entidades para quizzes, intentos, temas educativos y progreso |
| 5 | No se diferencia clasificación IA vs clasificación manual del usuario | ✅ **Resuelto** (2026-05-15) — Se agregaron a `Transaction`: `suggestedCategoryId` (UUID FK a `Category`), `aiConfidence` (`Decimal(3,2)`, 0.00–1.00) y `categorySource` (enum `AI` / `AI_OVERRIDDEN` / `USER`, default `USER`). El `categorySource` se deriva en el use case a partir de (`suggestedCategoryId`, `categoryId`); si el usuario edita la categoría después, se recalcula a `AI_OVERRIDDEN`. Permite calcular accuracy del KPI ≥80%. Migración: `20260515000000_add_transaction_ai_classification`. |
| 6 | Algunas entidades funcionales se encuentran poco definidas conceptualmente | Clarificar responsabilidades entre insights, predictions y recommendations |
| 7 | El modelo está muy cercano al esquema físico final | Evaluar simplificar visualmente el modelo para presentación académica |
| 8 | Existe posible sobre-normalización para un MVP académico | Revisar si algunas entidades pueden simplificarse sin perder funcionalidad |
| 9 | No se evidencia trazabilidad del aprendizaje del usuario | Incorporar entidades relacionadas a progreso financiero o educativo |
| 10 | Falta representación explícita de histórico de recomendaciones IA | Considerar persistencia de recomendaciones generadas y feedback del usuario |

---

## Lógico

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | El diagrama mezcla arquitectura lógica con infraestructura física | ✅ **Resuelto** (2026-05-15) — Se renombraron las agrupaciones para eliminar referencias a deployment: `Android App (Flutter)` → `Mobile Client`, `Application Service` → `Backend`. Comentarios XML que referenciaban Azure App Service / Azure PostgreSQL también actualizados. El diagrama ahora es puramente lógico, manteniendo el título "Logical Architecture". |
| 2 | Se incluyen detalles demasiado técnicos como "15 DB / 26 models" | Eliminar detalles implementativos y mantener nivel arquitectónico |
| 3 | Prisma ORM aparece como elemento arquitectónico principal | Reducir visibilidad de ORM ya que es detalle interno de persistencia |
| 4 | Algunas relaciones aún generan ruido visual | Reorganizar conexiones para minimizar cruces |
| 5 | No existe una capa clara de entrada/API Gateway | Agregar capa conceptual de controllers o API facade |
| 6 | Firebase Cloud Messaging queda visualmente aislado | Mostrar claramente que el backend dispara eventos hacia Firebase |
| 7 | Los módulos parecen depender directamente de persistencia | Considerar abstracción de persistencia mediante repositories o services |
| 8 | El nombre "Logical Architecture" no coincide completamente con el contenido | Mantener solo componentes lógicos o renombrar como "Logical + Deployment Overview" |
| 9 | Algunas responsabilidades de IA aún están muy concentradas | Evaluar separar orchestration AI de provider AI |
| 10 | Se mezclan responsabilidades funcionales y técnicas en el mismo nivel visual | Mantener separación clara entre dominio, infraestructura y cross-cutting concerns |

---

## Arquitectura Física

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | No se especifica región ni zona de disponibilidad de los servicios Azure | Agregar región (ej. `Brazil South` / `East US 2`) y AZ donde aplique |
| 2 | App Service y PostgreSQL no declaran SKU/tier ni capacidad | Indicar plan (ej. `B1`, `P1v3`) y tamaño de BD (vCores, storage) |
| 3 | Se menciona "Private Endpoint" pero no se dibuja la VNet ni las subnets | Añadir VNet, subnet del Private Endpoint y Private DNS Zone |
| 4 | No existe componente de observabilidad/monitoreo | Incluir Application Insights / Log Analytics como nodo dentro de Azure |
| 5 | No se representa el pipeline de CI/CD que despliega al App Service | Agregar GitHub Actions / Azure DevOps como nodo origen del despliegue |
| 6 | Falta el canal de distribución del APK al cliente | Insertar Google Play Store entre el desarrollador y el Mobile Client |
| 7 | El "Mobile Client" mezcla dispositivo físico (Android), runtime (Flutter) y almacenamiento local en un solo bloque | Separar conceptualmente "dispositivo" vs "aplicación" vs "storage local" |
| 8 | No hay representación de ambientes (dev / staging / prod) | Mostrar al menos slots de despliegue o duplicar la topología por ambiente |
| 9 | No se muestra estrategia de backup / recuperación de PostgreSQL | Indicar backups automáticos, point-in-time recovery o geo-redundancia |
| 10 | El "SMTP Gateway" no especifica proveedor (SendGrid, SES, Mailgun…) | Nombrar el proveedor concreto o etiquetarlo como "to be defined" |
| 11 | No se representa gestión de TLS / dominio personalizado | Agregar componente de certificados (App Service Managed Certificate / Front Door) |
| 12 | No existe API Gateway / WAF delante del App Service | Considerar Azure Front Door o API Management para rate-limit + WAF |

---

## Arquitectura por Capas

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | El actor "Student" no pertenece a una vista de módulos (la vista por capas describe estructura, no comportamiento) | Quitar el actor o trasladarlo a un diagrama de casos de uso/contexto |
| 2 | "Supporting Services" (IA, Email, Push) están en la Business Layer, pero son integraciones con sistemas externos | Crear una sub-capa "Integration / Anti-Corruption" o un bloque lateral de "External Services" |
| 3 | La Database Layer agrupa tablas por dominio funcional — eso es diseño de datos, no separación por capas | Dejar la Database Layer abstracta (motor + esquema) y mover el agrupamiento al ERD |
| 4 | No se hace explícita la frontera de red entre Presentation y Business (es una llamada remota, no local) | Marcar la frontera como "Network Boundary · HTTP" en la flecha entre L1 y L2 |
| 5 | Los "Cross-cutting Concerns" aparecen solo dentro de Business, pero realmente atraviesan todas las capas | Dibujar la barra cross-cutting como una banda lateral vertical que toque las 4 capas |
| 6 | La Business Layer tiene internamente 4 sub-bloques (Interface · Application · Domain · Supporting) → eso es Clean/Hexagonal, no "capas puras" | Renombrar el diagrama a "Layered + DDD Hybrid" o aplanar los sub-bloques |
| 7 | No se muestra dirección de dependencias (regla de capas: solo hacia abajo, sin saltos) | Agregar nota textual: *"Dependencies flow top-down only — no skip-layer calls"* |
| 8 | "Repository ports" están dentro del Domain pero las implementaciones están en Persistence — eso invierte la dependencia esperada en capas estrictas | Aclarar visualmente la inversión (flecha punteada de Persistence → Domain "implements") |
| 9 | "Connection Management" es un detalle interno del ORM, no un componente arquitectónico de primer nivel | Fusionar con "Object-Relational Mapping" |
| 10 | El nombre "API Client" en Presentation puede confundirse con el API real (que vive en Business) | Renombrar a "Backend Gateway" o "Remote Service Adapter" |
| 11 | El Domain agrupa todos los bounded contexts en un solo bloque (Auth · Users · Transactions · …) | Listar los bounded contexts en la Application Layer (donde viven los casos de uso) y dejar Domain abstracto |
| 12 | No se representa el flujo de autenticación/autorización entre capas | Indicar dónde se valida JWT (entrada de Business Layer, antes de Application) |

---

## Observaciones cruzadas entre arquitecturas

| # | Observación | Acción de mejora |
|---|-------------|------------------|
| 1 | No hay trazabilidad entre el diagrama por capas y el físico (qué capa corre dónde) | Agregar tabla de mapeo: Presentation → Mobile Client / Business + Persistence → App Service / Database → PostgreSQL |
| 2 | Cada diagrama debería declarar qué vista representa (4+1, C4, ISO/IEC/IEEE 42010) | Añadir nota al pie: *"Logical view (module decomposition)"* y *"Physical / Deployment view"* |
| 3 | Inconsistencia de nomenclatura: "AI Foundry" en físico vs "Artificial Intelligence" en capas | Estandarizar el nombre del componente IA en ambos diagramas |
