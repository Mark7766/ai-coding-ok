# 🧠 ai-coding-ok

> 一个可以直接安装的 **AI 编程记忆与护栏** skill，Claude Code、GitHub Copilot、OpenCode、Cursor 都能用。
>
> 基于实战验证过的 [ai-coding-ok](https://github.com/Mark7766/ai-coding-ok) 框架，把"拷贝文件 + 手动改占位符"的繁琐流程，打包成一条命令 / 一个 slash。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Works with](https://img.shields.io/badge/Works%20with-Claude%20Code%20%7C%20Copilot%20%7C%20OpenCode%20%7C%20Cursor-blueviolet)](#)
[![Version](https://img.shields.io/badge/Version-v2.2.0-blue)](#)

---

## 🤔 解决什么问题？

写代码用 AI 的人都遇到过：

- 🧩 **AI 失忆**：换个会话/窗口就不知道你项目长什么样
- 💥 **改一个，坏三个**：修一个 bug 顺手把别的功能删了
- 🎯 **风格漂移**：AI 一会儿 PascalCase 一会儿 snake_case
- 🔒 **越权操作**：AI 删了不该删的文件、改了不该改的配置
- 🚧 **推广困难**：整套 ai-coding-ok 配置虽然有效，但手动拷贝 + 改占位符对普通用户门槛太高

ai-coding-ok skill 把这一切打包：**一行命令装好，一句话描述需求，AI 自动填满所有配置**。

---

## ✨ v2.2.0 新特性

### 🛡️ Claude Code 三道触发保险

之前 Claude Code 用户在**新会话** + **简短指令**（如「加个收入功能」）时，可能同时绕过 skill 自动调用和 AGENTS.md 启发式读取，导致 PDCA 漏触发。v2.2.0 通过两项修复彻底堵住这个窗口：

1. **新增 `templates/CLAUDE.md`** — 内容是 `@AGENTS.md` import shim。Claude Code 启动时无条件加载项目根的 `CLAUDE.md`，顺着 import 直达 PDCA 强制指令，跟 Cursor 的 `alwaysApply: true` 等价。
2. **重写 SKILL.md `description`** — 句首改为命令式 "USE THIS SKILL FIRST on every coding task..."，把高频触发词（feat / fix / refactor / 新功能 / 修复 / 重构）前置，把 INSTALL/UPGRADE 降为从属子句，显著提升 Claude 语义匹配命中率。

现在 Claude Code 有三道独立保险：① CLAUDE.md 自动加载（最硬） → ② Skill description 命中 → ③ AGENTS.md 启发式读取（兜底）。

### 🔄 install 流程同步

`install.sh` / `install.py` 的冲突检查列表加入 `CLAUDE.md`；SKILL.md 的安装目录树和占位符替换文件清单也同步更新。

---

## ✨ v2.1.0 新特性

### 🌐 多平台支持扩展

| 平台 | 安装命令 | 触发机制 |
|------|---------|----------|
| **Claude Code** | `bash install.sh --claude-code` | skill 自动调用 |
| **OpenCode** | `bash install.sh --opencode` | 全局 AGENTS.md 注入触发指令 |
| **GitHub Copilot** | `bash install.sh --copilot` | `copilot-instructions.md` 自动加载 |
| **Cursor** | `bash install.sh --cursor` | `.cursor/rules/ai-coding-ok.mdc`（`alwaysApply: true`）|

### 🔄 四种工作模式（v2.0 起）

| 模式 | 触发条件 | 作用 |
|------|---------|------|
| **Mode A — Install** | 新项目 / 输入 "install ai-coding-ok" | 首次安装，拷贝模板 + 定制占位符 |
| **Mode B — PDCA Plan** | 项目已有 `.github/agent/memory/` + 任意开发任务 | 任务开始前自动读取记忆文件 |
| **Mode C — PDCA Act** | 任务完成时 | 自动更新 task-history / decisions-log |
| **Mode D — Upgrade** | 输入 "upgrade ai-coding-ok" | 自动升级框架文件，保留项目定制内容 |

### 🎯 PDCA 强制执行（v2.0 起）

在 `AGENTS.md`、`copilot-instructions.md` 和 `.cursor/rules/ai-coding-ok.mdc` 顶部嵌入了强制指令，确保 AI **每次任务都执行 PDCA**：
- 任务开始前：自动读取 4 个记忆文件
- 任务结束后：自动更新记忆（不可跳过）

### 🏷️ 版本标记

所有模板文件都带版本标记（`<!-- ai-coding-ok: v2.2.0 -->`），支持自动化升级检测。

---

## ⚡ 快速开始（30 秒）

### Claude Code 用户

```bash
# 1. 安装 skill
git clone https://github.com/Mark7766/ai-coding-ok ~/.claude/skills/ai-coding-ok

# 2. 进入你的项目，打开 Claude Code
cd your-project
claude

# 3. 在会话里输入
/ai-coding-ok
```

Claude 会自动：
1. 拷贝 16 个模板文件到你的项目
2. 问你一句话："你想做一个什么东西？"
3. 根据你这句话推断技术栈、架构、规范，**帮你把所有占位符填好**
4. 写好第一条任务历史，PDCA 循环就地生效

> 💡 v2.0 起，**PDCA 工作流自动执行** — 任务开始前自动读记忆，结束后自动写记忆，无需手动提醒。v2.1.0 新增 OpenCode 和 Cursor 支持。v2.2.0 增强 Claude Code 触发可靠性（CLAUDE.md import shim + skill description 重写）。

### GitHub Copilot 用户

```bash
# 1. clone
git clone https://github.com/Mark7766/ai-coding-ok

# 2. 进入你的项目，运行安装脚本
cd your-project
bash /path/to/ai-coding-ok/install.sh --copilot

# 3. 打开 Copilot Chat，把 scripts/customize-prompt.md 的内容粘贴进去
#    Copilot 会自动替换所有占位符
```

装好之后，Copilot 每次对话都会自动读取 `.github/copilot-instructions.md`，**PDCA 工作流、记忆系统、三级权限全部生效**。

### OpenCode 用户

```bash
# 1. 安装 skill（与 Claude Code 共用同一路径）
git clone https://github.com/Mark7766/ai-coding-ok ~/.claude/skills/ai-coding-ok

# 2. 进入你的项目，打开 OpenCode
cd your-project
opencode

# 3. 在会话里输入
install ai-coding-ok
```

> 💡 OpenCode 会自动从 `~/.claude/skills/` 加载技能，无需额外配置。
> 如果遇到技能不自动触发，运行 `bash install.sh --opencode` 来更新全局 AGENTS.md。

### Cursor 用户

```bash
# 1. clone
git clone https://github.com/Mark7766/ai-coding-ok

# 2. 进入你的项目，运行安装脚本
cd your-project
bash /path/to/ai-coding-ok/install.sh --cursor

# 2. 在 Cursor Agent 中输入
install ai-coding-ok
```

安装后，Cursor 会通过 `.cursor/rules/ai-coding-ok.mdc`（`alwaysApply: true`）在**每次会话**自动执行 PDCA 流程，无需手动触发。

---

## 📦 它到底装了什么？

```
你的项目/
├── AGENTS.md                          ← 🗺️  架构速查（AI 最先读）
├── CLAUDE.md                          ← 🔗 Claude Code 自动加载 → @AGENTS.md
├── .cursor/
│   └── rules/
│       └── ai-coding-ok.mdc           ← ⚡ Cursor 专属：alwaysApply PDCA 规则
└── .github/
    ├── copilot-instructions.md        ← 📋 全局行为规则（Copilot 自动加载）
    ├── project-metadata.yml           ← 🏷️  机器可读的项目元信息
    ├── PULL_REQUEST_TEMPLATE.md       ← 📝 PR 模板（含记忆更新检查）
    ├── ISSUE_TEMPLATE/                ← 🐛 Issue 模板
    ├── workflows/                     ← 🤖 CI + 记忆更新提醒
    └── agent/
        ├── system-prompt.md           ← 🎭 Agent 人格 + PDCA 工作流
        ├── coding-standards.md        ← 📏 编码规范
        ├── workflows.md               ← 🔄 场景化工作流
        ├── prompt-templates.md        ← 🧩 Prompt 模板库
        └── memory/
            ├── project-memory.md      ← 🧠 长期记忆：项目事实
            ├── decisions-log.md       ← 📝 中期记忆：技术决策 (ADR)
            └── task-history.md        ← 📜 短期记忆：近 30 条任务
```

---

## 🧠 三层记忆系统

| 层级 | 文件 | 内容 | 更新频率 |
|------|------|------|---------|
| 长期 | `project-memory.md` | 架构、约束、已知问题 | 很少 |
| 中期 | `decisions-log.md` | ADR 格式的技术决策 | 架构变更时 |
| 短期 | `task-history.md` | 近 30 条任务摘要 | 每次任务 |

AI 每次开始工作**先读这三个文件**，每次结束**写回 task-history**，架构变了再更新另外两个。这就是 AI 跨会话保持上下文的秘诀。

---

## 🔄 PDCA 工作流

```
  Plan           Do            Check          Act
 ─────▶        ─────▶         ─────▶         ─────▶
读记忆       写代码          跑测试         更新记忆
理解意图     写测试          验回归         提交 PR
出计划       自检            查安全         ...
```

每次任务都走一遍，保证"修 bug 不破坏其他功能"有代码 + 记忆双重保障。

---

## 🤝 与 superpowers skill 组合使用（推荐）

[`superpowers`](https://github.com/obra/superpowers) 擅长**发散思考、编排 sub-agent、深度研究**；
ai-coding-ok 擅长**固化上下文、保证代码质量、跨会话持续**。

**一句话组合法**：

> superpowers 想得深，ai-coding-ok 记得住。

详见 [`docs/superpowers-combo.md`](docs/superpowers-combo.md) 的五个实战配方。

---

## 📖 文档索引

- [Claude Code 快速上手](docs/claude-code-quickstart.md)
- [GitHub Copilot 快速上手](docs/copilot-quickstart.md)
- [OpenCode 快速上手](docs/opencode-quickstart.md)
- [Cursor 快速上手](docs/cursor-quickstart.md)
- [与 superpowers 组合使用](docs/superpowers-combo.md)
- [FAQ](docs/faq.md)
- [SKILL.md](SKILL.md) — skill 本体（Claude Code 会读）
- [CHANGELOG](CHANGELOG.md) — 版本变更记录

---

## 🔄 升级已安装的项目

### Claude Code 用户

在已安装 ai-coding-ok 的项目里：

```
upgrade ai-coding-ok
```

Claude 会自动：检测版本 → 识别变更 → 合并框架更新（保留你的项目定制内容）→ 更新版本标记

### Copilot 用户

把 [`scripts/upgrade-prompt.md`](scripts/upgrade-prompt.md) 的内容粘贴到 Copilot Chat 执行。

---

## 🚀 命令速查

| 命令 | 作用 |
|------|------|
| `bash install.sh` | 交互式安装（问你装到哪里） |
| `bash install.sh --claude-code` | 装成 Claude Code skill |
| `bash install.sh --opencode` | 装成 OpenCode skill + 更新全局 AGENTS.md |
| `bash install.sh --copilot` | 把模板装到当前 Copilot 项目 |
| `bash install.sh --cursor` | 把模板 + `.cursor/rules/` 装到当前 Cursor 项目 |
| `bash install.sh --copilot --target /path/to/proj` | 装到指定项目 |
| `bash install.sh --dry-run` | 预览要做什么，不真的写 |
| `bash install.sh --force` | 覆盖已存在的文件 |
| `python install.py ...` | 同上，跨平台版本（含 Windows） |
| `bash scripts/verify.sh` | 检查当前项目装得对不对 + 占位符是否都填了 |

---

## 🧪 测试 & 验证

安装后可以随时运行：

```bash
bash <(curl -sL https://raw.githubusercontent.com/Mark7766/ai-coding-ok/main/scripts/verify.sh)
# 或本地
bash /path/to/ai-coding-ok/scripts/verify.sh
```

它会：
- ✅ 检查 16 个必需文件是否齐全
- ⚠️ 统计还有多少 `{{占位符}}` 没填
- 🎯 退出码：0 = 完美，1 = 缺文件，2 = 占位符没填完

---

## 🧭 设计哲学

1. **一次安装，跨工具通用** — 不给 Claude/Copilot/Cursor 各自写一套配置
2. **让 AI 定制 AI 的配置** — 用户只说一句"想做什么"，剩下 AI 自己推断
3. **安全默认** — 不覆盖用户已有文件，除非 `--force`
4. **可审计** — 所有安装过的动作都能从 `task-history.md` 里回溯

---

## 🤲 贡献

欢迎提 Issue / PR。改模板改到 `templates/` 下，改 skill 行为改 `SKILL.md` 和 `scripts/`，改文档改 `docs/`。

---

## 📄 许可

[MIT](LICENSE) — 免费商用。
