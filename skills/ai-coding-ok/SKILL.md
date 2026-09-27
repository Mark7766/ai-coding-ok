---
name: ai-coding-ok
description: 在任何编码任务（feat、fix、bug、refactor、plan、design、brainstorm、code review、implement、add feature、write tests、新功能、修复、重构）时首先使用此 skill——当项目包含 `.github/agent/memory/` 或 `AGENTS.md` 时。在编写代码前加载三层项目记忆（project-memory、decisions-log、task-history）和 AGENTS.md，完成任务后更新 task-history（始终）、decisions-log（架构变更时）和 project-memory（事实变更时）——这是 PDCA 护栏，防止"AI 修了 bug X 却搞坏了功能 Y"跨迭代发生。同时处理 INSTALL（用户说"install ai-coding-ok"、"初始化 ai-coding-ok"等，或项目尚无 `.github/agent/memory/` 时）——复制模板并定制占位符。也处理 UPGRADE（用户说"upgrade ai-coding-ok"、"升级 ai-coding-ok"等）——将项目文件与最新模板 diff 并应用框架级变更，同时保留项目定制。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
compatibility: claude, opencode, cursor, copilot, codex, atomcode
---

# ai-coding-ok — PDCA 记忆闭环

> ⚠️ **贡献者注意**：本文件与 [`skills/ai-coding-ok/SKILL.md`](skills/ai-coding-ok/SKILL.md) 保持同步。`skills/ai-coding-ok/SKILL.md` 是规范源文件——当用户通过 `install.sh --claude-code` 安装到 `~/.claude/skills/ai-coding-ok/` 后，Claude Code 加载的是 `skills/` 目录下的版本。根目录的 SKILL.md 提供给直接在仓库目录中工作的开发者。**修改时请编辑 `skills/ai-coding-ok/SKILL.md` 然后执行 `cp skills/ai-coding-ok/SKILL.md SKILL.md` 再提交。**

三层记忆系统 + AI 编程护栏。PDCA 闭环（Plan → Do → Check → Act）在每次编码迭代中保持项目 context 准确。支持 Claude Code、GitHub Copilot、OpenCode、Cursor、OpenAI Codex CLI 和 AtomCode。

## 安装内容

Skill 激活后，会将一组精心设计的文件复制到目标项目中：

```
<项目根目录>/
├── AGENTS.md                              # 架构速查（AI 首先读取，Codex/OpenCode 自动加载）
├── CLAUDE.md                              # Claude Code 自动加载 shim → @AGENTS.md
├── .codex/skills/ai-coding-ok/            # Codex skill 定义
│   ├── SKILL.md                           # Codex skill 入口 + PDCA 工作流
│   └── verification.md                    # 任务完成验证清单
└── .github/
    ├── copilot-instructions.md            # 全局行为规则（Copilot 自动加载）
    ├── project-metadata.yml               # 机器可读的项目事实
    ├── PULL_REQUEST_TEMPLATE.md
    ├── ISSUE_TEMPLATE/…
    ├── workflows/                         # CI + 记忆更新提醒
    └── agent/
        ├── system-prompt.md               # Agent 人格 + PDCA 工作流
        ├── coding-standards.md
        ├── workflows.md                   # 场景工作流
        ├── prompt-templates.md
        └── memory/
            ├── project-memory.md          # 🧠 长期记忆（事实、约束）
            ├── decisions-log.md           # 📝 中期记忆（ADR）
            └── task-history.md            # 📜 短期记忆（近期任务）
```

## 触发条件

判断当前属于哪种模式，然后按对应模式执行。

### 模式 A：安装（新项目首次）

**触发条件：**
- 用户明确要求安装记忆系统（"install ai-coding-ok"、"初始化 ai-coding-ok"、"设置项目记忆" 等）
- 项目中尚不存在 `.github/agent/memory/` 目录

**执行：**
→ 执行下方的**安装流程**（步骤一至步骤八）

---

### 模式 B：PDCA Plan（每次编码任务——写代码前）

**触发条件：**
- 项目中已存在 `.github/agent/memory/` 目录
- 用户请求任何开发工作（新功能、bug 修复、重构、设计、brainstorming、plan 编写、code review 等）

