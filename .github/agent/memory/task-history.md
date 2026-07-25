# 📜 ai-coding-ok — 任务历史

> **用途**：记录近期任务摘要，为 AI Agent 提供短期上下文记忆。
> 保留最近 30 条任务记录，超出后归档。

---

## 记录格式

```markdown
### [TASK-{编号}] {任务标题}
- **日期**：YYYY-MM-DD
- **类型**：feat / fix / refactor / docs / chore
- **摘要**：一句话说明做了什么
- **变更文件**：列出核心变更文件
- **关联 Issue**：#xxx（如有）
- **注意事项**：后续需要注意的事项（如有）
```

---

## 任务记录

### [TASK-001] 安装 ai-coding-ok 并完成项目初始化（dogfooding）
- **日期**：2026-06-08
- **类型**：chore
- **摘要**：在 ai-coding-ok 仓库自身安装 ai-coding-ok 三层记忆系统。使用仓库最新的 zh/ 中文模板，dogfooding 自己的产品。完成所有占位符替换，初始化 project-memory.md（记录项目事实和 4 条约束）、decisions-log.md（记录 4 个 ADR，含 hook 整改方案 ADR-003）、task-history.md（本文件）。
- **变更文件**：AGENTS.md, CLAUDE.md, .github/copilot-instructions.md, .github/agent/system-prompt.md, .github/agent/workflows.md, .github/agent/coding-standards.md, .github/agent/prompt-templates.md, .github/agent/memory/project-memory.md, .github/agent/memory/decisions-log.md, .github/agent/memory/task-history.md, .github/project-metadata.yml, .github/workflows/ci.yml, .github/workflows/memory-check.yml, .github/ISSUE_TEMPLATE/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .cursor/rules/ai-coding-ok.mdc
- **注意事项**：首次安装，dogfooding 模式。需要区分"模板源码"（templates/zh/、templates/en/——产品）和"已安装文件"（./AGENTS.md、./.github/agent/memory/——过程记录）。后续开发中 AGENTS.md Plan 阶段增加到了 7 步（覆盖 agent 文档），这是一个框架级别的改进。

---

### [TASK-002] v3.1.0 五层防御体系实施 + 自用安装升级
- **日期**：2026-06-08
- **类型**：feat
- **摘要**：按 docs/hook-trigger-remediation-plan.md 实施五层防御体系。Layer 1: CLAUDE.md STOP 硬指令；Layer 2: AGENTS.md Plan 3→7 步 + Act 新增文档同步；Layer 3: copilot-instructions.md Act 新增第 4 步；Layer 4: 新增 .claude/settings.local.json 四重 hooks 模板；Layer 5: SKILL.md 安装流程新增 Step 5.5/5.6 hooks 配置。所有模板版本标记 v3.0.x → v3.1.0（zh+en 共 20 个文件）。测试验证通过。同步升级 ai-coding-ok 自用安装。
- **变更文件**：templates/zh/CLAUDE.md, templates/en/CLAUDE.md, templates/zh/AGENTS.md, templates/en/AGENTS.md, templates/zh/.github/copilot-instructions.md, templates/en/.github/copilot-instructions.md, templates/zh/.claude/settings.local.json（新）, templates/en/.claude/settings.local.json（新）, SKILL.md, install.sh, 全部模板版本标记, CLAUDE.md（根）, AGENTS.md（根）, .github/copilot-instructions.md（根）, .claude/settings.local.json（根，加 hooks）, .github/agent/memory/project-memory.md, .github/agent/memory/task-history.md
- **注意事项**：Stop hook 的 {{SOURCE_DIR_PATTERN}} 在模板中保留为占位符，由 AI 安装时按项目实际源码目录填充。settings.json 与 settings.local.json 冲突风险已在文档和安装日志中警示。

---

### [TASK-003] 提交 v3.1.0 并推送到远程仓库
- **日期**：2026-06-10
- **类型**：chore
- **摘要**：将 v3.1.0 全部变更（五层防御体系 + zh/en 模板同步 + self-dogfooding 安装文件 + hooks 配置文档）git add → commit → push 到 origin/master（github.com:Mark7766/ai-coding-ok.git）。41 files changed, 2207 insertions, 41 deletions。
- **变更文件**：全部 41 个文件（22 modified + 18 new + 1 new doc）
- **注意事项**：push 前确认 project-memory.md 约束1（push 需用户明确许可）合规。后续开发者将基于此 commit 继续工作。

---

