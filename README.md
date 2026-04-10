# 🤖 AI Coding OK — Copilot Agent 配置框架

[![GitHub](https://img.shields.io/badge/GitHub-ai--coding--ok-blue?logo=github)](https://github.com/Mark7766/ai-coding-ok)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **让 AI 像资深工程师一样写代码，而不是像实习生一样堆代码。**

一套从真实生产项目中沉淀出来的 **GitHub Copilot Agent 配置框架**，经过 500+ 测试用例验证。帮你解决 AI 编程的老大难问题：**代码写得快但不敢上线、Bug 修不完、改一个坏三个。**

⭐ 如果对你有帮助，请给个 Star，让更多人看到！

---

## 🤔 它解决什么问题？

| 你遇到的问题 | 这套框架怎么解决 |
|------------|---------------|
| AI 写的代码有很多隐藏 Bug | 强制 AI 每次写功能都附带测试，修 Bug 先写失败用例 |
| 修一个 Bug 又搞坏其他功能 | 累积的测试用例形成安全网，任何回归立即被发现 |
| AI 每次对话都"失忆" | 三级记忆系统（长/中/短期），跨会话保持上下文 |
| AI 写的代码风格混乱 | 详细的编码规范文件，AI 严格遵守 |
| 不知道 AI 能做什么不能做什么 | 三级权限制度（🟢🟡🔴），行为边界清晰 |

---

## 📦 仓库结构

```
ai-coding-ok/
├── README.md                          ← 本文件
├── AGENTS.md.template                 ← 项目地图模板（复制到你的项目根目录）
└── .github/
    ├── copilot-instructions.md        ← Copilot 全局行为指令
    ├── project-metadata.yml           ← 项目元信息（机器可读）
    ├── PULL_REQUEST_TEMPLATE.md       ← PR 模板（含记忆更新检查）
    ├── ISSUE_TEMPLATE/
    │   ├── config.yml
    │   ├── bug_report.yml
    │   └── feature_request.yml
    ├── workflows/
    │   ├── ci.yml                     ← CI 流水线模板
    │   └── memory-check.yml           ← 记忆文件更新提醒
    └── agent/
        ├── system-prompt.md           ← Agent 核心人格 & PDCA 工作流
        ├── coding-standards.md        ← 编码规范
        ├── workflows.md               ← 场景化工作流指南
        ├── prompt-templates.md        ← Prompt 模板库
        └── memory/
            ├── project-memory.md      ← 长期记忆（项目事实）
            ├── decisions-log.md       ← 技术决策日志（ADR）
            └── task-history.md        ← 短期记忆（任务历史）
```

---

## 🚀 快速开始（3 步上手）

### Step 1: 克隆仓库，复制配置到你的项目

```bash
# 克隆本仓库
git clone https://github.com/Mark7766/ai-coding-ok.git

# 复制 .github 目录到你的项目
cp -r ai-coding-ok/.github your-project/.github

# 复制 AGENTS.md 模板到你的项目根目录
cp ai-coding-ok/AGENTS.md.template your-project/AGENTS.md
```

### Step 2: 告诉 Copilot 你想做什么，让 AI 自动定制所有配置

复制配置文件后，你**不需要手动替换**模板中的 `{{占位符}}`，也**不需要懂技术栈、架构设计这些概念**。

打开 Copilot Chat，**只需要用你自己的话说清楚你想做一个什么东西就行：**

> 请阅读 `.github/` 下所有配置文件和 `AGENTS.md`，这些文件中有 `{{占位符}}` 需要替换。
>
> 我想做的东西是：**（用你自己的话描述）**
>
> 比如：
> - "我想做一个给自己用的记账小工具，能记录每天花了多少钱，月底能看到饼图统计"
> - "我想做一个公司内部的请假审批系统，员工提交请假单，主管在线审批"
> - "我想做一个爬虫，每天自动抓取某个网站的价格数据，存到数据库里"
>
> 请根据我的需求，自行判断合适的项目名称、技术栈、架构设计和编码规范，然后将所有配置文件中的 `{{占位符}}` 替换为实际内容。

**Copilot 会根据你的需求描述，自动推断出合适的技术选型、架构方案和编码规范，然后一次性替换所有配置文件中的占位符。** 你只需要 Review 一下结果就行了。

### Step 3: 开始用 Copilot 开发！

从现在起，AI 将自动遵循你定义的规范、流程和约束。每次开发：
- ✅ 先读记忆，理解上下文
- ✅ 先出计划，再写代码
- ✅ 写功能必带测试
- ✅ 完成后更新记忆

---

## 🧠 核心设计理念

### 1. 三层配置体系

| 层级 | 文件 | 作用 | 类比 |
|------|------|------|------|
| 第一层 | `AGENTS.md` | 架构速查，AI 最先读取 | 🗺️ 作战地图 |
| 第二层 | `copilot-instructions.md` | 全局行为指令 | 📋 岗位说明书 |
| 第三层 | `agent/` 子目录 | 编码规范、工作流、记忆 | 📖 操作手册 |

### 2. 记忆系统（解决 AI 跨会话失忆）

| 记忆类型 | 文件 | 内容 | 更新频率 |
|---------|------|------|---------|
| 长期记忆 | `project-memory.md` | 架构、约束、已知问题 | 很少变化 |
| 中期记忆 | `decisions-log.md` | 技术决策（ADR 格式） | 架构变更时 |
| 短期记忆 | `task-history.md` | 近 30 条任务摘要 | 每次任务后 |

### 3. PDCA 工作流

```
Plan(读记忆→理解→出计划) → Do(写代码+写测试) → Check(跑测试→验回归) → Act(更新记忆)
```

### 4. 多角色切换

产品经理 → 架构师 → 后端工程师 → 前端工程师 → 测试工程师 → Code Reviewer

### 5. 三级行为权限

- 🟢 可自主执行（命名优化、补测试、修明显 bug）
- 🟡 需确认后执行（新增依赖、改数据库、改核心逻辑）
- 🔴 禁止自主执行（删数据、改凭据、发版本）

---

## 💡 最佳实践

1. **先写配置，再写代码** — 30 分钟配置，后续省几十小时
2. **让 AI 定制配置** — Step 2 中描述清楚，AI 自动替换所有占位符
3. **及时更新记忆** — 每次架构变更后更新 decisions-log
4. **保持约束清晰** — "绝对不能做"的事写进 AGENTS.md
5. **定期审查记忆** — 每月检查一次，清理过期信息

---

## 🌟 实战验证

此框架来自一个真实生产项目的实践：

| 指标 | 数据 |
|------|------|
| 测试用例 | 563 个 |
| 测试覆盖率 | 83%+ |
| 功能模块 | 15+ |
| 线上事故 | **0** |

---

## 🤝 参与贡献

欢迎提 Issue 和 PR！如果你有更好的配置实践，欢迎分享。

---

## 📄 许可

[MIT](LICENSE) — 可自由使用、修改和分发。  
同时，咱们为关注者搭建了一个专属交流群，欢迎加入一起交流 AI 编程的最佳实践！扫码加群：    
![developer.png](developer.png)