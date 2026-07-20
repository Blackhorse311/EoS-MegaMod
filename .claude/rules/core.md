# Core Project Rules

> Loaded at session start (no `paths` frontmatter = always active). Keep this file lean —
> it costs context every session. Reference material belongs in `.claude/standards/`.

## Working Rules

1. **Do No Harm** — never "fix" working code that doesn't violate a documented standard.
2. **Minimal Change** — fix only what's broken or requested; no drive-by refactors or unsolicited comments.
3. **Consistency Over Perfection** — match the project's existing patterns, even when you'd design it differently.
4. **Evidence-Based** — reviews use the SEC/REL/CON/RES/DAT taxonomy with 0–100 confidence; never raise below 50. Full spec: `.claude/standards/REVIEW_GUIDELINES.md` (read on demand).
5. **Prevent Circular Work** — before changing something, check git history/comments to be sure you aren't undoing an intentional decision.

## Project-Specific Rules

{{PROJECT_SPECIFIC_RULES}}

## Do NOT Change

| Pattern / File | Reason | Since |
|----------------|--------|-------|
| {{PATTERN}} | {{REASON}} | {{DATE}} |
