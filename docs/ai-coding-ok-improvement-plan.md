# ai-coding-ok 综合改进方案

> **生成日期**：2026-04-19
> **测试平台**：GitHub Copilot (VS Code) + Claude Code
> **测试项目**：CashLog（个人记账 Web 工具）
> **目标版本**：ai-coding-ok v2.0

---

## 目录

- [1. 问题总结](#1-问题总结)
- [2. 根因分析](#2-根因分析)
- [3. 改进方案总览](#3-改进方案总览)
- [4. 详细改动清单](#4-详细改动清单)
- [5. 文件级改动 Diff 说明](#5-文件级改动-diff-说明)
- [6. 验收标准](#6-验收标准)
- [7. 已有项目升级方案](#7-已有项目升级方案)

---

## 1. 问题总结

### 1.1 Copilot 平台发现的问题

| 编号 | 问题 | 严重度 | 表现 |
|------|------|--------|------|
| C-1 | ai-coding-ok skill description 只覆盖安装场景 | 🔴 P0 | 用户说「把系统开发出来」不触发 ai-coding-ok，导致完全跳过 PDCA |
| C-2 | PDCA 日常循环规则藏在 SKILL.md 末尾 | 🔴 P0 | 安装后的所有开发会话不会读 SKILL.md，PDCA 规则形同虚设 |
| C-3 | writing-plans skill 不感知 ai-coding-ok 记忆文件 | 🟡 P1 | 写实施计划时不读 project-memory.md，可能违反已有架构决策 |
| C-4 | copilot-instructions.md 里的读取要求是建议性语言 | 🟡 P1 | 「请优先阅读」被 Copilot 优化掉，不强制执行 |

### 1.2 Claude Code 平台发现的问题

| 编号 | 问题 | 严重度 | 表现 |
|------|------|--------|------|
| CC-1 | SKILL.md 只有安装模式，没有日常使用模式 | 🔴 P0 | 同 C-1，但在 Claude Code 表现更明显——skill 触发后直接走安装流程 |
| CC-2 | 有 superpowers 时 PDCA 被 brainstorming/writing-plans 绕过 | 🔴 P0 | brainstorming Step 1 读 AGENTS.md，但 AGENTS.md 模板里没有 PDCA 强制指令 |
| CC-3 | writing-plans 生成的计划没有 Act 阶段 | 🟡 P1 | 执行计划后不更新 task-history.md / decisions-log.md |
| CC-4 | 两条执行路径（有/无 superpowers）缺乏统一覆盖 | 🔴 P0 | 路径 A（superpowers）依赖 AGENTS.md hook，路径 B 依赖 SKILL.md hook，两个都缺失 |

### 1.3 两平台共性问题

| 编号 | 问题 | 影响 |
|------|------|------|
| S-1 | workflows.md 各场景的收尾步骤缺少「不可跳过」标注 | Act 阶段被视为可选 |
| S-2 | memory-manager skill 是 ai-coding-ok 的副本但 description 完全一致 | 改 ai-coding-ok 时需同步改 memory-manager |

---

## 2. 根因分析

```
根因 1（核心）：SKILL.md 只有 "安装模式"，没有 "日常使用模式"
  ├── 后果 A：安装后的任何开发任务都不会触发 ai-coding-ok skill
  ├── 后果 B：PDCA 工作流规则只在安装时被读取一次，之后永久失效
  └── 后果 C：记忆文件变成摆设——装好了但没人去读/写

根因 2：AGENTS.md 模板缺少强制指令
  ├── 后果 A：superpowers brainstorming 读 AGENTS.md 时遇不到 PDCA 要求
  └── 后果 B：即使 AI 工具会读 AGENTS.md（如 Claude Code 会看它），也得不到 PDCA 指令

根因 3：copilot-instructions.md 模板的指令强度不够
  ├── 后果 A：Copilot 不强制读记忆文件就开始写代码
  └── 后果 B：任务结束后不提示更新 task-history.md

根因 4：ai-coding-ok 与 superpowers 之间没有协作协议
  └── 后果：writing-plans 生成的计划不包含 Act 阶段，executing-plans 执行完不更新记忆
```

---

## 3. 改进方案总览

### 核心思路

**不依赖外部 skill（superpowers 等）配合，通过 ai-coding-ok 自身控制的文件形成双保险：**

- **SKILL.md**：覆盖路径 B（无 superpowers，或 Claude Code 直接触发 skill 场景）
- **templates/AGENTS.md**：覆盖路径 A（有 superpowers 时，brainstorming Step 1 会读它）
- **templates/copilot-instructions.md**：覆盖 Copilot 场景（Copilot 每次请求自动加载此文件）

### 路径覆盖矩阵

```
┌────────────────────────────────────────┬───────────────────────────────┬─────────────────────┐
│                  场景                  │           触发路径            │      覆盖机制       │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ Claude Code，纯 ai-coding-ok          │ Claude 扫 SKILL.md           │ Mode B/C 声明覆盖   │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ Claude Code，有 superpowers            │ brainstorming 读 AGENTS.md    │ 顶部强制指令覆盖    │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ Claude Code，writing-plans 生成计划    │ ai-coding-ok 兼容协议         │ 强制追加 Act 步骤   │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ Claude Code，executing-plans 结束      │ ai-coding-ok 兼容协议         │ Mode C 强制执行     │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ Copilot，任何请求                      │ 自动加载 copilot-instructions │ 顶部强制指令覆盖    │
├────────────────────────────────────────┼───────────────────────────────┼─────────────────────┤
│ 其他 AI 工具（Cursor 等）              │ 读 AGENTS.md                  │ 顶部强制指令覆盖    │
└────────────────────────────────────────┴───────────────────────────────┴─────────────────────┘
```

---

## 4. 详细改动清单

### 优先级排序

| 优先级 | 文件 | 改动 | 解决问题 |
|--------|------|------|----------|
| P0-1 | `SKILL.md` | 修改 description，加日常使用 + upgrade 触发词 | C-1, CC-1 |
| P0-2 | `SKILL.md` | 顶部加「When to invoke」四模式章节（含 Mode D Upgrade） | C-2, CC-1, CC-4 |
| P0-3 | `SKILL.md` | 末尾加「Compatibility with superpowers」章节 | CC-2, CC-3, CC-4 |
| P0-4 | `templates/AGENTS.md` | 顶部加 PDCA 强制指令块 + 版本标记 | CC-2, CC-4 |
| P0-5 | `templates/.github/copilot-instructions.md` | 顶部加强制读取指令 + Act 阶段提醒 + 版本标记 | C-4 |
| P0-6 | `SKILL.md` | 新增 Mode D — Upgrade 完整实现章节 | 自动化升级 |
| P0-7 | 所有 `templates/*` 文件 | 添加 `<!-- ai-coding-ok: v2.0 -->` 版本标记 | 版本检测 |
| P1-1 | `templates/.github/agent/workflows.md` | 各场景收尾步骤加 ⚠️ 不可跳过标注 + 版本标记 | S-1 |
| P1-2 | `memory-manager/SKILL.md` | 同步 ai-coding-ok 的改动 | S-2 |

---

## 5. 文件级改动 Diff 说明

### 5.1 SKILL.md — description 改动 (P0-1)

**现有：**
```yaml
description: Installs the ai-coding-ok three-tier memory system (long-term project memory, mid-term decision log, short-term task history) plus coding guardrails into a software project so AI coding assistants (Claude Code, GitHub Copilot, Cursor, etc.) stop "forgetting" context across sessions and stop breaking unrelated features while fixing bugs. Use this skill when the user says "set up project memory", "install ai-coding-ok", "initialize AI guardrails", "stop AI from forgetting context", "add memory/PDCA workflow to this project", or otherwise wants persistent cross-session project context files for AI tools.
```

**改为：**
```yaml
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
```

> **关键变化**：增加了「任何开发任务 + 项目已有记忆文件」作为触发条件；增加了 upgrade 触发词，不再仅限于安装词。

---

### 5.2 SKILL.md — 新增「When to invoke」三模式章节 (P0-2)

在 `## What this skill installs` 之后、`## When invoked — step-by-step playbook` 之前，新增：

```markdown
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
```

---

### 5.3 SKILL.md — 新增「Compatibility with superpowers」章节 (P0-3)

在 SKILL.md 末尾（`## References` 之前），替换或补充现有的 `## Combining with the superpowers skill` 章节：

```markdown
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
```

---

### 5.4 SKILL.md — 重命名现有安装章节 (P0-2 附属)

将现有的：
```markdown
## When invoked — step-by-step playbook
```

改为：
```markdown
## Installation Playbook (Mode A only)
```

并在其下方第一行添加：
```markdown
> ⚠️ 以下步骤仅在 Mode A（首次安装）时执行。Mode B / Mode C 不走这个流程。
```

---

### 5.5 templates/AGENTS.md — 顶部加 PDCA 强制指令 (P0-4)

在现有 `# AGENTS.md — {{项目名称}}` 标题之后、`## 项目概述` 之前，新增：

```markdown
## ⚠️ AI Agent 必读规范（每次任务必须执行）

本项目使用 [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) 三层记忆系统。**在执行任何任务之前，必须完成以下步骤：**

### Plan 阶段（强制，任务开始前）
1. 读取 `.github/agent/memory/project-memory.md` — 了解项目事实和架构约束
2. 读取 `.github/agent/memory/decisions-log.md` — 了解历史技术决策
3. 读取 `.github/agent/memory/task-history.md` — 了解近期任务上下文

### Act 阶段（强制，任务结束后）
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> ⛔ 以上步骤不可跳过。若在使用 superpowers brainstorming / writing-plans，
> 在调用这些 skill **之前**先完成 Plan 阶段，**结束后**完成 Act 阶段。

---
```

---

### 5.6 templates/.github/copilot-instructions.md — 强制读取指令 (P0-5)

**改动 A：在文件最顶部（标题之前）新增强制指令块：**

```markdown
<!-- ⛔ MANDATORY: Copilot MUST execute these steps for EVERY request -->

## ⚠️ 强制执行：PDCA 工作流

本项目使用 ai-coding-ok 三层记忆系统。**每次处理任务前必须执行 Plan，完成后必须执行 Act。**

### 任务开始前（Plan）
1. 读取 `AGENTS.md`
2. 读取 `.github/agent/memory/project-memory.md`
3. 读取 `.github/agent/memory/decisions-log.md`
4. 读取 `.github/agent/memory/task-history.md`

### 任务结束后（Act）
1. 更新 `.github/agent/memory/task-history.md`
2. 如有架构决策 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> 跳过以上步骤视为不合规。如果任务过于简单（纯问答、代码解释），可跳过 Act 但仍需执行 Plan。

---
```

**改动 B：删除文件末尾原有的弱建议章节：**

删除：
```markdown
## 🔗 上下文文件引用

处理任务时，请优先阅读以下文件获取上下文：

1. `AGENTS.md` — 系统架构速查
2. `.github/agent/memory/project-memory.md` — 项目长期记忆
...
```

> 理由：已被顶部的强制版本替代，保留两份会造成混乱。

---

### 5.7 templates/.github/agent/workflows.md — 收尾步骤加标注 (P1-1)

对每个场景的收尾/Act 步骤增加 `⚠️ 不可跳过` 标注。

**场景 1（Feature）的 Step 5 改为：**
```
Step 5: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  ├── 如有架构决策 → 更新 decisions-log.md
  ├── 如有项目事实变化 → 更新 project-memory.md
  └── 提交代码（Conventional Commits 格式）
```

**场景 2（Fix）的 Step 5 改为：**
```
Step 5: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  └── 如果是常见坑 → 更新 project-memory.md
```

**场景 3（Refactor）增加 Step 4：**
```
Step 4: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  ├── 如重构改变了模块结构 → 更新 project-memory.md
  └── 如有技术决策 → 更新 decisions-log.md
```

---

### 5.8 memory-manager/SKILL.md — 同步改动 (P1-2)

`memory-manager` 是 `ai-coding-ok` 的 Copilot 别名。需要将上述 SKILL.md 的所有改动（P0-1, P0-2, P0-3）同步到 `memory-manager/SKILL.md`。

建议方案：
- **方案 A（推荐）**：将 `memory-manager/SKILL.md` 改为符号链接指向 `ai-coding-ok/SKILL.md`
- **方案 B**：在两个文件中使用完全相同的内容，并在 description 中额外加 `"install memory-manager"` 触发词

---

## 6. 验收标准

### 6.1 场景测试矩阵

完成改动后，需要在以下场景中测试通过：

| 测试编号 | 平台 | 场景 | 预期行为 |
|----------|------|------|----------|
| T-1 | Claude Code | 项目已有 `.github/agent/memory/`，用户说"实现一个新功能" | 触发 ai-coding-ok Mode B → 读取 4 个记忆文件 → 输出约束摘要 → 继续实现功能 → 结束时更新 task-history.md |
| T-2 | Claude Code | 有 superpowers，用户说"帮我设计一个新功能" | brainstorming → 读 AGENTS.md → 遇到 PDCA 指令 → 读取记忆文件 → 设计完成后更新记忆 |
| T-3 | Claude Code | 有 superpowers，用户说"写实施计划" | writing-plans → 计划最后一个 Task 是「更新项目记忆」 |
| T-4 | Copilot | 项目已有 `.github/agent/memory/`，用户发起任何开发请求 | Copilot 先读取 4 个记忆文件（或至少在输出中体现已理解约束）→ 结束时提示/执行记忆更新 |
| T-5 | Claude Code | 首次安装，项目没有 `.github/agent/memory/` | 正常走 Mode A（安装流程 Steps 1-8） |
| T-6 | 任意平台 | 纯问答/代码解释请求 | 执行 Plan（读记忆），跳过 Act（不需要更新记忆），不报错 |

### 6.2 回归检查

- [ ] 安装模式（Mode A）流程不受影响，Steps 1-8 正常工作
- [ ] templates/ 目录下所有 `{{占位符}}` 仍保留完好（改动不影响模板变量）
- [ ] SKILL.md 的 description 仍然被 Claude Code skill discovery 和 Copilot skill scanning 正确识别
- [ ] memory-manager 与 ai-coding-ok 功能保持一致

---

## 7. 已有项目升级方案

ai-coding-ok v2.0 改动了 **templates 模板**和 **SKILL.md**。已经使用 v1 初始化过的项目，模板内容已经被复制到项目中并做了定制化填充（`{{占位符}}` → 实际值）。升级时需要区分「通用框架部分」和「项目定制部分」，只合并框架变更，保留项目特有内容。

### 7.1 受影响项目清单

| 项目 | 路径 | 平台 | 初始化版本 |
|------|------|------|-----------|
| ai-coding-ok-cc-demo | `ai-coding-ok-cc-demo/` | Claude Code | v1.0 |
| ai-coding-ok-copilot-demo | `ai-coding-ok-copilot-demo/` | GitHub Copilot | v1.0 |

### 7.2 升级影响分析

v2.0 模板改动分为两类：

**A 类 — 纯新增内容（不影响已有定制化部分）：**

| 变更 | 目标文件 | 操作 | 风险 |
|------|---------|------|------|
| PDCA 强制指令块 | `AGENTS.md` | 在标题后、项目概述前**插入**新章节 | 🟢 低：纯新增，不动已有内容 |
| 强制读取指令块 | `.github/copilot-instructions.md` | 在文件顶部**插入**新章节 | 🟢 低：纯新增，不动已有内容 |

**B 类 — 修改已有内容：**

| 变更 | 目标文件 | 操作 | 风险 |
|------|---------|------|------|
| 删除末尾弱建议章节 | `.github/copilot-instructions.md` | 删除「🔗 上下文文件引用」章节 | 🟡 中：需确认项目没有额外自定义 |
| 收尾步骤加标注 | `.github/agent/workflows.md` | 修改 Step 5 等收尾步骤 | 🟡 中：如项目已定制过此处需手动合并 |

**C 类 — 仅 SKILL.md 变更（不涉及项目文件）：**

| 变更 | 说明 |
|------|------|
| description 触发词 | SKILL.md 在 skill 安装目录，不在项目里，升级 ai-coding-ok 仓库即可 |
| Mode A/B/C 三模式 | 同上 |
| superpowers 兼容协议 | 同上 |

### 7.3 逐文件升级操作手册

#### Step 1: 升级 AGENTS.md（两个项目均需执行）

在 `# AGENTS.md — {项目名称}` 标题之后、`## 项目概述` 之前，插入 PDCA 强制指令块：

```markdown
## ⚠️ AI Agent 必读规范（每次任务必须执行）

本项目使用 [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) 三层记忆系统。**在执行任何任务之前，必须完成以下步骤：**

### Plan 阶段（强制，任务开始前）
1. 读取 `.github/agent/memory/project-memory.md` — 了解项目事实和架构约束
2. 读取 `.github/agent/memory/decisions-log.md` — 了解历史技术决策
3. 读取 `.github/agent/memory/task-history.md` — 了解近期任务上下文

### Act 阶段（强制，任务结束后）
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> ⛔ 以上步骤不可跳过。若在使用 superpowers brainstorming / writing-plans，
> 在调用这些 skill **之前**先完成 Plan 阶段，**结束后**完成 Act 阶段。

---
```

**验证**：确认插入位置正确，`## 项目概述` 仍紧跟其后，项目特有的架构图、模块列表等不受影响。

---

#### Step 2: 升级 .github/copilot-instructions.md（两个项目均需执行）

**2a. 在文件最顶部（标题之前）插入强制指令块：**

```markdown
<!-- ⛔ MANDATORY: AI Agent MUST execute these steps for EVERY request -->

## ⚠️ 强制执行：PDCA 工作流

本项目使用 ai-coding-ok 三层记忆系统。**每次处理任务前必须执行 Plan，完成后必须执行 Act。**

### 任务开始前（Plan）
1. 读取 `AGENTS.md`
2. 读取 `.github/agent/memory/project-memory.md`
3. 读取 `.github/agent/memory/decisions-log.md`
4. 读取 `.github/agent/memory/task-history.md`

### 任务结束后（Act）
1. 更新 `.github/agent/memory/task-history.md`
2. 如有架构决策 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> 跳过以上步骤视为不合规。如果任务过于简单（纯问答、代码解释），可跳过 Act 但仍需执行 Plan。

---
```

**2b. 删除文件末尾的「🔗 上下文文件引用」章节**（已被顶部版本替代）。

**验证**：确认文件中不存在重复的「读取记忆文件」指令。

---

#### Step 3: 升级 .github/agent/workflows.md（两个项目均需执行）

修改各场景的收尾步骤，添加 `⚠️ 不可跳过` 标注。

以场景 1（Feature）为例，将：
```
Step 5: 收尾
  ├── 更新 task-history.md
```
改为：
```
Step 5: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
```

对所有场景（Feature / Fix / Refactor）执行同样操作。

---

#### Step 4: 记录升级到 task-history.md（两个项目均需执行）

在各项目的 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 v2.0
- **日期**：2026-04-XX（实际执行日期）
- **类型**：chore
- **摘要**：升级 ai-coding-ok 框架文件至 v2.0，新增 PDCA 强制指令块（AGENTS.md 顶部、copilot-instructions.md 顶部），强化 workflows.md 收尾步骤标注
- **变更文件**：AGENTS.md, .github/copilot-instructions.md, .github/agent/workflows.md, .github/agent/memory/task-history.md
- **注意事项**：SKILL.md 的改动在 ai-coding-ok 仓库本身，不需要在项目里操作
```

### 7.4 升级执行顺序

```
1. 先完成 ai-coding-ok 仓库本身的开发（SKILL.md + templates/ 改动）
2. 在 ai-coding-ok 仓库 templates/ 上验证模板正确性
3. 升级 ai-coding-ok-cc-demo（按 Step 1→2→3→4）
4. 在 ai-coding-ok-cc-demo 中运行验收测试 T-1, T-2, T-3, T-5
5. 升级 ai-coding-ok-copilot-demo（按 Step 1→2→3→4）
6. 在 ai-coding-ok-copilot-demo 中运行验收测试 T-4, T-5, T-6
```

### 7.5 自动化升级实现方案（Mode D — Upgrade）

#### 7.5.1 设计目标

用户在 Claude Code 或 Copilot 聊天框输入以下任意指令，即可触发自动升级：

```
upgrade ai-coding-ok
update ai-coding-ok
升级 ai-coding-ok
更新 ai-coding-ok
```

AI 自动完成：版本检测 → 差异分析 → 合并框架变更 → 保留项目定制内容 → 更新版本标记。

#### 7.5.2 版本标记机制

**在每个模板文件的第一行添加 HTML 注释版本标记：**

```html
<!-- ai-coding-ok: v2.0 -->
```

需要添加版本标记的文件（共 8 个）：

| 文件 | 标记位置 |
|------|----------|
| `templates/AGENTS.md` | 第 1 行 |
| `templates/.github/copilot-instructions.md` | 第 1 行 |
| `templates/.github/project-metadata.yml` | 第 1 行（用 `# ai-coding-ok: v2.0` YAML 注释） |
| `templates/.github/agent/system-prompt.md` | 第 1 行 |
| `templates/.github/agent/coding-standards.md` | 第 1 行 |
| `templates/.github/agent/workflows.md` | 第 1 行 |
| `templates/.github/agent/prompt-templates.md` | 第 1 行 |
| `templates/.github/workflows/ci.yml` | 第 1 行（用 `# ai-coding-ok: v2.0` YAML 注释） |

> **不标记的文件**：`memory/` 下的三个记忆文件（project-memory.md、decisions-log.md、task-history.md）是纯项目内容，不参与框架升级。ISSUE_TEMPLATE、PULL_REQUEST_TEMPLATE 内容稳定，变更频率低，暂不标记。

#### 7.5.3 SKILL.md 中 Mode D — Upgrade Playbook

在 SKILL.md 的 `## Installation Playbook (Mode A only)` 之后，新增完整升级章节：

```markdown
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
> "检测到项目 ai-coding-ok 版本：v1.0。最新模板版本：v2.0。" 

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

输出变更摘要，例如：
```
升级变更清单：
✅ AGENTS.md — 新增「⚠️ AI Agent 必读规范」章节（在标题后插入）
✅ copilot-instructions.md — 新增顶部「⚠️ 强制执行：PDCA 工作流」章节
✅ copilot-instructions.md — 删除末尾「🔗 上下文文件引用」章节（已被顶部替代）
✅ workflows.md — 修改 Step 5 收尾步骤（增加 ⚠️ 不可跳过标注）
✅ 所有文件 — 更新版本标记 v1.0 → v2.0
```

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
```

#### 7.5.4 占位符提取算法

Mode D 的核心难点是「将模板中的 `{{占位符}}` 替换为项目中的实际值」。实现方式：

```
算法：extract_placeholder_values(template_content, project_content)

1. 扫描 template_content，找到所有 {{xxx}} 占位符及其上下文
2. 对于每个占位符：
   a. 取占位符周围的固定文本作为锚点（如 "| 项目名称 | {{项目名称}} |"）
   b. 在 project_content 中搜索同一锚点模式
   c. 提取锚点中间的实际值（如 "CashLog"）
   d. 建立映射：{{项目名称}} → CashLog
3. 返回 placeholder_map: dict[str, str]

特殊情况：
- 新增章节中的占位符如果无法从已有文件提取 → 从 project-metadata.yml 读取
- project-metadata.yml 是机器可读的项目元信息，包含所有核心占位符的值
- 如果仍然无法确定 → 标记为 ⚠️ 需手动填写，不留 {{}} 在文件中
```

> **为什么选这个方案**：比纯 regex 可靠（有锚点上下文），比 AST 解析简单（Markdown 没有严格 AST）。project-metadata.yml 作为 fallback 是关键——它是唯一一个以结构化格式存储项目信息的文件。

#### 7.5.5 版本号管理规则

```
版本号格式：vMAJOR.MINOR

- MAJOR 升级（v1 → v2）：模板结构变更（新增/删除/重组章节）
- MINOR 升级（v2.0 → v2.1）：模板内容微调（措辞、格式、补充说明）

当前版本线：
- v1.0 = 初版（无版本标记的文件均视为 v1.0）
- v2.0 = 本次改进方案的目标版本
```

#### 7.5.6 Claude Code 与 Copilot 的触发差异

| 平台 | 触发机制 | 执行者 |
|------|---------|--------|
| Claude Code | 用户输入 → Claude 扫描 SKILL.md description → 匹配 upgrade 触发词 → 调用 SKILL.md → Mode D | SKILL.md 中的 Upgrade Playbook |
| Copilot (VS Code) | 用户输入 → Copilot 扫描 skill description → 匹配 upgrade 触发词 → 加载 SKILL.md → Mode D | SKILL.md 中的 Upgrade Playbook |
| Copilot (无 skill 系统) | 用户粘贴 `scripts/upgrade-prompt.md` 内容到聊天框 → Copilot 按 prompt 执行 | 独立 prompt 文件 |

> **新增文件**：`scripts/upgrade-prompt.md` — 给不支持 skill 系统的 Copilot 用户使用的升级 prompt。内容与 Mode D Playbook 等价，但以 prompt 形式编写。

#### 7.5.7 v1.0 → v2.0 的具体变更清单（供 Mode D 首次升级使用）

为确保首次升级准确，在 SKILL.md 或一个独立的 `CHANGELOG.md` 中记录每个版本的变更：

```markdown
## v2.0 (2026-04-19)

### 新增
- AGENTS.md: 顶部新增「⚠️ AI Agent 必读规范」PDCA 强制指令章节
- copilot-instructions.md: 顶部新增「⚠️ 强制执行：PDCA 工作流」章节
- 所有模板文件: 添加版本标记 `<!-- ai-coding-ok: v2.0 -->`

### 修改
- workflows.md: 各场景 Step 5 收尾步骤增加「⚠️ 不可跳过」标注
- Refactor 场景: 新增 Step 4 收尾（之前缺失）

### 删除
- copilot-instructions.md: 移除末尾「🔗 上下文文件引用」章节（已被顶部强制版本替代）

### SKILL.md 变更（不影响项目文件）
- description: 新增 PDCA 和 Upgrade 触发词
- 新增 Mode A/B/C/D 四模式章节
- 新增 Compatibility with superpowers 章节
- 新增 Upgrade Playbook 章节
```

---

## 附录：改动文件总清单

```
ai-coding-ok/
├── SKILL.md                                         ← P0-1, P0-2, P0-3, P0-6
├── CHANGELOG.md                                     ← 新增：版本变更记录
├── scripts/
│   └── upgrade-prompt.md                            ← 新增：Copilot 手动升级 prompt
├── templates/
│   ├── AGENTS.md                                    ← P0-4, P0-7（+版本标记）
│   └── .github/
│       ├── copilot-instructions.md                  ← P0-5, P0-7（+版本标记）
│       ├── project-metadata.yml                     ← P0-7（+版本标记）
│       ├── workflows/
│       │   └── ci.yml                               ← P0-7（+版本标记）
│       └── agent/
│           ├── system-prompt.md                      ← P0-7（+版本标记）
│           ├── coding-standards.md                   ← P0-7（+版本标记）
│           ├── workflows.md                         ← P1-1, P0-7（+版本标记）
│           └── prompt-templates.md                   ← P0-7（+版本标记）
└── (memory-manager/SKILL.md)                        ← P1-2（同步）
```

共 **10 个文件**需要修改 + **2 个新增文件**（CHANGELOG.md、upgrade-prompt.md）+ 1 个同步文件。
