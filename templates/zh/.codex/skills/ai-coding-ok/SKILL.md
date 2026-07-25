# ai-coding-ok — PDCA 记忆闭环（Codex Skill）

> 为项目安装三层记忆系统并强制执行 PDCA 工作流，防止 AI "修了 bug X 却搞坏了功能 Y"。
> 配合项目根目录的 `AGENTS.md` 使用——Codex 会自动加载 AGENTS.md 中的 PDCA 强制指令。

## 触发条件

当用户执行以下操作时激活本 skill：
- 说"安装 ai-coding-ok"、"初始化项目记忆"、"设置 AI 护栏"
- 说"升级 ai-coding-ok"、"更新 ai-coding-ok"
- 项目已安装 ai-coding-ok（`.github/agent/memory/` 存在）且用户进行编码任务

## PDCA 工作流

### Plan（任务前）
在编写任何代码之前：
1. 读取 `AGENTS.md` — 架构速查和约束
2. 读取 `.github/agent/memory/project-memory.md` — 项目事实和约束
3. 读取 `.github/agent/memory/decisions-log.md` — 历史技术决策（ADR）
4. 读取 `.github/agent/memory/task-history.md` — 近期任务 context

### Do（执行）
- 编写代码，同时编写测试
- 遵循 `.github/agent/coding-standards.md` 中的编码规范

### Check（验证）
- 运行测试，确认无回归
- 检查 lint/type check

### Act（任务后，⚠️ 不可跳过）
- 更新 `.github/agent/memory/task-history.md`（始终执行）
- 如有架构决策变更 → 更新 `.github/agent/memory/decisions-log.md`
- 如有项目事实变化 → 更新 `.github/agent/memory/project-memory.md`

## 安装（首次使用）

如果项目尚无 `.github/agent/memory/` 目录：

1. 定位 ai-coding-ok 的 `templates/zh/` 目录
2. 将模板复制到项目根目录
3. 询问用户："一句话告诉我你想做一个什么东西？"
4. 根据描述推断技术栈，替换所有 `{{占位符}}`
5. 初始化 `task-history.md` 第一条记录

## 升级（已安装项目）

如果项目已有 `.github/agent/memory/`：

1. 检测当前安装的 ai-coding-ok 版本（读取文件首行版本标记）
2. 对比最新模板与项目文件
3. 报告变更清单，征得用户确认后合并升级
4. 保留项目定制内容

## 验证

```bash
bash scripts/verify.sh
```

退出码：0 = 正常，1 = 缺失文件，2 = 未填充的占位符。

## 记忆文件结构

```
.github/agent/memory/
├── project-memory.md      # 🧠 长期记忆：架构、约束、已知问题
├── decisions-log.md       # 📝 中期记忆：ADR（为什么选 X 而不是 Y）
└── task-history.md        # 📜 短期记忆：最近 30 条任务摘要
```
