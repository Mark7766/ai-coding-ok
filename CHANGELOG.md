# 变更日志

本项目的所有重要变更将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [v4.2.0] - 2026-09-27

### Added

- **AtomCode 支持** — AtomCode 原生加载项目根目录 `AGENTS.md`，ai-coding-ok 的 PDCA 强制指令安装即生效。六平台覆盖：Claude Code + Copilot + Cursor + OpenCode + Codex + AtomCode
- **`install.sh` / `install.py` 新增 `--atomcode` 模式** — 交互菜单新增第 7 项 AtomCode 选项，将 `templates/zh/` 模板复制到项目目录（`--target` 可指定目标，`--force` 才覆盖已有文件），与 Copilot/Cursor 模式同属"项目内安装"路径

### Changed

- **SKILL.md** — compatibility 新增 `atomcode`；「非 Claude Code 用户」章节改为「Copilot / Cursor / OpenCode / Codex / AtomCode」；安装说明新增 `install.sh --atomcode` 用法
- **AGENTS.md** — 跨平台兼容层新增 AtomCode（AGENTS.md 自动加载，无独立 skill 入口）
- **README.md** — 安装章节新增「方式二：AtomCode（项目内安装）」；Works with 徽章、文件结构图、设计哲学同步更新

### 兼容性说明

AtomCode 与 Codex/OpenCode 共享 AGENTS.md 加载机制，无独立 skill 定义文件；占位符填充通过对话内指令（`安装 ai-coding-ok，我想做一个xxx`）由 AI 自动完成。

## [v4.1.0] - 2026-07-25

### 新增

- **Codex（OpenAI Codex CLI）支持** — Codex 原生加载 `AGENTS.md`，ai-coding-ok 的 PDCA 强制指令天然兼容。新增 `.codex/skills/ai-coding-ok/` skill 模板（SKILL.md + verification.md），Codex 用户可通过 skill 系统触发安装、升级和 PDCA 工作流
- **`install.sh` / `install.py` 新增 `--codex` 模式** — 交互菜单新增第 5 项 Codex 选项，将模板 + `.codex/skills/` 复制到项目目录
- **Codex skill 模板** — `templates/zh/.codex/skills/ai-coding-ok/SKILL.md` 定义 PDCA 工作流和安装/升级流程，`verification.md` 提供任务完成验证清单

### 修改

- **SKILL.md** — compatibility 新增 `codex`；「非 Claude Code 用户」章节改为「Copilot / Cursor / OpenCode / Codex」；安装内容示意图新增 `.codex/` 目录
- **AGENTS.md** — 跨平台兼容层新增 Codex（AGENTS.md 自动加载 + .codex/skills/ skill）
- **README.md** — 安装章节新增 Codex 说明；设计哲学更新；文件结构图新增 `.codex/` 目录
- **skills/ai-coding-ok/SKILL.md** — 同步自根目录 SKILL.md

### 技术要点

Codex CLI 使用三层 AGENTS.md 发现机制（全局 → 项目 → 子目录），与 ai-coding-ok 的 AGENTS.md 项目级指令天然兼容。Codex 还支持 `~/.codex/config.toml` TOML 配置和 `~/.codex/memories/` 自动记忆（独立于 ai-coding-ok 的三层记忆系统）。

---

## [v4.0.0] - 2026-07-25

### 为什么有这个版本

v4.0.0 标志着 ai-coding-ok 回归纯中文项目。v3.0.0 引入双语模板是为了争取成为 Claude 官方 Skill，官方 Skill 路线已不可行，双语维护成为纯负担。v4.0.0 删除所有英文支持，回到 v3.0.0 之前的纯中文状态，同时保留 v3.0.0 以来全部能力改进。

### 删除

- **`templates/en/`** — 全部 19 个英文模板文件删除，`templates/zh/` 成为唯一模板源
- **`README.zh.md`** — 内容合并到 `README.md` 后删除
- **`SKILL.md` 中的 "Language detection" 章节** — 不再需要语言检测
- **`install.sh` / `install.py` 中的 `--lang` 选项** — 不再需要语言选择

### 修改

- **`SKILL.md`** — 全文中文化（保留 PDCA、ADR、hook、template 等 AI 工具需要的技术术语及全部代码块），章节标题、步骤标题、Mode A 交互提示全部改为中文
- **`skills/ai-coding-ok/SKILL.md`** — 同步自根目录 SKILL.md
- **`README.md`** — 全文改为中文（原 `README.zh.md` 内容并入）
- **`CHANGELOG.md`** — 全文中文化
- **`install.sh`** — 注释和用户可见输出中文化，模板路径硬编码为 `templates/zh/`
- **`install.py`** — 同上
- **`scripts/verify.sh`** — 输出中文化
- **`scripts/customize-prompt.md`** — 全文中文化
- **`scripts/upgrade-prompt.md`** — 全文中文化
- **`AGENTS.md`** — "双语维护"约束改为"中文项目，模板仅在 `templates/zh/` 维护"
- **`templates/zh/AGENTS.md`** — 同上
- **`.claude-plugin/plugin.json`** — description 改为中文
- **全部版本标记** — v3.1.0 → v4.0.0

