# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. State Management (state)

**Impact:** CRITICAL
**Description:** Riverpod 3 is the single source of truth. Wrong provider types and ref misuse cause stale UI, missed updates, and hard-to-find bugs.

## 2. Navigation (navigation)

**Impact:** HIGH
**Description:** All routing decisions live in the GoRouter configuration. Auth guards, redirects, and data passing follow strict patterns to avoid broken deep links and navigation loops.

## 3. Architecture (architecture)

**Impact:** HIGH
**Description:** Feature-based structure with clear layer separation (widget → provider → repository → data source) keeps the codebase scalable and independently testable.

## 4. Local Storage (storage)

**Impact:** HIGH
**Description:** Choosing the wrong storage mechanism exposes sensitive data. JWTs and credentials must use encrypted storage; preferences use SharedPreferences.

## 5. Performance (performance)

**Impact:** MEDIUM
**Description:** const widgets, provider.select(), and ListView.builder prevent unnecessary rebuilds and keep the app smooth on mid-range Android devices.

## 6. Error Handling (error)

**Impact:** HIGH
**Description:** All three async states (loading, error, data) must be handled. Never swallow exceptions. Never show raw error messages to users.

## 7. Testing (testing)

**Impact:** MEDIUM
**Description:** Override providers in tests, not internals. ProviderContainer for unit tests; ProviderScope overrides for widget tests.
