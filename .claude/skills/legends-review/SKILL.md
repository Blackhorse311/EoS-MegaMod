---
name: legends-review
description: Legends Code Review — five coding legends (Torvalds, Knuth, Kernighan, Fagan, Metz) review code in parallel on the Fable model via the Workflow tool, findings are deduped, Critical findings adversarially verified, and a unified in-character report is delivered. Use when the user asks for a "Legends Code Review" or "legends review".
argument-hint: [files, directory, or blank for current changes]
---

# Legends Code Review

Multi-agent review by a panel of five coding legends. Runs as a Workflow: 5 parallel reviewers → dedup → adversarial verification of Critical findings → synthesized report.

## Step 1 — Scope

Resolve a concrete list of source files to review:

1. If the user named files or directories, use those (expand directories to source files).
2. Otherwise, in a git repo, use the changed files: `git diff --name-only HEAD` plus staged and untracked source files.
3. Otherwise, ask what to review.

Skip binaries, lockfiles, and generated code. If the list is empty, say so and stop.

## Step 2 — Run the workflow

Invoke the Workflow tool with the script below, passing:

```json
args: { "files": ["<path1>", "<path2>"], "context": "<one-line project description from CLAUDE.md, or empty string>" }
```

> **Model note**: reviewers are pinned to `fable` (Mythos tier, above Opus). If `fable` is unavailable in this environment, change `model: 'fable'` to `model: 'opus'` before invoking.

```js
export const meta = {
  name: 'legends-code-review',
  description: 'Five coding legends review code in parallel; findings deduped, Criticals adversarially verified',
  phases: [
    { title: 'Review', detail: 'five legends review in character', model: 'fable' },
    { title: 'Verify', detail: 'adversarial check of Critical findings' },
  ],
}

const files = args.files
const projectContext = args.context || 'No additional project context provided.'

const CATEGORIES = `
1. Syntax Errors - malformed code, typos, missing tokens
2. Runtime Errors - null refs, division by zero, uninitialized state
3. Logical (Semantic) Errors - code that compiles but does the wrong thing
4. Unhandled Edge Cases - missing boundary checks, race conditions, empty collections
5. Environmental Differences - platform assumptions, version-specific APIs, path issues
6. Security Vulnerabilities - injection, unsafe deserialization, exposed secrets
7. Poor Coding Practices - dead code, copy-paste, magic numbers, god classes
8. External Factors - dependency risks, API deprecation, compatibility concerns`

const LEGENDS = [
  {
    name: 'Linus Torvalds',
    persona: "Brutally honest, no-nonsense creator of Linux and git. Zero tolerance for unnecessary complexity, bloated abstractions, or 'enterprise' patterns. Calls out bad code in colorful language. Focus: performance, simplicity, proper resource management, 'does this actually need to exist?'. Hates over-engineering, cargo-cult patterns, premature abstraction. Channel his famous mailing-list review style.",
  },
  {
    name: 'Donald Knuth',
    persona: "Meticulous, mathematical, encyclopedic father of algorithm analysis. Reviews code as if writing The Art of Computer Programming. Focus: algorithmic correctness, computational complexity, edge cases in logic, mathematical precision, naming clarity. Suggests literate-programming-style improvements. He famously pays $2.56 for every bug found in his books — bring that attention to detail.",
  },
  {
    name: 'Brian Kernighan',
    persona: "Bell Labs elegance. Co-author of The C Programming Language and The Practice of Programming. Values clarity, simplicity, and code that reads like well-written prose. Focus: readability, clean interfaces, minimal API surface, 'say what you mean' naming, removing unnecessary cleverness.",
  },
  {
    name: 'Michael Fagan',
    persona: "IBM's inspection methodology pioneer; invented formal code inspection. Systematic, process-driven, thorough, checklist mentality. Focus: completeness of error handling, boundary conditions, data validation, conformance to specifications, defect categorization by severity. Apply Fagan Inspection rigor.",
  },
  {
    name: 'Sandi Metz',
    persona: "Practical OOP expert, author of POODR. Warm but firm. Believes in small objects, single responsibility, and code that's easy to change. Focus: class/method size, dependency management, SOLID adherence, test coverage gaps, 'is this easy to change later?'. Apply her famous rules (5 lines per method, 100 lines per class) pragmatically, not dogmatically.",
  },
]

const FINDINGS = {
  type: 'object',
  required: ['legend', 'findings'],
  properties: {
    legend: { type: 'string' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['file', 'line', 'category', 'severity', 'confidence', 'issue', 'explanation', 'fix'],
        properties: {
          file: { type: 'string' },
          line: { type: 'number' },
          category: { type: 'string', enum: ['syntax', 'runtime', 'logic', 'edge-case', 'environment', 'security', 'practice', 'external'] },
          severity: { type: 'string', enum: ['Critical', 'Warning', 'Style'] },
          confidence: { type: 'number', description: '0-100' },
          issue: { type: 'string', description: 'one-line summary of what was found' },
          explanation: { type: 'string', description: "why it matters, written in the legend's authentic voice" },
          fix: { type: 'string', description: 'suggested code change or approach' },
        },
      },
    },
  },
}

const VERDICT = {
  type: 'object',
  required: ['isReal', 'reasoning'],
  properties: {
    isReal: { type: 'boolean' },
    reasoning: { type: 'string' },
  },
}

phase('Review')
const reviews = await parallel(LEGENDS.map(l => () => agent(
`You are ${l.name}, conducting a code review fully IN CHARACTER.

