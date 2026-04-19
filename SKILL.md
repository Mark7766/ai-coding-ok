---
name: ai-coding-ok
description: Installs the ai-coding-ok three-tier memory system (long-term project memory, mid-term decision log, short-term task history) plus coding guardrails into a software project so AI coding assistants (Claude Code, GitHub Copilot, Cursor, etc.) stop "forgetting" context across sessions and stop breaking unrelated features while fixing bugs. Use this skill when the user says "set up project memory", "install ai-coding-ok", "initialize AI guardrails", "stop AI from forgetting context", "add memory/PDCA workflow to this project", or otherwise wants persistent cross-session project context files for AI tools.
---

# Memory Manager

A three-tier memory system + AI coding guardrails, packaged as a skill so both Claude Code and GitHub Copilot can consume it. Derived from the battle-tested [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) framework.

## What this skill installs

When activated in a project, the skill copies a curated set of files into the target project:

```
<project-root>/
├── AGENTS.md                              # Architecture cheatsheet (AI reads first)
└── .github/
    ├── copilot-instructions.md            # Global behavior rules (Copilot auto-loads)
    ├── project-metadata.yml               # Machine-readable project facts
    ├── PULL_REQUEST_TEMPLATE.md
    ├── ISSUE_TEMPLATE/…
    ├── workflows/                         # CI + memory update reminder
    └── agent/
        ├── system-prompt.md               # Agent persona + PDCA workflow
        ├── coding-standards.md
        ├── workflows.md                   # Scenario playbooks
        ├── prompt-templates.md
        └── memory/
            ├── project-memory.md          # 🧠 Long-term memory (facts, constraints)
            ├── decisions-log.md           # 📝 Mid-term memory (ADRs)
            └── task-history.md            # 📜 Short-term memory (recent tasks)
```

## When invoked — step-by-step playbook

Follow these steps in order. Do not skip Step 4 (customization): unfilled `{{placeholders}}` defeat the whole purpose.

### Step 1 — Locate the skill's template directory

The templates live at `<this-skill-dir>/templates/` (i.e. alongside this SKILL.md). Resolve the absolute path before copying.

### Step 2 — Pick the target project

Default target is the current working directory. Confirm with the user only if:
- The cwd is obviously not a project (e.g. `$HOME`, `/tmp`).
- Key files already exist and would be overwritten (see Step 3 conflict check).

### Step 3 — Conflict check (non-destructive)

Before copying anything, check whether any of these paths already exist in the target:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/agent/` (directory)

If **any** exist, STOP and report to the user. Offer three choices:
1. Overwrite (risky — they may have hand-edits).
2. Copy only missing files (safe, recommended).
3. Abort.

Never silently overwrite existing files.

### Step 4 — Copy templates into the project

Copy the entire contents of `templates/` into the project root. On POSIX:

```bash
cp -rn <skill-dir>/templates/. <project-root>/
```

`-n` = no-clobber, keeping the user's existing edits safe. On Windows/Node, do an equivalent merge-copy.

Verify the 16 target files/dirs are present. Fail loudly if any are missing.

### Step 5 — Ask the user what they're building

Do NOT ask the user to fill in placeholders manually. Instead, ask a single plain-language question:

> "一句话告诉我你想做一个什么东西？比如：'给自己用的记账小工具，能记录每天花了多少钱'。"

(English projects: "In one sentence, what are you building?")

### Step 6 — Infer and replace placeholders

Based on the user's sentence, infer:

- Project name (`{{项目名称}}` / `{{project-name}}`)
- Project type (`{{项目类型}}`, `{{项目类型简述}}`)
- Tech stack (language, framework, DB, ORM, test framework, package manager, etc.)
- Design principles (for a personal tool: "极简实用"; for an internal tool: "可维护 > 性能"; etc.)
- User scale, core features, business concepts, architecture, etc.

Then walk every copied file and replace every `{{...}}` placeholder with the inferred value. Files to process:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/project-metadata.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/memory-check.yml`
- `.github/agent/system-prompt.md`
- `.github/agent/coding-standards.md`
- `.github/agent/workflows.md`
- `.github/agent/prompt-templates.md`
- `.github/agent/memory/project-memory.md`
- `.github/agent/memory/decisions-log.md`
- `.github/agent/memory/task-history.md`

For `{{YYYY-MM-DD}}` placeholders use today's date.

When uncertain about a choice (e.g. "SQLite vs Postgres?"), pick the simpler one and note it in `decisions-log.md` as ADR-001. The user can override later.

### Step 7 — Bootstrap the first memory entries

After replacement, populate `task-history.md` with a real first entry:

```markdown
### [TASK-001] 安装 ai-coding-ok 并完成项目初始化
- **日期**: <today>
- **类型**: chore
- **摘要**: 通过 ai-coding-ok skill 安装三层记忆系统和编码规范；根据用户一句话需求（<用户原话>）自动推断并填充所有配置。
- **变更文件**: AGENTS.md, .github/**/*
- **注意事项**: 首次运行，后续如架构调整请同步更新 project-memory.md 和 decisions-log.md。
```

### Step 8 — Report back to the user

Output:

1. A checklist of files installed and customized.
2. Key inferred decisions (tech stack, design principle) so the user can sanity-check.
3. Next steps: "Open `AGENTS.md` to review. From now on, I will read the memory files before every task and update `task-history.md` after every task."

## Working rules after installation

Once installed, ALL subsequent sessions (this one included) must follow the PDCA loop defined in `.github/agent/system-prompt.md`:

1. **Plan** — Read `AGENTS.md` + `.github/agent/memory/*.md` before touching code.
2. **Do** — Write code AND tests in the same change.
3. **Check** — Run tests. Verify no regression in unrelated features.
4. **Act** — Update `task-history.md` (always), `decisions-log.md` (when architecture changed), `project-memory.md` (when facts changed).

This is the mechanism that prevents "AI fixed bug X and deleted feature Y".

## Combining with the `superpowers` skill

If the user also has `superpowers` installed, use them together as follows:

- **Strategy / big-picture work**: `superpowers` for brainstorming, deep research, orchestrating sub-agents.
- **Code guardrails + persistence**: `ai-coding-ok` for keeping the project's facts, decisions, and task log accurate across sessions.

Concretely: let `superpowers` generate plans and analyses, then **write the durable parts into `.github/agent/memory/*`** so the context survives after the superpowers session ends. See `docs/superpowers-combo.md` in this skill directory for detailed recipes.

## For GitHub Copilot users (non-Claude-Code)

Copilot does not load SKILL.md. Copilot users get the same value by:

1. Running `install.sh` (or `install.py`) once to copy `templates/` into their project.
2. Copilot Chat auto-loads `.github/copilot-instructions.md` on every request — that file references the memory system and PDCA workflow, so the behavior is inherited.
3. Paste `scripts/customize-prompt.md` into Copilot Chat to trigger placeholder replacement.

## References

- `templates/` — source of truth for all installed files.
- `scripts/customize-prompt.md` — the customization prompt to feed Copilot.
- `scripts/verify.sh` — post-install sanity check.
- `docs/claude-code-quickstart.md` — Claude Code users.
- `docs/copilot-quickstart.md` — Copilot users.
- `docs/superpowers-combo.md` — combo recipes with `superpowers`.
- `docs/faq.md` — common questions.
