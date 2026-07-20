# Performance Guidelines

The philosophy and the local tooling decisions. The anti-pattern catalog (N+1, string
concat in loops, missing timeouts, layout thrashing) is assumed knowledge.

---

## 1. Cardinal Rule: Measure First

Never optimize without a baseline number, and never keep an "optimization" that didn't
measurably improve it. Workflow: observe → measure → baseline → identify (the profiler
decides, not intuition) → optimize → verify → document.

**Exception — obvious inefficiency needs no profiler**: N+1 queries, loading a 500MB file
into memory when streaming works, blocking the main thread on network I/O, per-frame
allocations in a game loop. If a junior dev would call it obviously wasteful, fix it on
sight. Everything subtler waits for a measurement.

Do NOT optimize: unprofiled code that "looks slow", startup-only paths, or anything where
the readability cost exceeds a measured gain.

## 2. Preferred Profilers (installed / first choice)

| Language | Reach for |
|----------|-----------|
| C# / .NET | BenchmarkDotNet (microbenchmarks), Visual Studio Profiler, dotnet-counters/dotnet-trace (live/production) |
| Python | cProfile (built-in), py-spy (attach to running process), timeit |
| TS / JS | Chrome DevTools Performance/Memory, `performance.mark`, Lighthouse (web) |
| Unity mods | Unity Profiler when available; otherwise frame-time logging around the suspect code — GC allocations per frame are the usual killer |

## 3. Documenting Optimized Code

Code that sacrifices clarity for speed MUST carry a comment with: what metric was
unacceptable, the before/after measurement, and the date measured.

```csharp
// PERFORMANCE: ArrayPool + Span instead of string.Split + LINQ in the import pipeline.
// Measured 2026-03-15: 2.4GB -> 340MB allocations, 18s -> 4.2s for 500K rows.
```

Unoptimized code gets no performance comments — normal code is just normal.

## 4. Model Tiers and Review Effort (Claude Code)

Two levers for performance-sensitive agent work:

- **Model tier** (Agent tool `model` param): `haiku` < `sonnet` < `opus` < `fable`. Use
  `fable` (fallback `opus`) for Legends reviews, hard root-cause hunts, and critical perf
  investigations. `/fast` = Opus-level intelligence with lower latency, not a downgrade.
- **Review effort** (`/code-review` arg): `low`/`medium` fewer high-confidence findings,
  `high`/`max` broader coverage, `ultra` multi-agent cloud review of the branch.

Neither lever replaces profiling — a Fable agent guessing at bottlenecks is still guessing.