### [TASK-004] 编写中文化回归方案
- **日期**：2026-07-25
- **类型**：docs
- **摘要**：响应 wangliang 的要求，编写「ai-coding-ok 中文化回归方案」。第一版为"中英文优先"，经 wangliang 反馈后修改为"彻底删除英文支持"：删除 templates/en/ 全部 19 个文件、删除 README.zh.md、SKILL.md 全文中文化（保留 PDCA/ADR/hook 等技术术语和代码块）、install.sh 删除语言选择逻辑、README.md 改为中文。v3.0.0 以来的全部能力（五层防御、hooks、Install/Upgrade Playbook、dogfooding）保留。版本 v3.1.0 → v4.0.0。
- **变更文件**：docs/chinese-first-migration-plan.md（新建，二版修改）
- **注意事项**：方案已获 wangliang 确认方向。待确认后进入实施。ADR-005 和 ADR-001 状态更新待实施时写入。

---

### [TASK-005] 实施 v4.0.0 中文化回归
- **日期**：2026-07-25
- **类型**：feat
- **摘要**：按 docs/chinese-first-migration-plan.md 方案执行全部六个阶段的改造。阶段一：删除 templates/en/（19 个文件）和 README.zh.md。阶段二：SKILL.md 全文中文化（保留 PDCA/ADR/hook/template 等技术术语和代码块），删除 Language detection 章节，同步 skills/ai-coding-ok/SKILL.md。阶段三：README.md 改为中文，CHANGELOG.md 中文化并新增 v4.0.0 条目。阶段四：install.sh/install.py 中文化并删除 --lang 选项硬编码 templates/zh/，scripts/verify.sh/output/customize-prompt.md/upgrade-prompt.md 全部中文化。阶段五：AGENTS.md 约束更新、decisions-log.md 新增 ADR-005 + ADR-001 标为已替代、project-memory.md 更新、plugin.json 改中文。阶段六：全部版本标记 v3.1.0 → v4.0.0。
- **变更文件**：SKILL.md（重写）、skills/ai-coding-ok/SKILL.md（同步）、README.md（重写）、CHANGELOG.md（重写+新增 v4.0.0）、install.sh（中文化+删除--lang）、install.py（同上）、scripts/verify.sh（中文化）、scripts/customize-prompt.md（中文化）、scripts/upgrade-prompt.md（中文化+新增 v3.x→v4.0.0 路径）、.claude-plugin/plugin.json（中文 description+版本）、AGENTS.md（约束更新）、templates/zh/AGENTS.md（约束更新）、decisions-log.md（ADR-005+ADR-001 状态）、project-memory.md（主语言+架构）、task-history.md（TASK-005）、templates/en/（删除 19 个文件）、README.zh.md（删除）、全部文件版本标记
- **注意事项**：v4.0.0 Breaking Change——不再强制双语同步。v3.0.0 以来全部能力（五层防御、四重 hooks、Mode B/C/D、Install/Upgrade Playbook、dogfooding）完整保留。SKILL.md 技术术语保留英文以确保 AI 工具理解。待进入阶段六（版本标记更新）。

---

### [TASK-006] v4.1.0 新增 Codex 支持
- **日期**：2026-07-25
- **类型**：feat
- **摘要**：新增 OpenAI Codex CLI 支持。Codex 原生加载 AGENTS.md，ai-coding-ok 的 PDCA 强制指令天然兼容。新增 templates/zh/.codex/skills/ai-coding-ok/ 目录（SKILL.md + verification.md）作为 Codex skill 定义。install.sh/install.py 新增 --codex 安装模式（交互菜单第 5 项）。SKILL.md/AGENTS.md/README.md 全部更新添加 Codex 文档。新增 ADR-006。版本 v4.0.0 → v4.1.0。五平台覆盖：Claude Code + Copilot + Cursor + OpenCode + Codex。
- **变更文件**：templates/zh/.codex/skills/ai-coding-ok/SKILL.md（新）、templates/zh/.codex/skills/ai-coding-ok/verification.md（新）、SKILL.md（compatibility+Codex章节+架构图）、skills/ai-coding-ok/SKILL.md（同步）、AGENTS.md（跨平台层）、README.md（安装章节+架构图）、install.sh（--codex模式+菜单）、install.py（--codex模式+菜单）、CHANGELOG.md（v4.1.0条目）、decisions-log.md（ADR-006）、project-memory.md（版本更新）、task-history.md（TASK-006）、.claude-plugin/plugin.json（版本）、全部文件版本标记 v4.0.0→v4.1.0
- **注意事项**：Codex 与 OpenCode 共享 AGENTS.md 加载机制。Codex 的 ~/.codex/memories/ 自动记忆系统与 ai-coding-ok 三层记忆互补不冲突。Codex 使用 TOML 配置格式（~/.codex/config.toml 或 .codex/config.toml），与 Claude Code 的 JSON 配置不同。

