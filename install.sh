#!/usr/bin/env bash
# ai-coding-ok 安装脚本
# 适用于 Claude Code、GitHub Copilot、OpenCode、Cursor 和 Codex 用户。
#
# 用法：
#   bash install.sh                          # 交互式
#   bash install.sh --claude-code            # 安装到 ~/.claude/skills/ai-coding-ok
#   bash install.sh --opencode               # 安装到 ~/.config/opencode/skills/ + 全局 AGENTS.md
#   bash install.sh --copilot                # 将模板复制到当前目录
#   bash install.sh --cursor                 # 将模板 + .cursor/rules/ 复制到当前目录
#   bash install.sh --codex                  # 将模板 + .codex/skills/ 复制到当前目录
#   bash install.sh --copilot --target /path/to/project
#   bash install.sh --cursor  --target /path/to/project
#   bash install.sh --codex   --target /path/to/project
#   bash install.sh --force                  # 覆盖已有文件
#   bash install.sh --dry-run                # 预览操作，不实际写入
#
# 退出码：0 正常，1 用户取消，2 有冲突但未使用 --force，3 其他错误。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE=""
TARGET=""
FORCE="0"
DRY_RUN="0"

die() {
  echo "[ai-coding-ok] 错误：$*" >&2
  exit "${2:-3}"
}

log() {
  echo "[ai-coding-ok] $*"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude-code|--claude) MODE="claude" ;;
    --opencode)             MODE="opencode" ;;
    --copilot)              MODE="copilot" ;;
    --cursor)               MODE="cursor" ;;
    --codex)                MODE="codex" ;;
    --target)               TARGET="$2"; shift ;;
    --force|-f)             FORCE="1" ;;
    --dry-run|-n)           DRY_RUN="1" ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) die "未知选项：$1" ;;
  esac
  shift
done

TEMPLATES_DIR="$SCRIPT_DIR/templates/zh"
[[ -d "$TEMPLATES_DIR" ]] \
  || die "templates/zh/ 未找到：$TEMPLATES_DIR。请从 skill 根目录运行。"

# 交互式模式选择
if [[ -z "$MODE" ]]; then
  echo ""
  echo "ai-coding-ok 安装脚本"
  echo ""
  echo "选择安装方式："
  echo "  1) Claude Code skill  — 安装到 ~/.claude/skills/ai-coding-ok"
  echo "  2) OpenCode skill     — 安装到 ~/.config/opencode/skills/ + 全局 AGENTS.md"
  echo "  3) GitHub Copilot     — 将模板复制到项目目录"
  echo "  4) Cursor             — 将模板 + .cursor/rules/ 复制到项目目录"
  echo "  5) Codex              — 将模板 + .codex/skills/ 复制到项目目录"
  echo "  6) Claude Code + OpenCode（推荐 agentic CLI 用户）"
  printf "选项 [1/2/3/4/5/6]："
  read -r choice
  case "$choice" in
    1) MODE="claude"   ;;
    2) MODE="opencode" ;;
    3) MODE="copilot"  ;;
    4) MODE="cursor"   ;;
    5) MODE="codex"    ;;
    6) MODE="both"     ;;
    *) die "无效选项" 1 ;;
  esac
fi

