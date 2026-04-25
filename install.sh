#!/usr/bin/env bash
# ai-coding-ok installer
# Works for Claude Code, GitHub Copilot, OpenCode, and Cursor users.
#
# Usage:
#   bash install.sh                   # interactive
#   bash install.sh --claude-code     # install as ~/.claude/skills/ai-coding-ok
#   bash install.sh --opencode        # install to ~/.config/opencode/skills/ + global AGENTS.md
#   bash install.sh --copilot         # copy templates into current directory
#   bash install.sh --cursor          # copy templates + .cursor/rules/ into current directory
#   bash install.sh --copilot --target /path/to/project
#   bash install.sh --cursor  --target /path/to/project
#   bash install.sh --force           # overwrite existing files
#   bash install.sh --dry-run         # show what would happen
#
# Exit codes: 0 OK, 1 user abort, 2 conflict without --force, 3 other error.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

MODE=""
TARGET=""
FORCE="0"
DRY_RUN="0"

die() {
  echo "[ai-coding-ok] ERROR: $*" >&2
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
    --target)               TARGET="$2"; shift ;;
    --force|-f)             FORCE="1" ;;
    --dry-run|-n)           DRY_RUN="1" ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

[[ -d "$TEMPLATES_DIR" ]] || die "templates/ not found at $TEMPLATES_DIR. Run from the skill root."

# Interactive mode selection
if [[ -z "$MODE" ]]; then
  echo "Select how to install ai-coding-ok:"
  echo "  1) Claude Code skill  — install to ~/.claude/skills/ai-coding-ok"
  echo "  2) OpenCode skill     — install to ~/.config/opencode/skills/ + global AGENTS.md"
  echo "  3) GitHub Copilot     — copy templates into a project directory"
  echo "  4) Cursor             — copy templates + .cursor/rules/ into a project directory"
  echo "  5) Claude Code + OpenCode (recommended for agentic CLI users)"
  printf "Choice [1/2/3/4/5]: "
  read -r choice
  case "$choice" in
    1) MODE="claude"   ;;
    2) MODE="opencode" ;;
    3) MODE="copilot"  ;;
    4) MODE="cursor"   ;;
    5) MODE="both"     ;;
    *) die "Invalid choice" 1 ;;
  esac
fi

