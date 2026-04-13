# Contributing to Zenda

## Branching Model

```
main          — stable, protected; merged via PR only
develop       — integration branch
feature/<id>  — new features (e.g. feature/phase-2a-auth-profile)
fix/<id>      — bug fixes
chore/<id>    — tooling, deps, docs
```

All work branches off `develop`. PRs target `develop`. `develop` → `main` is a release merge.

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(auth): add refresh token endpoint
fix(transactions): prevent future-dated transactions
chore(deps): upgrade NestJS to 11.1
docs(contributing): add branching model
```

Types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `ci`

## Pull Request Process

1. Branch off `develop`
2. Write code following the conventions in `CLAUDE.md`
3. Ensure `npm run build` passes (backend) and `flutter analyze` passes (frontend)
4. Open a PR targeting `develop` with a description of what and why
5. At least one approval required before merge
6. Squash and merge

## Code Standards

- All code, comments, and variable names in **English**
- Backend: NestJS conventions, DDD architecture, Prisma enums (no string literals)
- Frontend: Riverpod Notifier pattern, GoRouter, feature-based folders
- Currency: PEN (S/) only
