#!/usr/bin/env python3
"""Update serein.

Serein has no releases, only nightly tags and a moving default branch, so
nix-update tracks the branch. Depending on which tag it happens to pick, it
rewrites the version to things like "1.0.0-nightly.20261121.100-unstable-
2026-11-21" or "0-unstable-<date>", both of which are wrong here: the
repository's convention keeps the release base and dates the snapshot, i.e.
"<base>-unstable-<date>". Normalise the version back to that after the update.
"""
import re
import subprocess
import sys
from pathlib import Path

VERSION = re.compile(r'(?m)^(\s*version = )"([^"]*)"')
BASE = re.compile(r"^(\d+(?:\.\d+)*)")
DATE = re.compile(r"(\d{4}-\d{2}-\d{2})")


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
    current = VERSION.search(package.read_text(encoding="utf-8"))
    base = BASE.match(current.group(2)) if current else None

    status = subprocess.run(
        ["nix-update", "--version=branch", "serein", *sys.argv[1:]],
        cwd=repo_root(),
        check=False,
    ).returncode

    if base and status == 0:
        content = package.read_text(encoding="utf-8")
        updated = VERSION.search(content)
        date = DATE.search(updated.group(2)) if updated else None
        if date:
            version = f"{base.group(1)}-unstable-{date.group(1)}"
            if updated.group(2) != version:
                content = VERSION.sub(
                    lambda match: f'{match.group(1)}"{version}"', content, count=1
                )
                package.write_text(content, encoding="utf-8")
                print(f"Normalised version to {version}")

    return status


if __name__ == "__main__":
    sys.exit(main())
