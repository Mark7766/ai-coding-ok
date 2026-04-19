#!/usr/bin/env bash
# Verify that ai-coding-ok is correctly installed in the current project.
# Usage: bash verify.sh [project-dir]
#
# Exit 0 if all required files exist AND no {{placeholders}} remain.
# Exit 1 if files are missing.
# Exit 2 if files exist but still contain {{placeholders}} (needs customization).

set -euo pipefail

TARGET="${1:-$(pwd)}"
TARGET="$(cd "$TARGET" && pwd)"

echo "Verifying ai-coding-ok installation in: $TARGET"
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
    echo "  ✗ MISSING: $f"
    missing=$((missing + 1))
  fi
done

echo
if [[ $missing -gt 0 ]]; then
  echo "✗ $missing file(s) missing. Re-run the installer."
  exit 1
fi
echo "✓ All 16 required files are present."
echo

# Check for unfilled placeholders
unfilled=0
for f in "${REQUIRED[@]}"; do
  if grep -q '{{' "$TARGET/$f" 2>/dev/null; then
    count=$(grep -c '{{' "$TARGET/$f" || true)
    echo "  ⚠ $f has $count unfilled {{placeholder(s)}}"
    unfilled=$((unfilled + count))
  fi
done

if [[ $unfilled -gt 0 ]]; then
  echo
  echo "⚠ $unfilled placeholder(s) still need customization."
  echo "  Tip: paste scripts/customize-prompt.md into Copilot Chat or Claude Code."
  exit 2
fi

echo "✓ No unfilled placeholders — setup looks fully customized."
exit 0
