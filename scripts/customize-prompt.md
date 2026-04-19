# 定制化提示词 / Customization Prompt

> 把下面整段复制粘贴到 **Copilot Chat** 或 **Claude Code** 会话里，AI 会自动读所有模板文件、推断合适的技术选型、替换所有 `{{占位符}}`。

---

## 提示词（复制我 👇）

请阅读项目根目录下所有 `{{...}}` 占位符文件并完成定制化，范围包括：

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/project-metadata.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
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

我想做的东西（一句话）：

> **【在这里用自己的话写一句，例如："一个给自己用的记账小工具，记录每天花销，月底能看饼图"】**

请按如下方式处理：

1. **不要让我回答一堆问题**，直接根据这一句话推断合理的：项目名称、项目类型、设计原则、用户规模、技术栈（语言 / 框架 / 数据库 / ORM / 前端 / 测试框架 / 包管理 / 格式化工具）、目录结构、核心模块划分、核心业务流程和关键业务概念。
2. 遵循极简原则：个人/小团队工具优先选**部署简单**的方案（如 SQLite + FastAPI + Jinja2 而不是 Postgres + React SPA）。
3. **用 Edit/写文件工具把每个 `{{占位符}}` 都替换掉**。如果某个占位符不适用（例如不需要前端），填 `N/A` 并在注释里说明。
4. `{{YYYY-MM-DD}}` 一律替换成今天的日期。
5. 如果某个技术决策有多个合理选项，选择较简单的那个，并在 `.github/agent/memory/decisions-log.md` 的 ADR-001 里记录"选它的理由"。
6. `.github/agent/memory/task-history.md` 的 TASK-001 写成真实的本次初始化记录。
7. 完成后输出一个简短清单：
   - 推断出的项目基本信息（名称 / 类型 / 技术栈一行）
   - 关键决策 2-3 条
   - 我需要 Review 确认的地方（如有）

请开始。
