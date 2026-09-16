# AGENTS.md

## Source of truth

The repository is the source of truth.

Before modifying code:

1. Read `AGENTS.md`.
2. Read `docs/ARCHITECTURE.md`.
3. Read `docs/AI_HANDOFF.md`.
4. Run `git status`.
5. Review the current diff before changing existing work.

## Development rules

- Preserve existing functionality.
- Do not rewrite working code only for stylistic reasons.
- Prefer focused and minimal changes.
- Keep frontend and backend contracts aligned.
- Follow the architecture documented in `docs/ARCHITECTURE.md`.
- Run relevant tests after changes.
- Run build/compilation when applicable.
- Do not silently remove changes made by another agent.
- Document important architectural decisions.

## Git safety

Do not use destructive Git commands unless explicitly requested.

Avoid:

- `git reset --hard`
- `git clean -fd`
- blindly restoring modified files
- overwriting another agent's work without reviewing it first

## Handoff

After substantial work, update:

`docs/AI_HANDOFF.md`

Include:

- current objective
- work completed
- remaining work
- files modified
- important decisions
- tests executed
- known issues
- recommended next step