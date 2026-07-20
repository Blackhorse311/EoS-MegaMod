---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---

# Python Rules

Follow PEP 8 and standard modern Python idiom (3.10+ union syntax, pathlib, dataclasses/Pydantic over raw dicts). Only the deltas and emphasis points below need stating.

## Project emphasis

- Type-hint all function signatures in production code; `mypy`/`pyright` strict in CI when configured.
- `is None` checks when falsy values (`0`, `""`, `[]`) are legitimate; sentinel `None` for mutable defaults.
- Never bare `except:`; preserve chains with `raise ... from e`; `contextlib.suppress` over try/except/pass.
- `with` for anything that has `close()`/`release()`; `logging` (module-level `getLogger(__name__)`, `%s` lazy formatting), never `print()` in production code.
- Virtual environments always — prefer `uv` for new projects, respect whatever the project already uses.
- Pydantic `BaseModel` for external input needing validation; `dataclass` for internal containers.
- Comment only the *why*: workarounds (with removal trigger), non-obvious business rules, intentional deviations.
