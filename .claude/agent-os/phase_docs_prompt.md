# Agent Prompt: Generate Phase Documentation After Roadmap Completion

## When to Execute This

This prompt runs **after every roadmap phase is fully implemented and verified**.  
Do not generate documentation for a phase that is partially complete — all tasks in the phase must be done, all tests passing, and all endpoints working before this runs.

---

## Phase 0 — Full Phase Retrospective

Before writing a single documentation file, perform a complete retrospective of everything built during this phase.

For every file created or modified during the phase, record:
- File path
- What it is (entity, service, controller, filter, DTO, test, config, enum, etc.)
- What it does in plain business terms
- Whether it was created new or modified from a previous state
- Which user story or task it fulfills (e.g. US-101, US-102)

Additionally record:
- Every architectural decision made and why (e.g. "state machine in entity, not service — because transitions are entity-owned behavior")
- Every constraint enforced (e.g. "REVOKED agents cannot be reactivated")
- Every standard applied (entity patterns, service layer rules, security rules, API conventions)
- Every test file produced and how many tests it contains

Do not write any file until this retrospective is complete and internally verified.

---

## Phase 1 — Create the Phase Folder

Create the following folder inside the `.claude/.agent-os/specs/` directory:

```
specs/{phase-name}/
```

Where `{phase-name}` matches the exact phase identifier used in the roadmap (e.g. `phase-1a`, `phase-2b`). Use lowercase kebab-case always.

Create exactly **four files** inside this folder. Nothing more, nothing less.

---

## File 1 — `spec.md`

The specification document. Written as if someone who has never seen this phase needs to fully understand what was built and why.

**Required sections, in this order:**

```markdown
# Phase {ID}: {Phase Title}

## Context
[2–4 sentences explaining the business problem this phase solves.
What did not exist before this phase? What does the platform now support that it did not?
Reference the roadmap user stories (US-XXX).]

## Tasks Completed
[Numbered list of every deliverable built in this phase.
One line per item. Use the same language as the roadmap.]

## What Was Built

### Entity: `ClassName`
[For each entity: describe its purpose, its key fields, and its behavior.
If it has a state machine, diagram it explicitly:]

```
STATE_A → STATE_B   (method name, condition)
STATE_B → STATE_C   (method name, condition)
```

### Service: `ClassName`
[For each service: describe what business operations it owns.]

### REST API
[Table format:]

| Method | Path | Description |
|--------|------|-------------|
| POST   | /api/v1/... | What it does, what it returns |

### Security / Filters (if applicable)
[Describe any filter, interceptor, or security component built.
Include: what it intercepts, how it validates, what it puts in the SecurityContext,
and what it returns on failure.]
```

**Rules:**
- No code snippets in this file — prose and tables only
- Every user story referenced in the roadmap for this phase must appear somewhere in this file
- State machines must be diagrammed in the ASCII format shown above — never described in prose only

---

## File 2 — `shape.md`

The architectural decisions document. Written for future developers and AI agents who need to understand *why* things are built the way they are — not just what was built.

**Required sections, in this order:**

```markdown
# Shape: Phase {ID} — {Phase Title}

## Decisions
[Bullet list. Each decision follows this exact format:]
- **Decision title** — explanation of what was decided and the concrete reason why.
  Include what the alternative was and why it was rejected if relevant.

## Constraints
[Bullet list of every hard business or technical constraint enforced in this phase.
Each constraint must be a falsifiable statement — something that can be tested.
Example: "REVOKED agents cannot be reactivated (permanent)" — not "agents have lifecycle rules"]
```

**Rules:**
- Every decision in this file must be non-obvious — do not document things that are self-evident from reading the code
- Every constraint must map to a guard, validation, or test that enforces it — if it cannot be verified in the code, it is not a constraint, it is a wish
- Do not repeat information from `spec.md` — shape is about *why*, spec is about *what*

---

## File 3 — `references.md`

The file map. A complete index of every file touched during this phase so any agent or developer can immediately locate what they need.

**Required sections, in this order:**

```markdown
# References: Phase {ID} — {Phase Title}

## Key Files

| File | Change |
|------|--------|
| `path/to/File.java` | Created — [one line description] |
| `path/to/Other.java` | Modified — [what changed] |

## Test Files

| File | Tests |
|------|-------|
| `path/to/SomeTest.java` | N tests — [what they cover] |

## Standards Applied
[Bullet list of every agent-os standard document referenced during this phase.
Use the exact file path as it exists in the agent-os folder.]
```

**Rules:**
- Every file created or modified during this phase must appear in the Key Files table — no exceptions
- Every test file must appear in the Test Files table with an accurate test count
- The standards list must only include standards that were actually applied — do not list standards that were read but not followed
- Use the relative path from the project root for all file paths

---

## File 4 — `standards.md`

The standards compliance record. Documents how each layer of the application was built in this phase relative to the project's coding standards.

**Required sections — include only sections relevant to what was built in this phase:**

```markdown
# Standards Applied: Phase {ID} — {Phase Title}

## Entity Patterns
[How entities in this phase follow the project's entity standards.
List specific decisions: PK type, enum storage strategy, soft-delete approach,
constraint naming, Lombok policy, etc.]

## Service Layer
[How services follow the project's service layer standards.
List: injection style, transaction strategy, exception types used, where state logic lives.]

## API / Controller
[How controllers follow the project's API standards.
List: base path, response types, status codes used, JSON naming convention.]

## Security (if applicable)
[How any security component follows the project's security standards.]

## Testing
[How tests follow the project's testing standards.
List: test framework used, assertion library, test structure pattern, Spring context usage policy.]
```

**Rules:**
- Do not write generic statements like "followed best practices" — every entry must be a specific, verifiable claim
- If a standard was intentionally deviated from, document it explicitly with the reason
- Do not include a section for a layer that was not touched in this phase (e.g. omit Security if no security work was done)

---

## Phase 2 — Verification Before Committing the Files

After all four files are written, verify:

1. **`spec.md`** covers every user story in the phase roadmap — nothing is undocumented
2. **`shape.md`** contains no decisions that are already obvious from reading `spec.md`
3. **`references.md`** file table matches the actual files on disk — no phantom entries, no missing files
4. **`standards.md`** contains no section for a layer not touched in this phase
5. The folder name matches the phase identifier exactly as used in the roadmap
6. All four files are present — no more, no less

---

## Output

```
specs/
└── {phase-name}/
    ├── spec.md
    ├── shape.md
    ├── references.md
    └── standards.md
```

No other files. No `README.md`, no `changelog.md`, no additional files unless the roadmap explicitly defines them as part of the phase documentation standard.
