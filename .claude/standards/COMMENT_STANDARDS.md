# Comment Standards

One principle and the house formats. Everything else (don't restate code, no closing-brace
labels, no changelogs in source, delete commented-out code) is assumed practice.

---

## The Principle

Comments explain **why**, never **what**. Always comment: workarounds (with the condition
for removal), non-obvious business rules, intentional deviations from convention,
"do not change" patterns, and performance-critical code that avoids the obvious approach.
Comment nothing else unless the project's style guide requires doc comments on public APIs.

## House Formats

**Workarounds** — name the external issue and the removal trigger:

```csharp
// WORKAROUND: EF Core 8.0.1 throws on owned types across split queries.
// Fixed in 8.0.3 (dotnet/efcore#31245) — remove .AsNoTracking() after upgrade.
```

**Fix references** — symptom + cause, 1–3 lines, directly above the fixed code:

```csharp
// FIX(ORH-042): GetTrader() returns null during the first server tick before
// registration completes. Previously NullReferenceException on cold start.
```

Use a ticket ID when one exists, otherwise a short tag: `FIX(auth-race)`.

**TODO / FIXME** — always traceable, never bare:

```python
# TODO(PROJ-456): replace linear scan with indexed lookup once search service ships.
# FIXME(james): silently drops malformed records; should dead-letter them. PROJ-789.
```

TODO = planned, code works without it. FIXME = wrong but tolerable. A vague `# TODO: fix
later` is comment debt — give it a ticket, a version, or a date.

**Do-not-change markers** — honor and write them:

```csharp
// INTENTIONAL: ArrayList, not List<T> — the legacy serializer requires non-generic
// collections. See commit abc1234.
```

**Performance comments** — only on code that was actually optimized, citing the measurement
(see PERFORMANCE_GUIDELINES.md §Documentation).

## Maintenance

A stale comment is worse than none: when touching code, update or delete adjacent comments
that no longer match. During upgrades, audit WORKAROUND/TODO comments whose trigger
condition has been met.
