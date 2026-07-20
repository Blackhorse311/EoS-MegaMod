# Code Review Guidelines

The review taxonomy, scoring, and reporting format used by `/quick-review`, `/full-review`,
and `/legends-review`. Every finding must be traceable to a rule ID here.

---

## 1. Philosophy

1. **Do No Harm** — functional, readable code that violates no documented standard is left alone.
2. **Minimal Change** — flag what's broken; no drive-by refactors of adjacent code.
3. **Consistency Over Perfection** — when existing project patterns conflict with this
   document, flag as Style, don't silently "correct".
4. **Evidence-Based** — every finding carries specific reasoning and a 0–100 confidence
   score. Below 50: discard. 50–70: state the uncertainty. Above 70: state the evidence.
5. **Prevent Circular Work** — see §5.

## 2. Categories (priority order)

### SEC — Security
| ID | Description |
|----|-------------|
| SEC-001 | Injection (SQL, command, LDAP, XPath) |
| SEC-002 | XSS (stored, reflected, DOM) |
| SEC-003 | Exposed secrets in source |
| SEC-004 | Unsafe deserialization of untrusted data |
| SEC-005 | Broken authentication / session management |
| SEC-006 | Broken access control / IDOR |
| SEC-007 | Security misconfiguration (debug in prod, default creds) |
| SEC-008 | Sensitive data exposure (PII in logs, unencrypted storage) |
| SEC-009 | Missing input validation at trust boundaries |
| SEC-010 | Known-vulnerable dependencies |
| SEC-011 | Insufficient security-event logging |
| SEC-012 | SSRF |
| SEC-013 | Path traversal |
| SEC-014 | Weak cryptography (weak algorithms, hardcoded IVs) |

### REL — Reliability
| ID | Description |
|----|-------------|
| REL-001 | Null/undefined dereference without guard |
| REL-002 | Unhandled exception propagating to caller |
| REL-003 | Resource leak (handle, connection, stream) |
| REL-004 | Race condition / thread-safety violation |
| REL-005 | Deadlock potential (lock ordering, sync-over-async) |
| REL-006 | Infinite loop / unbounded recursion |
| REL-007 | Swallowed exception (no log, no rethrow) |
| REL-008 | Missing timeout on external call |
| REL-009 | Unvalidated assumption about external state |
| REL-010 | Missing retry/backoff for transient failure |

### CON — Correctness
| ID | Description |
|----|-------------|
| CON-001 | Off-by-one (bounds, indexing, slicing) |
| CON-002 | Wrong comparison operator / boolean logic |
| CON-003 | Incorrect algorithm for stated purpose |
| CON-004 | Type confusion / lossy implicit conversion |
| CON-005 | Copy-paste error (duplicated logic, wrong variable) |
| CON-006 | Incorrect order of operations |
| CON-007 | Missing or wrong return value |
| CON-008 | Incorrect string formatting/interpolation |
| CON-009 | Wrong enum/constant used |
| CON-010 | Code contradicts documented intent |

### RES — Resource Management
| ID | Description |
|----|-------------|
| RES-001 | Unclosed handle/connection/socket |
| RES-002 | Memory leak (unremoved handler, cache without eviction) |
| RES-003 | Unbounded collection growth |
| RES-004 | Missing disposal / context manager |
| RES-005 | Excessive allocation in hot path |
| RES-006 | Locks held longer than necessary |
| RES-007 | LOH / pinning fragmentation risk |
| RES-008 | Blocking async (`.Result`, `.Wait()`) |

### DAT — Data Integrity
| ID | Description |
|----|-------------|
| DAT-001 | Data loss (overwrite without backup, truncation) |
| DAT-002 | Corruption (partial write, missing transaction) |
| DAT-003 | Invalid state transition |
| DAT-004 | Missing validation before persistence |
| DAT-005 | Inconsistency across related stores |
| DAT-006 | Missing idempotency on retryable operations |
| DAT-007 | Timezone/locale error |
| DAT-008 | Encoding mismatch |

## 3. Severity

| Severity | Definition | Merge impact |
|----------|-----------|--------------|
| **Critical** | Broken, insecure, or data-losing in production — not a matter of opinion | Must fix, no exceptions |
| **Warning** | Works, but meaningful risk or standard violation | Should fix; deferrable with documented justification |
| **Style** | Functional and safe; could be cleaner | Author's call |

Defaults: SEC with confidence > 70 → Critical. REL-001…006 on production-reachable paths →
Critical. DAT-001/002 → Critical. CON → Warning unless the wrong behavior is guaranteed to
manifest. Never escalate Style because you feel strongly.

## 4. Reporting Format

```
- **[CATEGORY-NNN]** `file:line` — One-sentence description.
  - **Severity**: Critical | Warning | Style
  - **Confidence**: NN/100
  - **Evidence**: Why this is an issue — cite the behavior and failure mode. Not optional.
  - **Fix**: Concrete resolution; code snippet if non-obvious.
```

One issue per entry; multi-location issues reported once listing all locations. More than
15 issues: top 5 Critical/Warning first, rest collapsed. Full-review output structure:
summary header (files, counts, verdict) → Critical → Warnings → Style → Notes (including
positive callouts — reviews aren't purely adversarial).

## 5. Circular-Work Prevention

Before flagging, check in order: explanatory comments → `git log`/`git blame` on the lines
→ CLAUDE.md / ADRs / rules files → `// INTENTIONAL` / `// DO NOT CHANGE` / `# noqa`
markers. If intent is still unclear, raise a `[QUESTION]` instead of an issue. Project
standards override global ones; newer decisions override older.

## 6. Scope

- **PR/diff reviews**: the diff plus its immediate containing context. Pre-existing issues
  only if the change interacts with them.
- **Full reviews** (explicitly requested): whole files/modules; mark pre-existing issues
  as such.
- **Security reviews**: everything in scope regardless of what changed — SEC issues get no
  grandfather clause.
- Never in scope: undocumented style preferences, unmeasured performance nits, settled
  architecture (raise separately).
