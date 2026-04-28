# Zenda — Documentation

This directory contains architecture documentation, design decisions, and the demo script.

---

## Index

| Document | Description | Status |
|----------|-------------|--------|
| `architecture.md` | System context diagram, component overview | Pending (Phase 16) |
| `database.md` | Entity-relationship diagram, schema notes | Pending (Phase 16) |
| `ai-flow.md` | Azure AI integration flow and API configuration | Pending (Phase 16) |
| `demo-script.md` | 15–20 min demo walkthrough for thesis presentation | Pending (Phase 16) |
| `installation.md` | Step-by-step setup for evaluators | Pending (Phase 16) |
| `technical-decisions.md` | Rationale for key architectural choices | Pending (Phase 16) |

---

## Key Design Decisions (Summary)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Backend framework | NestJS 11 | Structured modules, built-in validation, TypeScript |
| Database | PostgreSQL 15 | Relational integrity, JSONB for flexible fields |
| ORM | Prisma | Type-safe queries, migration management |
| Mobile framework | Flutter | Single codebase for Android, Riverpod state management |
| Auth | JWT (own implementation) | No Firebase dependency for auth, full control |
| AI integration | Azure OpenAI API (GPT-4o-mini) | Predictions, recommendations, anomaly detection |
| Budget model | 50/30/20 rule | Widely known, appropriate for student income levels |
| Currency | PEN only (MVP) | Reduces complexity; target users are in Metropolitan Lima |

---

## Standards Applied

- **ISO 25010** — Software product quality (functionality, reliability, usability, security)
- **ISO 27001** — Information security management
- **IEEE 829** — Test documentation
- **WCAG 2.1 Level AA** — Mobile accessibility
- **Law 29733** — Peruvian personal data protection

---

See also: [`SETUP.md`](../SETUP.md) for environment setup, [`CONTRIBUTING.md`](../CONTRIBUTING.md) for development workflow.
