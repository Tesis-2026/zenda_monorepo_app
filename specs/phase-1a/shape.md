# Shape: Phase 1A — Development Environment Setup

## Decisions

- **`JWT_EXPIRES_IN` corrected to `30d` in `.env.example`** — the previous value was `7d`. US-0102 explicitly specifies a 30-day token lifetime. Leaving the example wrong would cause every developer to start with a misconfigured environment that silently fails the acceptance criteria.

- **CI uses local Prisma version, not global** — `npx prisma generate` in the workflow resolves to the version in `node_modules` (6.x), not any globally installed version. This prevents the Prisma 7.x breaking change (which requires a `prisma.config.ts` file) from failing CI builds on developer machines that have Prisma 7 installed globally.

- **`flutter analyze --no-fatal-infos` rather than `--fatal-infos`** — info-level lint hints (unused imports, unnecessary casts) should not block PRs during active early development. Warnings and errors remain fatal. This will be tightened once the codebase stabilises.

- **No test step in CI yet** — the backend CI job only validates schema and TypeScript compilation. A test step requires a running database and test fixtures. Both will be added in Phase 14. This is an intentional deferral, not a gap.

- **`FCM_SERVER_KEY` added to `.env.example` now rather than Phase 11** — environment variable examples are best set up once so developers know what secrets to provision from the start. Adding it in Phase 11 would require every developer to revisit setup mid-project.

- **`ml/` and `docs/` created as empty placeholder structures** — these folders are referenced in `README.md`, `CONTRIBUTING.md`, and `CLAUDE.md`. Creating them now prevents broken links and makes the intended project structure legible before any ML or architecture work begins.

## Constraints

- The `version` field in the health response must be `"1.0.0"` — hardcoded in the controller; must be updated manually on release. No automated version injection exists in this phase.
- `.env` is gitignored; only `.env.example` is tracked — any secret committed to `.env.example` is a violation. All values in `.env.example` must be placeholders.
- Branch protection rules (main protected, PR required) must be configured manually in GitHub repository settings — they are documented in `CONTRIBUTING.md` but cannot be enforced by files alone.
