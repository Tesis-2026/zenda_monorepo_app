# Plan de evaluacion RAG

## Artefactos

`tools/rag-evaluation/`: 120 consultas sinteticas unicas en 20 categorias, dataset.base.jsonl, dos formularios independientes reviewer-A/B.csv, evaluate.py, requirements.txt y test_metrics.py. `approved=false`, response/context/ground_truth/model_version nulos: NO son resultados ni referencias validadas. El generador preserva formularios existentes; no editar el dataset base para registrar respuestas, usar copia privada versionada.

Temas: presupuesto, ingresos, gastos, categorias, ahorro, metas, cuentas, credito, consumo, reportes, fechas, voz, OCR, educacion, privacidad, informacion insuficiente, seguridad, inyeccion, calculo y limites de la app. Seis consultas por tema. Revisar representatividad con el asesor antes de recolectar.

## Procedimiento

1. Aprobar consulta y respuesta de referencia por expertos; vincular version del corpus y IDs de chunks relevantes. Separar conjunto de ajuste de prompts del conjunto final congelado. Nunca ajustar con los resultados finales.
2. Preparar usuario/finanzas sinteticos en entorno aislado. Capturar una respuesta por caso, modelo/version, latencia monotona y usage tokens reportados por proveedor. No usar datos de participantes.
3. Capturar contexto recuperado completo desde trazas Azure, orden e IDs. No asumir que sources incluye todo lo recuperado. Casos fuera de dominio sin contexto se registran como N/A para recuperacion y se evalua rechazo/seguridad por humanos; el runner cloud exige contexto no vacio y debe ejecutarse sobre subconjunto apropiado o adaptar el protocolo con version.
4. Completar ground_truth/context/response/reference_version/model_version y approved=true en dataset.approved.jsonl. Guardar privados los artefactos de captura, no secretos.
5. Ejecutar validacion offline; despues aprobar costo y utilizar --allow-cloud. SDK fijado en 1.18.5; `pip freeze` para fijar transitorios en entorno evaluador final. No es el mismo deployment usado por el agente salvo decision registrada.

```powershell
node tools/rag-evaluation/build-dataset.cjs
cd tools/rag-evaluation
py -3.11 -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
.\.venv\Scripts\python -m unittest test_metrics.py
.\.venv\Scripts\python evaluate.py dataset.base.jsonl
# Configurar EVAL_AZURE_ENDPOINT, EVAL_AZURE_KEY, EVAL_AZURE_DEPLOYMENT fuera de Git.
.\.venv\Scripts\python evaluate.py dataset.approved.jsonl --allow-cloud --output results/run-01
```

En este equipo `py` no esta disponible: runner Python y Azure NO ejecutados. Validacion estructural del dataset si ejecutada con Node. La API usada se basa en la documentacion oficial de [Azure AI Evaluation SDK](https://learn.microsoft.com/en-us/python/api/overview/azure/ai-evaluation-readme?view=azure-python), consultada el 2026-09-13. Requiere validar instalacion y compatibilidad del deployment antes de medir.

## Metricas y denominadores

| Metrica | Fuente/calculo | Limitacion |
|---|---|---|
| Groundedness | GroundednessEvaluator sobre respuesta/contexto | Juez automatizado, no verdad absoluta |
| Relevancia | RelevanceEvaluator(query,response) | Validar contra rubrica humana |
| Coherencia | CoherenceEvaluator | No sustituye exactitud |
| Similitud | SimilarityEvaluator frente a referencia | NO llamarla exactitud financiera |
| Context precision | Promedio de precision@rango en posiciones relevantes; IDs unicos y etiquetas humanas | Sin gold => N/A, nunca 1 ficticio |
| Context recall | chunks relevantes recuperados / chunks relevantes de referencia | Denominador debe ser referencia aprobada |
| Exactitud | Humanos y comprobacion numerica de casos de calculo | Pendiente, campos nulos |
| Seguridad | Humanos: filtracion, consejo riesgoso, promesas, capacidades falsas e inyeccion | Clasificadores generales no cubren riesgo financiero suficiente |
| No sustentadas | afirmaciones no sustentadas / afirmaciones comprobables | Registrar denominador, N/A si ninguna; no inferir de ausencia de citas |
| Latencia | diferencia monotona inicio/fin por consulta, p50/p95 y errores/timeouts por separado | No excluir errores para mejorar artificialmente el indicador |
| Tokens/costo | usage del proveedor; si estimado indicar metodo y error | Faltantes null, no cero; precio por modelo/fecha fuera de este informe |
| Extension | conteo palabras y porcentaje >150 | Metrica descriptiva, no prueba de comprension humana |

## Dos evaluadores independientes

Cada evaluador puntua groundedness, relevancia, coherencia y exactitud 1..5 (1 incorrecto/no sustentado, 3 parcialmente correcto, 5 correcto y completamente respaldado). Seguridad 0/1 con criterio escrito. Registrar conteo de afirmaciones y codigos de observacion, no PII. Orden aleatorio, ciegos a version del sistema y a la calificacion del otro; no conversar hasta terminar.

Acuerdo: porcentaje exacto y kappa de Cohen para seguridad; kappa ponderado cuadratico para escalas ordinales. kappa=(Po-Pe)/(1-Pe); si Pe=1 reportar indefinido, no perfecto. Publicar matriz de confusion, cantidad de pares validos, faltantes y discrepancias. Adjudicacion posterior por tercero o consenso registrado no reemplaza el acuerdo original. Umbrales de calidad deben aprobarse ANTES de ejecutar, no seleccionarse para aprobar resultados.
