# Product Backlog — Zenda

**Proyecto:** Zenda — App móvil de gestión financiera con IA para estudiantes universitarios  
**Versión:** 3.0  
**Total de historias de usuario:** 49  
**Total de sprints:** 4  
**Estimación total:** 612 h

> **Estados:** `Desarrollado` = backend + frontend implementados · `En curso` = implementación parcial · `No iniciado` = sin código

---

| Épica | ID US | COMO … | QUIERO … | PARA … | PRIORIDAD | SPRINT | NECESARIO PARA MVP | ESTIMACIÓN | ESTADO |
|-------|-------|--------|----------|--------|:---------:|:------:|:-----------------:|:----------:|--------|
| EPIC001 - Registro de transacciones | US-001 | estudiante universitario | registrar mis ingresos manualmente con monto, fecha, categoría y descripción opcional | llevar un control detallado de mis fuentes de dinero y mejorar mi gestión financiera | Alta | 1 | Sí | 8 | Desarrollado |
| | US-002 | estudiante universitario | registrar mis gastos manualmente con monto, fecha, categoría y nota opcional | identificar en qué gasto mi dinero y tomar decisiones más conscientes sobre mi consumo | Alta | 1 | Sí | 4 | Desarrollado |
| | US-003 | usuario registrado | editar el monto, categoría, fecha o descripción de una transacción registrada | corregir errores de captura sin eliminar la transacción, manteniendo mis reportes siempre precisos | Media | 2 | Sí | 12 | En curso |
| | US-004 | usuario registrado | eliminar una transacción tras confirmar la acción en un diálogo de verificación | mantener mi historial limpio y libre de registros incorrectos para que mis reportes sean precisos | Media | 2 | Sí | 6 | Desarrollado |
| EPIC002 - Categorización | US-005 | estudiante universitario | asignar una categoría al registrar un ingreso, eligiendo entre categorías existentes o la sugerencia automática de la IA | diferenciar mis ingresos por origen y obtener reportes precisos sobre mis fuentes de dinero | Alta | 2 | Sí | 8 | Desarrollado |
| | US-006 | usuario registrado | asignar o cambiar la categoría de un gasto al registrarlo o editarlo, incluyendo la sugerencia automática de la IA | organizar mis gastos por tipo de consumo y visualizarlos en gráficos para tomar mejores decisiones | Alta | 2 | Sí | 6 | Desarrollado |
| | US-040 | usuario registrado | crear una categoría personalizada para organizar mis transacciones | adaptar la clasificación a mis hábitos específicos, más allá de las categorías predefinidas | Media | 2 | No | 4 | Desarrollado |
| | US-041 | usuario registrado | renombrar o eliminar una categoría personalizada que ya no uso | mantener mi lista de categorías ordenada y actualizada con mis necesidades actuales | Baja | 2 | No | 6 | Desarrollado |
| EPIC003 - Reportes y visualización | US-007 | estudiante universitario | ver el total de gastos del día actual con desglose por categoría | monitorizar mis hábitos diarios en tiempo real y detectar si estoy gastando más de lo habitual | Media | 2 | No | 10 | En curso |
| | US-008 | usuario registrado | ver mis gastos e ingresos agrupados por día dentro de una semana seleccionada | identificar en qué días concentro más mis gastos y detectar tendencias tempranas de gasto | Media | 2 | No | 10 | En curso |
| | US-009 | usuario registrado | ver el total de ingresos, gastos y balance del mes seleccionado | evaluar mi salud financiera mensual y determinar si estoy ahorrando o gastando más de lo que recibo | Alta | 2 | Sí | 5 | Desarrollado |
| | US-010 | estudiante universitario | visualizar un gráfico del porcentaje y monto gastado por categoría en un periodo seleccionado | entender visualmente en qué categorías concentro mis gastos y dónde puedo reducir mi consumo | Alta | 3 | No | 12 | En curso |
| | US-011 | estudiante universitario | ver un gráfico comparativo de ingresos, gastos y ahorro entre dos o más meses | analizar si mis hábitos financieros están mejorando o empeorando y ajustar mi comportamiento | Media | 3 | No | 16 | En curso |
| | US-012 | usuario registrado | filtrar el historial de transacciones por rango de fechas y tipo de transacción | localizar transacciones de un periodo o tipo específico sin revisar todo el historial | Media | 3 | No | 8 | En curso |
| | US-013 | usuario registrado | exportar el reporte del periodo como PDF con gráficos y desglose, y compartirlo desde mi teléfono | guardar un respaldo de mis finanzas fuera de la app y compartirlo con mi asesor o para mi tesis | Baja | 3 | No | 16 | En curso |
| | US-014 | estudiante universitario | ver un indicador de evolución financiera comparando mis hábitos actuales con los de meses anteriores | entender si mis hábitos financieros están mejorando y tener evidencia concreta de mi progreso | Alta | 4 | No | 20 | No iniciado |
| | US-038 | usuario registrado | ver el desglose de gastos e ingresos por categoría en el resumen mensual | identificar qué categorías consumen más mi presupuesto mensual y detectar áreas de mejora financiera | Alta | 2 | Sí | 5 | Desarrollado |
| | US-039 | usuario registrado | filtrar el historial de transacciones por categoría y rango de monto | identificar patrones de gasto en categorías específicas y detectar transacciones de importes inusuales | Media | 3 | No | 6 | En curso |
| EPIC004 - IA y predicciones | US-015 | usuario registrado | consultar la predicción de la IA sobre mis gastos del próximo mes con desglose por categoría y nivel de confianza | anticipar mis gastos del próximo mes y planificar para no quedarme sin fondos en fechas críticas | Alta | 3 | No | 40 | No iniciado |
| | US-016 | usuario registrado | recibir una alerta de la IA cuando mis gastos en una categoría superen el 20% de mi promedio histórico mensual | detectar a tiempo gastos inusuales que puedan comprometer mi presupuesto antes de que sean difíciles de corregir | Alta | 3 | No | 24 | No iniciado |
| | US-017 | estudiante universitario | recibir recomendaciones personalizadas de la IA basadas en mi historial financiero, metas y presupuestos activos | tomar decisiones financieras más inteligentes con sugerencias concretas adaptadas a mi situación real | Alta | 4 | No | 40 | No iniciado |
| | US-018 | estudiante universitario | que la IA sugiera automáticamente la categoría de una transacción al analizar su descripción o monto | reducir el tiempo de registro y evitar errores de categorización manual, manteniendo mis reportes organizados | Media | 3 | Sí | 24 | No iniciado |
| EPIC005 - Presupuestos | US-019 | estudiante universitario | definir un límite de gasto mensual para una categoría específica | establecer límites claros de gasto por área y saber cuándo estoy cerca de exceder lo que me propuse | Alta | 1 | Sí | 8 | Desarrollado |
| | US-020 | estudiante universitario | recibir una notificación automática cuando mis gastos en una categoría alcancen el 80% del límite mensual definido | actuar con anticipación antes de sobrepasar mi presupuesto y evitar terminar el mes con un déficit | Alta | 3 | No | 16 | No iniciado |
| | US-042 | usuario registrado | ver el resumen de todos mis presupuestos activos del mes con su porcentaje de avance | monitorizar de un vistazo si estoy dentro de mis límites de gasto en cada categoría del mes | Alta | 1 | Sí | 6 | Desarrollado |
| | US-043 | usuario registrado | editar el límite de un presupuesto mensual existente o eliminarlo | ajustar mis objetivos de gasto cuando cambian mis prioridades financieras | Media | 2 | No | 8 | No iniciado |
| EPIC006 - Metas de ahorro | US-021 | usuario registrado | registrar una meta de ahorro con nombre, monto objetivo en soles y fecha límite | trabajar de forma organizada hacia un objetivo financiero concreto con un plazo definido | Media | 2 | Sí | 8 | Desarrollado |
| | US-022 | usuario registrado | ver el monto ahorrado, porcentaje de avance, monto restante y días restantes de una meta activa | saber en qué punto estoy respecto a mi meta y evaluar si voy al ritmo necesario para alcanzarla | Media | 3 | Sí | 8 | Desarrollado |
| | US-044 | usuario registrado | registrar un aporte económico hacia una meta de ahorro específica | hacer seguimiento de mi progreso real de ahorro y saber cuánto me falta para alcanzar mi objetivo | Alta | 2 | Sí | 6 | Desarrollado |
| | US-045 | usuario registrado | marcar una meta de ahorro como completada o eliminarla si ya no quiero seguirla | mantener mi lista de metas actualizada y enfocarme en los objetivos que siguen siendo relevantes | Baja | 3 | No | 6 | No iniciado |
| EPIC007 - Gamificación y retos | US-023 | estudiante universitario | acceder a módulos de educación financiera con contenido práctico adaptado a estudiantes universitarios peruanos | mejorar mi comprensión de finanzas personales de forma progresiva y tomar decisiones más informadas | Alta | 4 | No | 20 | No iniciado |
| | US-024 | estudiante universitario | ver y aceptar mini-retos financieros disponibles en la app | mejorar mis hábitos financieros a través de desafíos concretos que me mantengan comprometido con la app | Media | 4 | No | 14 | No iniciado |
| | US-025 | usuario registrado | recibir una insignia en mi perfil al completar una meta, terminar un reto o alcanzar un hito de uso | sentirme reconocido por mi progreso y mantener la motivación para seguir usando la app | Baja | 4 | No | 16 | No iniciado |
| | US-026 | estudiante universitario | responder preguntas de un reto de conocimiento financiero y recibir retroalimentación inmediata tras cada respuesta | aprender finanzas personales de forma activa dentro de la app mediante la práctica de conceptos clave | Alta | 4 | No | 28 | No iniciado |
| | US-046 | estudiante universitario | que la app verifique automáticamente si cumplí las condiciones de un mini-reto activo | recibir reconocimiento por mis logros sin tener que reportarlos manualmente | Alta | 4 | No | 10 | No iniciado |
| | US-048 | estudiante universitario | recibir una ruta de aprendizaje ordenada por la IA según mis patrones de gasto y áreas financieras con más oportunidad de mejora | enfocar mi aprendizaje en los temas más relevantes para mi situación real y mejorar más rápido mi literacidad financiera | Alta | 4 | No | 20 | No iniciado |
| | US-049 | estudiante universitario | responder preguntas de conocimiento financiero generadas por la IA a partir de mis hábitos de gasto y áreas donde tengo oportunidades de mejora | practicar conceptos financieros directamente relacionados con mi comportamiento real para aprender de forma más efectiva | Media | 4 | No | 24 | No iniciado |
| EPIC008 - Autenticación y seguridad | US-027 | usuario nuevo | registrarme en la app con mi nombre, correo y contraseña, e iniciar sesión automáticamente tras el registro | acceder a mis datos financieros de inmediato tras registrarme y tener mi cuenta protegida desde el primer momento | Alta | 1 | Sí | 8 | Desarrollado |
| | US-028 | usuario registrado | iniciar sesión con mi correo y contraseña, con bloqueo temporal tras tres intentos fallidos | garantizar que solo yo pueda acceder a mi información financiera personal | Alta | 1 | Sí | 6 | Desarrollado |
| | US-029 | usuario registrado | que mis datos personales y financieros se transmitan cifrados y se almacenen de forma segura en el servidor | tener la certeza de que mi información personal y financiera está protegida, en cumplimiento con la Ley 29733 de Protección de Datos Personales del Perú | Alta | 1 | Sí | 12 | En curso |
| EPIC009 - Perfil de usuario | US-030 | estudiante universitario | completar mi perfil la primera vez que uso la app, indicando mi edad, universidad y situación económica básica | que la app adapte sus recomendaciones, predicciones y contenido educativo a mi situación económica real | Media | 1 | Sí | 10 | Desarrollado |
| | US-031 | usuario registrado | seleccionar la moneda y el formato numérico con el que se mostrarán los montos en la app | tomar decisiones financieras correctas con información en el formato familiar de mi vida cotidiana | Media | 2 | No | 6 | En curso |
| | US-032 | estudiante universitario nuevo | ver pantallas guiadas de bienvenida al abrir la app por primera vez, con opción de omitirlas | entender rápidamente cómo usar la app desde el primer día sin explorarla por prueba y error | Alta | 1 | Sí | 8 | Desarrollado |
| EPIC010 - Evaluación e investigación | US-033 | estudiante universitario | responder la evaluación inicial de conocimiento financiero al abrir la app por primera vez | establecer un nivel base medible de educación financiera para compararlo con mis resultados al finalizar el uso de Zenda | Alta | 1 | Sí | 20 | No iniciado |
| | US-034 | estudiante universitario | recibir la invitación para la evaluación final de conocimiento tras 30 días de uso activo | recordarme que debo completar la evaluación final para medir mi evolución financiera | Alta | 4 | No | 6 | No iniciado |
| | US-035 | estudiante participante del piloto | completar el cuestionario de usabilidad SUS desde la app al finalizar el periodo de prueba | contribuir con mi evaluación de experiencia a la validación de la app y la medición objetiva de su usabilidad | Alta | 4 | No | 14 | No iniciado |
| | US-036 | estudiante universitario | enviar mis comentarios y sugerencias sobre la app desde una sección dedicada | contribuir con evidencia directa al proceso de mejora de la app para que futuras versiones sean más útiles | Media | 4 | No | 10 | No iniciado |
| | US-037 | investigador | analizar los patrones de uso registrados automáticamente en la app para cada usuario | identificar qué funcionalidades son más usadas y respaldar con datos las conclusiones de la investigación | Media | 4 | No | 16 | No iniciado |
| | US-047 | estudiante universitario | completar la evaluación final de conocimiento financiero cuando reciba la invitación | medir cuánto mejoré mis conocimientos financieros gracias al uso de Zenda | Alta | 4 | No | 8 | No iniciado |

