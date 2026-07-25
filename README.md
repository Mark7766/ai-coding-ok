# 🧠 ai-coding-ok

> **AI 编程的 PDCA 记忆闭环。**
> superpowers 给 Claude 一个 session 的纪律。ai-coding-ok 给 Claude 跨 50 次迭代依然准确的记忆。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Works with](https://img.shields.io/badge/Works%20with-Claude%20Code%20%7C%20Copilot%20%7C%20Cursor%20%7C%20OpenCode%20%7C%20Codex-blueviolet)](#)
[![Version](https://img.shields.io/badge/Version-v4.1.0-blue)](#)

---

## 要解决的问题

你让 Claude 完成了一个功能。三个 session 之后，Claude 通过静默删除它上周添加的约束来"修复"一个 bug。到第 50 次迭代，你的代码库里到处都是看不见的回归问题。

这不是 prompt 的问题，这是**缺乏反馈闭环的记忆问题**。

大多数 AI 工具（包括 [superpowers](https://github.com/obra/superpowers)）解决的是**单个 session 内的纪律**——编码前写计划、TDD、code review。但没有一个解决**跨 session 的记忆漂移**。

---

## ai-coding-ok 如何解决

四阶段 **PDCA 闭环**，每次任务强制执行：

```
  Plan          Do            Check         Act
 ─────▶       ─────▶         ─────▶        ─────▶
读取         编写           运行           更新
记忆         代码+          测试，         记忆
文件         测试           验证           文件
                           无回归
```

| 阶段 | 做什么 |
|------|--------|
| **Plan** | Claude 在改代码前读取 `project-memory.md`、`decisions-log.md`、`task-history.md` |
| **Do** | 同一变更中同时编写代码和测试 |
| **Check** | 运行测试，发现无关功能的回归 |
| **Act** | Claude 写回记忆：`task-history.md` 始终更新；架构变更时更新 `decisions-log.md`；事实变更时更新 `project-memory.md` |

**Act** 步骤是大多数工具缺失的。没有它，记忆文件就是一张快照——10 次迭代后就腐烂了，因为没人更新。有了它，context 保持准确，因为每次任务都闭环。

---

## 三层记忆

| 层级 | 文件 | 内容 | 更新频率 |
|------|------|------|---------|
| 长期 | `project-memory.md` | 架构、约束、已知问题 | 很少 |
| 中期 | `decisions-log.md` | ADR（为什么选 X 而不是 Y） | 架构变更时 |
| 短期 | `task-history.md` | 最近 30 条任务摘要 | 每次任务 |

第 50 次迭代读取的仍然是第 1 次迭代那三个文件——但它们已经积累了 50 条复合 context。这就是关键。

---

## 安装

### 准备工作：下载 ai-coding-ok

```bash
git clone https://github.com/Mark7766/ai-coding-ok ~/ai-coding-ok
```

> 只需执行一次，所有项目共用这一份。

---

### 方式一：Claude Code / Codex / OpenCode（推荐）

这三种工具支持 **skill 系统**——只需全局安装一次，之后在任意项目中一句话就能初始化。

```bash
# 全局安装 skill（选你用的工具，只需执行一次）
bash ~/ai-coding-ok/install.sh --claude-code   # Claude Code
bash ~/ai-coding-ok/install.sh --codex          # Codex
bash ~/ai-coding-ok/install.sh --opencode       # OpenCode
```

然后在**任意项目**中，对 AI 说（**记得带一句项目描述**）：

```
安装 ai-coding-ok，我想做一个个人记账工具，记录每天花销和收入
```

AI 会读取 skill 中的模板，自动复制到项目里，根据你的一句话描述推断技术栈，填好所有占位符。PDCA 闭环立即可用。

---

### 方式二：Copilot / Cursor

这两种工具没有 skill 系统，需要**在每个项目里单独复制模板**。

```bash
cd ~/你的项目目录

# 复制模板到当前项目
bash ~/ai-coding-ok/install.sh --copilot   # Copilot
bash ~/ai-coding-ok/install.sh --cursor    # Cursor
```

然后对 AI 说（**记得带一句项目描述**）：

```
安装 ai-coding-ok，我想做一个xxx
```

---

> **Claude Code 用户额外获得**：`CLAUDE.md`（自动加载 AGENTS.md）+ `.claude/settings.local.json`（四重 hooks 硬约束），提供最强 PDCA 保障。

---

## 安装到项目中的文件

```
你的项目/
├── AGENTS.md                          # 架构速查（AI 首先读取，Codex/OpenCode 自动加载）
├── CLAUDE.md                          # Claude Code 自动加载 shim → @AGENTS.md
├── .codex/skills/ai-coding-ok/        # Codex skill 定义
├── .cursor/rules/ai-coding-ok.mdc     # Cursor：alwaysApply PDCA 规则
└── .github/
    ├── copilot-instructions.md        # Copilot：自动加载的行为规则
    ├── project-metadata.yml           # 机器可读的项目事实
    ├── PULL_REQUEST_TEMPLATE.md       # PR 模板（记忆更新 checklist）
    ├── ISSUE_TEMPLATE/                # Issue 模板
    ├── workflows/                     # CI + 记忆更新提醒
    └── agent/
        ├── system-prompt.md           # Agent 人格 + PDCA 工作流
        ├── coding-standards.md        # 编码规范
        ├── workflows.md               # 场景工作流
        ├── prompt-templates.md        # Prompt 模板库
        └── memory/
            ├── project-memory.md      # 🧠 长期：项目事实
            ├── decisions-log.md       # 📝 中期：ADR
            └── task-history.md        # 📜 短期：最近 30 条任务
```

---

## 与 superpowers 搭配使用

ai-coding-ok 和 [superpowers](https://github.com/obra/superpowers) 解决不同的问题，可以无缝组合：

> **superpowers** 带来单 session 的纪律。
> **ai-coding-ok** 带来跨 session 的记忆。

组合流程：

```
1. ai-coding-ok 模式 B  (Plan: 加载记忆)        ← 每次任务开始
2. superpowers           (brainstorming → planning → execution)
3. ai-coding-ok 模式 C  (Act: 写回记忆)          ← 每次任务结束
```

详见 [`docs/superpowers-combo.md`](docs/superpowers-combo.md)，包含五个实战配方。

---

## 与手写 AGENTS.md 的区别

手写 AGENTS.md 是一张快照。10 次迭代后就过时了，因为没人更新它。ai-coding-ok 自动化了 **Act** 步骤——Claude 在每次任务后写回记忆，让文件保持生命力。

| | 手写 AGENTS.md | ai-coding-ok |
|---|---|---|
| 初始设置 | 手动填占位符 | 一句话提问，AI 推断其余 |
| 中期决策 | 丢失（或散落在 PR 描述中） | 在 `decisions-log.md` 中作为 ADR 捕获 |
| 近期任务 context | session 间丢失 | `task-history.md` 保存最近 30 条 |
| 记忆更新 | 手动（且经常被遗忘） | 通过 PDCA Act 阶段自动执行 |
| 多工具支持 | 每个工具一个文件 | 一套模板，所有工具自动加载 |

---

## 坦诚的局限

- Act 步骤依赖 Claude 实际遵循指令写回记忆。实战中约 95% 可靠；剩余 5% 可被 CI 中运行的 `scripts/verify.sh` 捕获。
- 记忆文件会随时间增长。`task-history.md` 按约定上限 30 条；`project-memory.md` 应保持在 500 行以内，否则收益递减（将旧事实轮转到 ADR）。
- ai-coding-ok 对文件布局有自己的主张。如果你已有手写编辑的 `AGENTS.md`，首次安装时需要手动合并。

---

## 升级

升级分两层：先升级 skill 本身（全局），再升级各个项目里的框架文件（项目）。

### 第一步：升级 skill 本身

```bash
cd ~/ai-coding-ok && git pull
```

如果你是 **Claude Code / Codex / OpenCode** 用户，还需要把最新版同步到 skill 目录：

```bash
bash ~/ai-coding-ok/install.sh --claude-code --force   # Claude Code
bash ~/ai-coding-ok/install.sh --codex --force          # Codex
bash ~/ai-coding-ok/install.sh --opencode --force       # OpenCode
```

> Copilot / Cursor 用户跳过这步——你们没有全局 skill，直接做下一步。

### 第二步：升级各个项目

进入每个已安装 ai-coding-ok 的项目，对 AI 说：

```
升级 ai-coding-ok
```

AI 会检测项目当前版本、列出框架变更、征得你确认后合并升级——保留你的项目定制。

> 如果不方便用 AI 自动升级，把 [`scripts/upgrade-prompt.md`](scripts/upgrade-prompt.md) 的内容粘贴给你的 AI 工具即可。

---

## 验证

安装后检查一切是否正确连接：

```bash
bash ~/ai-coding-ok/scripts/verify.sh
```

退出码：`0` = 正常，`1` = 缺失文件，`2` = 未填充的占位符。

---

## 文档

- [Claude Code 快速上手](docs/claude-code-quickstart.md)
- [Copilot 快速上手](docs/copilot-quickstart.md)
- [与 superpowers 组合使用](docs/superpowers-combo.md)
- [常见问题](docs/faq.md)
- [SKILL.md](skills/ai-coding-ok/SKILL.md) — 规范 skill 定义
- [CHANGELOG](CHANGELOG.md)

---

## 设计哲学

1. **一次安装，所有工具** — Claude Code、Copilot、Cursor、OpenCode、Codex 共享同一套模板
2. **让 AI 定制 AI 的配置** — 用户说一句话，AI 推断其余
3. **默认安全** — 除非 `--force`，否则永不覆盖已有文件
4. **可审计** — 每次安装/升级在 `task-history.md` 中留下痕迹

---

## 贡献

欢迎 Issue 和 PR。模板编辑在 `templates/zh/` 中进行。Skill 行为编辑在 `skills/ai-coding-ok/SKILL.md` 中进行。文档编辑在 `docs/` 中进行。

---

## 许可证

[MIT](LICENSE) — 允许商业使用。