**执行（约 30 秒，在实际工作开始前）：**
1. 读取 `AGENTS.md` — 架构速查
2. 读取 `.github/agent/memory/project-memory.md` — 稳定事实和约束
3. 读取 `.github/agent/memory/decisions-log.md` — 历史技术决策
4. 读取 `.github/agent/memory/task-history.md` — 近期任务 context
5. 内部（或向用户）总结关键约束，确认理解无误
6. **然后继续执行用户的原始任务**（不要停在这里）

> ⚠️ 模式 B 不是用户任务的替代品。它是在任务之前执行的 context 加载。如果同时触发了其他 skill（如 superpowers 的 `writing-plans`），先执行模式 B，再进入那个 skill。

---

### 模式 C：PDCA Act（每次编码任务——完成后）

**触发条件：**
- 编码/设计任务刚刚完成，即将向用户返回最终结果

**执行（不可跳过）：**
1. 更新 `.github/agent/memory/task-history.md` — 记录本次任务摘要
2. 如有架构/技术决策变更 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目基本事实变化（新模块、技术栈变动等）→ 更新 `.github/agent/memory/project-memory.md`
4. 在最终输出中包含「记忆更新」小节，列出哪些记忆文件被更新

> ⚠️ 如果 context 限制导致无法直接编辑文件，将需要的更新以文本形式输出，告知用户手动应用。

---

### 模式 D：升级（升级已安装的 ai-coding-ok）

**触发条件：**
- 用户说 "upgrade ai-coding-ok"、"更新 ai-coding-ok"、"升级 ai-coding-ok" 等

**执行：**
→ 执行下方的**升级流程**

## 安装流程（仅 Mode A）

> ⚠️ 以下步骤仅在模式 A（首次安装）中执行。模式 B 和模式 C 不使用此流程。

按顺序执行各步骤。不要跳过步骤五到步骤六（定制化）——未填充的 `{{占位符}}` 会让整个安装失去意义。

### 步骤一：定位模板目录

模板位于 `<project-root>/templates/zh/`，其中 `<project-root>` 是 ai-coding-ok 仓库的根目录（即包含本 `SKILL.md` 的目录）。复制前先解析为绝对路径。

根据安装方式确定 `<project-root>`：
- 通过 `install.sh --claude-code` 安装时：`~/.claude/skills/ai-coding-ok/`
- 直接从 git clone 目录使用时：`/path/to/ai-coding-ok/`

### 步骤二：确定目标项目

默认目标是当前工作目录。仅在以下情况向用户确认：
- 当前目录明显不是项目目录（如 `$HOME`、`/tmp`）
- 关键文件已存在且将被覆盖（见步骤三冲突检查）

### 步骤三：冲突检查（非破坏性）

复制前，检查目标项目中是否已存在以下路径：

- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `.github/agent/`（目录）

如果**任意一个**存在，停止并向用户报告。提供三个选项：
1. 覆盖（有风险——用户可能有手动修改）
2. 仅复制缺失文件（安全，推荐）
3. 放弃

绝不在未告知的情况下静默覆盖已有文件。

### 步骤四：复制模板到项目

将模板目录的全部内容复制到项目根目录。在 POSIX 系统上：

```bash
cp -rn <project-root>/templates/zh/. <项目根目录>/
```

`-n` = no-clobber，保护用户已有的编辑不被覆盖。在 Windows/Node 环境下，执行等效的合并复制。

验证目标文件/目录已存在。如有缺失，大声报错。

### 步骤五：询问项目信息

不要让用户手动填写占位符。用一句话提问：

> "一句话告诉我你想做一个什么东西？例如：'一个记账工具，记录每天花了多少钱。'"

### 步骤五.五：询问源码目录（用于 Stop hook）

询问用户：

> "你的项目源码目录是什么？（如 `src/`、`lib/`，空格分隔多个，默认：`src/ tests/`）"

将回答转换为 grep 兼容的正则表达式。示例：
- `src/ tests/` → `^src/\\|^tests/`
- `src/` → `^src/`
- `lib/ app/` → `^lib/\\|^app/`

### 步骤五.六：配置 Claude Code hooks

检查项目中是否存在 `.claude/` 目录（表明用户使用 Claude Code）：

