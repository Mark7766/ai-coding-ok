---
name: ai-coding-ok
description: >-
  Three modes: (1) INSTALL — sets up the ai-coding-ok three-tier memory system
  (project-memory, decisions-log, task-history) plus coding guardrails when the
  user says "set up project memory", "install ai-coding-ok", "initialize AI
  guardrails", or the project has no .github/agent/memory/ yet.
  (2) PDCA WORKFLOW — for ANY coding task (feat, fix, refactor, plan, design,
  review, brainstorming) when the project ALREADY HAS .github/agent/memory/
  or AGENTS.md: loads project context before work, enforces memory updates
  after work. ALWAYS invoke this skill when .github/agent/memory/ exists,
  regardless of the task type.
  (3) UPGRADE — when the user says "upgrade ai-coding-ok", "update ai-coding-ok",
  "升级 ai-coding-ok", or "更新 ai-coding-ok": reads version markers from
  project files, compares with latest templates, and applies framework-level
  changes while preserving project-specific customizations.
compatibility: opencode, claude, cursor
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

## When to invoke this skill

Determine which mode applies, then follow that mode's instructions.

### Mode A — Install（首次安装，仅执行一次）

**触发条件：**
- 用户明确要求安装记忆系统（"install ai-coding-ok"、"set up project memory" 等）
- 或项目尚无 `.github/agent/memory/` 目录

**执行：**
→ 走下方「Installation Playbook」（Steps 1–8）

---

### Mode B — PDCA Plan（每次开发任务开始时）

**触发条件：**
- 项目已存在 `.github/agent/memory/` 目录
- 用户请求任何开发工作（新功能、修 bug、重构、设计方案、brainstorming、写计划、code review……）

**执行（~30 秒，在开始实际工作前完成）：**
1. 读取 `AGENTS.md` — 架构速查
2. 读取 `.github/agent/memory/project-memory.md` — 稳定事实和约束
3. 读取 `.github/agent/memory/decisions-log.md` — 历史技术决策
4. 读取 `.github/agent/memory/task-history.md` — 近期任务上下文
5. 在内部（或向用户）输出一段关键约束摘要，确认理解正确
6. **然后继续执行用户的原始任务**（不要在这里停下）

> ⚠️ 注意：Mode B 不是"代替"用户的任务，而是在任务开始前加载上下文。
> 如果同时触发了其他 skill（如 writing-plans），先执行 Mode B，再进入那个 skill。

---

### Mode C — PDCA Act（每次开发任务结束时）

**触发条件：**
- 一段代码/设计工作已完成，即将向用户返回最终结果

**执行（不可跳过）：**
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构/技术方案决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目基本事实变化（新模块、技术栈变动等）→ 更新 `.github/agent/memory/project-memory.md`
4. 在输出中包含「记忆更新」小节，列出更新了哪些记忆文件

> ⚠️ 如果由于上下文限制无法直接编辑记忆文件，至少要以文本形式输出需要更新的内容，
> 告知用户手动更新。

---

### Mode D — Upgrade（升级已安装的 ai-coding-ok）

**触发条件：**
- 用户说 "upgrade ai-coding-ok"、"update ai-coding-ok"、"升级 ai-coding-ok"、"更新 ai-coding-ok"

**执行：**
→ 走下方「Upgrade Playbook」

## Installation Playbook (Mode A only)

> ⚠️ 以下步骤仅在 Mode A（首次安装）时执行。Mode B / Mode C 不走这个流程。

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

## Compatibility with superpowers skill

当 superpowers 和 ai-coding-ok 同时安装时，**ai-coding-ok 负责确保 PDCA 完整执行**，不依赖 superpowers 主动配合。

### 执行路径分析

```
路径 A（有 superpowers）：
  using-superpowers → brainstorming → writing-plans → executing-plans
                ↑
  brainstorming Step 1 会读 AGENTS.md（Explore project context）
  ← AGENTS.md 顶部的 PDCA 强制指令是 hook 点

路径 B（无 superpowers，纯 ai-coding-ok）：
  用户发起任务 → AI 扫描 skill 触发条件 → 调用 ai-coding-ok SKILL.md
  ← SKILL.md Mode B / Mode C 是 hook 点
```

### 规则 1：开始任何 superpowers skill 之前

在调用 brainstorming / writing-plans / executing-plans 之前，必须先执行 **Mode B**（读取记忆文件）。将约束和历史上下文带入后续流程。

### 规则 2：writing-plans 生成计划时

无论 writing-plans 生成什么内容，在计划的 **最后一个 Task 之后** 必须追加：

```markdown
### Task N+1: 更新项目记忆（PDCA Act — ⚠️ 不可省略）

**Files:**
- Modify: `.github/agent/memory/task-history.md`
- Modify: `.github/agent/memory/decisions-log.md`（如有架构决策）
- Modify: `.github/agent/memory/project-memory.md`（如有事实变化）

- [ ] 更新 task-history.md，记录本次开发任务摘要
- [ ] 如本次有架构/技术决策 → 在 decisions-log.md 记录新 ADR
- [ ] 如项目事实变化（新模块、新依赖、状态变更）→ 更新 project-memory.md
- [ ] 确认所有记忆文件已更新
```

### 规则 3：executing-plans / subagent-driven-development 执行完毕后

执行 **Mode C**（Act 阶段），更新记忆文件。这一步由 ai-coding-ok 自身强制执行，与 superpowers 版本无关。

### 规则 4：AGENTS.md 是路径 A 的 hook 点

`templates/AGENTS.md` 顶部已嵌入 PDCA 强制指令。当 brainstorming 的 Step 1（Explore project context）读取 AGENTS.md 时，AI 会直接遇到 PDCA 要求并执行。这确保了即使 ai-coding-ok SKILL.md 没被触发，PDCA 也会通过 AGENTS.md 生效。

