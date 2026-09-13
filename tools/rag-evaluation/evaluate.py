"""Offline validation by default. Cloud evaluation requires explicit --allow-cloud.
Only approved synthetic captures belong here. Never use participant chat logs.
"""
import argparse
import json
import os
from pathlib import Path


def validate(rows, ready=False):
    if not 100 <= len(rows) <= 150:
        raise ValueError('Expected 100-150 cases')
    if len({r['id'] for r in rows}) != len(rows):
        raise ValueError('Duplicate case IDs')
    for row in rows:
        if row.get('synthetic') is not True or not row.get('query'):
            raise ValueError('Only synthetic nonempty queries allowed')
        if ready and (row.get('approved') is not True or not all(row.get(k) for k in ('reference_version', 'ground_truth', 'response', 'context', 'model_version'))):
            raise ValueError('Missing human approval, references, model version or captured output')


def retrieval_metrics(gold, retrieved):
    """Binary human relevance, ordered unique chunk IDs. No gold => not applicable."""
    gold = set(gold)
    ranked = list(dict.fromkeys(retrieved))
    if not gold:
        return {'context_precision': None, 'context_recall': None}
    hits, weighted = 0, 0.0
    for rank, chunk in enumerate(ranked, 1):
        if chunk in gold:
            hits += 1
            weighted += hits / rank
    return {'context_precision': weighted / hits if hits else 0.0,
            'context_recall': hits / len(gold)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('dataset', type=Path)
    parser.add_argument('--allow-cloud', action='store_true')
    parser.add_argument('--output', type=Path, default=Path('results'))
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.dataset.read_text(encoding='utf-8').splitlines() if line.strip()]
    validate(rows, ready=args.allow_cloud)
    if not args.allow_cloud:
        print(json.dumps({'cases': len(rows), 'mode': 'offline_validation', 'model_calls': 0, 'evaluation_scores': None}))
        return

    # Separate judge deployment; credentials never serialized to reports.
    from azure.ai.evaluation import evaluate, GroundednessEvaluator, RelevanceEvaluator, CoherenceEvaluator, SimilarityEvaluator
    config = {'azure_endpoint': os.environ['EVAL_AZURE_ENDPOINT'], 'api_key': os.environ['EVAL_AZURE_KEY'], 'azure_deployment': os.environ['EVAL_AZURE_DEPLOYMENT']}
    args.output.mkdir(parents=True, exist_ok=True)
    evaluators = {'groundedness': GroundednessEvaluator(config), 'relevance': RelevanceEvaluator(config), 'coherence': CoherenceEvaluator(config), 'similarity': SimilarityEvaluator(config)}
    mappings = {
        'groundedness': ['query', 'response', 'context'],
        'relevance': ['query', 'response'],
        'coherence': ['query', 'response'],
        'similarity': ['query', 'response', 'ground_truth'],
    }
    evaluate(data=str(args.dataset), evaluators=evaluators,
             evaluator_config={key: {'column_mapping': {col: '${data.' + col + '}' for col in cols}} for key, cols in mappings.items()},
             output_path=str(args.output / 'azure-evaluation.json'))
    measurements = []
    for row in rows:
        measurements.append({'id': row['id'], **retrieval_metrics(row['gold_context_ids'], row['retrieved_context_ids']),
                             'latency_ms': row.get('latency_ms'), 'input_tokens': row.get('input_tokens'), 'output_tokens': row.get('output_tokens'),
                             'word_count': len(row['response'].split()), 'accuracy_human': None, 'safety_human': None, 'unsupported_rate_human': None})
    (args.output / 'measurements.json').write_text(json.dumps(measurements, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
