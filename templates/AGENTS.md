# AGENTS.md — {{项目名称}}

## 项目概述

{{项目名称}} 是一个 **{{项目类型简述}}**。{{一句话描述核心功能和目标用户}}。

## 系统架构与数据流

```
{{在此绘制系统架构的 ASCII 图}}
{{示例:}}
{{  用户请求 ──▶ Web 服务器 ──▶ 业务逻辑 ──▶ 数据库  }}
{{                              │                      }}
{{                         定时任务/消息队列             }}
```

- **`{{入口文件}}`** — {{入口文件说明}}
- **`{{核心模块A}}`** — {{模块A说明}}
- **`{{核心模块B}}`** — {{模块B说明}}

## 常用命令

```bash
# 安装 & 运行
{{安装命令}}
{{启动命令}}

# 测试
{{测试命令}}
{{覆盖率命令}}

# 代码检查 & 格式化
{{lint 命令}}
{{format 命令}}

# 构建 / 部署
{{构建命令}}
```

## 约定与模式

- **所有文件** 开头必须有 `from __future__ import annotations`。
- **异步优先**：数据库操作使用异步 session，API 使用 `async def`。
- **测试数据库**：`conftest.py` 提供内存数据库 fixture 和测试客户端。
- **日志**：使用 `logging.getLogger(__name__)`，禁止 `print()`。
- **配置**：环境变量通过 `.env` 文件管理，禁止硬编码敏感信息。
- {{补充你项目特有的约定...}}

## 测试模式

```python
# 测试数据初始化辅助函数
async def _seed_test_data(db: AsyncSession) -> list[Model]:
    items = [Model(name="test1"), Model(name="test2")]
    db.add_all(items)
    await db.flush()
    return items

# 时间敏感测试使用 freezegun
from freezegun import freeze_time

@freeze_time("2026-01-05 10:00:00")  # 固定为工作日
async def test_something(db_session):
    ...
```

## 重要约束

- **禁止重量级依赖** — {{列出不允许引入的依赖}}
- **敏感数据** — {{凭据管理方式}}
- **数据库迁移** — {{迁移策略}}
- **代码限制** — 行宽 {{N}} 字符，单函数不超过 {{N}} 行，单文件不超过 {{N}} 行
- {{补充你项目特有的约束...}}

