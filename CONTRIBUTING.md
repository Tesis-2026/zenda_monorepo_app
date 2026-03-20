# Contributing to Zenda

This document describes the conventions for contributing to this repository.

---

## Branching Strategy

```
main          ← protected, production-ready only
  └── develop ← integration branch, all features merge here first
        └── feature/<short-name>  ← your work branch
```

- **Never commit directly to `main` or `develop`.**
- Branch names use lowercase kebab-case: `feature/auth-integration`, `fix/budget-alert`.
- Open a PR from `feature/*` → `develop`; from `develop` → `main` only at release.

---

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]
```

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change without feature/fix |
| `test` | Adding or updating tests |
| `chore` | Build, CI, tooling changes |

**Examples:**
```
feat(auth): add JWT refresh endpoint
fix(transactions): correct soft-delete ownership check
docs(ml): add feature extraction README
```

---

## Pull Request Process

1. Branch from `develop`, not `main`.
2. Keep PRs focused — one feature or fix per PR.
3. All CI checks must pass before merging.
4. At least one team member must review before merging.
5. Squash and merge into `develop`.

---

## Code Standards

All conventions are defined in [`CLAUDE.md`](CLAUDE.md) and the `skills/` directory:

- **Language:** All code, comments, and strings in **English**.
- **Backend:** Follow NestJS module pattern — controller → service → DTOs.
- **Frontend:** Feature-based structure under `lib/features/`, Riverpod state management.
- **ML:** Document every feature variable and its calculation.
- **No `any`** in TypeScript. No type assertions.
- **No mocking the database** in integration tests.

---

## Environment Setup

See [`SETUP.md`](SETUP.md) for detailed instructions.

---

## Questions

Open an issue on GitHub or contact the team directly.
