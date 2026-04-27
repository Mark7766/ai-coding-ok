<!-- ai-coding-ok: v2.2.0 -->
# 📏 {{项目名称}} — 编码规范

> 所有人类和 AI 提交的代码都应遵守本文件中的规范。

---

## 1. 通用规范

### 1.1 导入

```python
# 标准库
from __future__ import annotations

import logging
from datetime import datetime
from pathlib import Path

# 第三方库
from {{framework}} import {{imports}}

# 项目内部
from src.config import settings
```

- 导入分三组：标准库 → 第三方 → 项目内部，组间空一行
- 禁止使用 `from xxx import *`
- 使用绝对导入

### 1.2 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 模块/包 | snake_case | `user_service.py` |
| 类 | PascalCase | `UserService` |
| 函数/方法 | snake_case | `get_user()` |
| 变量 | snake_case | `user_count` |
| 常量 | UPPER_SNAKE | `MAX_RETRY` |
| 私有成员 | _leading_under | `_parse_data()` |
| API 路由 | kebab-case | `/api/users` |
| 数据库表 | snake_case 复数 | `users` |
| 环境变量 | UPPER_SNAKE | `DATABASE_URL` |

### 1.3 类型注解

```python
# ✅ 正确
def get_users(limit: int | None = None) -> list[User]:
    ...

# ❌ 错误 — 缺少类型注解
def get_users(limit=None):
    ...
```

- 所有函数参数和返回值必须有类型注解
- 使用 Python 3.12+ 语法：`list[int]` 而非 `List[int]`
- 使用 `X | None` 而非 `Optional[X]`

### 1.4 Docstring（Google 风格）

```python
def process_item(item: Item, priority: int) -> Result:
    """Process an item with given priority.

    Args:
        item: The item to process.
        priority: Processing priority (1=highest).

    Returns:
        The processing result.

    Raises:
        ValueError: If priority is out of range.
    """
```

### 1.5 错误处理

```python
# ✅ 正确 — 具体异常 + 有意义的处理
try:
    result = await service.fetch_data()
except TimeoutError:
    logger.warning("Service timeout, will retry")
    return []

# ❌ 错误 — 裸 except
try:
    result = await service.fetch_data()
except:
    pass
```

### 1.6 日志

```python
import logging

logger = logging.getLogger(__name__)

logger.info("Item processed: id=%s, status=%s", item.id, item.status)
logger.error("Failed to process: %s", exc, exc_info=True)

# ⚠️ 禁止记录敏感信息
# ❌ logger.info("Password: %s", password)
```

- 使用 `logging` 模块，禁止 `print()`
- 每个模块创建独立 logger
- 日志级别：DEBUG(调试) / INFO(业务操作) / WARNING(可恢复) / ERROR(错误) / CRITICAL(致命)

---

## 2. Web 框架规范

### 2.1 路由层

```python
router = APIRouter(prefix="/api/items", tags=["items"])

@router.get("/")
async def list_items(db: AsyncSession = Depends(get_db)) -> list[ItemResponse]:
    """List all items."""
    ...
```

- 路由函数只做：参数校验 → 调用 service → 返回响应
- 业务逻辑放在 service 层
- 使用依赖注入获取数据库 session

---

## 3. 数据库规范

### 3.1 Model 定义

```python
class Item(Base):
    """Item model."""

    __tablename__ = "items"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=func.now())
```

### 3.2 注意事项
- 使用 WAL 模式提升并发读性能（如使用 SQLite）
- 不做复杂的并发写操作
- 备份策略要简单可靠

---

## 4. 测试规范

### 4.1 测试命名

```python
# 格式：test_<被测方法>_<场景>_<期望结果>
def test_process_item_with_valid_input_returns_success():
    ...

def test_process_item_with_empty_list_raises_error():
    ...
```

### 4.2 测试结构（AAA 模式）

```python
async def test_round_robin_skips_inactive():
    # Arrange — 准备数据
    items = [Item(name="A", active=True), Item(name="B", active=False)]

    # Act — 执行操作
    selected = select_next(items, last_index=0)

    # Assert — 验证结果
    assert selected.name == "A"
```

### 4.3 Mock 策略
- 外部服务：使用 `unittest.mock.AsyncMock` 模拟
- 时间相关：使用 `freezegun.freeze_time` 固定时间
- 数据库：使用内存数据库 fixture

---

## 5. Git 规范

### 5.1 Commit Message
- 遵循 Conventional Commits
- 格式：`<type>(<scope>): <subject>`
- 类型：`feat` / `fix` / `docs` / `style` / `refactor` / `test` / `chore`

