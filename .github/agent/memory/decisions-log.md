# 📝 ai-coding-ok — 技术决策日志 (ADR)

> **用途**：记录项目中的每个重要技术决策，使决策可追溯、可理解。
> 格式参考 [Architecture Decision Records](https://adr.github.io/)。

---

## ADR 模板

复制以下模板记录新决策：

```markdown
### ADR-{编号}: {标题}

- **日期**：YYYY-MM-DD
- **状态**：✅ 已采纳 / ❌ 已废弃 / 🔄 已替代
- **决策者**：{人员/Agent}

#### 背景
> 为什么需要做这个决策？遇到了什么问题？

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 方案 A | ... | ... |
| 方案 B | ... | ... |

#### 决策
> 选择了哪个方案？

#### 理由
> 为什么选这个方案？

#### 影响
> 这个决策会影响什么？
```

---

## 决策记录

### ADR-001: 选用双语模板架构（zh/ + en/）

- **日期**：2026-04-19
- **状态**：🔄 已替代（被 ADR-005 替代）
- **决策者**：wangliang

#### 背景
> ai-coding-ok 最初只有中文模板，但目标用户包含国际开发者。需要支持英文安装，同时保持两套模板同步。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 单一模板 + 运行时翻译 | 只需维护一套模板 | 翻译质量靠 AI 不稳定，占位符替换复杂 |
| 双语独立模板（zh/ + en/） | 翻译质量可控，各自独立测试 | 需同步维护两套文件 |

#### 决策
> 选择 **双语独立模板（zh/ + en/）**。

#### 理由
> 模板是静态 Markdown 文件，独立翻译可确保质量可控。同步维护的开销通过 "新增功能必须同时更新两套" 的约束来保证。

#### 影响
> 所有模板文件有两份（zh/ 和 en/），新增功能需同时修改两套模板。install 时按用户语言选择对应模板集。

---

### ADR-002: SKILL.md 设计为四模式（A/B/C/D）而非单一安装模式

- **日期**：2026-04-19
- **状态**：✅ 已采纳
- **决策者**：wangliang

#### 背景
> v1.0 的 SKILL.md 只覆盖安装场景（Mode A），导致安装后 AI 不再触发 PDCA。需要让同一个 Skill 覆盖"安装"和"日常使用"两种场景。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 两个独立 skill（install + guard） | 职责清晰 | 用户需安装两次，维护成本翻倍 |
| 单一 skill 四模式（A/B/C/D） | 一个入口，全生命周期覆盖 | SKILL.md 变长，需维护触发条件判断 |

#### 决策
> 选择 **单一 skill 四模式（A/B/C/D）**。

#### 理由
> 一个 Skill 同时处理 Install（A）、Plan（B）、Act（C）、Upgrade（D），用户只需安装一次。触发条件用简单的文件存在性判断（.github/agent/memory/ 是否存在）。

#### 影响
> SKILL.md 从 ~2000 字符增长到 ~19000 字符。四个模式各自有明确的触发条件和执行步骤。

---

### ADR-003: 使用 Claude Code hooks 做硬约束（v3.1.0 规划）

- **日期**：2026-06-08
- **状态**：✅ 已采纳（v3.1.0 已实施）
- **决策者**：wangliang + Claude

#### 背景
> ai-coding-ok 在 codex-switch-server 项目中经常不被触发。经过 30+ 轮迭代发现：纯文本指令（AGENTS.md 中的 "必须读取 XXX"）在长上下文、频繁工具调用下会被 AI 跳过。必须用 Claude Code hooks 机制做硬约束。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 继续优化 AGENTS.md 文字措辞 | 不依赖平台特性 | 已验证效果有限 |
| 新增 Claude Code hooks（四重钩子） | 硬约束，Stop hook exit 2 阻断 | 仅 Claude Code 平台有效，Copilot/Cursor 不适用 |

#### 决策
> 选择 **新增 Claude Code hooks 作为第四层防线**，保持前三级（CLAUDE.md + AGENTS.md + copilot-instructions.md）作为所有平台的基础保障。

#### 理由
> 五层防御体系中每一层独立工作。hooks 是最强的 Claude Code 专属层，但 Copilot/Cursor 用户仍能从前三层获得保障。不把鸡蛋放一个篮子里。

#### 影响
> 新增 `templates/zh/.claude/settings.local.json` 和 `templates/en/.claude/settings.local.json`。安装流程需新增 Step 5.5（询问源码目录）+ Step 5.6（生成 hooks 配置）。详见 `docs/hook-trigger-remediation-plan.md`。

---

### ADR-004: 本项目 dogfooding 自己的 ai-coding-ok

- **日期**：2026-06-08
- **状态**：✅ 已采纳
- **决策者**：wangliang

#### 背景
> ai-coding-ok 项目本身有持续开发任务（改 SKILL.md、模板升级、文档维护），但一直没有使用自己的记忆系统。需要决定是否在 ai-coding-ok 仓库中安装 ai-coding-ok。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 不安装 | 简单，无混淆风险 | 开发过程无记忆积累，每次会话从零开始 |
| 安装（dogfooding） | 自己吃自己的狗粮，亲身验证产品质量 | 需区分"模板源码"和"已安装文件" |

#### 决策
> 选择 **安装（dogfooding）**。

#### 理由
> 模板（templates/zh/、templates/en/）是产品源码，已安装文件（./AGENTS.md、./.github/agent/memory/）是开发过程记录。路径不同，不会混淆。dogfooding 同时能第一时间发现框架的问题。

#### 影响
> 根目录新增 AGENTS.md、CLAUDE.md、.github/agent/memory/*.md 等文件。这些文件属于"已安装"层，描述 ai-coding-ok 自身的开发过程，不参与模板分发。

---

### ADR-005: 中文化回归——删除英文支持，回归纯中文项目

- **日期**：2026-07-25
- **状态**：✅ 已采纳
- **决策者**：wangliang

#### 背景
> ADR-001 选择了双语模板架构（zh/ + en/）以争取成为 Claude 官方 Skill。官方 Skill 路线已不可行。当前用户全部为中国开发者，双语维护无实际价值——每次改模板要同步 19×2=38 个文件，英文模板实际使用率为零。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| A: 保留 en/ 降级标注 | 国际用户可参考 | 仍需维护两套目录结构 |
| B: 彻底删除 en/，回退到纯中文 | 维护成本最低，目录简洁，回到 v3.0.0 之前的状态 | 国际用户需自行翻译 |

#### 决策
> 选择方案 B：**彻底删除 `templates/en/`，回到 v3.0.0 之前的纯中文项目状态**。同时保留 v3.0.0 以来全部能力改进（五层防御、hooks、Mode B/C/D、Install/Upgrade Playbook、dogfooding）。

#### 理由
> 目标用户是中国开发者，英文模板实际使用率为零。保留不维护的英文模板比删除更差——用户用了过时模板会遇到问题。v3.0.0 以来的能力改进全部保留，仅去掉双语支持。SKILL.md 中的技术术语（PDCA/ADR/hook/template 等）保留英文，方便 AI 编程工具理解。

#### 影响
> - `templates/en/` 目录删除（19 个文件）
> - `README.zh.md` 删除（内容合并到 `README.md`）
> - SKILL.md 全文改中文（技术术语保留英文）
> - README.md 改为中文
> - install.sh/install.py 删除 `--lang` 选项，硬编码 `templates/zh/`
> - CHANGELOG.md 中文化
> - scripts/ 下所有脚本中文化
> - AGENTS.md "双语维护"约束改为"中文项目"
> - ADR-001 标记为已替代
> - 版本号 v3.1.0 → v4.0.0

---

### ADR-006: 新增 Codex（OpenAI Codex CLI）支持

- **日期**：2026-07-25
- **状态**：✅ 已采纳
- **决策者**：wangliang

#### 背景
> OpenAI Codex CLI 已成为主要的 AI 编程工具之一。ai-coding-ok 已覆盖 Claude Code、Copilot、Cursor、OpenCode 四个平台，需要评估是否以及如何支持 Codex。

#### 关键发现
> Codex CLI 原生加载项目根目录的 `AGENTS.md`（与 OpenCode 相同），ai-coding-ok 安装的 AGENTS.md 中的 PDCA 强制指令天然生效。Codex 还支持 `.codex/skills/<name>/SKILL.md` skill 系统和 TOML 格式的 `config.toml` 配置。

#### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| A: 仅依赖 AGENTS.md 自动加载 | 零额外工作 | 无 skill 触发入口，安装/升级需手动 |
| B: AGENTS.md + .codex/skills/ Skill 文件 | 完整 skill 体验，覆盖安装/升级/PDCA 全流程 | 需新增模板文件和安装模式 |

#### 决策
> 选择方案 B：**AGENTS.md 自动加载 + `.codex/skills/ai-coding-ok/` skill 文件**。

#### 理由
> AGENTS.md 已经提供 PDCA 强制指令（Plan：读记忆 → Do：编码 → Check：验证 → Act：写回记忆），Codex 自动加载后即可生效。额外添加 `.codex/skills/` 是为了让 Codex 用户可以通过 skill 系统触发安装（Mode A）和升级（Mode D）操作。Codex 的 `~/.codex/memories/` 自动记忆系统与 ai-coding-ok 的三层记忆是互补关系，不冲突。

#### 影响
> - 新增 `templates/zh/.codex/skills/ai-coding-ok/SKILL.md`（Codex skill 定义 + PDCA 工作流）
> - 新增 `templates/zh/.codex/skills/ai-coding-ok/verification.md`（任务验证清单）
> - install.sh/install.py 新增 `--codex` 模式
> - SKILL.md compatibility 新增 `codex`
> - AGENTS.md 跨平台兼容层新增 Codex
> - README 新增 Codex 安装说明
> - 版本号 v4.0.0 → v4.1.0
