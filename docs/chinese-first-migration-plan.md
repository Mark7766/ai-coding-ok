# ai-coding-ok 中文化回归方案

> **状态**：已确认，待实施
> **日期**：2026-07-25
> **作者**：wangliang + Claude

---

## 一、背景与动机

### 1.1 历史回顾

- **v2.x 及之前**：纯中文项目，模板只有一套中文版，README 是中文
- **v3.0.0**：为争取成为 Claude 官方 Skill，引入双语模板架构（`templates/zh/` + `templates/en/`），README 拆分为 README.md（英文）+ README.zh.md（中文），SKILL.md 全面英文化
- **v3.1.0**：五层防御体系（CLAUDE.md STOP + AGENTS.md Plan 7 步 + copilot-instructions Act 4 步 + hooks 四重 + 安装自动配置），能力大幅增强

### 1.2 为什么改回去

成为 Claude 官方 Skill 已不可能。双语维护是纯负担：

- 每次改模板要同步 19×2=38 个文件
- SKILL.md 英文在前、中文在括号里，用户（中国开发者）读起来别扭
- GitHub 首页 README.md 是英文，中国开发者第一眼看不到中文
- 项目 issue、讨论、commit 全是中文，英文模板无人使用
- 用户的原话：*"原来这个项目最早也是以中文为主的，只是为了成为 Claude 的官方 skill 才支持英文的"*

### 1.3 目标

**彻底去掉英文支持，回到 v3.0.0 引入双语之前的纯中文状态——但保留 v3.0.0 以来所有的能力改进。**

具体来说：

- 删除 `templates/en/` 目录（不再保留任何英文模板）
- SKILL.md 全文改为中文
- README.md 改回中文，删除 README.zh.md
- 脚本输出和注释改为中文
- 同时保留 v3.0.0+ 全部能力：Mode B/C/D、Install/Upgrade Playbook、五层防御体系、hooks 配置、dogfooding 记忆系统

---

## 二、保留与删除的边界

### 2.1 必须保留的英文（方便 AI 编程工具理解）

| 保留内容 | 原因 |
|---------|------|
| **技术术语**：PDCA、ADR、hook、template、skill、plugin、Mode A/B/C/D、Plan/Do/Check/Act、Phase | AI 工具（Claude、Copilot、Cursor）对这些术语有原生的语义理解，翻译反而降低触发准确率 |
| **代码块**：Shell 命令、Python 代码、正则表达式 | 代码本身就是英文 |
| **文件路径**：`templates/zh/`、`.github/agent/memory/` 等 | 路径是跨平台标识符 |
| **配置 Key**：JSON/YAML 的字段名 | 机器可读，不可翻译 |
| **Git 术语**：commit、push、branch、worktree | 通用技术词汇 |
| **占位符标记**：`{{...}}` 语法 | 模板引擎机制 |
| **工具名称**：Claude Code、Copilot、Cursor、OpenCode | 专有名词 |

### 2.2 必须改掉的英文（人机交互文本）

| 删除/改为中文 | 说明 |
|-------------|------|
| SKILL.md 全部正文（除代码块和术语） | 安装指引、Mode 说明、Playbook 步骤 |
| Mode A 交互提示的英文部分 | 只保留中文提示 |
| README.md | 整份文档改为中文 |
| install.sh / install.py 的注释和 echo | 用户可见输出全部中文 |
| scripts/verify.sh 的输出 | 检查结果用中文 |
| scripts/customize-prompt.md | 全文中文 |
| scripts/upgrade-prompt.md | 全文中文 |
| CHANGELOG.md | 全文中文 |
| `templates/en/` 整个目录 | 直接删除，不留 |

### 2.3 一个具体的例子

SKILL.md Mode A Step 5 的交互提示，最终应该是这样：

```
### 步骤五：询问项目信息

不要直接让用户手动填占位符，而是用一句话提问：

> "一句话告诉我你想做一个什么东西？例如：'一个记账工具，记录每天花了多少钱。'"
```

只有中文，没有英文原文，没有英文括号附注。但是 "Step 5" 保留英文数字标记，因为 AI 工具理解 "Step" 的流程含义。

---

## 三、改造清单

### 3.1 删除

| 路径 | 说明 |
|------|------|
| `templates/en/` 整个目录 | 19 个英文模板文件全部删除 |
| `README.zh.md` | 内容合并到 README.md 后删除 |

### 3.2 重写（中文）

| 文件 | 当前状态 | 改动 |
|------|---------|------|
| `SKILL.md` | 英文正文 + 中文括号附注 | 全文中文化（保留代码块和术语），删除 "Language detection" 章节 |
| `skills/ai-coding-ok/SKILL.md` | 同上 | 同步覆盖 |
| `README.md` | 英文 | 用原 README.zh.md 的内容为基础重写 |
| `CHANGELOG.md` | 英文 | 中文化 |

