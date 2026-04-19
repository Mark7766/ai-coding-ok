# GitHub Copilot 快速上手

> Copilot 不支持 skill 概念，但它会**自动读** `.github/copilot-instructions.md`。我们就利用这个机制，把 skill 的能力装进项目本身。

---

## 1. 克隆 ai-coding-ok（只需一次）

```bash
git clone https://github.com/Mark7766/ai-coding-ok ~/tools/ai-coding-ok
```

路径随意，下文以 `~/tools/ai-coding-ok` 为例。

---

## 2. 在你的项目里跑安装脚本

```bash
cd your-project

# Mac / Linux
bash ~/tools/ai-coding-ok/install.sh --copilot

# Windows
python $env:USERPROFILE\tools\ai-coding-ok\install.py --copilot
```

输出示意：

```
[ai-coding-ok] Installing Copilot templates -> /home/you/your-project
[ai-coding-ok] Templates installed.
[ai-coding-ok] Next: paste scripts/customize-prompt.md into Copilot Chat to fill in placeholders.
```

装好后你的项目里会多出 `AGENTS.md` 和 `.github/` 下的一组文件（共 16 个）。

---

## 3. 让 Copilot 帮你定制

打开 VS Code / JetBrains 里的 **Copilot Chat**，把
`~/tools/ai-coding-ok/scripts/customize-prompt.md` 整个内容粘贴进去，**把中间那一句"我想做的东西"换成你自己的**，然后发送。

```
我想做的东西（一句话）：

> 一个给自己用的每日任务管理 CLI，能给任务打标签，每天早上列出今日任务
```

Copilot 会：
- 推断项目名、技术栈、架构、规范
- 打开每个含占位符的文件逐一替换
- 最后告诉你它做了什么决策

等它跑完，**Review 一下** `AGENTS.md` 和 `decisions-log.md`，有问题让它改。

---

## 4. 验证

```bash
bash ~/tools/ai-coding-ok/scripts/verify.sh .
```

退出码 0 = 完美；2 = 还有占位符没填完（把上一步的提示词再发一次）。

---

## 5. 提交到版本库

```bash
git add AGENTS.md .github/
git commit -m "chore: install ai-coding-ok (ai-coding-ok framework)"
```

从此团队所有成员用 Copilot 时都会自动共享这份记忆。

---

## 6. 日常怎么用？

Copilot 会自动读 `.github/copilot-instructions.md`，所以**你不用做任何特殊操作**。但有两个好习惯：

### 🪢 任务开始前

跟 Copilot 说：

> 读一下 `.github/agent/memory/` 下所有文件，告诉我你理解的项目上下文，然后开始执行：<你的任务>

### 🧾 任务结束后

让 Copilot 自检：

> 按 `.github/agent/system-prompt.md` 里的 Act 阶段要求，把这次变更写进 `task-history.md`。如果改动了架构，也更新 `decisions-log.md`。

CI 上的 `memory-check.yml` 会在你忘记更新记忆时在 PR 里留言提醒你。

---

## 7. 高级：把定制化也自动化

如果你想批量给多个项目装 ai-coding-ok，可以写个包装脚本：

```bash
#!/usr/bin/env bash
for proj in proj-a proj-b proj-c; do
  (cd "$proj" && bash ~/tools/ai-coding-ok/install.sh --copilot --force)
done
```

然后让 Copilot 在每个项目的第一次会话里读 `customize-prompt.md` 自动定制。

---

## 8. 和 Cursor / Cline / Continue 等其他 AI 工具兼容吗？

兼容。原则是：任何会"自动读 `.github/copilot-instructions.md`"或"自动读 `AGENTS.md`"的 AI 工具，都能直接吃这套配置。实测兼容：

- ✅ GitHub Copilot
- ✅ Claude Code (通过 skill 机制)
- ✅ Cursor (通过 `.cursorrules` 可软链到 `.github/copilot-instructions.md`)
- ✅ Cline / Continue（通过 rules 配置引用 AGENTS.md）

---

## 9. 遇到问题？

- 占位符没填完：重新粘贴 `scripts/customize-prompt.md` 到 Copilot Chat
- 想回滚：`git checkout -- AGENTS.md .github/` 再删没 commit 的新增文件
- 模板过期想同步最新版：`cd ~/tools/ai-coding-ok && git pull`，然后 `install.sh --copilot --force`（注意：会覆盖你项目里的文件，建议先备份）
