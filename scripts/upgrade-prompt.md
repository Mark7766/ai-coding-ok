# ai-coding-ok 升级 Prompt

> **用途**：给不支持 skill 系统的 Copilot / Cursor 用户使用的升级 prompt。
> **使用方式**：复制对应版本的 prompt 到 Copilot Chat 或 Cursor Agent 中执行。

---

## 使用前准备

1. 确保你的项目已经安装过 ai-coding-ok（即项目中有 `.github/agent/memory/` 目录）
2. 下载最新版本的 ai-coding-ok 仓库或确保可以访问最新的 templates/ 目录

---

## 升级 Prompt — v2.1.0 → v2.2.0

将以下内容复制到 Copilot Chat 或 Cursor Agent：

```
请帮我将项目的 ai-coding-ok 框架从 v2.1.0 升级到 v2.2.0。按以下步骤执行：

## Step 1 — 检测当前版本

读取以下文件的第一行，检查版本标记 `<!-- ai-coding-ok: vX.Y.Z -->` 或 `# ai-coding-ok: vX.Y.Z`：
- AGENTS.md
- .github/copilot-instructions.md
- .github/agent/system-prompt.md
- .github/agent/coding-standards.md
- .github/agent/workflows.md
- .github/agent/prompt-templates.md
- .github/project-metadata.yml
- .github/workflows/ci.yml
- .cursor/rules/ai-coding-ok.mdc

报告检测结果。如果当前不是 v2.1.0，请先按对应路径升级到 v2.1.0。

## Step 2 — 执行升级（v2.1.0 → v2.2.0 变更清单）

### 2a. 新增项目根 CLAUDE.md（Claude Code 自动加载 shim）

在项目根新建文件 `CLAUDE.md`：

```markdown
<!-- ai-coding-ok: v2.2.0 -->
# CLAUDE.md

> Claude Code 自动加载本文件。它通过 `@` 语法导入项目级 AGENTS.md，
> 让 ai-coding-ok 的 PDCA 强制指令在每个会话开始时无条件生效。

@AGENTS.md
```

> 💡 即使你主用 Copilot / Cursor，加上这个文件也无害——它只在 Claude Code 中起作用，对其他工具不可见。

### 2b. 更新版本标记

将以下文件第一行的版本标记从 `v2.1.0` 更新为 `v2.2.0`：
- AGENTS.md
- .github/copilot-instructions.md
- .github/agent/system-prompt.md
- .github/agent/coding-standards.md
- .github/agent/workflows.md
- .github/agent/prompt-templates.md
- .github/project-metadata.yml（注释格式 `# ai-coding-ok: ...`）
- .github/workflows/ci.yml（同上）
- .cursor/rules/ai-coding-ok.mdc

## Step 3 — 验证

1. 项目根存在 CLAUDE.md 且内容含 `@AGENTS.md`
2. 所有版本标记已更新到 v2.2.0
3. 项目特有内容（项目名称、技术栈、架构图等）未被改动
4. 没有遗留 `{{占位符}}`

## Step 4 — 记录升级

在 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 v2.2.0
- **日期**：{今天日期}
- **类型**：chore
- **摘要**：升级 ai-coding-ok 至 v2.2.0；新增 CLAUDE.md（Claude Code 自动加载 shim → @AGENTS.md）；更新所有版本标记
- **变更文件**：CLAUDE.md（新增），AGENTS.md 等 9 个文件（版本标记）
- **注意事项**：框架升级，记忆文件未变动
```

请按上述步骤执行升级，完成后输出变更摘要。
```

---

## 升级 Prompt — v2.0 → v2.1.0

将以下内容复制到 Copilot Chat 或 Cursor Agent：

```
请帮我将项目的 ai-coding-ok 框架从 v2.0 升级到 v2.1.0。按以下步骤执行：

## Step 1 — 检测当前版本

读取以下文件的第一行，检查版本标记 `<!-- ai-coding-ok: vX.Y -->` 或 `# ai-coding-ok: vX.Y`：
- AGENTS.md
- .github/copilot-instructions.md
- .github/agent/system-prompt.md
- .github/agent/coding-standards.md
- .github/agent/workflows.md
- .github/agent/prompt-templates.md

如果文件缺少版本标记，视为 v1.0。报告检测结果。

## Step 2 — 执行升级（v2.0 → v2.1.0 变更清单）

### 2a. 新增 .cursor/rules/ai-coding-ok.mdc

创建 `.cursor/rules/` 目录（如不存在），新建文件 `.cursor/rules/ai-coding-ok.mdc`：

