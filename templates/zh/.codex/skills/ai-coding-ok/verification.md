# ai-coding-ok 验证清单

每次编码任务完成后，确认以下各项：

## Plan 阶段检查
- [ ] 已读取 `AGENTS.md`
- [ ] 已读取 `.github/agent/memory/project-memory.md`
- [ ] 已读取 `.github/agent/memory/decisions-log.md`
- [ ] 已读取 `.github/agent/memory/task-history.md`

## Check 阶段检查
- [ ] 所有测试通过
- [ ] 无新增 lint/type 错误
- [ ] 无回归（已有功能未受影响）

## Act 阶段检查（⚠️ 必填）
- [ ] `task-history.md` 已更新（记录本次任务摘要）
- [ ] `decisions-log.md` 已更新（如有架构决策变更）
- [ ] `project-memory.md` 已更新（如有项目事实变化）

## 输出检查
- [ ] 最终响应包含「记忆更新」小节，列出所有记忆文件更新情况