### 新增

- **`docs/chinese-first-migration-plan.md`** — 中文化回归方案文档
- **ADR-005** — 中文化回归：删除英文支持（ADR-001 标记为已替代）

### 保留（不受影响）

v3.0.0 以来全部能力保留：Mode B/C/D、Install/Upgrade Playbook、五层防御体系、四重 hooks、占位符系统、多平台兼容、dogfooding 记忆系统、superpowers 兼容。

---

## [v3.0.1] - 2026-05-03

### 修复

- **`templates/zh/.github/copilot-instructions.md`** — 输出格式章节从"应包含"改为"**必须**包含所有小节，缺少任意小节视为不合规"；新增必填的 `## 记忆更新（⚠️ 必填）` 小节，含 task-history / decisions-log / project-memory checklist
- **`templates/en/.github/copilot-instructions.md`** — 输出格式从 "should contain" 改为 "**must** include all of the following sections. Omitting any section is non-compliant"；新增必填的 `## Memory Updates (⚠️ Required)` 小节
- **`templates/zh/.github/agent/system-prompt.md`** — Phase 4 Act 标注为"⚠️ 不可跳过"；新增必填的记忆更新输出结构，定义跳过 Act 的唯一合法条件
- **`templates/en/.github/agent/system-prompt.md`** — Phase 4 Act 标注为 "⚠️ must not skip"；新增同样的结构强制

### 根因

Act 阶段之前只被描述为任务清单中的一项，但从未嵌入到 AI 模型实际生成的响应结构中。模型在完成代码实现后会自然地结束响应，而不触发记忆更新。修复方案将 `## 记忆更新` 小节变为**必填输出小节**——它不能从响应中缺失，因此 Act 阶段不能被静默跳过。

---

## [v3.0.0] - 2026-05-01

### 为什么有这个版本

v3.0.0 标志着 ai-coding-ok 进入"plugin 时代"。核心 PDCA 逻辑不变；这是一个结构性升级，使 skill 可以通过 `/plugin install ai-coding-ok@claude-plugins-official` 安装，同时保持 git-clone 路径对 Copilot/Cursor/OpenCode 用户完全可用。

### 新增

- **`.claude-plugin/plugin.json`** — plugin manifest，支持 Claude Code 中 `/plugin install ai-coding-ok@claude-plugins-official`
- **`skills/ai-coding-ok/SKILL.md`** — 规范英文 skill 定义，作为 plugin 安装时 Claude Code 自动加载；包含语言检测（en/zh）用于模板选择
- **`templates/en/`** — 完整英文模板集（18 个文件），使用 `{{kebab-case-placeholders}}`；与 `templates/zh/` 结构一致
- **`README.md`** — 英文根 README，围绕 PDCA 定位和 plugin 安装重写；中文 README 移至 `README.zh.md`
- **`README.zh.md`** — 原有的中文 README 保留于此
- **`--lang en|zh` 选项** — `install.sh` 和 `install.py` 新增 `--lang` 参数选择模板语言（默认：`en`）

### 修改

- **`templates/zh/`** — 所有中文模板从 `templates/` 移入此处；版本标记升级至 v3.0.0
- **`SKILL.md`**（根目录）— 更新以匹配 `skills/ai-coding-ok/SKILL.md`；新增贡献者注意事项，提示从 `skills/` 同步而非直接编辑
- **`install.sh`** / **`install.py`** — `TEMPLATES_DIR` 现在指向 `templates/$LANG`；交互菜单和日志消息更新，推荐 Claude Code 用户使用 plugin 安装
- **全部模板版本标记** — 从 v2.2.0 升级至 v3.0.0

### 向后兼容

- 旧版 git-clone 用户（`~/.claude/skills/ai-coding-ok/`）**不受影响**——根目录 `SKILL.md` 仍然是他们的入口
- `install.sh` / `install.py` 不带 `--lang` 仍然可用；默认是 `en`（之前是中文 `templates/` 根目录）；**中文用户应加 `--lang zh`**
- `templates/zh/` 包含与旧 `templates/` 相同的文件，只是移动了位置

---

## [v2.2.0] - 2026-04-27

