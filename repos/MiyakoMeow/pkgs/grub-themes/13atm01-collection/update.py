#!/usr/bin/env python3
"""
Generate theme-list.json for 13atm01 GRUB themes collection.
- If --repo-path is provided, use it; otherwise clone the upstream repo with depth 1.
- Discover all directories that directly contain a file named 'theme.txt'.
- For each discovered theme, compute a package name by sanitizing the parent directory name
  (lowercase, non-alphanumeric -> '-', collapse repeats, trim '-') and map it to a relative
  path from the repo root to the directory containing theme.txt.

Additionally: after updating theme-list.json, call nix-update to update the src
(commit and hash) for this collection package. The attribute path is expected to be
"grub-themes.13atm01-collection.meta" or "grub-themes.13atm01-collection" depending on
how the flake exposes it; we attempt meta first then fallback.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

UPSTREAM_REPO = "https://github.com/13atm01/GRUB-Theme.git"


def log(msg: str) -> None:
    print(msg, file=sys.stderr)


def sanitize_name(name: str) -> str:
    name = name.lower()
    name = re.sub(r"[^a-z0-9]", "-", name)
    name = re.sub(r"-+", "-", name)
    name = name.strip("-")
    return name


def clone_repo(temp_dir: Path) -> Path:
    log("未提供仓库路径，将临时克隆仓库...")
    dest = temp_dir / "repo"
    subprocess.run(
        [
            "git",
            "clone",
            "--depth",
            "1",
            UPSTREAM_REPO,
            str(dest),
        ],
        check=True,
    )
    log(f"临时克隆完成: {dest}")
    return dest


def find_themes(repo_root: Path) -> dict:
    themes = {}
    # Walk and find files named 'theme.txt'
    for root, dirs, files in os.walk(repo_root):
        if "theme.txt" in files:
            theme_dir = Path(root)
            rel_path = theme_dir.relative_to(repo_root).as_posix()

            parent_dir = theme_dir.parent
            dir_name = parent_dir.name  # package name is based on parent directory

            package_name = sanitize_name(dir_name)
            themes[package_name] = rel_path
    return themes


def write_json(output_path: Path, mapping: dict) -> None:
    # Sort keys for stable output
    with output_path.open("w", encoding="utf-8") as f:
        json.dump(mapping, f, indent=2, sort_keys=True, ensure_ascii=False)


def try_run(cmd: list[str]) -> tuple[bool, str]:
    try:
        log("执行: " + " ".join(cmd))
        subprocess.run(cmd, check=True)
        return True, ""
    except subprocess.CalledProcessError as e:
        return False, str(e)


def run_nix_update(attr_paths: list[str]) -> None:
    # Ensure flake mode
    args_common = ["nix-update", "--flake", "--version=unstable"]
    last_err = None
    for attr in attr_paths:
        ok, err = try_run(args_common + [attr])
        if ok:
            log(f"nix-update 成功: {attr}")
            return
        last_err = err
        log(f"nix-update 失败: {attr}: {err}")
    raise SystemExit(f"nix-update 全部尝试失败: {attr_paths}. 最后错误: {last_err}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate 13atm01 GRUB theme list JSON and update src via nix-update"
    )
    parser.add_argument(
        "--repo-path",
        help="Path to an existing GRUB-Theme repository (skips cloning)",
    )
    parser.add_argument(
        "--skip-nix-update",
        action="store_true",
        help="Only refresh theme-list.json without running nix-update",
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    output_file = script_dir / "theme-list.json"

    log("正在更新GRUB主题列表...")
    log(f"输出位置: {output_file}")

    temp_dir: tempfile.TemporaryDirectory | None = None
    try:
        if args.repo_path:
            repo_root = Path(args.repo_path).resolve()
            if not repo_root.is_dir():
                log(f"错误: 提供的仓库路径不存在或不是目录: {repo_root}")
                return 1
            log(f"使用外部仓库路径: {repo_root}")
        else:
            temp_dir = tempfile.TemporaryDirectory()
            repo_root = clone_repo(Path(temp_dir.name))

        themes = find_themes(repo_root)

        if not themes:
            # Write empty object for determinism then fail like the shell script
            write_json(output_file, {})
            return 1

        write_json(output_file, themes)
        log(f"成功生成 {len(themes)} 个主题到 {output_file}")

        if not args.skip_nix_update:
            # Prefer updating the meta derivation which carries the src
            # Attribute paths to try in order
            attr_candidates = [
                "grub-themes.13atm01-collection.meta",
            ]
            run_nix_update(attr_candidates)
        else:
            log("跳过 nix-update 根据参数 --skip-nix-update")

        return 0
    finally:
        if temp_dir is not None:
            # Ensure cleanup
            temp_dir.cleanup()


if __name__ == "__main__":
    sys.exit(main())
