<!-- ai-coding-ok: v3.1.0 -->
# 📏 {{project-name}} — Coding Standards

> All code submitted by humans or AI must follow the standards in this document.

---

## 1. General

### 1.1 Imports

```python
# Standard library
from __future__ import annotations

import logging
from datetime import datetime
from pathlib import Path

# Third-party
from {{framework}} import {{imports}}

# Project-internal
from src.config import settings
```

- Imports are split into three groups: stdlib → third-party → internal, with a blank line between groups
- `from xxx import *` is forbidden
- Use absolute imports

### 1.2 Naming

| Kind | Convention | Example |
|------|------|------|
| Module/package | snake_case | `user_service.py` |
| Class | PascalCase | `UserService` |
| Function/method | snake_case | `get_user()` |
| Variable | snake_case | `user_count` |
| Constant | UPPER_SNAKE | `MAX_RETRY` |
| Private member | _leading_under | `_parse_data()` |
| API route | kebab-case | `/api/users` |
| DB table | snake_case plural | `users` |
| Env variable | UPPER_SNAKE | `DATABASE_URL` |

### 1.3 Type Annotations

```python
# ✅ Good
def get_users(limit: int | None = None) -> list[User]:
    ...

# ❌ Bad — missing type annotations
def get_users(limit=None):
    ...
```

- All function parameters and return values must have type annotations
- Use Python 3.12+ syntax: `list[int]` instead of `List[int]`
- Use `X | None` instead of `Optional[X]`

### 1.4 Docstrings (Google style)

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

### 1.5 Error Handling

```python
# ✅ Good — specific exception + meaningful handling
try:
    result = await service.fetch_data()
except TimeoutError:
    logger.warning("Service timeout, will retry")
    return []

# ❌ Bad — bare except
try:
    result = await service.fetch_data()
except:
    pass
```

### 1.6 Logging

```python
import logging

logger = logging.getLogger(__name__)

logger.info("Item processed: id=%s, status=%s", item.id, item.status)
logger.error("Failed to process: %s", exc, exc_info=True)

# ⚠️ Do not log sensitive data
# ❌ logger.info("Password: %s", password)
```

- Use the `logging` module; `print()` is forbidden
- Each module creates its own logger
- Log levels: DEBUG (debug) / INFO (business operations) / WARNING (recoverable) / ERROR (errors) / CRITICAL (fatal)

---

## 2. Web Framework

### 2.1 Routes

```python
router = APIRouter(prefix="/api/items", tags=["items"])

@router.get("/")
async def list_items(db: AsyncSession = Depends(get_db)) -> list[ItemResponse]:
    """List all items."""
    ...
```

- Route handlers only do: input validation → call service → return response
- Business logic lives in the service layer
- Use dependency injection for database sessions

---

## 3. Database

### 3.1 Model Definition

```python
class Item(Base):
    """Item model."""

    __tablename__ = "items"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=func.now())
```

### 3.2 Notes
- Use WAL mode to improve read concurrency (if using SQLite)
- Avoid complex concurrent writes
- Backup strategy should be simple and reliable

---

## 4. Tests

### 4.1 Test Naming

```python
# Format: test_<method>_<scenario>_<expected>
def test_process_item_with_valid_input_returns_success():
    ...

def test_process_item_with_empty_list_raises_error():
    ...
```

### 4.2 Test Structure (AAA)

```python
async def test_round_robin_skips_inactive():
    # Arrange
    items = [Item(name="A", active=True), Item(name="B", active=False)]

    # Act
    selected = select_next(items, last_index=0)

    # Assert
    assert selected.name == "A"
```

### 4.3 Mocking
- External services: use `unittest.mock.AsyncMock`
- Time-related: use `freezegun.freeze_time` to pin time
- Database: use the in-memory database fixture

---

## 5. Git

### 5.1 Commit Message
- Follow Conventional Commits
- Format: `<type>(<scope>): <subject>`
- Types: `feat` / `fix` / `docs` / `style` / `refactor` / `test` / `chore`
