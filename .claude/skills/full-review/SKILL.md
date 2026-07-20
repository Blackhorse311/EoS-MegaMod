---
name: full-review
description: Comprehensive review of the current changes against all project standards — all categories (SEC/REL/CON/RES/DAT), confidence 50+, grouped by severity. Use before merging or after significant changes. For a cloud multi-agent review of a whole branch, use the built-in /code-review ultra instead.
argument-hint: [files or blank for current diff]
context: fork
---

# Full Code Review

Perform a comprehensive code review of the current codebase changes.

## Instructions

1. Run `git diff` to identify all changed files
2. Read each changed file in full to understand context
3. Review ALL categories with confidence threshold >= 50/100:
   - **SEC** (Security): Injection, XSS, exposed secrets, unsafe deserialization, OWASP top 10
   - **REL** (Reliability): Null refs, unhandled exceptions, resource leaks, race conditions
   - **CON** (Correctness): Wrong logic, off-by-one, semantic errors, incorrect algorithm
   - **RES** (Resource Management): Unclosed handles, memory leaks, unbounded collections
   - **DAT** (Data Integrity): Data loss, corruption, invalid state transitions
4. Also check:
   - Unhandled edge cases and boundary conditions
   - Environmental differences (platform assumptions, version-specific APIs)
   - Poor coding practices (dead code, copy-paste, magic numbers)
   - External factors (dependency risks, API deprecation)
5. Report findings grouped by severity (Critical first, then Warning, then Style):
   ```
   ## Critical Issues
   - **[SEC-001]** `file:line` — Description
     - **Confidence**: NN/100
     - **Evidence**: Why this is an issue
     - **Fix**: Suggested resolution

   ## Warnings
   ...

   ## Style Suggestions
   ...
   ```
6. End with a summary: total issues by category and severity, overall assessment.
7. Before reporting, check git history to ensure you're not flagging intentional decisions (circular work prevention).
