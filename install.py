#!/usr/bin/env python3
"""ai-coding-ok cross-platform installer.

Equivalent to install.sh, but runs on Windows PowerShell / cmd as well.

Usage:
    python install.py                      # interactive
    python install.py --claude-code        # install as ~/.claude/skills/ai-coding-ok
    python install.py --opencode           # install to ~/.config/opencode/skills/ + global AGENTS.md
    python install.py --copilot            # copy templates into the current dir
    python install.py --cursor             # copy templates + .cursor/rules/ into the current dir
    python install.py --copilot --target C:/path/to/project
    python install.py --cursor  --target C:/path/to/project
    python install.py --force              # overwrite existing files
    python install.py --dry-run            # preview only
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
CONFLICT_PATHS_COPILOT = ("AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md", ".github/agent")
CONFLICT_PATHS_CURSOR  = ("AGENTS.md", "CLAUDE.md", ".cursor/rules/ai-coding-ok.mdc", ".github/agent")


def log(msg: str) -> None:
    print(f"[ai-coding-ok] {msg}")


def die(msg: str, code: int = 3) -> None:
    print(f"[ai-coding-ok] ERROR: {msg}", file=sys.stderr)
    sys.exit(code)


def copy_tree(src: Path, dst: Path, overwrite: bool, dry_run: bool) -> None:
    """Recursively merge-copy src/* into dst/, respecting overwrite."""
    for item in src.rglob("*"):
        rel = item.relative_to(src)
        target = dst / rel
        if item.is_dir():
            if not dry_run:
                target.mkdir(parents=True, exist_ok=True)
            continue
        if target.exists() and not overwrite:
            log(f"  skip (exists): {target}")
            continue
        if dry_run:
            log(f"  [dry-run] copy {item} -> {target}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(item, target)


def install_claude(args: argparse.Namespace) -> None:
    dest_root = Path(os.environ.get("CLAUDE_SKILLS_DIR", str(Path.home() / ".claude" / "skills")))
    dest = dest_root / "ai-coding-ok"
    log(f"Installing Claude Code skill -> {dest}")

    if dest.exists() and not args.force:
        die(f"{dest} already exists. Re-run with --force to overwrite.", 2)

    if args.dry_run:
        log(f"[dry-run] would copy {SCRIPT_DIR}/* to {dest} (excluding .git)")
        return

    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    for item in SCRIPT_DIR.iterdir():
        if item.name == ".git":
            continue
        if item.is_dir():
            shutil.copytree(item, dest / item.name)
        else:
            shutil.copy2(item, dest / item.name)
    log("Done. In Claude Code, run:  /ai-coding-ok")


def install_opencode(args: argparse.Namespace) -> None:
    opencode_skills_dir = Path(
        os.environ.get("OPENCODE_SKILLS_DIR", str(Path.home() / ".config" / "opencode" / "skills"))
    )
    dest = opencode_skills_dir / "ai-coding-ok"
    log(f"Installing OpenCode skill -> {dest}")

    if dest.exists() and not args.force:
        die(f"{dest} already exists. Re-run with --force to overwrite.", 2)

    if args.dry_run:
        log(f"[dry-run] would copy {SCRIPT_DIR}/* to {dest} (excluding .git)")
        log("[dry-run] would update ~/.config/opencode/AGENTS.md with skill-trigger instruction")
        return

    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    for item in SCRIPT_DIR.iterdir():
        if item.name == ".git":
            continue
        if item.is_dir():
            shutil.copytree(item, dest / item.name)
        else:
            shutil.copy2(item, dest / item.name)

    # Ensure ~/.config/opencode/AGENTS.md has the skill-trigger instruction
    global_agents = Path.home() / ".config" / "opencode" / "AGENTS.md"
    trigger_marker = "# ai-coding-ok: skill-trigger"
    trigger_block = (
        f"\n{trigger_marker}\n## AI Agent Skill Loading\n\n"
        "At the start of every session, invoke the `using-superpowers` skill to discover\n"
        "and load relevant skills for the current task (including ai-coding-ok).\n"
    )
    global_agents.parent.mkdir(parents=True, exist_ok=True)
    if global_agents.exists():
        if trigger_marker in global_agents.read_text():
            log("~/.config/opencode/AGENTS.md already has skill-trigger instruction, skipping.")
        else:
            with global_agents.open("a") as f:
                f.write(trigger_block)
            log("Appended skill-trigger instruction to ~/.config/opencode/AGENTS.md")
    else:
        global_agents.write_text(trigger_block.lstrip())
        log("Created ~/.config/opencode/AGENTS.md with skill-trigger instruction.")

    log("Done. Start opencode in your project and say: install ai-coding-ok")


def install_copilot(args: argparse.Namespace) -> None:
    if not TEMPLATES_DIR.is_dir():
        die(f"templates/ not found at {TEMPLATES_DIR}. Run from the skill root.")

    dest = Path(args.target).resolve() if args.target else Path.cwd()
    log(f"Installing Copilot templates -> {dest}")

    conflicts = [p for p in CONFLICT_PATHS_COPILOT if (dest / p).exists()]
    if conflicts and not args.force:
        print("[ai-coding-ok] ERROR: conflicts found:", file=sys.stderr)
        for c in conflicts:
            print(f"  - {c}", file=sys.stderr)
        print("Re-run with --force to overwrite.", file=sys.stderr)
        sys.exit(2)

    copy_tree(TEMPLATES_DIR, dest, overwrite=args.force, dry_run=args.dry_run)
    log("Templates installed.")
    log("Next: paste scripts/customize-prompt.md into Copilot Chat to fill in placeholders.")


def install_cursor(args: argparse.Namespace) -> None:
    if not TEMPLATES_DIR.is_dir():
        die(f"templates/ not found at {TEMPLATES_DIR}. Run from the skill root.")

    dest = Path(args.target).resolve() if args.target else Path.cwd()
    log(f"Installing Cursor rules -> {dest}")

    conflicts = [p for p in CONFLICT_PATHS_CURSOR if (dest / p).exists()]
    if conflicts and not args.force:
        print("[ai-coding-ok] ERROR: conflicts found:", file=sys.stderr)
        for c in conflicts:
            print(f"  - {c}", file=sys.stderr)
        print("Re-run with --force to overwrite.", file=sys.stderr)
        sys.exit(2)

    copy_tree(TEMPLATES_DIR, dest, overwrite=args.force, dry_run=args.dry_run)
    log("Templates installed.")
    log("Next: in Cursor Agent, type: install ai-coding-ok")
    log("      Cursor will fill in all placeholders based on your project.")


def main() -> None:
    parser = argparse.ArgumentParser(description="ai-coding-ok installer")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--claude-code", "--claude", action="store_true", dest="claude")
    mode.add_argument("--opencode", action="store_true")
    mode.add_argument("--copilot", action="store_true")
    mode.add_argument("--cursor", action="store_true")
    mode.add_argument("--both", action="store_true")
    parser.add_argument("--target", help="Target project directory for --copilot / --cursor")
    parser.add_argument("--force", "-f", action="store_true", help="Overwrite existing files")
    parser.add_argument("--dry-run", "-n", action="store_true", help="Preview actions without writing")
    args = parser.parse_args()

    if not (args.claude or args.opencode or args.copilot or args.cursor or args.both):
        print("Select installation mode:")
        print("  1) Claude Code skill  — install to ~/.claude/skills/ai-coding-ok")
        print("  2) OpenCode skill     — install to ~/.config/opencode/skills/ + global AGENTS.md")
        print("  3) GitHub Copilot     — copy templates into a project directory")
        print("  4) Cursor             — copy templates + .cursor/rules/ into a project directory")
        print("  5) Claude Code + OpenCode (recommended for agentic CLI users)")
        choice = input("Choice [1/2/3/4/5]: ").strip()
        {
            "1": lambda: setattr(args, "claude", True),
            "2": lambda: setattr(args, "opencode", True),
            "3": lambda: setattr(args, "copilot", True),
            "4": lambda: setattr(args, "cursor", True),
            "5": lambda: setattr(args, "both", True),
        }.get(choice, lambda: die("Invalid choice", 1))()

    if args.claude or args.both:
        install_claude(args)
    if args.opencode or args.both:
        install_opencode(args)
    if args.copilot:
        install_copilot(args)
    if args.cursor:
        install_cursor(args)

    log("All done.")


if __name__ == "__main__":
    main()
