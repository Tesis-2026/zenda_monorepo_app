# Zenda — Documentation

This directory contains the project's architecture artifacts, audit and refactor tracking, and the canonical schema. It is the source of truth for "how the system is designed" and "what work is in flight".

For setup and contribution rules, see the repo root:
[`SETUP.md`](../SETUP.md) · [`CONTRIBUTING.md`](../CONTRIBUTING.md) · [`CLAUDE.md`](../CLAUDE.md)

---

## Index

### Active tracking (read first when joining the project)

| Document | Description |
|----------|-------------|
| [`architecture-compliance-plan.md`](architecture-compliance-plan.md) | Refactor batch tracker (B1–B32+). Status per batch, PR refs, recommended execution order across 4 tiers. **Living document — updated after every batch ships.** |
| [`audit-issues.md`](audit-issues.md) | Findings tracker: P1 (thesis validity), S (security), AC (acceptance criteria), UX, ARCH (architecture debt), GAP (phase-level gaps). Fix log at the bottom. |
| [`project-status.md`](project-status.md) | Phase- and user-story-level execution status. **English; primary status doc.** |
| [`project-status-spanish.md`](project-status-spanish.md) | Spanish summary mirror for non-English readers. |

### Data model

| Document | Description |
|----------|-------------|
| [`zenda-erd.dbml`](zenda-erd.dbml) | Logical ERD in DBML format — paste into [dbdiagram.io](https://dbdiagram.io). Authoritative schema doc. |
| [`zenda-erd-conceptual.dbml`](zenda-erd-conceptual.dbml) | Conceptual ERD (high-level entities + relations, no FK or technical details). |
| [`zenda-erd-conceptual.mmd`](zenda-erd-conceptual.mmd) | Same conceptual ERD as Mermaid (renders inline on GitHub). |
| [`zenda-schema.sql`](zenda-schema.sql) | Auto-generated DDL from the Prisma schema. Regenerate with `npx prisma migrate diff --from-empty --to-schema-datamodel zenda_backend_app/prisma/schema.prisma --script > docs/zenda-schema.sql` (B15). |

### Architecture diagrams

| Document | Description |
|----------|-------------|
| [`zenda.dsl`](zenda.dsl) | Structurizr DSL model — full container/component/relation view. |
| [`zenda-layered-architecture.drawio`](zenda-layered-architecture.drawio) | Backend DDD layers (interface → application → domain ← infrastructure). |
| [`zenda-logical-architecture.drawio`](zenda-logical-architecture.drawio) | Logical container view (Flutter app, NestJS API, Postgres, Azure OpenAI). |
| [`zenda-physical-architecture.drawio`](zenda-physical-architecture.drawio) | Deployment topology. |

### Thesis archive (Spanish, for academic deliverables)

| Document | Description |
|----------|-------------|
| [`thesisDocs/P202616_Product_Backlog_V1.md`](thesisDocs/P202616_Product_Backlog_V1.md) | Initial product backlog. |
| [`thesisDocs/P202616_Epicas_HU_V1.md`](thesisDocs/P202616_Epicas_HU_V1.md) | Epics and user-story summary. |
| [`thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md`](thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md) | Full user stories + acceptance criteria. |

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

For deeper architectural decisions per refactor batch, see each PR description and the per-batch row in [`architecture-compliance-plan.md`](architecture-compliance-plan.md).

---

## Standards Applied

- **ISO 25010** — Software product quality (functionality, reliability, usability, security)
- **ISO 27001** — Information security management
- **IEEE 829** — Test documentation
- **WCAG 2.1 Level AA** — Mobile accessibility
- **Ley 29733** — Peruvian personal data protection (consent in `User.consentGiven` + audit trail in `AuditLog`)

---

## Regenerating documentation

| What | Command |
|------|---------|
| SQL schema (`zenda-schema.sql`) | `cd zenda_backend_app && npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > ../docs/zenda-schema.sql` |
| Swagger / OpenAPI spec | Boot the backend (`npm run start:dev`) and open `http://localhost:3000/api/docs` |
| Flutter localizations | `cd zenda_fronted_app && flutter gen-l10n` |
