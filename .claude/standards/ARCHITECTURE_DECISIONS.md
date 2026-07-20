# Architecture Decision Records

House conventions for ADRs. Template: `.claude/templates/ADR_TEMPLATE.md`.

---

## When to Write One

Any decision a future developer will stare at and ask "why?": framework/library choices,
storage changes, new architectural patterns, project-wide conventions, trade-offs with
long-term consequences. NOT for routine implementation choices, bug fixes, or style
decisions (linter config handles those).

## Format

`docs/adr/NNNN-short-title.md` (4-digit, kebab-case), indexed in `docs/adr/README.md`
(table: number, title, status, date). Required sections: **Status** (Proposed → Accepted →
Deprecated | Superseded), **Date**, **Context**, **Decision**, **Options Considered**
(every seriously evaluated alternative with pros/cons — this is the section that prevents
re-litigating settled choices), **Consequences** (positive AND negative; a one-sided ADR
isn't credible).

## Rules

1. **Accepted ADRs are immutable.** To change a decision: new ADR, mark the old one
   Superseded with a link. The chain is the project's memory.
2. Keep them to 1–2 pages. Why, not how — link to code for implementation.
3. Write for a reader with zero project context; don't reference meetings or chats
   without summarizing them.
4. Commit ADRs like code: `docs(adr): add ADR-0004 for event sourcing adoption`.