install_claude() {
  local dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/ai-coding-ok"
  log "安装 Claude Code skill -> $dest"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    die "$dest 已存在。使用 --force 覆盖。" 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 将复制 $SCRIPT_DIR/* 到 $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  [[ -e "$dest" ]] && rm -rf "$dest"
  mkdir -p "$dest"
  # 复制除 .git 之外的所有内容
  (cd "$SCRIPT_DIR" && find . -maxdepth 1 -mindepth 1 ! -name '.git' -exec cp -r {} "$dest/" \;)
  log "完成。Skill 已安装到 $dest"
  log "在 Claude Code 会话中，Skill 会自动通过 SKILL.md 触发。"
}

install_opencode() {
  local skill_dest="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}/ai-coding-ok"
  log "安装 OpenCode skill -> $skill_dest"

  if [[ -e "$skill_dest" && "$FORCE" != "1" ]]; then
    die "$skill_dest 已存在。使用 --force 覆盖。" 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 将复制 $SCRIPT_DIR/* 到 $skill_dest"
    log "[dry-run] 将更新 ~/.config/opencode/AGENTS.md 添加 skill-trigger 指令"
    return 0
  fi

  mkdir -p "$(dirname "$skill_dest")"
  [[ -e "$skill_dest" ]] && rm -rf "$skill_dest"
  mkdir -p "$skill_dest"
  (cd "$SCRIPT_DIR" && find . -maxdepth 1 -mindepth 1 ! -name '.git' -exec cp -r {} "$skill_dest/" \;)
  log "Skill 已安装。"

  # 确保 ~/.config/opencode/AGENTS.md 包含 skill-trigger 指令
  local global_agents="$HOME/.config/opencode/AGENTS.md"
  local trigger_marker="# ai-coding-ok: skill-trigger"
  local trigger_block="$trigger_marker\n## AI Agent Skill Loading\n\nAt the start of every session, invoke the \`using-superpowers\` skill to discover\nand load relevant skills for the current task (including ai-coding-ok).\n"

  mkdir -p "$(dirname "$global_agents")"
  if [[ -f "$global_agents" ]]; then
    if grep -q "$trigger_marker" "$global_agents"; then
      log "~/.config/opencode/AGENTS.md 已包含 skill-trigger 指令，跳过。"
    else
      printf "\n%b" "$trigger_block" >> "$global_agents"
      log "已将 skill-trigger 指令追加到 ~/.config/opencode/AGENTS.md"
    fi
  else
    printf "%b" "$trigger_block" > "$global_agents"
    log "已创建 ~/.config/opencode/AGENTS.md 并写入 skill-trigger 指令。"
  fi

  log "完成。在项目目录中启动 opencode，然后说：安装 ai-coding-ok"
}

install_copilot() {
  local dest="${TARGET:-$(pwd)}"
  dest="$(cd "$dest" && pwd)"
  log "安装 Copilot 模板 -> $dest"

  # 冲突检查
  local -a conflicts=()
  for p in AGENTS.md CLAUDE.md .github/copilot-instructions.md .github/agent; do
    [[ -e "$dest/$p" ]] && conflicts+=("$p")
  done
  if [[ ${#conflicts[@]} -gt 0 && "$FORCE" != "1" ]]; then
    echo "[ai-coding-ok] 错误：$dest 中存在冲突文件：" >&2
    printf '  - %s\n' "${conflicts[@]}" >&2
    echo "使用 --force 覆盖，或先备份你的文件。" >&2
    exit 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 将合并 $TEMPLATES_DIR/ 到 $dest/"
    (cd "$TEMPLATES_DIR" && find . -type f | sed "s#^\./#  -> $dest/#")
    return 0
  fi

  # 合并复制（不覆盖用户已有文件，除非使用 --force）
  local cp_flag="-n"
  [[ "$FORCE" == "1" ]] && cp_flag=""
  (cd "$TEMPLATES_DIR" && cp -r $cp_flag . "$dest/")

  log "模板已安装。"
  log "下一步：将 scripts/customize-prompt.md 粘贴到 Copilot Chat 中填充占位符。"
  if [[ -d "$dest/.claude" ]]; then
    log "Claude Code hooks 模板已安装。如果使用 AI 安装，占位符会自动填充。"
    log "  如果手动安装，请编辑 .claude/settings.local.json 将 {{SOURCE_DIR_PATTERN}} 替换为实际路径。"
    log "  示例 pattern：'^src/\\|^tests/' 匹配 src/ 和 tests/ 目录中的变更。"
    log "  警告：如果存在 settings.json，请将 hooks 合并到 settings.local.json 以避免冲突。"
  fi
}

install_cursor() {
  local dest="${TARGET:-$(pwd)}"
  dest="$(cd "$dest" && pwd)"
  log "安装 Cursor 规则 -> $dest"

  # 冲突检查
  local -a conflicts=()
  for p in AGENTS.md CLAUDE.md .cursor/rules/ai-coding-ok.mdc .github/agent; do
    [[ -e "$dest/$p" ]] && conflicts+=("$p")
  done
  if [[ ${#conflicts[@]} -gt 0 && "$FORCE" != "1" ]]; then
    echo "[ai-coding-ok] 错误：$dest 中存在冲突文件：" >&2
    printf '  - %s\n' "${conflicts[@]}" >&2
    echo "使用 --force 覆盖，或先备份你的文件。" >&2
    exit 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 将合并 $TEMPLATES_DIR/ 到 $dest/"
    log "[dry-run] 将创建 AGENTS.md、CLAUDE.md、.cursor/rules/ai-coding-ok.mdc 和 .github/agent/memory/"
    return 0
  fi

  # 合并复制（不覆盖用户已有文件，除非使用 --force）
  local cp_flag="-n"
  [[ "$FORCE" == "1" ]] && cp_flag=""
  (cd "$TEMPLATES_DIR" && cp -r $cp_flag . "$dest/")

  log "模板已安装。"
  log "下一步：在 Cursor Agent 中输入：安装 ai-coding-ok"
  log "      Cursor 会根据你的项目自动填充所有占位符。"
}

install_codex() {
  local dest="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}/ai-coding-ok"
  log "安装 Codex skill -> $dest"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    die "$dest 已存在。使用 --force 覆盖。" 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 将复制 $SCRIPT_DIR/* 到 $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  [[ -e "$dest" ]] && rm -rf "$dest"
  mkdir -p "$dest"
  # 复制除 .git 之外的所有内容
  (cd "$SCRIPT_DIR" && find . -maxdepth 1 -mindepth 1 ! -name '.git' -exec cp -r {} "$dest/" \;)
  log "完成。Skill 已安装到 $dest"
  log "在任意项目中启动 Codex，然后说：安装 ai-coding-ok，我想做一个xxx"
}

case "$MODE" in
  claude)   install_claude ;;
  opencode) install_opencode ;;
  copilot)  install_copilot ;;
  cursor)   install_cursor ;;
  codex)    install_codex ;;
  both)     install_claude; install_opencode ;;
  *)        die "未知模式：$MODE" ;;
esac

log "全部完成。"
