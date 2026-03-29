# ML — Prediction and Recommendation Models

This folder will contain the Python models for:
- Monthly income/expense prediction (scikit-learn)
- Spending anomaly detection
- Budget recommendation engine

## Structure (planned)

```
ml/
├── data/           # Sample/training data (gitignored)
├── models/         # Serialized model files (gitignored)
├── notebooks/      # Exploratory notebooks
├── src/
│   ├── features.py     # Feature extraction from transaction history
│   ├── predict.py      # Prediction model (RandomForest / LinearRegression)
│   └── recommend.py    # Rule-based recommendation engine
└── requirements.txt
```

## Setup

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Status
Phase 8 (ML Prediction) — not yet implemented.
