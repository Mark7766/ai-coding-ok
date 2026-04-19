# Claude Code 快速上手

> 5 分钟内把 ai-coding-ok 装进 Claude Code，并让它在你项目上立即生效。

---

## 1. 安装 skill

Claude Code 会自动加载 `~/.claude/skills/` 下的每个 skill 目录，所以最省事的安装就是：

```bash
# macOS / Linux
git clone https://github.com/Mark7766/ai-coding-ok ~/.claude/skills/ai-coding-ok

# Windows (PowerShell)
git clone https://github.com/Mark7766/ai-coding-ok $env:USERPROFILE\.claude\skills\ai-coding-ok
```

或者走安装脚本（效果一样，但会排除 `.git/`）：

```bash
git clone https://github.com/Mark7766/ai-coding-ok
cd ai-coding-ok
bash install.sh --claude-code
```

---

## 2. 在你的项目里启用

```bash
cd your-project
claude           # 打开 Claude Code
```

在会话里说其中任意一句都行，Claude 会自动触发 skill：

- `/ai-coding-ok`
- "帮我装上 ai-coding-ok"
- "给这个项目配上三层记忆系统"
- "让 AI 跨会话不失忆"

---

## 3. 交互流程（长这样）

```
You:   /ai-coding-ok

Claude: 我要把 16 个模板文件拷到当前项目。检测到现在是一个空目录，没有冲突。
         开始拷贝... ✓
         现在请用一句话告诉我：你想做什么？

You:   一个给团队用的周报收集工具，每周五自动提醒提交，汇总后发邮件

Claude: 推断如下：
         - 项目名：team-weekly
         - 类型：内部效率工具
         - 技术栈：Python 3.12 + FastAPI + SQLite + Jinja2 + pytest
         - 设计原则：极简，部署简单 > 性能 > 扩展性
         - 核心流程：定时提醒 → 收集表单 → 周日汇总发邮件
         正在替换所有占位符... ✓
         记录为 ADR-001（SQLite 选型理由） + TASK-001（本次初始化）✓

         ✅ 全部就绪。建议打开 AGENTS.md 确认一下架构描述。
```

---

## 4. 验证

```bash
bash ~/.claude/skills/ai-coding-ok/scripts/verify.sh
```

应输出：

```
✓ All 16 required files are present.
✓ No unfilled placeholders — setup looks fully customized.
```

---

## 5. 从此刻起的工作方式

每次你给 Claude 新任务时，它都会：

1. **Plan**：先读 `AGENTS.md` + `.github/agent/memory/*.md`，再出计划
2. **Do**：按计划写代码 + 写测试
3. **Check**：跑测试，看有没有回归
4. **Act**：把这次任务写进 `task-history.md`；架构变了再动 `decisions-log.md`

你不需要手动提醒它做这些 — `SKILL.md` 已经把规则植入进去了。

---

## 6. 常见问题

**Q: 我的项目已经有 `AGENTS.md` 或 `.github/`，会不会被覆盖？**
A: 不会。skill 发现冲突会停下来问你。安装脚本也默认 `cp -n`（不覆盖）。

**Q: 我想升级到最新版 skill 怎么办？**
A: `cd ~/.claude/skills/ai-coding-ok && git pull`。模板更新只影响**新项目**，已经定制好的项目不会被动。

**Q: 我不想让 skill 自动读记忆怎么办？**
A: 删掉 `.github/agent/memory/` 即可，其余规则仍有效。

**Q: 团队成员也要用，怎么办？**
A: 让他们也 `git clone` 到 `~/.claude/skills/ai-coding-ok`。项目里那份 `.github/` 已经随 git 分享了，所以大家读到的是同一份记忆。
