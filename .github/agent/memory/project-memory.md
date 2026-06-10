# 🧠 ai-coding-ok — 项目长期记忆

> **用途**：存储项目的稳定事实、架构决策、关键约束和常见问题。
> AI Agent 在每次任务开始时应阅读此文件获取上下文。
> 当项目发生重大变化时，必须同步更新此文件。

---

## 📋 项目基本信息

| 属性 | 值 |
|------|---|
| 项目名称 | ai-coding-ok |
| 项目类型 | AI 编程护栏 Skill 框架 |
| 业务场景 | 为任意开发者项目安装三层记忆系统（project-memory + decisions-log + task-history），强制执行 PDCA 工作流，防止 AI "修了 bug X 搞坏功能 Y" |
| 用户规模 | 面向所有使用 Claude Code、GitHub Copilot、Cursor 的开发者 |
| 当前阶段 | v3.1.0 已完成（五层防御体系：CLAUDE.md STOP 指令 + AGENTS.md Plan 7 步 + copilot-instructions Act 4 步 + .claude/settings.local.json 四重 hooks + 安装自动配置） |
| 设计原则 | 可靠 > 易用 > 简洁；硬约束 > 软建议；多平台兼容；零外部依赖 |
| 主语言 | Shell + Python 3 + Markdown |
| 后端框架 | 无（非 Web 项目，是 Skill 框架） |
| 数据库 | 无 |

---

## 🏗️ 架构概述

```
ai-coding-ok/
├── SKILL.md                    ← Skill 定义入口（Mode A/B/C/D）
├── CLAUDE.md                   ← Claude Code 自动加载 shim
├── templates/zh/               ← 中文安装模板（产品源码）
├── templates/en/               ← 英文安装模板（产品源码）
├── scripts/                    ← install.sh/py + verify.sh
├── docs/                       ← 使用文档 + 改进方案
├── .github/agent/memory/       ← 本项目自用记忆（dogfooding）
└── .claude/settings.local.json ← Claude Code hooks + 权限配置
```

### 核心特征
- **模板即产品**：`templates/zh/` 和 `templates/en/` 是核心产出物，通过 install 流程分发到下游项目
- **SKILL.md 是大脑**：所有行为逻辑（Mode A/B/C/D、Install/Upgrade Playbook）均在 SKILL.md 中定义
- **占位符系统**：`{{占位符}}` 标注待替换内容，安装时由 AI 推断并填充
- **版本标记**：每个安装文件首行 `<!-- ai-coding-ok: vX.Y -->`，Upgrade 依赖此标记做 diff
- **多平台兼容**：Claude Code（Skill 系统）+ Copilot（copilot-instructions.md 自动加载）+ Cursor（.cursor/rules/）

---

## 🔄 核心业务流程

```
1. 开发者说"install ai-coding-ok"
2. AI invoke Skill(ai-coding-ok) → Mode A Install
3. 复制模板 → 问一句话 → 推断填充占位符 → 引导记忆文件
4. 之后每次编码任务:
   Mode B (Plan) → 读取 AGENTS + agent 规范 + 记忆文件
   Mode C (Act)  → 更新 task-history（始终）+ decisions-log/project-memory（按需）
5. 开发者说"upgrade ai-coding-ok"
6. AI invoke Skill(ai-coding-ok) → Mode D Upgrade
7. 检测版本 → diff 模板 → 合并变更 → 保留项目定制
```

---

## 📦 核心模块

| 模块 | 说明 | 状态 |
|------|------|------|
| SKILL.md | Skill 定义文件，Mode A/B/C/D 完整逻辑 + Install/Upgrade Playbook | ✅ 完成 |
| templates/zh/ | 中文安装模板（AGENTS + CLAUDE + agent 规范 + 记忆文件 + CI） | ✅ 完成 |
| templates/en/ | 英文安装模板（同上结构） | ✅ 完成 |
| scripts/install.sh | Bash 安装脚本 | ✅ 完成 |
| scripts/install.py | Python 安装脚本 | ✅ 完成 |
| scripts/verify.sh | 安装完整性验证 | ✅ 完成 |
| docs/ | 使用文档：quickstart × 2、FAQ、superpowers-combo、改进方案 | ✅ 完成 |
| .claude/settings.local.json hooks | Claude Code 四重 hooks 模板（SessionStart/UserPromptSubmit/PreToolUse/Stop） | 🔨 v3.1.0 规划中 |

---

## ⚠️ 关键约束

1. **不可未经用户明确许可执行 git push** — 永远不在用户未明确要求时推送到远程仓库
2. **模板不可被安装流程修改** — `templates/zh/` 和 `templates/en/` 是框架源码，只有开发 ai-coding-ok 本身时可以改
3. **占位符不可泄漏到项目文件** — 安装后所有 `{{...}}` 必须已被替换，verify.sh 检查确认无残留
4. **zh/en 模板必须同步更新** — 不可只改一个语言，新增功能需同时覆盖两套模板
5. **零外部依赖** — install.sh 仅依赖 bash 内置命令，install.py 仅依赖 Python 3 标准库
6. **记忆文件只能追加** — project-memory.md 和 decisions-log.md 不删除历史内容，task-history.md 保留最近 30 条

---

## 🐛 已知问题 & 常见坑

| 编号 | 问题描述 | 解决方案 | 日期 |
|------|---------|---------|------|
| 1 | ai-coding-ok 在真实项目中经常不被触发 | ✅ 已解决 — v3.1.0 五层防御体系（见 docs/hook-trigger-remediation-plan.md） | 2026-06-08 |
| 2 | settings.json 与 settings.local.json 冲突导致 hooks 失效 | 安装时只写 settings.local.json，不创建 settings.json | 2026-06-06 |
| 3 | agent 文档（system-prompt/workflows/coding-standards）长期不维护导致内容过时 | AGENTS.md Plan 阶段从 3 步扩展到 7 步，覆盖所有 agent 文档 | 2026-06-07 |

---

## 🔧 开发环境

### 启动方式
```bash
# 本项目无需"启动"——它是 Skill 框架，通过 Claude Code / Copilot 加载

# 在目标项目中安装
bash install.sh

# 验证安装
bash scripts/verify.sh

# 查看版本
head -1 AGENTS.md
```