- 如果 `.claude/` 存在，在 `.claude/settings.local.json` 中配置 Stop hook 的 `{{SOURCE_DIR_PATTERN}}`：
  - 读取文件
  - 将 `{{SOURCE_DIR_PATTERN}}` 替换为步骤五.五得到的正则表达式
  - 如果文件已有 `hooks` 段（来自之前的安装或用户配置），合并：只添加不存在的 hook
  - 如果文件不存在，从 `<project-root>/templates/zh/.claude/settings.local.json` 复制模板并填入 pattern
  - ⚠️ 关键：绝不在未经用户许可的情况下覆盖已有的 `.claude/settings.local.json`。如果文件中有 ai-coding-ok hooks 之外的用户原创内容，保留全部内容，仅添加/替换 ai-coding-ok 的 hook 条目
  - ⚠️ 关键：如果项目同时有 `settings.json` 和 `settings.local.json`，两者中的 hooks 会冲突。警告用户并建议合并到 `settings.local.json` 中
- 如果 `.claude/` 不存在，跳过 hooks 配置（用户可能使用 Copilot/Cursor）

### 步骤六：推断并替换占位符

根据用户的一句话描述，推断以下信息：

- 项目名称（`{{项目名称}}`）
- 项目类型（`{{项目类型}}`、`{{项目类型简述}}`）
- 技术栈（语言、框架、数据库、ORM、测试框架、包管理器等）
- 设计原则（个人工具："极简实用"；内部工具："可维护性 > 性能"；等等）
- 用户规模、核心功能、业务概念、架构等

然后遍历每个已复制文件，将所有 `{{...}}` 占位符替换为推断的值。需要处理的文件：

- `AGENTS.md`
- `CLAUDE.md`
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
- `.claude/settings.local.json`（将 `{{SOURCE_DIR_PATTERN}}` 替换为步骤五.五的 pattern）

对于 `{{YYYY-MM-DD}}` 占位符使用今天的日期。

对于不确定的选择（如 "SQLite or Postgres？"），选择更简单的方案，并记录到 `decisions-log.md` 作为 ADR-001。用户可以后续修改。

### 步骤七：初始化记忆条目

占位符替换完成后，在 `task-history.md` 中填充第一条真实记录：

```markdown
### [TASK-001] 安装 ai-coding-ok 并初始化项目
- **日期**：<今天>
- **类型**：chore
- **摘要**：通过 ai-coding-ok skill 安装了三层记忆系统和编码规范。技术栈和约束根据用户的一句话描述（<用户的原始描述>）自动推断并应用。
- **变更文件**：AGENTS.md, .github/**/*
- **注意事项**：首次安装——随着架构演进，请保持 `project-memory.md` 和 `decisions-log.md` 同步更新。
```

### 步骤八：反馈安装结果

输出以下内容：

1. 已安装和已定制的文件清单
2. 关键推断决策（技术栈、设计原则），让用户确认
3. 下一步提示："打开 `AGENTS.md` 查看。从现在起，我会在每次任务前读取记忆文件，每次任务后更新 `task-history.md`。"

## 安装后的工作规则

安装完成后，所有后续会话（包括本次）必须遵循 `.github/agent/system-prompt.md` 中定义的 PDCA 循环：

1. **Plan** — 在改代码之前读取 `AGENTS.md` + `.github/agent/memory/*.md`
2. **Do** — 同一变更中同时编写代码和测试
3. **Check** — 运行测试。验证无关功能无回归
4. **Act** — 更新 `task-history.md`（始终）、`decisions-log.md`（架构变更时）、`project-memory.md`（事实变更时）

这就是防止"AI 修了 bug X 却搞坏了功能 Y"的机制。

## 与 superpowers 的兼容

当 `superpowers` 和 `ai-coding-ok` 同时安装时，**ai-coding-ok 负责确保 PDCA 端到端执行**，不依赖 superpowers 的配合。

### 执行路径

```
路径 A（有 superpowers）：
  using-superpowers → brainstorming → writing-plans → executing-plans
                ↑
  brainstorming 步骤一读取 AGENTS.md（探索项目 context）
  ← AGENTS.md 顶部的 PDCA 强制指令是 hook point

路径 B（无 superpowers，纯 ai-coding-ok）：
  用户请求 → AI 扫描 skill 触发条件 → 调用 ai-coding-ok SKILL.md
  ← SKILL.md 模式 B / 模式 C 是 hook point
```

