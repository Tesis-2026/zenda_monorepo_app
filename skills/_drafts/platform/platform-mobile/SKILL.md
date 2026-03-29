---
name: platform-mobile
description: Flutter mobile development patterns — Riverpod 3 state management, GoRouter
  17 navigation, repository architecture, API integration, and local storage. Use
  when building or reviewing any Flutter screen, provider, route, or service.
metadata:
  category: platform
  extends: core-coding-standards
  tags:
  - flutter
  - dart
  - riverpod
  - mobile
  - gorouter
  status: ready
  version: 1
---

# Principles

- State lives in providers, not in widgets — widgets only read and display
- Screens depend on providers; providers depend on repositories; repositories depend on data sources
- Every navigation decision is declared in the router, never triggered imperatively from business logic
- Fail visibly — never swallow async errors silently; always surface loading, error, and data states

# Rules

See [rules index](rules/_sections.md) for detailed patterns.

## Examples

### Positive Trigger

User: "Add a transaction history screen that loads from the API with loading and error states."

Expected behavior: Use `platform-mobile` guidance — create an `AsyncNotifierProvider`, a repository, implement `.when(loading, error, data)` in the widget, use `GoRoute` in the router file.

### Non-Trigger

User: "Design the color palette for the dashboard."

Expected behavior: Do not prioritize `platform-mobile`; this is a design/theme task.

## Troubleshooting

### Skill Does Not Trigger

- Error: skill not selected when building Flutter screens or providers.
- Cause: Request wording doesn't mention Flutter/Riverpod/GoRouter explicitly.
- Solution: Rephrase with "screen", "provider", "route", "Riverpod", or "Flutter".

### Guidance Conflicts With Another Skill

- Error: `core-coding-standards` and `platform-mobile` conflict on architecture.
- Cause: `platform-mobile` is the more specific skill for Flutter work.
- Solution: `platform-mobile` takes precedence for all Flutter-specific patterns.

## Workflow

1. Identify the layer: state (provider/notifier), navigation (router), data (repository/model), or UI (widget/screen).
2. Apply the section rules for that layer.
3. Validate: no business logic in widgets, no `ref.watch` in callbacks, no hardcoded route strings.