install_claude() {
  local dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/ai-coding-ok"
  log "Installing Claude Code skill -> $dest"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    die "$dest already exists. Re-run with --force to overwrite." 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] would copy $SCRIPT_DIR/* to $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  [[ -e "$dest" ]] && rm -rf "$dest"
  mkdir -p "$dest"
  # Copy everything except .git
  (cd "$SCRIPT_DIR" && find . -maxdepth 1 -mindepth 1 ! -name '.git' -exec cp -r {} "$dest/" \;)
  log "Done. In Claude Code, run:  /ai-coding-ok"
}

install_opencode() {
  local skill_dest="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}/ai-coding-ok"
  log "Installing OpenCode skill -> $skill_dest"

  if [[ -e "$skill_dest" && "$FORCE" != "1" ]]; then
    die "$skill_dest already exists. Re-run with --force to overwrite." 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] would copy $SCRIPT_DIR/* to $skill_dest"
    log "[dry-run] would update ~/.config/opencode/AGENTS.md with skill-trigger instruction"
    return 0
  fi

  mkdir -p "$(dirname "$skill_dest")"
  [[ -e "$skill_dest" ]] && rm -rf "$skill_dest"
  mkdir -p "$skill_dest"
  (cd "$SCRIPT_DIR" && find . -maxdepth 1 -mindepth 1 ! -name '.git' -exec cp -r {} "$skill_dest/" \;)
  log "Skill installed."

  # Ensure ~/.config/opencode/AGENTS.md has the skill-trigger instruction
  local global_agents="$HOME/.config/opencode/AGENTS.md"
  local trigger_marker="# ai-coding-ok: skill-trigger"
  local trigger_block="$trigger_marker\n## AI Agent Skill Loading\n\nAt the start of every session, invoke the \`using-superpowers\` skill to discover\nand load relevant skills for the current task (including ai-coding-ok).\n"

  mkdir -p "$(dirname "$global_agents")"
  if [[ -f "$global_agents" ]]; then
    if grep -q "$trigger_marker" "$global_agents"; then
      log "~/.config/opencode/AGENTS.md already has skill-trigger instruction, skipping."
    else
      printf "\n%b" "$trigger_block" >> "$global_agents"
      log "Appended skill-trigger instruction to ~/.config/opencode/AGENTS.md"
    fi
  else
    printf "%b" "$trigger_block" > "$global_agents"
    log "Created ~/.config/opencode/AGENTS.md with skill-trigger instruction."
  fi

  log "Done. Start opencode in your project and say: install ai-coding-ok"
}

install_copilot() {
  local dest="${TARGET:-$(pwd)}"
  dest="$(cd "$dest" && pwd)"
  log "Installing Copilot templates -> $dest"

  # Conflict check
  local -a conflicts=()
  for p in AGENTS.md .github/copilot-instructions.md .github/agent; do
    [[ -e "$dest/$p" ]] && conflicts+=("$p")
  done
  if [[ ${#conflicts[@]} -gt 0 && "$FORCE" != "1" ]]; then
    echo "[ai-coding-ok] ERROR: conflicts found in $dest:" >&2
    printf '  - %s\n' "${conflicts[@]}" >&2
    echo "Re-run with --force to overwrite, or back up your files first." >&2
    exit 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] would merge $TEMPLATES_DIR/ into $dest/"
    (cd "$TEMPLATES_DIR" && find . -type f | sed "s#^\./#  -> $dest/#")
    return 0
  fi

  # Merge-copy (preserves user's existing files when not forced)
  local cp_flag="-n"
  [[ "$FORCE" == "1" ]] && cp_flag=""
  (cd "$TEMPLATES_DIR" && cp -r $cp_flag . "$dest/")

  log "Templates installed."
  log "Next: paste scripts/customize-prompt.md into Copilot Chat to fill in placeholders."
}

install_cursor() {
  local dest="${TARGET:-$(pwd)}"
  dest="$(cd "$dest" && pwd)"
  log "Installing Cursor rules -> $dest"

  # Conflict check
  local -a conflicts=()
  for p in AGENTS.md .cursor/rules/ai-coding-ok.mdc .github/agent; do
    [[ -e "$dest/$p" ]] && conflicts+=("$p")
  done
  if [[ ${#conflicts[@]} -gt 0 && "$FORCE" != "1" ]]; then
    echo "[ai-coding-ok] ERROR: conflicts found in $dest:" >&2
    printf '  - %s\n' "${conflicts[@]}" >&2
    echo "Re-run with --force to overwrite, or back up your files first." >&2
    exit 2
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] would merge $TEMPLATES_DIR/ into $dest/"
    log "[dry-run] AGENTS.md, .cursor/rules/ai-coding-ok.mdc, and .github/agent/memory/ would be created"
    return 0
  fi

  # Merge-copy (preserves user's existing files when not forced)
  local cp_flag="-n"
  [[ "$FORCE" == "1" ]] && cp_flag=""
  (cd "$TEMPLATES_DIR" && cp -r $cp_flag . "$dest/")

  log "Templates installed."
  log "Next: in Cursor Agent, type: install ai-coding-ok"
  log "      Cursor will fill in all placeholders based on your project."
}

case "$MODE" in
  claude)   install_claude ;;
  opencode) install_opencode ;;
  copilot)  install_copilot ;;
  cursor)   install_cursor ;;
  both)     install_claude; install_opencode ;;
  *)        die "Unknown mode: $MODE" ;;
esac

log "All done."
