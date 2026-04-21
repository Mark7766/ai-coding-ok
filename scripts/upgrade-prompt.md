# ai-coding-ok 升级 Prompt

> **用途**：给不支持 skill 系统的 Copilot 用户使用的升级 prompt。
> **使用方式**：复制以下内容到 Copilot Chat 中执行。

---

## 使用前准备

1. 确保你的项目已经安装过 ai-coding-ok v1.0（即项目中有 `.github/agent/memory/` 目录）
2. 下载最新版本的 ai-coding-ok 仓库或确保可以访问最新的 templates/ 目录

---

## 升级 Prompt

将以下内容复制到 Copilot Chat：

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

### 2c. .github/agent/workflows.md — 修改收尾步骤

1. 场景 1（Feature）的 Step 5 改为：
```
Step 5: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  ├── 如有架构决策 → 更新 decisions-log.md
  ├── 如有项目事实变化 → 更新 project-memory.md
  └── 提交代码（Conventional Commits 格式）
```

2. 场景 2（Fix）的 Step 5 改为：
```
Step 5: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  └── 如果是常见坑 → 更新 project-memory.md
```

3. 场景 3（Refactor）新增 Step 4：
```
Step 4: 收尾 ⚠️ 不可跳过
  ├── 更新 task-history.md ← 必须
  ├── 如重构改变了模块结构 → 更新 project-memory.md
  └── 如有技术决策 → 更新 decisions-log.md
```

### 2d. 添加版本标记

在以下文件的第一行添加版本标记：
- `.github/agent/system-prompt.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/agent/coding-standards.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/agent/prompt-templates.md`: `<!-- ai-coding-ok: v2.0 -->`
- `.github/project-metadata.yml`: `# ai-coding-ok: v2.0`
- `.github/workflows/ci.yml`: `# ai-coding-ok: v2.0`

## Step 3 — 验证

1. 确认所有文件的版本标记已更新到 v2.0
2. 确认项目特有内容（项目名称、技术栈、架构图等）未被改动
3. 确认没有遗留的 `{{占位符}}`

## Step 4 — 记录升级

在 `.github/agent/memory/task-history.md` 追加：

```markdown
### [TASK-00N] 升级 ai-coding-ok 至 v2.0
- **日期**：{今天日期}
- **类型**：chore
- **摘要**：升级 ai-coding-ok 框架至 v2.0；新增 PDCA 强制指令章节到 AGENTS.md 和 copilot-instructions.md；强化 workflows.md 收尾步骤标注
- **变更文件**：AGENTS.md, .github/copilot-instructions.md, .github/agent/workflows.md, .github/agent/system-prompt.md, .github/agent/coding-standards.md, .github/agent/prompt-templates.md, .github/project-metadata.yml, .github/workflows/ci.yml
- **注意事项**：框架升级，记忆文件（project-memory.md 等）未变动
```

请按上述步骤执行升级，完成后输出变更摘要。
```

---

## 升级完成后

升级完成后，ai-coding-ok 将在每次 Copilot 会话中自动执行 PDCA 工作流：
1. **任务开始前**：读取记忆文件，加载项目上下文
2. **任务结束后**：更新记忆文件，沉淀本次工作成果

这确保了 AI 不会「忘记」之前的架构决策和项目约束。
