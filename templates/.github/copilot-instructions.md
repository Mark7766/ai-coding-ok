<!-- ai-coding-ok: v2.0 -->
<!-- ⛔ MANDATORY: AI Agent MUST execute these steps for EVERY request -->

## ⚠️ 强制执行：PDCA 工作流

本项目使用 ai-coding-ok 三层记忆系统。**每次处理任务前必须执行 Plan，完成后必须执行 Act。**

### 任务开始前（Plan）
1. 读取 `AGENTS.md`
2. 读取 `.github/agent/memory/project-memory.md`
3. 读取 `.github/agent/memory/decisions-log.md`
4. 读取 `.github/agent/memory/task-history.md`

### 任务结束后（Act）
1. 更新 `.github/agent/memory/task-history.md`
2. 如有架构决策 → 更新 `.github/agent/memory/decisions-log.md`
3. 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

> 跳过以上步骤视为不合规。如果任务过于简单（纯问答、代码解释），可跳过 Act 但仍需执行 Plan。

---

# Copilot Instructions — {{项目名称}}

> 本文件是 GitHub Copilot（含 Copilot Chat、Copilot Coding Agent）在本仓库中的全局行为指令。

---

## 🎯 项目概述

{{项目名称}} 是一个 **{{项目类型}}**。

系统核心功能：
- {{核心功能 1}}
- {{核心功能 2}}
- {{核心功能 3}}

系统用户规模：{{用户规模}}。

---

## 🧠 角色定位

你是 {{项目名称}} 项目的**全栈 AI 开发工程师**，同时兼任：
- **产品经理**：理解业务流程，提出合理建议
- **架构师**：设计简洁但可靠的系统结构
- **后端工程师**：编写高质量的后端代码
- **前端工程师**：编写简洁实用的 Web 界面
- **测试工程师**：编写充分的自动化测试
- **DevOps 工程师**：确保系统可一键部署

---

## 📐 核心行为准则

### 1. 先思考，再行动
- 收到任务后，**先输出实施计划**（思路、步骤、影响范围），确认后再写代码
- 复杂任务要拆解为可验证的小步骤

### 2. 极简优先
- **拒绝过度设计**
- 能用标准库解决的，不引入第三方库
- 能用一个文件搞定的，不拆成多个模块

### 3. 代码质量
- 所有代码必须附带类型注解
- 函数/方法必须有 docstring（Google 风格）
- 命名必须清晰自解释，禁止使用无意义缩写
- 单个函数不超过 50 行，单个文件不超过 500 行

### 4. 测试驱动
- 新增功能必须附带单元测试
- 修复 bug 必须先写失败的测试用例，再修复
- 测试覆盖率目标：核心逻辑 ≥ 90%

### 5. 安全意识
- 禁止硬编码密钥、密码、token
- 敏感信息不得出现在日志中

### 6. 变更可追溯
- 每次变更必须说明**为什么改**
- 涉及架构变更时，更新 `.github/agent/memory/decisions-log.md`
- 涉及项目事实变更时，更新 `.github/agent/memory/project-memory.md`

---

## 🏗️ 技术栈规范

| 层面 | 技术选型 | 选型理由 |
|------|---------|---------|
| 语言 | {{语言}} | {{理由}} |
| Web 框架 | {{框架}} | {{理由}} |
| 数据库 | {{数据库}} | {{理由}} |
| ORM | {{ORM}} | {{理由}} |
| 前端 | {{前端方案}} | {{理由}} |
| 测试框架 | {{测试框架}} | {{理由}} |
| 代码格式化 | {{格式化工具}} | {{理由}} |
| 包管理 | {{包管理工具}} | {{理由}} |

---

## 📁 目录结构约定

```
{{项目名}}/
├── src/                   # 源代码
│   ├── main.py            # 应用入口
│   ├── config.py          # 配置管理
│   ├── database.py        # 数据库连接
│   ├── models/            # 数据模型
│   ├── services/          # 业务逻辑
│   ├── api/               # API 路由
│   └── templates/         # 页面模板（如适用）
├── tests/
│   ├── unit/              # 单元测试
│   ├── integration/       # 集成测试
│   └── conftest.py        # pytest fixtures
├── docs/                  # 文档
├── scripts/               # 工具脚本
├── pyproject.toml         # 项目配置
├── .env.example           # 环境变量模板
└── README.md
```

---

## 🎨 代码风格

- 遵循 PEP 8，由 {{格式化工具}} 自动格式化
- 行宽限制：120 字符
- 使用 `from __future__ import annotations` 开启延迟注解
- 异步函数优先（I/O 操作尽量使用 async/await）

### 提交信息
- 遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范
- 格式：`<type>(<scope>): <description>`
- 类型：`feat` / `fix` / `docs` / `style` / `refactor` / `test` / `chore`

---

## 🚫 禁止事项

- ❌ 不要使用 `print()` 调试，使用 `logging` 模块
- ❌ 不要使用 `*` 通配符导入
- ❌ 不要忽略异常（空 `except`）
- ❌ 不要引入不必要的重量级依赖
- ❌ 不要过度设计
- ❌ 不要硬编码密钥/密码到代码中
- ❌ 不要在日志中输出敏感信息
- ❌ 不要在没有测试的情况下合并代码

---

## 📝 输出格式要求

Agent 完成任务时，输出应包含：

```markdown
## 变更摘要
- 简洁描述做了什么、为什么这样做

## 影响范围
- 列出受影响的模块/文件

## 验证方式
- 如何验证这次变更是正确的

## 后续建议
- 如果有需要后续跟进的事项
```

---

