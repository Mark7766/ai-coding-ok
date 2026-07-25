#!/usr/bin/env bash
# 验证 ai-coding-ok 是否正确安装在当前项目中。
# 用法：bash verify.sh [项目目录]
#
# 退出码：0 — 所有必需文件存在且无 {{占位符}} 残留
#        1 — 有文件缺失
#        2 — 文件存在但仍包含 {{占位符}}（需要定制化）

set -euo pipefail

TARGET="${1:-$(pwd)}"
TARGET="$(cd "$TARGET" && pwd)"

echo "验证 ai-coding-ok 安装状态：$TARGET"
echo

REQUIRED=(
  "AGENTS.md"
  ".github/copilot-instructions.md"
  ".github/project-metadata.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/ISSUE_TEMPLATE/bug_report.yml"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".github/ISSUE_TEMPLATE/feature_request.yml"
  ".github/workflows/ci.yml"
  ".github/workflows/memory-check.yml"
  ".github/agent/system-prompt.md"
  ".github/agent/coding-standards.md"
  ".github/agent/workflows.md"
  ".github/agent/prompt-templates.md"
  ".github/agent/memory/project-memory.md"
  ".github/agent/memory/decisions-log.md"
  ".github/agent/memory/task-history.md"
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ -f "$TARGET/$f" ]]; then
    echo "  ✓ $f"
  else
    echo "  ✗ 缺失：$f"
    missing=$((missing + 1))
  fi
done

echo
if [[ $missing -gt 0 ]]; then
  echo "✗ 缺失 $missing 个文件。请重新运行安装脚本。"
  exit 1
fi
echo "✓ 全部 16 个必需文件均已就位。"
echo

# 检查未填充的占位符
unfilled=0
for f in "${REQUIRED[@]}"; do
  if grep -q '{{' "$TARGET/$f" 2>/dev/null; then
    count=$(grep -c '{{' "$TARGET/$f" || true)
    echo "  ⚠ $f 有 $count 个未填充的 {{占位符}}"
    unfilled=$((unfilled + count))
  fi
done

if [[ $unfilled -gt 0 ]]; then
  echo
  echo "⚠ 仍有 $unfilled 个占位符需要定制化。"
  echo "  提示：将 scripts/customize-prompt.md 粘贴到 Copilot Chat 或 Claude Code 中。"
  exit 2
fi

echo "✓ 无未填充占位符——安装看起来已完全定制化。"
exit 0
