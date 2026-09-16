# Configuracion IA / RAG

## Flujo real

Flutter -> JWT /api/ai/chat -> SendChatMessageUseCase -> contexto financiero de usuario -> AzureFoundryAgentClient -> agente Foundry o asistente clasico -> respuesta y fuentes -> persistencia conversacion/mensajes. El backend prepara contexto y aplica reglas; NO es un modelo predictivo entrenado por Zenda. Predicciones, quiz, clasificacion y ruta tienen prompts/fallbacks distintos: no atribuirles identica calidad.

| Parametro | Evidencia local | Estado reproducibilidad |
|---|---|---|
| Proveedor | Microsoft Azure AI Foundry; @azure/ai-projects y @azure/ai-agents | Confirmado por SDK, no llamada real en esta auditoria |
| Modelo / version / deployment | Agente referenciado por nombre; ID asst usa ruta clasica | Desconocido remoto; NO inferir de .env.example |
| Temperatura, top-p, max tokens | No se fijan en llamada del agente | Exportar configuracion del agente y deployment |
| Embeddings, chunk size/overlap, top-k | File Search configurado fuera del backend | No verificado |
| Indice/vector store/documentos | Fuentes file_citation/file_path/url_citation parseadas | Cantidad y version del corpus no verificadas |
| Prompt local | defaultTaskInstructions y taskInstructions de casos de uso | Hashes en version-manifest; no alterados |
| Prompt remoto | Configuracion de Foundry | Snapshot pendiente |
| Historial enviado | Ultimos 6 mensajes, max 500 caracteres por mensaje, limpieza de correo/numeros largos | Limite en caracteres, no presupuesto exacto de tokens |
| Mensaje actual | Validado por DTO, incluido en texto de entrada | No asumir anonimizado ni resistente a prompt injection |
| Contexto | ingreso aproximado, gastos, categorias, meta, ahorro; nombres sanitizados | Datos financieros agregados enviados al proveedor; sin equivalencia a consentimiento especifico |
| Timeout | AZURE_AI_AGENT_TIMEOUT_MS; defecto 30000 | No es garantia de latencia <10s del backlog |
| Salida | answer/reply, sources, metadata, identificadores remotos | No contiene consumo de tokens ni modelo exacto persistidos |

## Autenticacion por entorno

Credenciales SP completas -> ClientSecretCredential. Managed Identity activada -> credencial MI. Sin SP -> DefaultAzureCredential para CLI local. Configurar fuera de Git. Nunca incluir claves de servidor en Flutter/dart-defines. Endpoint y nombre del agente no sustituyen autenticacion/autorizacion. Permisos reales, rotacion, red privada y TLS pendientes de evidencia del operador.

## Guardrails existentes y limites

El prompt pide educacion, entre 100 y 150 palabras como maximo, hasta tres bullets, sin promesas de ganancia ni inversiones especificas; usa guia de capacidades reales. Se limpian marcadores de archivos del texto visible y se devuelven fuentes por separado. Esto NO prueba que el modelo obedezca ni que su respuesta este sustentada.

`usedRag=true` esta asignado por la ruta del agente incluso si sources esta vacio. Es evidencia de modo de ejecucion, NO de recuperacion efectiva ni groundedness. Registrar trazas de File Search y chunks recuperados para evaluarlo. Fuentes citadas no equivalen al conjunto de contexto recuperado.

Persisten riesgos: instrucciones y datos mezclados en string, ausencia de version remota fijada, nombres/nota de usuario que contienen instrucciones, longitud no limitada en postprocesamiento, falta de presupuesto por usuario/costo y telemetria de tokens. Un hilo remoto nuevo en ruta clasica puede conservar datos fuera de la BD local; definir retencion tambien en Azure. El historial local no conserva todas las fuentes de cada respuesta. No comprobar RAG con una sola respuesta exitosa.

## Congelacion antes de estudio

1. Exportar una ficha SIN secretos: modelo/version, deployment, agente/version, instrucciones, herramientas, vector store, hashes de documentos, embeddings, retrieval y limites.
2. Mantener copia versionada del corpus autorizado y aprobacion del contenido financiero; no incorporar respuestas del pre/post al corpus.
3. Fijar version del agente para toda una cohorte o registrar cambio como intervencion diferente.
4. Capturar entradas exclusivamente sinteticas para las 120 consultas; recuperar contexto real de la traza, no reconstruirlo desde citas.
5. Ejecutar evaluacion automatica y dos evaluadores humanos; congelar los resultados con version de juez distinta del agente.

Configuracion remota y calidad: pendientes, sin llamadas a Azure ni costos generados por esta auditoria.