### 3.3 中文化（注释和输出）

| 文件 | 改动 |
|------|------|
| `install.sh` | 注释 + echo 输出 → 中文 |
| `install.py` | 注释 + print 输出 → 中文 |
| `scripts/verify.sh` | 输出信息 → 中文 |
| `scripts/customize-prompt.md` | 全文 → 中文 |
| `scripts/upgrade-prompt.md` | 全文 → 中文 |

### 3.4 更新（约束和记忆）

| 文件 | 改动 |
|------|------|
| `AGENTS.md` | "双语维护"约束 → "纯中文项目" |
| `templates/zh/AGENTS.md` | 同上 |
| `.github/agent/memory/decisions-log.md` | 新增 ADR-005，ADR-001 标为已替代 |
| `.github/agent/memory/project-memory.md` | 更新主语言、模板架构描述 |
| `.github/agent/memory/task-history.md` | 记录本次改造 |
| `.claude-plugin/plugin.json` | description 改为中文 |

### 3.5 不改动

| 文件 | 原因 |
|------|------|
| `templates/zh/` 下所有模板 | 已经是中文，内容不动 |
| `.github/agent/memory/*.md` | 已经是中文 |
| `docs/*.md` | 基本都是中文 |
| `.github/workflows/*.yml` | CI 配置，值本身是命令/路径 |
| `.github/ISSUE_TEMPLATE/*.yml` | 已经是中文 |
| `.claude/settings.local.json` | JSON 配置 |

---

## 四、SKILL.md 中文化细则

SKILL.md 是本次改造的核心，单独说明。

### 4.1 删除的章节

- **"Language detection"**（约 7 行）→ 删除，不需要语言检测逻辑

### 4.2 章节标题翻译对照

中文是最终标题，不需要英文原文：

| 原标题 | 新标题 |
|--------|--------|
| What this skill installs | 安装内容 |
| When to invoke this skill | 触发条件 |
| Mode A — Install (one-time, on a new project) | 模式 A：安装（新项目首次） |
| Mode B — PDCA Plan (every coding task — before writing code) | 模式 B：PDCA Plan（任务前） |
| Mode C — PDCA Act (every coding task — after finishing) | 模式 C：PDCA Act（任务后） |
| Mode D — Upgrade (upgrade an installed ai-coding-ok) | 模式 D：升级 |
| Installation Playbook (Mode A only) | 安装流程（仅 Mode A） |
| Working rules after installation | 安装后的工作规则 |
| Compatibility with superpowers | 与 superpowers 的兼容 |
| Upgrade Playbook (Mode D only) | 升级流程（仅 Mode D） |
| For non-Claude-Code users (Copilot / Cursor / OpenCode) | 非 Claude Code 用户（Copilot / Cursor / OpenCode） |
| References | 参考文件 |

### 4.3 步骤标题翻译对照

| 原标题 | 新标题 |
|--------|--------|
| Step 1 — Locate the skill's template directory | 步骤一：定位模板目录 |
| Step 2 — Pick the target project | 步骤二：确定目标项目 |
| Step 3 — Conflict check (non-destructive) | 步骤三：冲突检查（非破坏性） |
| Step 4 — Copy templates into the project | 步骤四：复制模板 |
| Step 5 — Ask the user what they're building | 步骤五：询问项目信息 |
| Step 5.5 — Ask about source directories (for Stop hook) | 步骤五.五：询问源码目录（用于 Stop hook） |
| Step 5.6 — Configure Claude Code hooks | 步骤五.六：配置 Claude Code hooks |
| Step 6 — Infer and replace placeholders | 步骤六：推断并替换占位符 |
| Step 7 — Bootstrap the first memory entries | 步骤七：初始化记忆条目 |
| Step 8 — Report back to the user | 步骤八：反馈安装结果 |

### 4.4 关键段落翻译示例

**Mode A 触发条件：**

原文：
```
**Triggers:**
- The user explicitly asks to install the memory system ("install ai-coding-ok", "set up project memory", "初始化 ai-coding-ok", etc.)
- The project does not yet contain `.github/agent/memory/`
```

改为：
```
**触发条件：**
- 用户明确要求安装记忆系统（"install ai-coding-ok"、"初始化 ai-coding-ok" 等）
- 项目中尚不存在 `.github/agent/memory/` 目录
```

**Step 5 交互提示：**