### 规则 1：在调用任何 superpowers skill 之前

在调用 `brainstorming` / `writing-plans` / `executing-plans` 之前，先执行**模式 B**（读取记忆文件）。这样约束和历史 context 会传递到下游流程中。

### 规则 2：当 writing-plans 生成 plan 时

无论 `writing-plans` 产出了什么，在 plan 的**最后一个任务**之后追加：

```markdown
### Task N+1: 更新项目记忆（PDCA Act — ⚠️ 不可跳过）

**文件：**
- 修改：`.github/agent/memory/task-history.md`
- 修改：`.github/agent/memory/decisions-log.md`（如有架构变更）
- 修改：`.github/agent/memory/project-memory.md`（如有事实变更）

- [ ] 在 task-history.md 中记录本次工作摘要
- [ ] 如果本次工作引入了架构/技术决策 → 在 decisions-log.md 中记录新的 ADR
- [ ] 如果项目事实发生了变化（新模块、新依赖、状态变更）→ 更新 project-memory.md
- [ ] 确认所有记忆文件已更新
```

### 规则 3：executing-plans / subagent-driven-development 完成后

执行**模式 C**（Act 阶段）并更新记忆文件。此步骤由 ai-coding-ok 自身强制执行，无论安装的是哪个版本的 superpowers。

### 规则 4：AGENTS.md 是路径 A 的 hook

`templates/zh/AGENTS.md` 顶部已嵌入 PDCA 强制指令。当 `brainstorming` 步骤一（探索项目 context）读取 AGENTS.md 时，AI 直接命中 PDCA 要求并执行。这保证了即使 `ai-coding-ok` SKILL.md 没有被触发——AGENTS.md 也会生效。

## 升级流程（仅 Mode D）

> ⚠️ 以下步骤仅在模式 D（升级）中执行。

### 步骤一：检测当前版本

读取项目中以下文件的第一行并提取版本标记：
- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/agent/system-prompt.md`
- `.github/agent/coding-standards.md`
- `.github/agent/workflows.md`
- `.github/agent/prompt-templates.md`

版本标记格式：`<!-- ai-coding-ok: vX.Y -->` 或 `# ai-coding-ok: vX.Y`。

如果文件缺少版本标记，视为 v1.0（初始发布，无标记）。

向用户报告检测到的版本：
> "检测到项目中 ai-coding-ok 版本：vX.Y。最新模板版本：vX.Y。"

### 步骤二：读取最新模板

读取 `<project-root>/templates/zh/` 中的所有模板文件——这些文件包含 `{{占位符}}`，代表最新的框架结构。

### 步骤三：识别框架变更

将**最新模板结构**与项目中的**已安装文件**进行对比，逐个文件 diff：

策略：
- 以 Markdown 章节（`##` / `###`）为粒度进行 diff
- 识别三种变更类型：
  1. **新增章节**：模板中有，项目中无 → 插入
  2. **删除章节**：模板中已删除，项目中仍存在 → 删除前询问用户
  3. **修改章节**：章节内容变化 → 智能合并

输出变更摘要，例如（v2.1.0 → v2.2.0）：
```
升级变更清单：
✅ templates/CLAUDE.md — 新增（Claude Code 自动加载 shim，@AGENTS.md import）
✅ 全部文件 — 版本标记升级 v2.1.0 → v2.2.0
```

> 📌 **历史升级路径**（查询当前已安装版本）：
>
> | 路径 | 主要变更 |
> |------|---------|
> | v1.0 → v2.0 | AGENTS.md / copilot-instructions.md 新增强制 PDCA 章节；workflows.md Step 5 新增"⚠️ DO NOT SKIP"标注；所有文件添加版本标记 |
> | v2.0 → v2.1.0 | 新增 `templates/.cursor/rules/ai-coding-ok.mdc`（Cursor 支持）；版本标记升级至 v2.1.0 |
> | v2.1.0 → v2.2.0 | 新增 `templates/CLAUDE.md`（Claude Code 自动加载 shim → @AGENTS.md）；SKILL.md description 重写（仅框架层面，不影响项目文件）；版本标记升级至 v2.2.0 |
> | v2.2.0 → v3.0.0 | Plugin 打包（`.claude-plugin/plugin.json`、`skills/ai-coding-ok/`）；双语模板（`templates/en/`、`templates/zh/`）；README 拆分（英文根 README，中文 `README.zh.md`）；版本标记升级至 v3.0.0 |
> | v3.x → v4.1.0 | 删除 `templates/en/`，回归纯中文项目；SKILL.md 全文中文化；README 合并为单一中文版；install.sh 删除语言选择逻辑 |
>
> 跨多步跳转时按顺序应用（如 v1.0 → v2.0 → v2.1.0 → v2.2.0 → v3.0.0 → v4.1.0）。

