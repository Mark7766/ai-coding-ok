# ai-coding-ok 触发可靠性整改方案

> **生成日期**：2026-06-08
> **来源项目**：codex-switch-server（经过 30+ 轮实战迭代验证）
> **目标版本**：ai-coding-ok v3.1.0
> **目标**：确保 ai-coding-ok 在任何 Claude Code 项目中被可靠触发，PDCA 循环不可跳过

---

## 目录

1. [问题诊断：为什么 ai-coding-ok 经常不被触发](#1-问题诊断)
2. [解决方案：五层防御体系](#2-解决方案五层防御体系)
3. [各层详细方案](#3-各层详细方案)
4. [安装流程改造](#4-安装流程改造)
5. [升级路径](#5-升级路径)
6. [验收标准](#6-验收标准)
7. [参考资料](#7-参考资料)

---

## 1. 问题诊断

### 1.1 现状回顾

ai-coding-ok 当前依赖以下链路来触发 PDCA：

```
CLAUDE.md (@AGENTS.md) → AGENTS.md (Plan/Act 文字指令) → AI 主动遵守
```

这个链路有两个致命缺陷：

| 缺陷 | 说明 | 后果 |
|------|------|------|
| **纯文本依赖** | 所有指令都是 Markdown 文字，AI 可以"选择性忽略" | 忙碌/长上下文时，AI 跳过 Plan 阶段直接写代码 |
| **无强制约束** | 没有 Claude Code hooks 机制介入，没有退出码阻断 | AI 可以在不更新记忆文件的情况下结束会话 |
| **CLAUDE.md 太弱** | 模板的 CLAUDE.md 只有 `@AGENTS.md` 导入，没有 STOP 级指令 | Claude Code 加载 CLAUDE.md 后不把 PDCA 当作最高优先级 |
| **AGENTS.md Plan 阶段太短** | 只要求读 3 个记忆文件，不要求读 agent 文档 | system-prompt.md / workflows.md / coding-standards.md 长年不过时无人发现 |

### 1.2 实战验证：codex-switch-server 的经验

在 codex-switch-server 项目中，ai-coding-ok 经历了以下迭代才逐步稳定：

| 阶段 | 任务 | 做了什么 | 效果 |
|------|------|---------|------|
| 1 | TASK-016 | CLAUDE.md 强化 + sessionStart hook 修复 | 从"完全不触发"到"偶尔触发" |
| 2 | TASK-023 | Stop hook 改为 `asyncRewake: true` + exit 2 | 从"偶尔触发"到"大部分触发" |
| 3 | TASK-024 | AGENTS.md Plan 阶段从 3 步扩展到 7 步 | agent 文档不再腐化 |
| 4 | TASK-027 | 发现 Act 阶段只更新 task-history 的坏习惯 | 仍需强化 Stop hook 提示 |
| 5 | TASK-030 | 新增 git push / SSH / docker compose 三个阻断钩子 | 安全操作有保障 |

**关键发现**：仅靠 AGENTS.md 里的文字指令（"必须读取 XXX"），在长时间会话、大量上下文、频繁的工具调用下，AI 会跳过 PDCA。**必须用 Claude Code hooks 机制来硬约束**。

### 1.3 触发失败的五种典型场景

| 场景 | 描述 | 根因 |
|------|------|------|
| **新会话首问** | 用户开口就是"帮我加个功能"，AI 直接写代码 | CLAUDE.md 太弱，AI 不认为必须先 invoke skill |
| **长上下文衰减** | 会话超过 30 轮后，早期的 Plan 指令被遗忘 | 纯文本指令在长上下文中优先级下降 |
| **惯性编码** | AI 在连续多轮编码后进入"惯性模式"，跳过 Act | 没有 Stop hook 阻断 |
| **子任务遗忘** | 用 subagent 执行子任务时，子 agent 不知道要更新记忆 | 子 agent 不读 AGENTS.md |
| **简单任务遗漏** | 用户说"改个 typo"，AI 改完就走 | 没有 hook 提示，AI 认为"太简单不需要 Act" |

---

## 2. 解决方案：五层防御体系

借鉴 codex-switch-server 的实战经验，设计五层防御体系，确保至少有一层能拦住 AI：

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: CLAUDE.md 硬指令                                   │
│  "⛔ STOP — CALL Skill(ai-coding-ok) BEFORE ANY CODE WORK"   │
│  每个会话启动时 Claude Code 自动加载，第一行就是 STOP 指令     │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: AGENTS.md Plan 阶段扩展（3 → 7 步）                 │
│  不仅读记忆文件，还要读 agent 文档，Act 阶段增加文档同步       │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: copilot-instructions.md 强制记忆更新输出节           │
│  "记忆更新" 节必须出现在 Agent 输出中，不输出视为不合规         │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Claude Code Hooks（四重钩子）                       │
│  SessionStart → UserPromptSubmit → PreToolUse → Stop         │
│  在关键节点用 echo 提醒 + exit 2 阻断                         │
├─────────────────────────────────────────────────────────────┤
│  Layer 5: Install 自动生成 hooks 配置                         │
│  安装时自动将 hooks 写入 .claude/settings.local.json          │
└─────────────────────────────────────────────────────────────┘
```

**核心原则**：每一层都是独立的防线，任何一层被跳过都不会导致整体失效。

---

## 3. 各层详细方案

### 3.1 Layer 1：CLAUDE.md 硬指令

**当前状态**（ai-coding-ok v3.0.0 模板）：

```markdown
<!-- ai-coding-ok: v3.0.0 -->
# CLAUDE.md
> Claude Code 自动加载本文件。它通过 `@` 语法导入项目级 AGENTS.md...
@AGENTS.md
```

**问题**：被动描述，没有 STOP 级指令。AI 读了 CLAUDE.md 但可能不执行里面的指令。

**目标状态**（来自 codex-switch-server 验证）：

```markdown
<!-- ai-coding-ok: v3.1.0 -->
# ⛔ STOP — CALL Skill("ai-coding-ok") BEFORE ANY CODE WORK.
# THEN CALL Skill("ai-coding-ok") AFTER ALL WORK.
# THIS IS NON-NEGOTIABLE.

@AGENTS.md
```

**改动要点**：
- 第一行必须是 ALL-CAPS 直接指令，包含 `⛔ STOP` 标记
- 明确要求 Before + After 两次 invoke
- 使用 `NON-NEGOTIABLE` 措辞，消除 AI 的"可选"判断空间
- 保留 `@AGENTS.md` 导入，确保 AGENTS.md 也被加载

### 3.2 Layer 2：AGENTS.md Plan/Act 阶段扩展

**当前状态**（ai-coding-ok v3.0.0 模板 Plan 阶段）：

```markdown
### Plan 阶段（强制，任务开始前）
1. 读取 `.github/agent/memory/project-memory.md`
2. 读取 `.github/agent/memory/decisions-log.md`
3. 读取 `.github/agent/memory/task-history.md`
```

**问题**：缺少对 agent 自身文档（system-prompt.md / workflows.md / coding-standards.md）的 Plan 读取要求。codex-switch-server 发现这些文件长期不维护，内容严重过时。

**目标状态**（来自 codex-switch-server TASK-024 验证）：

```markdown
### Plan 阶段（强制，任务开始前）
1. 读取 `AGENTS.md` — 本文件，架构速查
2. 读取 `.github/agent/system-prompt.md` — Agent 人格、角色切换、行为边界
3. 读取 `.github/agent/workflows.md` — 场景工作流（Feature/Bug/Refactor/部署）
4. 读取 `.github/agent/coding-standards.md` — 编码规范
5. 读取 `.github/agent/memory/project-memory.md` — 项目事实和架构约束
6. 读取 `.github/agent/memory/decisions-log.md` — 历史技术决策
7. 读取 `.github/agent/memory/task-history.md` — 近期任务上下文

### Act 阶段（强制，任务结束后）
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`
4. 如 AGENTS.md / system-prompt.md / workflows.md / coding-standards.md 有事实性过时内容 → 同步更新对应文件
```

**改动要点**：
- Plan 从 3 步扩展到 7 步（覆盖所有 agent 文档）
- Act 新增第 4 条：同步更新过时的 agent 文档
- 解决 `system-prompt.md` / `workflows.md` / `coding-standards.md` 长期腐化问题

### 3.3 Layer 3：copilot-instructions.md 强制记忆更新输出节

**当前状态**（ai-coding-ok v3.0.1 模板已有记忆更新输出节）：

模板中已经有一个"记忆更新"强制输出节，这是好的。需要确认它在所有语言模板中都存在且措辞足够强硬。

**确认项**：
- ✅ 开头 `<!-- ⛔ MANDATORY: AI Agent MUST execute these steps for EVERY request -->`
- ✅ Plan 阶段 4 步（读 AGENTS.md + 3 个记忆文件）
- ✅ Act 阶段 3 步（更新 3 个记忆文件）
- ✅ "记忆更新"输出节（必填，不可省略）

**模板中已基本到位**，只需要：
1. 确认 zh/en 两套模板都包含相同的强制结构
2. 在 Act 阶段增加：如 agent 文档（system-prompt.md / workflows.md / coding-standards.md）过时 → 同步更新

### 3.4 Layer 4：Claude Code Hooks（核心防线）

**这是本次整改最关键的新增内容。** ai-coding-ok 目前没有任何 hooks 配置模板。

#### 3.4.1 目标 hooks 配置

来自 codex-switch-server 经过 30+ 轮迭代验证的 hooks 配置：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA GATE: Invoke Skill(ai-coding-ok) Plan BEFORE code. Update memory AFTER. <<<'"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA: Is this coding? Invoke Skill(ai-coding-ok) BEFORE + AFTER. <<<'"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA PLAN: Are you about to edit code? Invoke Skill(ai-coding-ok) Plan phase FIRST. <<<'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "CHANGED=$(git diff --name-only 2>/dev/null | grep -c '^src/\\|^tests/\\|^lib/\\|^app/'); if [ \"$CHANGED\" -gt 0 ]; then echo '>>> PDCA ACT BLOCK: You have '${CHANGED}' source files changed. MANDATORY: (1) task-history.md (2) decisions-log.md? (3) project-memory.md? <<<' && exit 2; else echo '>>> PDCA ACT: No source changes, skip. <<<'; fi",
            "asyncRewake": true
          }
        ]
      }
    ]
  }
}
```

#### 3.4.2 四个 hook 的设计意图

| Hook | 触发时机 | 设计目的 | 阻断机制 |
|------|---------|---------|---------|
| **SessionStart** | 每次新会话启动 | 在 AI 开始工作前提醒 PDCA | 无阻断（仅提醒） |
| **UserPromptSubmit** | 用户每次提交 prompt | 在每次交互开始时提醒 PDCA | 无阻断（仅提醒） |
| **PreToolUse (Edit/Write)** | AI 准备编辑/写入文件前 | 防止"不读记忆就直接改代码" | 无阻断（仅提醒） |
| **Stop** | AI 尝试结束回复时 | 检测有源码变更但未更新记忆文件的情况 | **阻断（exit 2 + asyncRewake）** |

#### 3.4.3 Stop hook 的关键设计

Stop hook 是整个防御体系的最后一道关：

```bash
CHANGED=$(git diff --name-only 2>/dev/null | grep -c '^src/\|^tests/\|^lib/\|^app/')
if [ "$CHANGED" -gt 0 ]; then
  echo '>>> PDCA ACT BLOCK: ... <<<'
  exit 2
fi
```

**关键参数**：
- `asyncRewake: true` — 退出码 2 会强制唤醒 AI，不更新记忆文件就无法"自然结束"
- 匹配模式 `src/|tests/|lib/|app/` — 覆盖主流项目结构，可根据项目定制
- exit 2 — 告诉 Claude Code 这不是致命错误，而是需要 AI 继续工作的信号

#### 3.4.4 项目特定的 PreToolUse 阻断钩子

codex-switch-server 还加了三个项目特定的安全阻断钩子：

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "echo '>>> PUSH BLOCKER: git push detected...' && exit 2",
      "if": "Bash(git push*)",
      "asyncRewake": true
    },
    {
      "type": "command", 
      "command": "echo '>>> DEPLOY BLOCKER: SSH to production...' && exit 2",
      "if": "Bash(*ssh*<production-ip>*)",
      "asyncRewake": true
    },
    {
      "type": "command",
      "command": "echo '>>> DEPLOY BLOCKER: docker compose up...' && exit 2",
      "if": "Bash(*docker compose up*)",
      "asyncRewake": true
    }
  ]
}
```

**整改决定**：这些安全阻断钩子属于项目特定配置，**不应放入通用模板**。但应在安装时询问用户是否需要，并在文档中提供示例。

### 3.5 Layer 5：安装流程自动化

#### 3.5.1 安装时自动生成 hooks 配置

当前安装流程（SKILL.md Installation Playbook）没有步骤涉及 hooks 配置。需要新增：

**新增 Step：配置 Claude Code hooks（仅 Claude Code 用户）**

安装完成后，检测 `.claude/` 目录是否存在：
- 如果存在 `settings.local.json`，将 hooks 合并进去（保留用户已有配置）
- 如果存在 `settings.json` 但不存在 `settings.local.json`，创建 `settings.local.json`（避免冲突，见 TASK-016 的经验）
- 如果都不存在，询问用户是否使用 Claude Code，如果是则创建 `.claude/settings.local.json`

**关键经验（来自 TASK-016）**：`settings.json` 与 `settings.local.json` 同时存在时会冲突，导致 hooks 不生效。**只写入 `settings.local.json`**。

#### 3.5.2 安装时询问项目源码目录

Stop hook 的 `grep` 模式需要匹配项目的源码目录。安装时询问：

> "你的项目源码在哪个目录下？（如 `src/`、`lib/`、`app/`，多个用空格分隔）"

默认值：`src/ tests/`

---

## 4. 安装流程改造

### 4.1 当前安装流程（8 steps）

```
Step 1: Locate skill template dir
Step 2: Pick target project  
Step 3: Conflict check
Step 4: Copy templates
Step 5: Ask user what they're building
Step 6: Replace placeholders
Step 7: Bootstrap first memory entries
Step 8: Report back
```

### 4.2 改造后的安装流程（9 steps）

```
Step 1-4: 不变
Step 5: Ask user what they're building
Step 5.5 (NEW): Ask project source directories (for Stop hook)
Step 5.6 (NEW): Generate .claude/settings.local.json with hooks
Step 6: Replace placeholders
Step 7: Bootstrap first memory entries  
Step 8: Report back (include hooks verification)
```

### 4.3 新增模板文件

需要在 `templates/` 下新增：

```
templates/
├── zh/
│   └── .claude/
│       └── settings.local.json   ← 新增：hooks 模板
├── en/
│   └── .claude/
│       └── settings.local.json   ← 新增：hooks 模板
```

`settings.local.json` 模板内容：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA GATE: Invoke Skill(ai-coding-ok) Plan BEFORE code. Update memory AFTER. <<<'"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA: Is this coding? Invoke Skill(ai-coding-ok) BEFORE + AFTER. <<<'"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo '>>> PDCA PLAN: Are you about to edit code? Invoke Skill(ai-coding-ok) Plan phase FIRST. <<<'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "CHANGED=$(git diff --name-only 2>/dev/null | grep -c '{{SOURCE_DIR_PATTERN}}'); if [ \"$CHANGED\" -gt 0 ]; then echo '>>> PDCA ACT BLOCK: You have '${CHANGED}' source files changed. MANDATORY: (1) task-history.md (2) decisions-log.md? (3) project-memory.md? <<<' && exit 2; else echo '>>> PDCA ACT: No source changes, skip. <<<'; fi",
            "asyncRewake": true
          }
        ]
      }
    ]
  }
}
```

`{{SOURCE_DIR_PATTERN}}` 在安装时替换为实际值（如 `^src/\\|^tests/`）。

---

## 5. 升级路径

### 5.1 现有项目升级（v3.0.x → v3.1.0）

已安装 ai-coding-ok 的项目需要手动升级。升级时需要：

1. **更新 CLAUDE.md** — 将模板的弱指令替换为 STOP 级硬指令
2. **更新 AGENTS.md** — Plan 阶段从 3 步扩展到 7 步，Act 阶段新增文档同步
3. **更新 copilot-instructions.md** — 确认 PDCA 强制指令块和记忆更新输出节存在
4. **新建 `.claude/settings.local.json`** — 添加四重 hooks
5. **更新版本标记** — 所有文件 v3.0.x → v3.1.0

### 5.2 升级时的注意事项

- **settings.local.json 冲突**：如果项目已有 `settings.local.json`，需要将 hooks 合并进去，不能覆盖
- **settings.json 冲突**：如果项目有 `settings.json`，提醒用户 `settings.json` 与 `settings.local.json` 会冲突（见 TASK-016 经验），建议合并到后者
- **Stop hook 的源码匹配模式**：需要适配每个项目的实际源码目录结构
- **AGENTS.md 保留项目定制内容**：Plan/Act 阶段是框架级变更，但其下的项目概述/架构/约定等是项目定制的，不能覆盖

---

## 6. 验收标准

### 6.1 模板层验收

- [ ] `templates/zh/CLAUDE.md` 第一行包含 `⛔ STOP — CALL Skill("ai-coding-ok")` 指令
- [ ] `templates/en/CLAUDE.md` 第一行包含 `⛔ STOP — CALL Skill("ai-coding-ok")` 指令
- [ ] `templates/zh/AGENTS.md` Plan 阶段包含 7 个步骤
- [ ] `templates/en/AGENTS.md` Plan 阶段包含 7 个步骤
- [ ] `templates/zh/AGENTS.md` Act 阶段包含文档同步（第 4 条）
- [ ] `templates/en/AGENTS.md` Act 阶段包含文档同步（第 4 条）
- [ ] `templates/zh/.claude/settings.local.json` 存在且包含四重 hooks
- [ ] `templates/en/.claude/settings.local.json` 存在且包含四重 hooks
- [ ] `templates/zh/.github/copilot-instructions.md` 记忆更新输出节完整
- [ ] `templates/en/.github/copilot-instructions.md` 记忆更新输出节完整
- [ ] 所有文件版本标记更新为 `v3.1.0`

### 6.2 安装流程验收

- [ ] 新项目安装后 `.claude/settings.local.json` 存在且 hooks 可工作
- [ ] 已有 `settings.json` 的项目不与之冲突
- [ ] Stop hook 检查的源码模式与项目实际结构匹配
- [ ] 安装输出中包含 hooks 验证结果

### 6.3 功能验收

| 场景 | 预期行为 |
|------|---------|
| 新会话首次编码 | SessionStart hook 打印 PDCA GATE 提醒 → AI invoke Skill(ai-coding-ok) |
| 长会话中写代码 | PreToolUse(Edit/Write) hook 提醒 Plan |
| 用户每次发 prompt | UserPromptSubmit hook 提醒 |
| AI 改完代码想结束 | Stop hook 检测 git diff → exit 2 阻断 → AI 更新记忆文件 |
| 纯问答/解释代码 | Stop hook 检测无变更 → 正常结束 |

### 6.4 回归验收

- [ ] 不影响 Copilot 用户体验（不生成 `.claude/` 目录）
- [ ] 不影响 Cursor 用户体验
- [ ] 不影响已有项目的三层记忆文件内容
- [ ] Superpowers skill 的兼容性不受影响

---

## 7. 参考资料

### 7.1 codex-switch-server 关键任务记录

| 任务 | 日期 | 内容 | 经验 |
|------|------|------|------|
| TASK-016 | 2026-06-06 | sessionStart hook 修复：settings.json 与 settings.local.json 冲突 | 只写入 settings.local.json |
| TASK-023 | 2026-06-07 | Stop hook asyncRewake 修复：退出码 2 强制唤醒 | asyncRewake: true 是阻断的关键 |
| TASK-024 | 2026-06-07 | AGENTS.md Plan 阶段 3→7 步 | agent 文档也需要持续维护 |
| TASK-027 | 2026-06-07 | Act 阶段只更新 task-history 的坏习惯 | Stop hook 提示中要强化"检查是否架构变更" |
| TASK-030 | 2026-06-07 | 新增 PreToolUse 安全阻断钩子 | git push / SSH / docker compose 阻断 |

### 7.2 关键配置文件（当前生效版本）

- `codex-switch-server/CLAUDE.md` — STOP 指令的实战版本
- `codex-switch-server/AGENTS.md` — 7 步 Plan 的实战版本
- `codex-switch-server/.claude/settings.local.json` — 四重 hooks 的实战版本
- `codex-switch-server/.github/copilot-instructions.md` — PDCA 强制指令块的实战版本

### 7.3 相关文档

- [ai-coding-ok 综合改进方案 v2.0](./ai-coding-ok-improvement-plan.md) — 上一版改进方案（2026-04-19）
- [Claude Code Quickstart](./claude-code-quickstart.md)
- [FAQ](./faq.md)

---

## 附录 A：变更文件清单

| 文件 | 变更类型 | 说明 |
|------|---------|------|
| `templates/zh/CLAUDE.md` | 修改 | 改为 STOP 级硬指令 |
| `templates/en/CLAUDE.md` | 修改 | 改为 STOP 级硬指令 |
| `templates/zh/AGENTS.md` | 修改 | Plan 3→7 步 + Act 新增文档同步 |
| `templates/en/AGENTS.md` | 修改 | Plan 3→7 步 + Act 新增文档同步 |
| `templates/zh/.github/copilot-instructions.md` | 微调 | Act 阶段新增 agent 文档同步 |
| `templates/en/.github/copilot-instructions.md` | 微调 | Act 阶段新增 agent 文档同步 |
| `templates/zh/.claude/settings.local.json` | **新增** | 四重 hooks 模板 |
| `templates/en/.claude/settings.local.json` | **新增** | 四重 hooks 模板 |
| `SKILL.md` | 修改 | 安装流程新增 hooks 配置步骤 |
| `install.sh` | 修改 | 新增 hooks 安装逻辑 |
| `install.py` | 修改 | 新增 hooks 安装逻辑 |
| `CHANGELOG.md` | 修改 | 记录 v3.1.0 变更 |

## 附录 B：不在本次范围的内容

以下内容在 codex-switch-server 中存在，但**不纳入通用模板**（属于项目特定配置）：

- `PreToolUse` 的 git push / SSH / docker compose 安全阻断钩子 → 在文档中提供示例，安装时询问用户是否添加
- `settings.local.json` 中的 `permissions.allow` 配置 → 项目特定
- `AGENTS.md` 中的项目概述/架构/约定/设计规范 → 项目定制内容，由用户维护
