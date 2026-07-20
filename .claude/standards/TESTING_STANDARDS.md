# Testing Standards

The decisions that vary by team — naming, coverage targets, mocking philosophy. Standard
testing craft (AAA, isolation, no sleeps) is assumed knowledge.

---

## 1. Conventions

- **Names describe the scenario**: `MethodName_Scenario_ExpectedResult` (or the project's
  existing pattern). The name alone should make a CI failure meaningful.
- **AAA** (Arrange / Act / Assert), one Act per test, blank-line separated.
- **Test behavior, not implementation.** Survival test: would this pass after an
  internals-only refactor? If no, it's coupled too tightly.
- Test files mirror source structure; shared builders/fixtures in `fixtures/` or `helpers/`.

## 2. Coverage Targets

Coverage is a guide, not a goal — meaningful assertions beat percentage.

| Code type | Target |
|-----------|--------|
| Business logic / domain | 80%+ |
| Utilities / pure functions | 90%+ |
| Controllers / handlers | 70%+ (integration-style) |
| Data access | 70%+ (real DB or in-memory equivalent, not mocked queries) |
| Infrastructure / glue | 60%+ (focus on failure modes) |
| Generated code | skip |

Track branch coverage, not just line. Game mods: pure logic (config parsing, calculations,
ID generation) gets unit tests; Unity/game-loop code is verified in-game — don't build
elaborate mocks of the game engine.

## 3. Mocking Philosophy

- Mock at **architectural boundaries** (DB, HTTP, filesystem, external APIs) and
  **non-determinism** (clock, random) only.
- **Don't mock what you don't own** — wrap third-party APIs in your own abstraction and
  mock that, or integration-test the real thing.
- Prefer the simplest double that works: stub > fake > mock > spy. Verify interactions
  only when the call *is* the contract (audit log, notification).

## 4. Test Data

- Builders/factories with descriptive defaults, not raw constructors with magic values.
- Name data by purpose: `expiredToken`, `adminUser`, `emptyCart`.
- Realistic shapes: `"Jean-Pierre O'Brien"` catches bugs `"test"` never will.

## 5. E2E

Happy path + critical error paths for key user journeys only — don't re-test unit
coverage through the UI. Full suite under 5 minutes. No fixed sleeps; poll or await
conditions. Quarantine flaky tests immediately.