```markdown
---
description: "ai-coding-ok PDCA memory workflow — reads project memory before tasks, writes updates after. Applies to ALL coding tasks."
alwaysApply: true
---

<!-- ai-coding-ok: v2.1.0 -->

## ⚠️ AI Agent 必读规范（每次任务必须执行）

本项目使用 [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) 三层记忆系统。**在执行任何任务之前，必须完成以下步骤：**

### Plan 阶段（强制，任务开始前）
1. 读取 `AGENTS.md` — 了解架构速查和项目约束
2. 读取 `.github/agent/memory/project-memory.md` — 了解项目事实和架构约束
3. 读取 `.github/agent/memory/decisions-log.md` — 了解历史技术决策
4. 读取 `.github/agent/memory/task-history.md` — 了解近期任务上下文

### Act 阶段（强制，任务结束后）
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> ⛔ 以上步骤不可跳过。
```

### 2b. 更新版本标记

将以下文件第一行的版本标记从 `v2.0` 更新为 `v2.1.0`：
- AGENTS.md：`<!-- ai-coding-ok: v2.0 -->` → `<!-- ai-coding-ok: v2.1.0 -->`
- .github/copilot-instructions.md：同上
- .github/agent/system-prompt.md：同上
- .github/agent/coding-standards.md：同上
- .github/agent/workflows.md：同上
- .github/agent/prompt-templates.md：同上
- .github/project-metadata.yml：`# ai-coding-ok: v2.0` → `# ai-coding-ok: v2.1.0`
- .github/workflows/ci.yml：同上

## Step 3 — 验证

1. 确认所有文件的版本标记已更新到 v2.1.0
2. 确认 `.cursor/rules/ai-coding-ok.mdc` 已创建
3. 确认项目特有内容（项目名称、技术栈、架构图等）未被改动
4. 确认没有遗留的 `{{占位符}}`

## Step 4 — 记录升级

在 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 v2.1.0
- **日期**：{今天日期}
- **类型**：chore
- **摘要**：升级 ai-coding-ok 框架至 v2.1.0；新增 .cursor/rules/ai-coding-ok.mdc（Cursor alwaysApply PDCA）；更新所有版本标记
- **变更文件**：.cursor/rules/ai-coding-ok.mdc（新增），AGENTS.md 等 8 个文件（版本标记）
- **注意事项**：框架升级，记忆文件（project-memory.md 等）未变动
```

请按上述步骤执行升级，完成后输出变更摘要。
```

---

## 升级 Prompt — v1.0 → v2.0（旧版参考）

> 如果你的项目版本是 v1.0，先用这个 prompt 升级到 v2.0，再用上面的 prompt 升级到 v2.1.0。

```
请帮我将项目的 ai-coding-ok 框架升级到 v2.0。按以下步骤执行：

## Step 1 — 检测当前版本

读取以下文件的第一行，检查是否有版本标记 `<!-- ai-coding-ok: vX.Y -->` 或 `# ai-coding-ok: vX.Y`：
- AGENTS.md
- .github/copilot-instructions.md
- .github/agent/system-prompt.md
- .github/agent/coding-standards.md
- .github/agent/workflows.md
- .github/agent/prompt-templates.md

如果文件缺少版本标记，视为 v1.0。报告检测结果。

## Step 2 — 执行升级（v1.0 → v2.0 变更清单）

### 2a. AGENTS.md — 新增 PDCA 强制指令章节

在文件标题 `# AGENTS.md — {项目名称}` 之后、`## 项目概述` 之前插入：

```markdown
<!-- ai-coding-ok: v2.0 -->
（在标题行之前）

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

### 2b. .github/copilot-instructions.md — 新增顶部强制指令章节

在文件最顶部（标题之前）插入：

```markdown
<!-- ai-coding-ok: v2.0 -->
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

同时删除文件末尾的「🔗 上下文文件引用」章节（已被顶部版本替代）。

### 2c. 添加版本标记

在以下文件的第一行添加版本标记：
- `.github/agent/system-prompt.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/agent/coding-standards.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/agent/prompt-templates.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/project-metadata.yml`: `# ai-coding-ok: v2.0`
- `.github/workflows/ci.yml`: `# ai-coding-ok: v2.0`

## Step 3 — 验证

1. 确认所有文件的版本标记已更新到 v2.0
2. 确认项目特有内容（项目名称、技术栈、架构图等）未被改动

## Step 4 — 记录升级

在 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 v2.0
- **日期**：{今天日期}
- **类型**：chore
- **摘要**：升级 ai-coding-ok 框架至 v2.0；新增 PDCA 强制指令章节；强化 workflows.md 收尾步骤标注
- **变更文件**：AGENTS.md, .github/copilot-instructions.md, .github/agent/workflows.md 等
- **注意事项**：框架升级，记忆文件未变动
```

请按上述步骤执行升级，完成后输出变更摘要。
```


---

## 升级完成后

升级完成后，ai-coding-ok 将在每次 Copilot 会话中自动执行 PDCA 工作流：
1. **任务开始前**：读取记忆文件，加载项目上下文
2. **任务结束后**：更新记忆文件，沉淀本次工作成果

这确保了 AI 不会「忘记」之前的架构决策和项目约束。
