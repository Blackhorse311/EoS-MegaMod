---
name: fix-issues
description: Apply fixes from the most recent review report in the conversation, sorted by confidence then severity. Skips Style-level issues and flags risky fixes for user decision. Use after /quick-review, /full-review, or /legends-review.
disable-model-invocation: true
---

# Fix Issues from Review

Apply fixes from a code review report.

## Instructions

1. Parse the most recent review output in the conversation
2. Sort issues by confidence (highest first), then by severity (Critical > Warning > Style)
3. For each issue:
   a. Read the relevant file and surrounding context
   b. Apply the suggested fix (or an improved version if the suggestion is incomplete)
   c. Verify the fix doesn't break adjacent code
   d. Document the change
4. After all fixes are applied:
   - List all changes made with file:line references
   - List any issues that were SKIPPED and why (e.g., intentional pattern, would break other code, insufficient confidence)
   - Run any available tests to verify no regressions
5. Do NOT fix Style-level issues unless explicitly asked
6. Do NOT modify code that wasn't flagged in the review
7. If a fix would require significant refactoring, flag it for user decision instead of implementing
