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
- **状态**：✅ 已采纳
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
- **状态**：🔄 规划中
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