---

## Resumen por Sprint

| Sprint | Enfoque | HUs | Estimación | MVPs |
|:------:|---------|:---:|:----------:|:----:|
| 1 | Autenticación, onboarding, perfil, transacciones base, presupuestos, panel de presupuestos y evaluación inicial | 10 | 90 h | 10 |
| 2 | Categorización, gestión de categorías, edición/eliminación, metas, aportes a metas y resúmenes básicos | 14 | 100 h | 8 |
| 3 | Reportes avanzados, filtros, PDF, IA básica, alertas y gestión de presupuestos y metas | 11 | 176 h | 2 |
| 4 | Recomendaciones IA, gamificación, retos, ruta de aprendizaje IA, preguntas IA, evaluación final y SUS | 14 | 246 h | 0 |
| **Total** | | **49** | **612 h** | **20** |

---

## Resumen por Épica

| Épica | Nombre | HUs | Estimación | MVPs | Sprints |
|:-----:|--------|:---:|:----------:|:----:|---------|
| EPIC001 | Registro de transacciones | 4 | 30 h | 4 | 1–2 |
| EPIC002 | Categorización | 4 | 24 h | 2 | 2 |
| EPIC003 | Reportes y visualización | 10 | 108 h | 2 | 2–4 |
| EPIC004 | IA y predicciones | 4 | 128 h | 1 | 3–4 |
| EPIC005 | Presupuestos | 4 | 38 h | 2 | 1–3 |
| EPIC006 | Metas de ahorro | 4 | 28 h | 3 | 2–3 |
| EPIC007 | Gamificación y retos | 7 | 132 h | 0 | 4 |
| EPIC008 | Autenticación y seguridad | 3 | 26 h | 3 | 1 |
| EPIC009 | Perfil de usuario | 3 | 24 h | 2 | 1–2 |
| EPIC010 | Evaluación e investigación | 6 | 74 h | 1 | 1, 4 |
| **Total** | | **49** | **612 h** | **20** | **4** |