原文：
```
> "In one sentence, what are you building? Example: 'A personal expense tracker that records what I spend each day.'"

(Chinese: "一句话告诉我你想做一个什么东西？")
```

改为：
```
> "一句话告诉我你想做一个什么东西？例如：'一个记账工具，记录每天花了多少钱。'"
```

**Step 5.5 交互提示：**

原文：
```
> "Where does your source code live? (e.g. `src/`, `lib/`, `app/` — space-separated, default: `src/ tests/`)"

(Chinese: "你的项目源码目录是什么？（如 `src/`、`lib/`，空格分隔多个，默认：`src/ tests/`）")
```

改为：
```
> "你的项目源码目录是什么？（如 `src/`、`lib/`，空格分隔多个，默认：`src/ tests/`）"
```

### 4.5 术语保留位置示例

在中文正文中，这些术语保留英文原文不翻译：

```
在中文段落中，PDCA 闭环（Plan → Do → Check → Act）在每次编码任务前后强制执行。
AI Agent 在 Plan 阶段读取 3 个 memory 文件获取 context。
如果用户使用 Claude Code，通过 hooks 机制做硬约束。
安装时使用 `cp -rn` 将 templates/zh/ 复制到目标项目。
```

翻译的标准：
- "PDCA" 不翻译为 "计划执行检查处理"
- "memory" 作为项目特定概念保留
- "context" 保留，不翻译为 "上下文"（虽然有时也可以用中文）
- "hooks" 保留，不翻译为 "钩子"
- "templates/zh/" 是路径，保留

---

## 五、install.sh 路径简化

当前 install.sh 中有模板语言选择逻辑（zh vs en），删除 en/ 后可以简化：

- 删除语言选择相关的变量和分支
- 模板路径硬编码为 `templates/zh/`
- `cp` 命令不再需要 `<lang>` 变量

```bash
# 改造前（伪代码）
LANG="en"  # 或 "zh"
cp -rn "$TEMPLATE_DIR/$LANG/." "$TARGET_PROJECT/"

# 改造后（伪代码）
cp -rn "$TEMPLATE_DIR/zh/." "$TARGET_PROJECT/"
```

> 注意：install.sh 中与语言无关的逻辑（如 hooks 配置、占位符替换引导提示）保持不变，这些是 v3.1.0 的能力。

---

## 六、ADR 记录

### 6.1 新增 ADR-005

```markdown
### ADR-005: 中文化回归——删除英文支持

- **日期**：2026-07-25
- **状态**：✅ 已采纳
- **决策者**：wangliang

#### 背景
> ADR-001 选择了双语模板架构（zh/ + en/）以争取成为 Claude 官方 Skill。
> 官方 Skill 路线已不可行。当前用户全部为中国开发者，双语维护无实际价值。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| A: 保留 en/ 降级标注 | 国际用户可参考 | 仍需维护两套目录结构 |
| B: 彻底删除 en/，回退到纯中文 | 维护成本最低，目录简洁 | 国际用户需自行翻译 |

#### 决策
> 选择方案 B：**彻底删除 `templates/en/`，回到 v3.0.0 之前的纯中文项目状态**。

#### 理由
> 目标用户是中国开发者，英文模板实际使用率为零。保留不维护的英文模板比删除更差——用户用了过时模板会遇到问题。v3.0.0 以来的能力改进（Mode B/C/D、五层防御、hooks、Install/Upgrade Playbook）全部保留，仅去掉双语支持。

#### 影响
> - `templates/en/` 目录删除（19 个文件）
> - SKILL.md 全文改中文（技术术语如 PDCA/ADR/hook 保留英文）
> - README.md 改为中文，README.zh.md 删除
> - install.sh 删除语言选择逻辑
> - AGENTS.md "双语维护"约束改为"纯中文项目"
> - 版本号 v3.1.0 → v4.0.0
```

### 6.2 ADR-001 状态更新

ADR-001（双语模板架构）状态从 `✅ 已采纳` 改为 `🔄 已替代（被 ADR-005 替代）`。

---

## 七、实施步骤

### 阶段一：删除（无风险，先做）

1. 删除 `templates/en/` 整个目录
2. 删除 `README.zh.md`

### 阶段二：SKILL.md 中文化（核心，工作量最大）

1. `SKILL.md` 全文翻译为中文（保留代码块和技术术语）
2. 删除 "Language detection" 章节
3. 所有 Mode A 交互提示改为纯中文
4. 所有章节和步骤标题中文化
5. `skills/ai-coding-ok/SKILL.md` 同步覆盖

### 阶段三：README + CHANGELOG

1. `README.md` 用中文重写（以原 `README.zh.md` 为基础，合并 v3.1.0 新增内容）
2. `CHANGELOG.md` 中文化