### 步骤四：与用户确认

向用户展示变更清单并询问：
> "以上是计划的升级变更。是否继续？（Y/n）"

⚠️ **绝不自自动应用**——升级会修改已有文件，必须经用户确认。

### 步骤五：应用升级

确认后，逐文件应用变更：

**5a. 新增章节：**
- 根据模板中的位置上下文确定插入点
- 将新内容中的 `{{占位符}}` 替换为项目中已填充的值
  - 从已有项目文件（项目名称、技术栈等）中提取已填充的值
  - 如果新章节没有占位符（如 PDCA 强制指令块），直接插入
- 在正确位置插入

**5b. 删除章节：**
- 找到章节的起始和结束位置（标题到下一个同级标题）
- 删除整个章节

**5c. 修改章节：**
- 读取模板中的新章节内容
- 将 `{{占位符}}` 替换为项目的实际值
- 替换项目中的旧章节

**5d. 升级版本标记：**
- 将每个文件首行的版本标记更新为最新版本
- 如果文件缺少版本标记，在第一行插入

### 步骤六：验证

- 确认所有文件的版本标记已更新
- 确认项目特定内容（架构图、模块清单、技术栈）未被覆盖
- 确认没有 `{{占位符}}` 泄漏到项目文件中

### 步骤七：记录升级

追加到 `.github/agent/memory/task-history.md`：

```markdown
### [TASK-00N] 升级 ai-coding-ok 到 vX.Y
- **日期**：<今天>
- **类型**：chore
- **摘要**：通过 Mode D 自动升级 ai-coding-ok 框架文件。新增/修改的章节：<变更摘要>
- **变更文件**：<实际变更清单>
- **注意事项**：<需要检查的合并细节，如有>
```

### 步骤八：报告

```markdown
## ai-coding-ok 升级完成

| 项目 | 旧 | 新 |
|------|-----|-----|
| ai-coding-ok | vX.Y | vX.Y |

### 变更文件
- ✅ AGENTS.md — <摘要>
- ✅ .github/copilot-instructions.md — <摘要>
- ...

### 保留的项目定制
- 项目名称、技术栈、架构图不变
- 记忆文件（project-memory.md 等）不变

### 需要人工检查
- <如有>
```

## 非 Claude Code 用户（Copilot / Cursor / OpenCode / Codex / AtomCode）

这些工具不会加载 SKILL.md。用户通过以下方式获得相同的价值：

1. 在 ai-coding-ok 仓库根目录运行 `install.sh --atomcode`（或对应平台模式 / `install.py`）一次，将 `templates/zh/` 复制到项目中。
2. 工具会自动加载对应文件：
   - Copilot 加载 `.github/copilot-instructions.md`
   - Cursor 加载 `.cursor/rules/ai-coding-ok.mdc`
   - OpenCode、Codex 和 AtomCode 加载 `AGENTS.md`
   - Codex 还支持 `.codex/skills/ai-coding-ok/SKILL.md` skill 文件
3. 如需初始占位符定制，将 `scripts/customize-prompt.md` 粘贴到工具的对话中触发替换。

## 参考文件

- `templates/zh/` — 安装文件的唯一模板源
- `scripts/customize-prompt.md` — 非 Claude Code 工具的定制 prompt
- `scripts/upgrade-prompt.md` — Copilot / Cursor 的手动升级 prompt
- `scripts/verify.sh` — 安装后完整性检查
- `docs/claude-code-quickstart.md` — Claude Code 用户快速上手
- `docs/copilot-quickstart.md` — Copilot 用户快速上手
- `docs/superpowers-combo.md` — 与 `superpowers` 的组合配方
- `docs/faq.md` — 常见问题
