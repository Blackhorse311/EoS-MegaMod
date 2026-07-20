# Error Handling Standards

The decision rules for this codebase family. Standard implementation patterns (guard
clauses, exception chaining, context managers) are assumed knowledge — not restated here.

---

## 1. Fail Fast vs Degrade Gracefully

| Situation | Strategy |
|-----------|----------|
| Startup / initialization (missing config, bad state, incompatible deps) | **Fail fast** — a server that starts broken is worse than one that refuses to start |
| API boundary / invalid input / data validation | **Fail fast** — reject at the edge, never let bad data propagate |
| External call, transient failure (timeout, 429, 5xx, network) | **Degrade** — retry with exponential backoff + jitter, fall back to cache/default |
| External call, permanent failure (400, 401, 403, 404) | **Fail fast** — don't retry what retrying can't fix |
| Non-critical feature fails | **Degrade** — disable the feature, log a warning, keep the app running (especially in game mods: never take the game down for a mod feature) |

Retry defaults: base 100–500ms, exponential with jitter, max 3–5 attempts, cap 30–60s.
Circuit-break after ~5 consecutive failures. Non-idempotent operations need idempotency
keys before any retry.

## 2. Error Messages

- **User-facing**: what happened + what to do, no jargon, no stack traces, no internals.
- **Developer-facing**: what + where + why + context (IDs, values, correlation ID). Template:
  `[WHAT] in [WHERE]. [WHY]. [CONTEXT for debugging].`
- Same incident, both audiences: clean message out, full detail to the log, matched by
  correlation ID.

## 3. Hard Rules

1. No empty catch blocks, ever. Intentionally ignored errors get a comment + Debug-level log.
2. Catch-and-rethrow must add context (a more specific exception with IDs) or not exist.
3. Log where the error is *handled*, throw where it's *propagated* — never both for the same error.
4. Exceptions are not control flow — use `TryGet`-style APIs for expected cases.
5. Never log secrets, tokens, passwords, or PII. Sanitize request bodies before logging.
6. Every external call has a timeout.

## Log Levels (all languages)

| Level | Meaning |
|-------|---------|
| ERROR | Operation failed; needs human attention |
| WARN | Unexpected but handled (retry fired, fallback used) |
| INFO | Significant business events; the happy-path audit trail |
| DEBUG | Diagnostic detail for development |
| TRACE | High-volume firehose, temporarily enabled only |