PERSONA: ${l.persona}

If web access is available, briefly research ${l.name}'s reviewing style and famous principles first so your voice and priorities are authentic.

PROJECT CONTEXT: ${projectContext}

Read and review EVERY file listed below, in full. Evaluate ALL eight categories:${CATEGORIES}

FILES TO REVIEW:
${files.join('\n')}

Only report issues you are at least 50/100 confident about. Cite the exact file and line. Severity: Critical (security hole, crash, data loss), Warning (bug, bad practice, potential issue), Style (readability, naming, minor improvement). Write each explanation in your authentic voice. Set legend to "${l.name}".`,
  { label: `legend:${l.name}`, phase: 'Review', model: 'fable', schema: FINDINGS }
)))

// Barrier is intentional: dedup needs every legend's findings before verification.
const merged = new Map()
const rank = { Critical: 3, Warning: 2, Style: 1 }
for (const r of reviews.filter(Boolean)) {
  for (const f of r.findings) {
    const k = `${f.file}|${f.line}|${f.category}`
    const prev = merged.get(k)
    if (!prev) {
      merged.set(k, { ...f, legends: [r.legend], voices: [{ legend: r.legend, explanation: f.explanation }] })
      continue
    }
    prev.legends.push(r.legend)
    prev.voices.push({ legend: r.legend, explanation: f.explanation })
    if (rank[f.severity] > rank[prev.severity]) prev.severity = f.severity
    if (f.confidence > prev.confidence) prev.confidence = f.confidence
  }
}
const findings = [...merged.values()]
log(`${findings.length} unique findings from ${reviews.filter(Boolean).length} legends`)

phase('Verify')
const criticals = findings.filter(f => f.severity === 'Critical')
const verdicts = await parallel(criticals.map(f => () => agent(
`Adversarially verify this Critical code-review finding. Read the actual code at the cited location and try to REFUTE it — assume it is wrong until the code proves otherwise. If still uncertain after reading the code, set isReal=false.

FINDING: [${f.category}] ${f.file}:${f.line} — ${f.issue}
CLAIM: ${f.voices[0].explanation}
PROPOSED FIX: ${f.fix}`,
  { label: `verify:${f.file}:${f.line}`, phase: 'Verify', schema: VERDICT }
).then(v => ({ key: `${f.file}|${f.line}|${f.category}`, verdict: v }))))

const refutedKeys = new Map()
for (const v of verdicts.filter(Boolean)) {
  if (v.verdict && !v.verdict.isReal) refutedKeys.set(v.key, v.verdict.reasoning)
}
const keyOf = f => `${f.file}|${f.line}|${f.category}`
const confirmed = findings.filter(f => !(f.severity === 'Critical' && refutedKeys.has(keyOf(f))))
const refuted = findings
  .filter(f => f.severity === 'Critical' && refutedKeys.has(keyOf(f)))
  .map(f => ({ ...f, refutation: refutedKeys.get(keyOf(f)) }))

return { confirmed, refuted, legendCount: reviews.filter(Boolean).length }
```

## Step 3 — Report

From the returned `{ confirmed, refuted }`:

- Group confirmed findings by severity: **Critical → Warning → Style**.
- For each finding: `file:line`, category, confidence, which legend(s) flagged it, the explanation in the legend's voice (pick the sharpest voice when several flagged it), and the fix.
- If any Criticals were refuted, add a short **"Withdrawn after verification"** footnote listing them with the refuting reasoning.
- Close with a one-line verdict from each legend, in character.
- If fewer than 5 legends returned results (nulls), note which were lost.

## Fallback (no Workflow tool)

If the Workflow tool is unavailable, run the same five personas as parallel Agent-tool calls (`subagent_type: "general-purpose"`, `model: "fable"`, or `opus` if fable is unavailable), each given their persona, the eight categories, and the file list. Then dedup and compile the report manually using the Step 3 format.
