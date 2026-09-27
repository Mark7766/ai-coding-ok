#!/usr/bin/env python3
"""ai-coding-ok 跨平台安装脚本。

与 install.sh 功能等价，同时支持 Windows PowerShell / cmd。

用法：
    python install.py                        # 交互式
    python install.py --claude-code          # 安装到 ~/.claude/skills/ai-coding-ok
    python install.py --opencode             # 安装到 ~/.config/opencode/skills/ + 全局 AGENTS.md
    python install.py --copilot              # 将模板复制到当前目录
    python install.py --cursor               # 将模板 + .cursor/rules/ 复制到当前目录
    python install.py --codex                # 将模板 + .codex/skills/ 复制到当前目录
    python install.py --atomcode             # 将模板复制到当前目录（AtomCode 自动加载 AGENTS.md）
    python install.py --copilot --target C:/path/to/project
    python install.py --cursor  --target C:/path/to/project
    python install.py --codex   --target C:/path/to/project
    python install.py --force                # 覆盖已有文件
    python install.py --dry-run              # 仅预览
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CONFLICT_PATHS_COPILOT = ("AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md", ".github/agent")
CONFLICT_PATHS_CURSOR  = ("AGENTS.md", "CLAUDE.md", ".cursor/rules/ai-coding-ok.mdc", ".github/agent")
CONFLICT_PATHS_ATOMCODE = ("AGENTS.md", "CLAUDE.md", ".github/agent")


def log(msg: str) -> None:
    print(f"[ai-coding-ok] {msg}")


def die(msg: str, code: int = 3) -> None:
    print(f"[ai-coding-ok] 错误：{msg}", file=sys.stderr)
    sys.exit(code)


def get_templates_dir() -> Path:
    templates_dir = SCRIPT_DIR / "templates" / "zh"
    if not templates_dir.is_dir():
        die(f"templates/zh/ 未找到：{templates_dir}。请从 skill 根目录运行。")
    return templates_dir


def copy_tree(src: Path, dst: Path, overwrite: bool, dry_run: bool) -> None:
    """递归合并复制 src/* 到 dst/，尊重 overwrite 选项。"""
    for item in src.rglob("*"):
        rel = item.relative_to(src)
        target = dst / rel
        if item.is_dir():
            if not dry_run:
                target.mkdir(parents=True, exist_ok=True)
            continue
        if target.exists() and not overwrite:
            log(f"  跳过（已存在）：{target}")
            continue
        if dry_run:
            log(f"  [dry-run] 复制 {item} -> {target}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(item, target)


def install_claude(args: argparse.Namespace) -> None:
    dest_root = Path(os.environ.get("CLAUDE_SKILLS_DIR", str(Path.home() / ".claude" / "skills")))
    dest = dest_root / "ai-coding-ok"
    log(f"安装 Claude Code skill -> {dest}")

    if dest.exists() and not args.force:
        die(f"{dest} 已存在。使用 --force 覆盖。", 2)

    if args.dry_run:
        log(f"[dry-run] 将复制 {SCRIPT_DIR}/* 到 {dest}（排除 .git）")
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
    log(f"完成。Skill 已安装到 {dest}")
    log("在 Claude Code 会话中，Skill 会自动通过 SKILL.md 触发。")


def install_opencode(args: argparse.Namespace) -> None:
    opencode_skills_dir = Path(
        os.environ.get("OPENCODE_SKILLS_DIR", str(Path.home() / ".config" / "opencode" / "skills"))
    )
    dest = opencode_skills_dir / "ai-coding-ok"
    log(f"安装 OpenCode skill -> {dest}")

    if dest.exists() and not args.force:
        die(f"{dest} 已存在。使用 --force 覆盖。", 2)

    if args.dry_run:
        log(f"[dry-run] 将复制 {SCRIPT_DIR}/* 到 {dest}（排除 .git）")
        log("[dry-run] 将更新 ~/.config/opencode/AGENTS.md 添加 skill-trigger 指令")
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

    # 确保 ~/.config/opencode/AGENTS.md 包含 skill-trigger 指令
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
            log("~/.config/opencode/AGENTS.md 已包含 skill-trigger 指令，跳过。")
        else:
            with global_agents.open("a") as f:
                f.write(trigger_block)
            log("已将 skill-trigger 指令追加到 ~/.config/opencode/AGENTS.md")
    else:
        global_agents.write_text(trigger_block.lstrip())
        log("已创建 ~/.config/opencode/AGENTS.md 并写入 skill-trigger 指令。")

    log("完成。在项目目录中启动 opencode，然后说：安装 ai-coding-ok")


def install_copilot(args: argparse.Namespace) -> None:
    templates_dir = get_templates_dir()
    dest = Path(args.target).resolve() if args.target else Path.cwd()
    log(f"安装 Copilot 模板 -> {dest}")

    conflicts = [p for p in CONFLICT_PATHS_COPILOT if (dest / p).exists()]
    if conflicts and not args.force:
        print("[ai-coding-ok] 错误：发现冲突文件：", file=sys.stderr)
        for c in conflicts:
            print(f"  - {c}", file=sys.stderr)
        print("使用 --force 覆盖，或先备份你的文件。", file=sys.stderr)
        sys.exit(2)

    copy_tree(templates_dir, dest, overwrite=args.force, dry_run=args.dry_run)
    log("模板已安装。")
    log("下一步：将 scripts/customize-prompt.md 粘贴到 Copilot Chat 中填充占位符。")


def install_cursor(args: argparse.Namespace) -> None:
    templates_dir = get_templates_dir()
    dest = Path(args.target).resolve() if args.target else Path.cwd()
    log(f"安装 Cursor 规则 -> {dest}")

    conflicts = [p for p in CONFLICT_PATHS_CURSOR if (dest / p).exists()]
    if conflicts and not args.force:
        print("[ai-coding-ok] 错误：发现冲突文件：", file=sys.stderr)
        for c in conflicts:
            print(f"  - {c}", file=sys.stderr)
        print("使用 --force 覆盖，或先备份你的文件。", file=sys.stderr)
        sys.exit(2)

    copy_tree(templates_dir, dest, overwrite=args.force, dry_run=args.dry_run)
    log("模板已安装。")
    log("下一步：在 Cursor Agent 中输入：安装 ai-coding-ok")
    log("      Cursor 会根据你的项目自动填充所有占位符。")


def install_codex(args: argparse.Namespace) -> None:
    dest_root = Path(os.environ.get("CODEX_SKILLS_DIR", str(Path.home() / ".codex" / "skills")))
    dest = dest_root / "ai-coding-ok"
    log(f"安装 Codex skill -> {dest}")

    if dest.exists() and not args.force:
        die(f"{dest} 已存在。使用 --force 覆盖。", 2)

    if args.dry_run:
        log(f"[dry-run] 将复制 {SCRIPT_DIR}/* 到 {dest}（排除 .git）")
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
    log(f"完成。Skill 已安装到 {dest}")
    log("在任意项目中启动 Codex，然后说：安装 ai-coding-ok，我想做一个xxx")


def install_atomcode(args: argparse.Namespace) -> None:
    templates_dir = get_templates_dir()
    dest = Path(args.target).resolve() if args.target else Path.cwd()
    log(f"安装 AtomCode 模板 -> {dest}")

    # AtomCode 原生加载项目根目录的 AGENTS.md，PDCA 指令安装即生效
    conflicts = [p for p in CONFLICT_PATHS_ATOMCODE if (dest / p).exists()]
    if conflicts and not args.force:
        print("[ai-coding-ok] 错误：发现冲突文件：", file=sys.stderr)
        for c in conflicts:
            print(f"  - {c}", file=sys.stderr)
        print("使用 --force 覆盖，或先备份你的文件。", file=sys.stderr)
        sys.exit(2)

    copy_tree(templates_dir, dest, overwrite=args.force, dry_run=args.dry_run)
    log("模板已安装。")
    log("AtomCode 会自动加载项目根目录的 AGENTS.md，PDCA 指令即时生效。")
    log("下一步：在 AtomCode 中输入：安装 ai-coding-ok，我想做一个xxx")
    log("      AtomCode 会根据你的项目自动填充所有占位符。")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="ai-coding-ok 安装脚本——将模板复制到项目中，支持 Claude Code / Copilot / Cursor / OpenCode / Codex / AtomCode"
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--claude-code", "--claude", action="store_true", dest="claude")
    mode.add_argument("--opencode", action="store_true")
    mode.add_argument("--copilot", action="store_true")
    mode.add_argument("--cursor", action="store_true")
    mode.add_argument("--codex", action="store_true")
    mode.add_argument("--atomcode", action="store_true")
    mode.add_argument("--both", action="store_true")
    parser.add_argument("--target", help="适用于 --copilot / --cursor / --atomcode 的目标项目目录")
    parser.add_argument("--force", "-f", action="store_true", help="覆盖已有文件")
    parser.add_argument("--dry-run", "-n", action="store_true", help="预览操作，不实际写入")
    args = parser.parse_args()

    if not (args.claude or args.opencode or args.copilot or args.cursor or args.codex or args.atomcode or args.both):
        print("\nai-coding-ok 安装脚本\n")
        print("选择安装方式：")
        print("  1) Claude Code skill  — 安装到 ~/.claude/skills/ai-coding-ok")
        print("  2) OpenCode skill     — 安装到 ~/.config/opencode/skills/ + 全局 AGENTS.md")
        print("  3) GitHub Copilot     — 将模板复制到项目目录")
        print("  4) Cursor             — 将模板 + .cursor/rules/ 复制到项目目录")
        print("  5) Codex              — 将模板 + .codex/skills/ 复制到项目目录")
        print("  7) AtomCode           — 将模板复制到项目目录（自动加载 AGENTS.md）")
        print("  6) Claude Code + OpenCode（推荐 agentic CLI 用户）")
        choice = input("选项 [1/2/3/4/5/6/7]：").strip()
        {
            "1": lambda: setattr(args, "claude", True),
            "2": lambda: setattr(args, "opencode", True),
            "3": lambda: setattr(args, "copilot", True),
            "4": lambda: setattr(args, "cursor", True),
            "5": lambda: setattr(args, "codex", True),
            "7": lambda: setattr(args, "atomcode", True),
            "6": lambda: setattr(args, "both", True),
        }.get(choice, lambda: die("无效选项", 1))()

    if args.claude or args.both:
        install_claude(args)
    if args.opencode or args.both:
        install_opencode(args)
    if args.copilot:
        install_copilot(args)
    if args.cursor:
        install_cursor(args)
    if args.codex:
        install_codex(args)
    if args.atomcode:
        install_atomcode(args)

    log("全部完成。")


if __name__ == "__main__":
    main()
