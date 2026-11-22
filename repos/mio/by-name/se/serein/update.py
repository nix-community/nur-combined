#!/usr/bin/env python3
"""Update serein.

Serein has no releases, only nightly tags and a moving default branch, so
nix-update tracks the branch. That rewrites the version as
"0-unstable-<date>", dropping the 1.0.0 base; keep the base from the current
version, as the repository's versioning convention requires.
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
    package = repo_root() / "by-name/se/serein/package.nix"
    base = BASE.search(package.read_text(encoding="utf-8"))

    status = subprocess.run(
        ["nix-update", "--version=branch", "serein", *sys.argv[1:]],
        cwd=repo_root(),
        check=False,
    ).returncode

    if base and status == 0:
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
