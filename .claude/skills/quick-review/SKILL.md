---
name: quick-review
description: Fast security and crash-bug scan of the current changes using the project taxonomy (SEC/REL only, confidence 80+). Use for a quick sanity check before commit or PR. For broader coverage use /full-review or the built-in /code-review.
argument-hint: [files or blank for current diff]
---

# Quick Review

Perform a fast security and crash-bug scan of the current codebase changes.

## Instructions

1. Run `git diff` to identify all changed files and modifications
2. For each changed file, scan for:
   - **SEC (Security)**: Injection vulnerabilities, exposed secrets, unsafe deserialization, XSS, CSRF, OWASP top 10
   - **REL (Reliability)**: Null reference exceptions, unhandled exceptions, resource leaks, division by zero, infinite loops
3. Only report issues with confidence >= 80/100
4. Use this format for each finding:
   ```
   - **[CATEGORY]** `file:line` — Description
     - **Severity**: Critical/Warning
     - **Confidence**: NN/100
     - **Fix**: Suggested resolution
   ```
5. If no issues found, report "Quick review complete — no critical security or reliability issues detected."
6. Do NOT report style issues, naming issues, or minor code quality concerns — this is a fast scan only.
