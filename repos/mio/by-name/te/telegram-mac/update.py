#!/usr/bin/env python3
"""Update telegram-mac.

nix-update derives new versions from tags and GitHub releases, but
telegram-macos publishes neither, so a plain `nix-update --version=branch`
would rewrite "13.1.0-unstable-2026-10-30" to "0-unstable-2026-11-04" and
drop the upstream base version. Remember the base and restore it afterwards.
"""
import re
import subprocess
import sys
from pathlib import Path

BASE = re.compile(r'(?m)^(\s*version = )"([0-9][^-]*)-unstable-')
DROPPED_BASE = re.compile(r'(?m)^(\s*version = )"0-unstable-')


def repo_root() -> Path:
    try:
        return Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
        )
    except Exception:
        return Path.cwd()


def main() -> int:
    package = repo_root() / "by-name/te/telegram-mac/package.nix"
    base = BASE.search(package.read_text(encoding="utf-8"))

    status = subprocess.run(
        ["nix-update", "--version=branch", "telegram-mac", *sys.argv[1:]],
        check=False,
    ).returncode

    if base:
        content, replaced = DROPPED_BASE.subn(
            rf'\g<1>"{base.group(2)}-unstable-',
            package.read_text(encoding="utf-8"),
            count=1,
        )
        if replaced:
            package.write_text(content, encoding="utf-8")
            print(f"Restored base version {base.group(2)}")

    return status


if __name__ == "__main__":
    sys.exit(main())
