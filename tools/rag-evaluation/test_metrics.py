import unittest
from evaluate import retrieval_metrics


class RetrievalTests(unittest.TestCase):
    def test_rank_and_recall(self):
        result = retrieval_metrics(['a', 'b'], ['x', 'a', 'a'])
        self.assertEqual(result, {'context_precision': 0.5, 'context_recall': 0.5})

    def test_missing_references_not_fake_perfect_score(self):
        self.assertEqual(retrieval_metrics([], []), {'context_precision': None, 'context_recall': None})

    def test_no_retrieval(self):
        self.assertEqual(retrieval_metrics(['a'], []), {'context_precision': 0.0, 'context_recall': 0.0})


if __name__ == '__main__':
    unittest.main()
