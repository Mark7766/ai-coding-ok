<!-- ai-coding-ok: v3.1.0 -->
# AGENTS.md — {{project-name}}

## ⚠️ AI Agent Mandatory Spec (run on every task)

This project uses the [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) three-tier memory system. **You MUST complete the steps below before doing any task work:**

### Plan Phase (mandatory, before starting the task)
1. Read `AGENTS.md` — this file, architecture quick reference
2. Read `.github/agent/system-prompt.md` — Agent persona, role switching, behavior boundaries
3. Read `.github/agent/workflows.md` — scenario workflows (Feature/Bug/Refactor/Deploy)
4. Read `.github/agent/coding-standards.md` — coding standards
5. Read `.github/agent/memory/project-memory.md` — project facts and architectural constraints
6. Read `.github/agent/memory/decisions-log.md` — historical technical decisions
7. Read `.github/agent/memory/task-history.md` — recent task context

### Act Phase (mandatory, after finishing the task)
1. Update `.github/agent/memory/task-history.md` — record a summary of this task
2. If architectural decisions changed → update `.github/agent/memory/decisions-log.md`
3. If project facts changed → update `.github/agent/memory/project-memory.md`
4. If AGENTS.md / system-prompt.md / workflows.md / coding-standards.md have stale content → sync those files

> ⛔ These steps are not optional. If you are using superpowers brainstorming / writing-plans,
> complete the Plan phase **before** calling those skills, and the Act phase **after** they finish.

---

## Project Overview

{{project-name}} is a **{{project-type-brief}}**. {{one-line description of core functionality and target users}}.

## System Architecture and Data Flow

```
{{ASCII architecture diagram here}}
{{Example:}}
{{  user request ──▶ web server ──▶ business logic ──▶ database  }}
{{                                  │                            }}
{{                            scheduled jobs / message queue     }}
```

- **`{{entry-file}}`** — {{entry-file-description}}
- **`{{core-module-A}}`** — {{module-A-description}}
- **`{{core-module-B}}`** — {{module-B-description}}

## Common Commands

```bash
# Install & run
{{install-command}}
{{start-command}}

# Test
{{test-command}}
{{coverage-command}}

# Lint & format
{{lint-command}}
{{format-command}}

# Build / deploy
{{build-command}}
```

## Conventions and Patterns

- **All files** must start with `from __future__ import annotations`.
- **Async-first**: database operations use async sessions, APIs use `async def`.
- **Test database**: `conftest.py` provides an in-memory database fixture and test client.
- **Logging**: use `logging.getLogger(__name__)`; `print()` is forbidden.
- **Configuration**: environment variables are managed via `.env` files; never hardcode secrets.
- {{additional project-specific conventions...}}

## Test Patterns

```python
# Helper to seed test data
async def _seed_test_data(db: AsyncSession) -> list[Model]:
    items = [Model(name="test1"), Model(name="test2")]
    db.add_all(items)
    await db.flush()
    return items

# For time-sensitive tests use freezegun
from freezegun import freeze_time

@freeze_time("2026-01-05 10:00:00")  # pinned to a weekday
async def test_something(db_session):
    ...
```

## Important Constraints

- **No heavy dependencies** — {{list of disallowed heavy dependencies}}
- **Sensitive data** — {{credentials-management}}
- **Database migrations** — {{migration-strategy}}
- **Code limits** — line width {{N}} chars, single function ≤ {{N}} lines, single file ≤ {{N}} lines
- {{additional project-specific constraints...}}
