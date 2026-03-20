# Zenda — ML Pipeline

This directory contains the Python machine learning pipeline for Zenda's AI-powered predictions and recommendations.

---

## Overview

The ML pipeline is responsible for:

1. **Feature extraction** — transforms raw transaction data into model features per user per month
2. **Model training** — evaluates and trains expense/income prediction models
3. **Model validation** — verifies accuracy ≥ 80% before deployment
4. **Model export** — exports to TFLite for on-device inference or REST endpoint for server inference
5. **Re-training** — monthly pipeline that re-trains with new real user data

---

## Directory Structure

```
ml/
├── data/               # Datasets (gitignored — generated or downloaded)
│   ├── synthetic/      # Synthetic training data for bootstrapping
│   └── processed/      # Processed feature CSVs
├── models/             # Trained model artifacts (gitignored)
├── notebooks/          # Exploratory analysis (Jupyter)
├── src/
│   ├── features.py     # Feature extraction pipeline
│   ├── train.py        # Model training and selection
│   ├── validate.py     # Model validation (run: python ml/validate.py)
│   └── export.py       # TFLite export
├── requirements.txt    # Python dependencies
└── README.md
```

---

## Setup

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

---

## Models Evaluated

Per [US-0703](../.claude/agent-os/product/user_stories.md):

| Model | Notes |
|-------|-------|
| Linear Regression | Baseline |
| Random Forest | Strong for tabular data |
| XGBoost | Main candidate |
| LSTM | For sequential patterns |

**Target metric:** Predict next month's total spending with accuracy ≥ 80% (defined as `1 - |predicted - actual| / actual`).

---

## Feature Set

Per [US-0701](../.claude/agent-os/product/user_stories.md):

| Feature | Description |
|---------|-------------|
| `total_spending_per_category_per_month` | Spending per category per month |
| `total_income_per_month` | Total income per month |
| `expense_income_ratio` | Expense / income ratio |
| `transaction_frequency` | Number of transactions per month |
| `income_variability` | Std dev of monthly income |
| `peak_spending_day_of_week` | Day with highest average spend |
| `top_3_categories` | Top 3 expense categories by amount |

---

## Status

- [ ] Feature extraction pipeline (`src/features.py`)
- [ ] Synthetic dataset generation (`data/synthetic/`)
- [ ] Model training and selection (`src/train.py`)
- [ ] Model validation (`src/validate.py`)
- [ ] TFLite export (`src/export.py`)
- [ ] Re-training pipeline

**Phase 7–8 of the roadmap.** Implementation begins after core transactional features are complete.
