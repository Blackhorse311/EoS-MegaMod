# Git Standards

House conventions. Standard git craft (what to gitignore, force-push etiquette, hook
managers) is assumed knowledge.

---

## 1. Branches

`type/kebab-description`, 2–5 words, ticket number when one exists:
`feature/quest-image-resizing`, `bugfix/GH-127-expired-token-handling`,
`hotfix/db-pool-exhaustion`. Prefixes: `feature/` `bugfix/` `hotfix/` `chore/`
`refactor/` `test/` `docs/`.

## 2. Commits

Conventional commits: `type(scope): description`

- Types: `feat` `fix` `refactor` `test` `docs` `chore` `perf` `ci` `style` `build`.
- Description: imperative mood, lowercase, no trailing period, subject ≤ 72 chars.
- Body (when needed): what + why, never how. Footers: `Fixes #123`, `BREAKING CHANGE:`,
  `Co-Authored-By:`.
- **One logical change per commit** — if the message needs "and", split it.
- Stage files by name (`git add <file>`, `git add -p` for mixed files), never `git add -A`
  blind. Review with `git diff --staged` before committing.
- Never commit: secrets (rotate immediately if it happens — history scrubbing is not
  enough), build artifacts, commented-out code.

> Claude Code note: interactive commands (`git rebase -i`, `git add -i`) don't work in the
> harness. Use non-interactive equivalents: `git commit --fixup` + `git rebase --autosquash`
> only outside the session, or squash at merge time instead.

## 3. PRs

- Title = conventional commit format, ≤ 70 chars.
- Description: Summary bullets, Test Plan checklist, Breaking Changes (or "None"),
  screenshots for UI.
- Target ≤ 400 changed lines; split or provide a review order when larger.
- Squash-merge feature branches to main; merge commits for release/long-lived branches;
  rebase your own unpushed branch on main before opening the PR.
- Don't force-push during active review — reviewers lose context; push new commits.

## 4. Hooks (when a project adopts them)

pre-commit: lint + format + secret scan on staged files (fast, < 10s).
commit-msg: conventional-commit validation. pre-push: tests. Use a hook manager
(Husky / pre-commit / Lefthook), commit the config, never bypass with `--no-verify`.
