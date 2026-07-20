---
name: review-help
description: Display help for the project's review skills and how they relate to the built-in review tools.
---

# Review Command Help

Print the following help text:

---

## Available Review Commands

### `/quick-review`
Fast scan for security vulnerabilities and crash bugs.
- **Confidence threshold**: 80+
- **Categories**: SEC (Security), REL (Reliability) — critical only
- **Use when**: Quick sanity check before commit or PR

### `/full-review`
Comprehensive code review covering all categories.
- **Confidence threshold**: 50+
- **Categories**: SEC, REL, CON, RES, DAT — all severities
- **Use when**: Before merging, after significant changes, periodic quality check

### `/fix-issues`
Apply fixes from the most recent review.
- **Processes**: Issues sorted by confidence (highest first)
- **Skips**: Style-level issues (unless explicitly asked)
- **Use when**: After running /quick-review, /full-review, or /legends-review

### `/legends-review` (if installed)
Five coding legends (Torvalds, Knuth, Kernighan, Fagan, Metz) review in parallel via a multi-agent workflow on the Fable model, with adversarial verification of Critical findings.
- **Use when**: You want the deepest, multi-perspective review of specific files

### Built-in Alternatives
| Skill | Use when |
|-------|----------|
| `/code-review <low/medium/high/max>` | Built-in diff review without the project taxonomy |
| `/code-review ultra` | Multi-agent cloud review of a whole branch or PR |
| `/security-review` | Dedicated security pass on pending branch changes |
| `/simplify` | Quality/reuse cleanup of changed code (not a bug hunt) |

### Issue Categories
| Code | Category | Examples |
|------|----------|----------|
| SEC | Security | Injection, XSS, exposed secrets |
| REL | Reliability | Null refs, resource leaks, race conditions |
| CON | Correctness | Wrong logic, off-by-one, semantic errors |
| RES | Resource Mgmt | Unclosed handles, memory leaks |
| DAT | Data Integrity | Data loss, corruption, invalid state |

### Severity Levels
| Level | Meaning |
|-------|---------|
| Critical | Must fix before merge — security hole, crash, data loss |
| Warning | Should fix — bug, bad practice, potential issue |
| Style | Optional — readability, naming, minor improvement |

---
