# FAQ

## v2.0 新特性

### Q0: v2.0 改了什么？

主要改动：
1. **三种工作模式**：Install（首次安装）/ PDCA（日常使用）/ Upgrade（升级）
2. **PDCA 强制执行**：`AGENTS.md` 和 `copilot-instructions.md` 顶部嵌入强制指令，确保 AI 每次都执行 PDCA
3. **版本标记**：所有模板文件带 `<!-- ai-coding-ok: v2.0 -->` 标记
4. **自动升级**：输入 `upgrade ai-coding-ok` 可自动升级框架文件

详见 [CHANGELOG.md](../CHANGELOG.md)。

### Q0.1: 怎么升级已安装的项目到 v2.0？

**Claude Code 用户**：在项目里输入 `upgrade ai-coding-ok`

**Copilot 用户**：把 `scripts/upgrade-prompt.md` 内容粘贴到 Copilot Chat

升级会：
- 添加 PDCA 强制指令块
- 添加版本标记
- 强化收尾步骤标注
- 保留你的项目定制内容（项目名、技术栈、架构图等不变）

---

## 安装 & 兼容性

### Q1: ai-coding-ok 和 ai-coding-ok 是什么关系？

`ai-coding-ok` 是原始的**模板仓库**，用户要手动 clone + 拷贝 + 改占位符。
`ai-coding-ok` 是把这个流程打包成**可装即用的 skill**，模板内容完全一样，但安装和定制全自动。

如果你已经手动装过 ai-coding-ok，**不需要**换成 ai-coding-ok — 运行时行为是一致的。

### Q2: 需要 Claude Code 的付费版才能用吗？

不需要。skill 是 Claude Code 的原生能力，免费版也支持。
Copilot 那边也只需要订阅 Copilot 本身即可，ai-coding-ok 完全免费。

### Q3: 能在 Cursor / Continue / Cline 里用吗？

可以，但需要手动配置一下：

- **Cursor**: 把项目里的 `.github/copilot-instructions.md` 软链或复制为 `.cursorrules`
- **Continue / Cline**: 在对应的 rules 配置里引用 `AGENTS.md` 和 `.github/agent/system-prompt.md`

记忆文件（`.github/agent/memory/*.md`）是纯 markdown，任何 AI 工具都能读。

### Q4: Windows 上怎么装？

用 `install.py`：

```powershell
python install.py --claude-code
python install.py --copilot --target C:\your-project
```

`install.sh` 依赖 bash，如果你装了 Git Bash 也能用。

---

## 使用细节

### Q5: AI 每次都读记忆文件会不会很慢？

三个记忆文件一般加起来 < 10KB，在 AI 的上下文预算里几乎不可见。
而且不读记忆的代价（乱改、失忆、破坏已有功能）远高于读记忆的成本。

### Q6: `task-history.md` 会越来越大吗？

不会。规则是"保留近 30 条，超出归档"。skill 装进来的系统 prompt 里有明确指令让 AI 自动归档。
你也可以人工把老条目移到 `docs/task-history-archive-YYYY-Q1.md`。

### Q7: 我要不要手动更新记忆文件？

通常不用。AI 会在每次任务的 Act 阶段自动写。你要做的是：
- 偶尔 Review 一下 AI 写得对不对
- 重大架构决策时**自己手动**加一个 ADR（比只让 AI 写更保险）
- 每月扫一遍 `project-memory.md`，清掉过时信息

### Q8: 占位符没填完会怎样？

影响不大，但 AI 读记忆时会被 `{{项目名称}}` 这种字符串干扰。**跑一下 `scripts/verify.sh`** 看一眼：

- 退出码 0 = 完美
- 退出码 2 = 还有占位符没填，把 `scripts/customize-prompt.md` 再发给 AI 一次

---

## 冲突 & 回滚

### Q9: 我的项目已经有 `AGENTS.md`，会被覆盖吗？

**默认不会**。skill 和安装脚本都会先做冲突检查，发现已有文件就停下来。
只有你明确指定 `--force` 才会覆盖。

### Q10: 装错了想卸载？

```bash
# 删掉 skill 安装的所有文件
rm AGENTS.md
rm -rf .github/copilot-instructions.md .github/project-metadata.yml \
       .github/PULL_REQUEST_TEMPLATE.md .github/ISSUE_TEMPLATE \
       .github/workflows/ci.yml .github/workflows/memory-check.yml \
       .github/agent
# 如果 .github/workflows/ 或 .github/ 本来就空了，也删掉
```

或者直接 `git reset --hard HEAD~1`（前提是你 commit 了安装结果又没做其他改动）。

### Q11: 升级 skill 会不会把我改过的文件覆盖？

**不会。** v2.0 提供两种升级方式：

1. **升级 skill 仓库**（`git pull`）：只更新 skill 本身，不触碰你项目里的文件
2. **升级项目框架文件**（`upgrade ai-coding-ok`）：智能合并框架更新，保留项目定制内容

升级项目时，AI 会：
- 识别框架变更（新增/删除/修改章节）
- 展示变更清单并**请求确认**
- 只更新框架部分，不覆盖你的项目名、技术栈、架构图等定制内容

---

## 和 superpowers 组合

### Q12: 两个 skill 会打架吗？

不会。它们管的事情不重叠：
- superpowers 管"怎么思考"
- ai-coding-ok 管"记住什么、怎么写代码"

Claude Code 会根据你的 prompt 内容和每个 skill 的 `description` 自动决定激活哪一个。

### Q13: 只想装一个可以吗？

可以。ai-coding-ok 自己就能独立工作 — 失去的只是深度研究/brainstorm 的能力。superpowers 自己也能独立工作 — 失去的是跨会话记忆。

推荐两个都装，但如果你只有精力学一个，先装 ai-coding-ok（解决的问题更紧迫 — 失忆和乱改）。

---

## 贡献 & 反馈

### Q14: 我改了模板想贡献回去，怎么做？

1. Fork `ai-coding-ok` 仓库
2. 改 `templates/` 下对应文件
3. 发 PR，PR 描述里说明"哪个模板改了什么 + 为什么改"
4. 如果涉及 skill 行为变化，也改 `SKILL.md`

### Q15: 模板里我觉得某个约束不适合所有项目？

完全可能。模板是**默认值**，你在定制化阶段可以让 AI 按你的项目需要调整（例如去掉 `from __future__ import annotations` 约束，改成 JS 项目的 eslint 规则）。

如果你觉得默认值本身有问题（比如对 Node 项目不友好），欢迎提 Issue 讨论，我们会增加按语言/技术栈的模板变体。

---

## 还有问题？

去仓库发 Issue：https://github.com/Mark7766/ai-coding-ok/issues
