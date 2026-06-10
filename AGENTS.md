<!-- ai-coding-ok: v3.1.0 -->
# AGENTS.md — ai-coding-ok

## ⚠️ AI Agent 必读规范（每次任务必须执行）

本项目使用 [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) 三层记忆系统。**在执行任何任务之前，必须完成以下步骤：**

### Plan 阶段（强制，任务开始前）
1. 读取 `AGENTS.md` — 本文件，架构速查
2. 读取 `.github/agent/system-prompt.md` — Agent 人格、角色切换、行为边界
3. 读取 `.github/agent/workflows.md` — 场景工作流（Feature/Bug/Refactor/发布）
4. 读取 `.github/agent/coding-standards.md` — 编码规范
5. 读取 `.github/agent/memory/project-memory.md` — 项目事实和架构约束
6. 读取 `.github/agent/memory/decisions-log.md` — 历史技术决策
7. 读取 `.github/agent/memory/task-history.md` — 近期任务上下文

### Act 阶段（强制，任务结束后）
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构决策变化 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`
4. 如 AGENTS.md / system-prompt.md / workflows.md / coding-standards.md 有事实性过时内容 → 同步更新对应文件

> ⛔ 以上步骤不可跳过。若在使用 superpowers brainstorming / writing-plans，
> 在调用这些 skill **之前**先完成 Plan 阶段，**结束后**完成 Act 阶段。

---

## 项目概述

ai-coding-ok 是一个 **AI 编程护栏 Skill 框架**。为任意项目安装三层记忆系统（project-memory + decisions-log + task-history）并强制执行 PDCA 工作流，确保 AI Agent 在每次编码任务前后读取和更新项目记忆，解决"AI 修了 bug X 却搞坏了功能 Y"的问题。目标用户是所有使用 Claude Code、GitHub Copilot、Cursor 的开发者。

## 系统架构与数据流

```
开发者发起编码任务
      │
      ▼
CLAUDE.md (@AGENTS.md) ──→ AGENTS.md (PDCA 强制指令)
      │
      ├── Plan: 读取 7 个文件（AGENTS + 3 agent 规范 + 3 记忆文件）
      ├── Do:   编码 + 测试
      ├── Check: 验证
      └── Act:   更新记忆文件（task-history 始终 + decisions-log/project-memory 按需）

跨平台兼容层：
  Claude Code  → SKILL.md (Mode A/B/C/D) + CLAUDE.md shim
  Copilot      → .github/copilot-instructions.md (自动加载)
  Cursor       → .cursor/rules/ai-coding-ok.mdc
```

- **`SKILL.md`** — Skill 定义文件，包含 Mode A(Install) / B(Plan) / C(Act) / D(Upgrade) 完整逻辑
- **`templates/zh/` `templates/en/`** — 双语安装模板（AGENTS.md + 三层记忆文件 + agent 规范），安装时自动替换占位符
- **`scripts/`** — install.sh / install.py 自动化安装脚本 + verify.sh 安装验证 + customize-prompt.md / upgrade-prompt.md 手动触发提示

## 常用命令

```bash
# 安装（在目标项目中执行）
bash install.sh
# 或
python3 install.py

# 验证安装
bash scripts/verify.sh

# 查看 skill 文件结构
find . -type f -not -path './.git/*' | sort
```

## 约定与模式

- **模板优先** — 所有安装文件来源于 `templates/zh/` 或 `templates/en/`，修改行为应先在模板中完成
- **占位符替换** — 模板中 `{{占位符}}` 由安装流程（SKILL.md Mode A Step 5-6）自动填充，不可手动填
- **版本标记** — 每个已安装文件第一行含 `<!-- ai-coding-ok: vX.Y -->`，Upgrade 模式依赖此标记
- **双语维护** — zh/ 和 en/ 模板必须同步更新，不可只改一个语言
- **非代码项目** — 本工程以 Markdown + Shell + Python 为主，无 Web 框架、无数据库、无前端
- **SKILL.md 是入口** — 所有行为定义在 SKILL.md 中，AGENTS.md / copilot-instructions.md 是项目级指令

## 重要约束

- **禁止重量级依赖** — 安装脚本仅依赖 Python 3 标准库或 Bash，不引入任何第三方框架
- **敏感数据** — 本框架不涉及凭据，GitHub Token 等由用户自行管理
- **版本兼容** — 通过语义版本管理（vMAJOR.MINOR.PATCH），Upgrade mode 自动 diff 模板与项目文件，保留项目定制
- **不可删除模板** — `templates/` 目录是框架源码，不可被安装或升级流程修改
- **跨平台** — 所有路径使用 `/`，Shell 脚本兼容 bash/zsh，Python 脚本兼容 3.8+