### 阶段四：脚本中文化

1. `install.sh` 注释和 echo 中文化，删除语言选择逻辑
2. `install.py` 注释和 print 中文化
3. `scripts/verify.sh` 输出中文化
4. `scripts/customize-prompt.md` 全文中文化
5. `scripts/upgrade-prompt.md` 全文中文化

### 阶段五：约束和记忆更新

1. `AGENTS.md` 约束描述更新（双语维护 → 纯中文项目）
2. `templates/zh/AGENTS.md` 同步更新约束描述
3. `decisions-log.md` 新增 ADR-005，ADR-001 标记为已替代
4. `project-memory.md` 更新主语言、模板架构描述
5. `task-history.md` 记录本次改造
6. `.claude-plugin/plugin.json` description 改中文

### 阶段六：版本发布

- 版本号：`v4.0.0`
- 更新所有版本标记（`<!-- ai-coding-ok: v4.0.0 -->`），涉及：
  - 根目录：AGENTS.md、CLAUDE.md
  - 本项目自用：`.github/agent/system-prompt.md`、`coding-standards.md`、`workflows.md`、`prompt-templates.md`
  - templates/zh/ 下所有 19 个文件
  - SKILL.md（两处）
- CHANGELOG 记录

---

## 八、不改动内容确认

以下 v3.0.0+ 的能力**全部保留，不受中文化影响**：

| 能力 | 引入版本 | 说明 |
|------|---------|------|
| Mode B：Plan 阶段（读取 7 个文件） | v3.0.0 | 保留，只是 SKILL.md 描述文字变中文 |
| Mode C：Act 阶段（更新记忆文件） | v3.0.0 | 保留 |
| Mode D：Upgrade（diff 升级） | v3.0.0 | 保留 |
| Install Playbook（Step 1~8） | v3.0.0 | 保留，步骤标题变中文 |
| Step 5.5/5.6：源码目录 + hooks 配置 | v3.1.0 | 保留 |
| 五层防御体系 | v3.1.0 | 保留，CLAUDE.md/AGENTS.md 内容不变 |
| 四重 hooks（SessionStart/UserPromptSubmit/PreToolUse/Stop） | v3.1.0 | 保留 |
| 版本标记 `<!-- ai-coding-ok: vX.Y -->` | v3.0.0 | 保留，版本号升为 v4.0.0 |
| 占位符系统 `{{...}}` | v1.0 | 保留 |
| copilot-instructions.md 自动加载 | v2.0 | 保留 |
| Cursor .cursor/rules/ 支持 | v2.1.0 | 保留 |
| Dogfooding 自用记忆系统 | v3.1.0 | 保留 |
| superpowers 兼容 | v3.0.0 | 保留 |

---

## 九、最终项目结构

```
ai-coding-ok/
├── SKILL.md                          ← 中文，Skill 定义入口
├── CLAUDE.md                         ← 不变（已经是 @AGENTS.md shim）
├── AGENTS.md                         ← 中文，约束从"双语维护"改为"纯中文项目"
├── README.md                         ← 中文，唯一 README
├── CHANGELOG.md                      ← 中文
├── install.sh                        ← 注释/输出中文，无语言选择逻辑
├── install.py                        ← 注释/输出中文
├── templates/
│   └── zh/                           ← 唯一模板源（不再有 en/）
│       ├── AGENTS.md
│       ├── CLAUDE.md
│       ├── .claude/settings.local.json
│       ├── .cursor/rules/ai-coding-ok.mdc
│       └── .github/...
├── scripts/
│   ├── verify.sh                     ← 输出中文
│   ├── customize-prompt.md           ← 全文中文
│   └── upgrade-prompt.md             ← 全文中文
├── docs/                             ← 全部中文文档
├── skills/ai-coding-ok/
│   └── SKILL.md                      ← 同步自根 SKILL.md
├── .claude-plugin/
│   └── plugin.json                   ← description 改中文
└── .github/agent/memory/             ← 本项目自用记忆（dogfooding，不变）
```

---

## 十、风险

| 风险 | 评估 | 说明 |
|------|------|------|
| 国际用户无法使用 | **无影响** | 实际上没有国际用户，项目 issue 和讨论全部是中文 |
| AI 工具对中文 SKILL.md 理解偏差 | **低** | Claude、Copilot 对中英文指令理解能力相当；关键术语（PDCA、ADR、hook）保留英文确保触发 |
| install.sh 改动引入 bug | **低** | 只改注释和输出字符串，不碰逻辑 |
| templates/en/ 删除后有人需要 | **极低** | Git 历史保留，可从 v3.1.0 tag 恢复 |
