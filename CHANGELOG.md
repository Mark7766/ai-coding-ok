# Changelog

All notable changes to ai-coding-ok will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v2.2.0] - 2026-04-27

### Added
- **`templates/CLAUDE.md`**：Claude Code 自动加载 shim，内容为 `@AGENTS.md` import。这是 Claude Code 的"硬保险"——即使 skill description 没匹配上、即使是新会话还没主动读 AGENTS.md，PDCA 强制指令也会通过 CLAUDE.md → AGENTS.md 的 import 链路被触发。补齐了 v2.1.0 之前 Claude Code 在「新会话 + 简短指令」组合下偶发的 PDCA 漏触发问题。
- **install.sh / install.py**：Copilot 和 Cursor 模式的冲突检查列表加入 `CLAUDE.md`，避免覆盖用户已有文件
- **SKILL.md**：安装目录树和占位符替换文件清单同步加入 `CLAUDE.md`

### Modified
- **SKILL.md `description` 重写**：句首改为命令式 "USE THIS SKILL FIRST on every coding task (feat, fix, bug, refactor, plan, design, brainstorm, code review, implement, add feature, write tests, 新功能, 修复, 重构) whenever the project contains `.github/agent/memory/` or `AGENTS.md`"，把高频 PDCA 触发词（含中英双语）前置，把 INSTALL / UPGRADE 降为从属子句。显著提升 Claude Code skill 自动调用的语义匹配命中率。
- **所有模板文件**：版本标记 `v2.1.0` → `v2.2.0`

### Why this release
v2.1.0 实战录视频时发现：在「新会话 + 一句话指令（如"加个收入功能"）」场景下，Claude Code 既没命中 ai-coding-ok skill（旧 description 句首 "Three modes: (1) INSTALL — sets up..." 让语义匹配器误判为安装类工具），又没主动读 AGENTS.md，导致 PDCA 整圈漏触发。v2.2.0 从两端同时加固：description 让 skill 路径更稳，CLAUDE.md import 让自动加载路径不可绕过。

---

## [v2.1.0] - 2026-04-26

### Added
- **OpenCode 支持**：新增 `--opencode` 安装模式，将 skill 部署到 `~/.config/opencode/skills/`，自动创建/更新 `~/.config/opencode/AGENTS.md` 注入 `using-superpowers` 触发指令，解决 OpenCode 无 slash 命令入口的问题
- **Cursor 支持**：新增 `--cursor` 安装模式，新增 `templates/.cursor/rules/ai-coding-ok.mdc`（`alwaysApply: true`），Cursor 每次会话自动强制执行 PDCA 工作流，无需手动触发
- **install.py**：补充 `install_opencode()` 函数，新增 `--opencode` 和 `--cursor` 参数，与 `install.sh` 功能对齐
- **SKILL.md**：frontmatter 新增 `compatibility: opencode, claude, cursor`
- **文档**：README 新增 OpenCode 和 Cursor 快速上手章节，命令速查表补充新选项

### Modified
- **install.sh / install.py**：交互菜单扩展为 5 项（新增 OpenCode、Cursor 选项）；`both` 模式更新为 Claude Code + OpenCode

---

## [v2.0] - 2026-04-19

### Added
- **AGENTS.md**: 顶部新增「⚠️ AI Agent 必读规范」PDCA 强制指令章节
- **copilot-instructions.md**: 顶部新增「⚠️ 强制执行：PDCA 工作流」章节
- **所有模板文件**: 添加版本标记 `<!-- ai-coding-ok: v2.0 -->` 或 `# ai-coding-ok: v2.0`
- **SKILL.md**: 新增 Mode A/B/C/D 四模式章节（When to invoke this skill）
- **SKILL.md**: 新增「Compatibility with superpowers skill」章节
- **SKILL.md**: 新增 Upgrade Playbook（Mode D）完整实现
- **CHANGELOG.md**: 新增版本变更记录文件
- **scripts/upgrade-prompt.md**: 新增 Copilot 手动升级 prompt

### Modified
- **SKILL.md description**: 新增 PDCA 和 Upgrade 触发词，支持三种模式触发
- **workflows.md**: 各场景 Step 5 收尾步骤增加「⚠️ 不可跳过」标注
- **workflows.md**: Refactor 场景新增 Step 4 收尾（之前缺失）

### Removed
- **copilot-instructions.md**: 移除末尾「🔗 上下文文件引用」章节（已被顶部强制版本替代）

### SKILL.md Changes (framework level, not project files)
- description: 新增 PDCA 和 Upgrade 触发词
- 新增 Mode A/B/C/D 四模式章节
- 新增 Compatibility with superpowers 章节
- 新增 Upgrade Playbook 章节

---

## [v1.0] - 2025-XX-XX (Initial Release)

初版发布。文件无版本标记的项目视为 v1.0。

### Features
- 三层记忆系统（project-memory、decisions-log、task-history）
- PDCA 工作流规范
- 编码规范和工作流指南
- Claude Code 和 GitHub Copilot 双平台支持
