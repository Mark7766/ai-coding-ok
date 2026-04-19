#!/usr/bin/env bash
# ai-coding-ok installer
# Works for both Claude Code users (installs as a skill) and GitHub Copilot
# users (copies templates into the current project).
#
# Usage:
#   bash install.sh                   # interactive
#   bash install.sh --claude-code     # install as ~/.claude/skills/ai-coding-ok
#   bash install.sh --copilot         # copy templates into current directory
#   bash install.sh --copilot --target /path/to/project
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
    --copilot)              MODE="copilot" ;;
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
  echo "  2) GitHub Copilot     — copy templates into a project directory"
  echo "  3) Both"
  printf "Choice [1/2/3]: "
  read -r choice
  case "$choice" in
    1) MODE="claude"  ;;
    2) MODE="copilot" ;;
    3) MODE="both"    ;;
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

case "$MODE" in
  claude)  install_claude ;;
  copilot) install_copilot ;;
  both)    install_claude; install_copilot ;;
  *)       die "Unknown mode: $MODE" ;;
esac

log "All done."
