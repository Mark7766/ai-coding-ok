# GitHub Copilot 快速上手

> Copilot 不支持 skill 概念，但它会**自动读** `.github/copilot-instructions.md`。我们就利用这个机制，把 skill 的能力装进项目本身。

---

## ✨ v2.0 新特性速览

- **PDCA 强制执行**：`copilot-instructions.md` 顶部内置强制指令，确保每次任务都执行 PDCA
- **版本标记**：所有模板文件带版本标记，支持自动化升级检测
- **升级脚本**：`scripts/upgrade-prompt.md` 支持一键升级已安装项目

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

Copilot 会自动读 `.github/copilot-instructions.md`，**v2.0 起 PDCA 工作流是强制执行的**：

### 🔄 自动执行（无需手动提醒）

- **任务开始前**：Copilot 会自动读取 `AGENTS.md` + 4 个记忆文件
- **任务结束后**：Copilot 会自动更新 `task-history.md`（如有架构变化也更新相应文件）

> 💡 v2.0 在 `copilot-instructions.md` 顶部增加了强制指令块，确保 Copilot 不会跳过这些步骤。

### 🛡️ 万一 Copilot 忘了

如果 Copilot 某次没执行 PDCA（比如遇到 bug 或上下文过长），可以手动提醒：

```
按 `.github/agent/system-prompt.md` 里的 Act 阶段要求，把这次变更写进 `task-history.md`。
```

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
- 模板过期想同步最新版：`cd ~/tools/ai-coding-ok && git pull`，然后用 `scripts/upgrade-prompt.md` 升级项目
- **升级到 v2.0**：把 `scripts/upgrade-prompt.md` 内容粘贴到 Copilot Chat，会自动添加版本标记和 PDCA 强制指令
