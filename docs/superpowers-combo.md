# ai-coding-ok × superpowers — 组合使用指南

> [`superpowers`](https://github.com/obra/superpowers) 擅长**发散思考、深度研究、多 sub-agent 编排**；
> `ai-coding-ok` 擅长**固化上下文、保证代码质量、跨会话持续**。
>
> 两个组合起来就是：**想得深 + 记得住**。

---

## ✨ v2.0 组合增强

v2.0 专门优化了与 superpowers 的协作：

1. **AGENTS.md hook**：brainstorming 的 Step 1 读 AGENTS.md 时会遇到 PDCA 强制指令
2. **writing-plans 兼容**：生成的计划自动追加「更新项目记忆」任务
3. **双路径覆盖**：无论用 superpowers 还是直接用 ai-coding-ok，PDCA 都会执行

详见 [SKILL.md](../SKILL.md) 的「Compatibility with superpowers skill」章节。

---

## 为什么要组合？

|              | superpowers | ai-coding-ok |
|--------------|-------------|----------------|
| 主要价值     | 让 Claude 聪明地思考一件事 | 让 Claude 长期一致地做一堆事 |
| 时间尺度     | 单次会话内                 | 跨会话、跨月份 |
| 负责人       | 多 sub-agent，"发散 + 收敛" | 三层记忆，"沉淀 + 召回" |
| 触发时机     | 需要规划、研究、调研        | 每次写代码前 + 每次写完后 |
| 典型输出     | 设计稿、调研报告、方案对比  | `AGENTS.md` / `decisions-log.md` 更新 |

**直觉类比**：superpowers 是"脑力工作坊"，ai-coding-ok 是"组织记忆档案馆"。你光有工作坊，下一个团队来了还得从头开始；你光有档案馆，遇到新问题谁来想办法？两者配齐才能让 AI 编程像一个真正的团队运作。

---

## 同时安装

```bash
# Claude Code：两个 skill 一起装
git clone https://github.com/obra/superpowers        ~/.claude/skills/superpowers
git clone https://github.com/Mark7766/ai-coding-ok ~/.claude/skills/ai-coding-ok

# 在项目里初始化 ai-coding-ok
cd your-project && claude
# 会话里：
> /ai-coding-ok
```

两个 skill 完全独立，各自有自己的 `SKILL.md`，Claude 会按需激活，不会冲突。

---

## 五个实战配方 🍳

### 配方 1：新项目启动（Brainstorm → Memorize）

1. **superpowers**: 
   > "用 brainstorm 和 deep-research，帮我设计一个 xxx 系统的架构方案，对比三种技术栈。"
   
   → 得到 3 个方案的权衡分析。

2. **你选一个方案。**

3. **ai-coding-ok**:
   > "/ai-coding-ok。项目要做的是 <方案摘要>，技术栈选 <选中的方案>。"
   
   → ai-coding-ok 把选型结果**固化进 `decisions-log.md`**（带权衡理由），后续所有会话都继承。

**效果**：下一次你/队友/另一个 AI 打开项目，直接读 `decisions-log.md` 就知道"为啥用 Postgres 而不是 Mongo" — 不用再调研一遍。

---

### 配方 2：修复复杂 Bug（Research → Fix → Record）

1. **ai-coding-ok** 自动触发的 Plan 阶段：
   
   Claude 先读 `project-memory.md` 里的 "已知问题 & 常见坑" 表，看这个 bug 是不是老熟人。

2. **如果是新 bug**，让 **superpowers** 出场：
   > "用 debug sub-agent 深度分析这个栈，找出根因。"

3. 修完之后，**ai-coding-ok** 的 Act 阶段：
   
   Claude 自动把"这个 bug 的根因和修复方法"写进 `project-memory.md` 的常见坑表 + `task-history.md`。

**效果**：同一类 bug 第二次出现时，Plan 阶段 3 秒命中记忆，省掉整轮 superpowers 调研。

---

### 配方 3：架构重构（Plan → Execute → Document）

1. **superpowers**:
   > "用 plan sub-agent，评估把 <模块 X> 从同步改异步的成本和收益。"

2. **你拍板。**

3. **ai-coding-ok** 保证执行：
   - Plan 阶段把整件事拆成可验证小步
   - Check 阶段每步跑测试
   - Act 阶段写 ADR-XXX 到 `decisions-log.md`

**效果**：半年后回头看，为啥要重构、怎么做的、踩了哪些坑 — `decisions-log.md` 全有。

---

### 配方 4：跨会话的长跑任务

场景：一个功能要做 3 天，中间要开好几次 Claude Code。

1. **Day 1 开工前**：
   > "/ai-coding-ok 读记忆"（Claude 自动做）

2. **Day 1 收工前**：
   > "更新 task-history，下次我继续时第一句读这个。"

3. **Day 2 开工**：直接 `claude`，告诉它：
   > "继续昨天的 TASK-037。"
   
   Claude 读 task-history 即可立刻跟上。

4. **需要加新组件时**调 **superpowers**：
   > "用 research sub-agent 看看主流解决方案。"

**效果**：3 天的任务没有一秒钟是在"重新建立上下文"上浪费的。

---

### 配方 5：团队接手 & Onboard

新队友接手项目时：

1. 让他 `git clone` 两个 skill。
2. 在项目里：
   > "用 ai-coding-ok 的记忆文件给我一份 15 分钟上手指南。用 superpowers 的 research 深入解释其中最复杂的一个模块。"

Claude 会：
- 从 `project-memory.md` 抽架构摘要
- 从 `decisions-log.md` 列关键决策
- 从 `task-history.md` 讲最近在做什么
- 调 superpowers 对指定模块做深度解析

**效果**：新人 Day-1 即战力，不用老司机陪读文档。

---

## 反模式：不要这么做 🚫

❌ **用 superpowers 做日常 CRUD** — 杀鸡用牛刀，白烧 token，ai-coding-ok 的 PDCA 完全够用。

❌ **用 ai-coding-ok 做头脑风暴** — 它是记录系统，不是思考系统。遇到需要发散的问题立刻切 superpowers。

❌ **让两个 skill 都写同一个文件** — 容易打架。分工：superpowers 产出"方案 markdown"放 `docs/`；ai-coding-ok 把"方案摘要 + 选择理由"写进 `decisions-log.md`。

> 💡 v2.0 改进：ai-coding-ok 现在会**自动**在 superpowers 流程结束后触发 Mode C（Act），同步记忆。你不再需要手动提醒。

---

## 配置建议

### Claude Code 全局 `settings.json`（可选）

如果你两个 skill 都装了，可以在 `~/.claude/settings.json` 加一条偏好：

```json
{
  "preferences": {
    "default_workflow": "read .github/agent/memory/ before acting; record decisions to decisions-log.md"
  }
}
```

Claude 每次会话都会继承这个偏好，相当于把 ai-coding-ok 的 Plan/Act 默认打开。

### 给 superpowers 的 hint（v2.0 前需要，v2.0 后自动）

v2.0 起，`AGENTS.md` 顶部已嵌入 PDCA 强制指令。当 brainstorming 读取 AGENTS.md 时，会自动遇到 PDCA 要求。

如果你用的是 v1.0，可以手动给 superpowers 一句 prompt 前缀：

> "运行前先读 `.github/agent/memory/project-memory.md` 理解约束，运行后把关键产出存进 `.github/agent/memory/decisions-log.md` 的新 ADR。"

---

## 一句话总结

**superpowers 让一次对话变聪明，ai-coding-ok 让一个项目变聪明。两个一起用，AI 编程就接近一个真正的工程师了。**