## Upgrade Playbook (Mode D only)

> ⚠️ 以下步骤仅在 Mode D（升级）时执行。

### Step 1 — 检测当前版本

读取项目中以下文件的第一行，提取版本标记：
- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/agent/system-prompt.md`
- `.github/agent/coding-standards.md`
- `.github/agent/workflows.md`
- `.github/agent/prompt-templates.md`

版本标记格式：`<!-- ai-coding-ok: vX.Y -->` 或 `# ai-coding-ok: vX.Y`

如果任何文件缺少版本标记，视为 v1.0（初版，无标记）。

将检测到的版本报告给用户：
> "检测到项目 ai-coding-ok 版本：v2.0。最新模板版本：v2.1.0。" 

### Step 2 — 读取最新模板

从 skill 的 `templates/` 目录读取所有模板文件的最新内容。
这些模板包含 `{{占位符}}`，代表框架的最新结构。

### Step 3 — 识别框架变更

逐文件对比 **最新模板的结构**（章节标题、指令块）与 **项目中已安装的文件**：

对比策略：
- **以 Markdown 章节标题（## / ###）为单位**进行结构 diff
- 识别三类变更：
  1. **新增章节**：模板中有、项目中没有 → 需要插入
  2. **删除章节**：模板中移除、项目中还在 → 提示用户确认是否删除
  3. **修改章节**：模板中章节内容变了 → 需要智能合并

输出变更摘要，例如（v2.0 → v2.1.0）：
```
升级变更清单：
✅ .cursor/rules/ai-coding-ok.mdc — 新增（Cursor alwaysApply PDCA 规则）
✅ 所有文件 — 更新版本标记 v2.0 → v2.1.0
```

> 📌 **历史升级路径参考**（按当前安装版本选择对应行）：
>
> | 升级路径 | 主要变更 |
> |----------|----------|
> | v1.0 → v2.0 | AGENTS.md / copilot-instructions.md 新增 PDCA 强制指令章节；workflows.md Step 5 加「⚠️ 不可跳过」标注；所有文件添加版本标记 |
> | v2.0 → v2.1.0 | 新增 `templates/.cursor/rules/ai-coding-ok.mdc`（Cursor 支持）；所有版本标记 v2.0 → v2.1.0 |
>
> 跨多个版本时按顺序逐级应用（如 v1.0 → v2.0 → v2.1.0）。

### Step 4 — 请求用户确认

将变更清单展示给用户，询问：
> "以上是本次升级的变更清单。是否继续？(Y/n)"

⚠️ **不可自动执行**：升级涉及修改已有文件，必须经过用户确认。

### Step 5 — 执行升级

用户确认后，逐文件执行变更：

**5a. 新增章节：**
- 定位插入点（根据模板中的位置关系）
- 将模板内容中的 `{{占位符}}` 替换为项目中已有的对应值
  - 从项目现有文件中提取已填充的值（项目名称、技术栈等）
  - 如果新章节不含占位符（如 PDCA 指令块），直接插入
- 在正确位置插入新章节

**5b. 删除章节：**
- 定位目标章节的起止范围（从标题到下一个同级标题前）
- 删除整个章节

**5c. 修改章节：**
- 读取模板中的新版章节内容
- 将 `{{占位符}}` 替换为项目中的实际值
- 替换项目中的旧版章节

**5d. 更新版本标记：**
- 将每个文件第一行的版本标记更新为最新版本
- 如果文件没有版本标记，在第一行插入

### Step 6 — 验证

- 确认所有文件的版本标记已更新
- 确认项目特有内容（架构图、模块列表、技术栈等）未被覆盖
- 确认 `{{占位符}}` 没有泄漏到项目文件中

### Step 7 — 记录升级

在 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 vX.Y
- **日期**：<today>
- **类型**：chore
- **摘要**：通过 Mode D 自动升级 ai-coding-ok 框架文件；新增/修改章节列表：<变更摘要>
- **变更文件**：<实际变更的文件列表>
- **注意事项**：<如有需要人工关注的合并细节>
```

### Step 8 — 输出升级报告

```markdown
## ai-coding-ok 升级完成

| 项目 | 旧版本 | 新版本 |
|------|--------|--------|
| ai-coding-ok | vX.Y | vX.Y |

### 变更文件
- ✅ AGENTS.md — <变更概述>
- ✅ .github/copilot-instructions.md — <变更概述>
- ...

### 保留的项目定制内容
- 项目名称、技术栈、架构图等未变
- 记忆文件（project-memory.md 等）未变

### 需要人工关注
- <如有>
```

## For GitHub Copilot users (non-Claude-Code)

Copilot does not load SKILL.md. Copilot users get the same value by:

1. Running `install.sh` (or `install.py`) once to copy `templates/` into their project.
2. Copilot Chat auto-loads `.github/copilot-instructions.md` on every request — that file references the memory system and PDCA workflow, so the behavior is inherited.
3. Paste `scripts/customize-prompt.md` into Copilot Chat to trigger placeholder replacement.

## References

- `templates/` — source of truth for all installed files.
- `scripts/customize-prompt.md` — the customization prompt to feed Copilot.
- `scripts/upgrade-prompt.md` — manual upgrade prompt for Copilot / Cursor (no skill system).
- `scripts/verify.sh` — post-install sanity check.
- `docs/claude-code-quickstart.md` — Claude Code users.
- `docs/copilot-quickstart.md` — Copilot users.
- `docs/superpowers-combo.md` — combo recipes with `superpowers`.
- `docs/faq.md` — common questions.
