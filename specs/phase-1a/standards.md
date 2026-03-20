# Standards Applied: Phase 1A — Development Environment Setup

## API / Controller

- **Health endpoint DTO mirrors response:** `HealthResponseDto` declares exactly the three fields returned by the controller (`status`, `version`, `timestamp`). No extra fields in the response; no undocumented fields. Follows the output schema convention from `skills/platform/platform-backend/`.
- **`@ApiProperty` on every DTO field:** All fields in `HealthResponseDto` are decorated with `@ApiProperty` including example values. Swagger documentation is accurate and does not require manual maintenance.

## CI/CD

- **Separate jobs per sub-project:** Backend and frontend run as independent CI jobs rather than sequential steps. A frontend lint failure does not block a valid backend build and vice versa.
- **Dependency caching enabled:** `actions/setup-node@v4` with `cache: 'npm'` and `cache-dependency-path` set to the backend `package-lock.json`. Reduces install time on repeated runs.
- **`prisma generate` runs before `nest build`:** The Prisma client must be generated from the current schema before TypeScript compilation — otherwise imports from `@prisma/client` fail. This ordering is enforced in the CI step sequence.