### 新增
- **`templates/CLAUDE.md`**：Claude Code 自动加载 shim，内容为 `@AGENTS.md` import。这是 Claude Code 的"硬保险"——即使 skill description 没匹配上、即使是新会话还没主动读 AGENTS.md，PDCA 强制指令也会通过 CLAUDE.md → AGENTS.md 的 import 链路被触发。补齐了 v2.1.0 之前 Claude Code 在「新会话 + 简短指令」组合下偶发的 PDCA 漏触发问题。
- **install.sh / install.py**：Copilot 和 Cursor 模式的冲突检查列表加入 `CLAUDE.md`，避免覆盖用户已有文件
- **SKILL.md**：安装目录树和占位符替换文件清单同步加入 `CLAUDE.md`

### 修改
- **SKILL.md `description` 重写**：句首改为命令式 "USE THIS SKILL FIRST on every coding task…"，把高频 PDCA 触发词（含中英双语）前置，把 INSTALL / UPGRADE 降为从属子句。显著提升 Claude Code skill 自动调用的语义匹配命中率。
- **所有模板文件**：版本标记 `v2.1.0` → `v2.2.0`

### 为什么有这个版本
v2.1.0 实战录视频时发现：在「新会话 + 一句话指令（如"加个收入功能"）」场景下，Claude Code 既没命中 ai-coding-ok skill（旧 description 句首让语义匹配器误判为安装类工具），又没主动读 AGENTS.md，导致 PDCA 整圈漏触发。v2.2.0 从两端同时加固：description 让 skill 路径更稳，CLAUDE.md import 让自动加载路径不可绕过。

---

## [v2.1.0] - 2026-04-26

### 新增
- **OpenCode 支持**：新增 `--opencode` 安装模式，将 skill 部署到 `~/.config/opencode/skills/`，自动创建/更新 `~/.config/opencode/AGENTS.md` 注入 `using-superpowers` 触发指令，解决 OpenCode 无 slash 命令入口的问题
- **Cursor 支持**：新增 `--cursor` 安装模式，新增 `templates/.cursor/rules/ai-coding-ok.mdc`（`alwaysApply: true`），Cursor 每次会话自动强制执行 PDCA 工作流，无需手动触发
- **install.py**：补充 `install_opencode()` 函数，新增 `--opencode` 和 `--cursor` 参数，与 `install.sh` 功能对齐
- **SKILL.md**：frontmatter 新增 `compatibility: opencode, claude, cursor`
- **文档**：README 新增 OpenCode 和 Cursor 快速上手章节，命令速查表补充新选项

### 修改
- **install.sh / install.py**：交互菜单扩展为 5 项（新增 OpenCode、Cursor 选项）；`both` 模式更新为 Claude Code + OpenCode

---

## [v2.0] - 2026-04-19

### 新增
- **AGENTS.md**: 顶部新增「⚠️ AI Agent 必读规范」PDCA 强制指令章节
- **copilot-instructions.md**: 顶部新增「⚠️ 强制执行：PDCA 工作流」章节
- **所有模板文件**: 添加版本标记 `<!-- ai-coding-ok: v2.0 -->` 或 `# ai-coding-ok: v2.0`
- **SKILL.md**: 新增 Mode A/B/C/D 四模式章节（触发条件）
- **SKILL.md**: 新增「与 superpowers skill 的兼容」章节
- **SKILL.md**: 新增 Upgrade Playbook（Mode D）完整实现
- **CHANGELOG.md**: 新增版本变更记录文件
- **scripts/upgrade-prompt.md**: 新增 Copilot 手动升级 prompt

### 修改
- **SKILL.md description**: 新增 PDCA 和 Upgrade 触发词，支持三种模式触发
- **workflows.md**: 各场景 Step 5 收尾步骤增加「⚠️ 不可跳过」标注
- **workflows.md**: Refactor 场景新增 Step 4 收尾（之前缺失）

### 删除
- **copilot-instructions.md**: 移除末尾「🔗 上下文文件引用」章节（已被顶部强制版本替代）

### SKILL.md 变更（框架层面，非项目文件）
- description: 新增 PDCA 和 Upgrade 触发词
- 新增 Mode A/B/C/D 四模式章节
- 新增 Compatibility with superpowers 章节
- 新增 Upgrade Playbook 章节

---

## [v1.0] - 2025-XX-XX（首次发布）

初版发布。文件无版本标记的项目视为 v1.0。

### 特性
- 三层记忆系统（project-memory、decisions-log、task-history）
- PDCA 工作流规范
- 编码规范和工作流指南
- Claude Code 和 GitHub Copilot 双平台支持
