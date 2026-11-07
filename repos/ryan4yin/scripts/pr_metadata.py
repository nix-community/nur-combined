#!/usr/bin/env python3
"""Emit title, commit and body outputs for a package update pull request.

Run from the repository root after the updater. NAME, OLD_VERSION and
OLD_CHANGELOG describe the package before the update (from the discover
matrix). The body links the new meta.changelog and, when both changelogs are
GitHub release tag pages of the same repository, a compare view between them.
"""

from __future__ import annotations

import os
import re
import subprocess

from update_lib import write_output

SYSTEM = "x86_64-linux"
RELEASE_TAG_URL = re.compile(r"https://github\.com/([^/]+/[^/]+)/releases/tag/([^/]+)")


def nix_eval(name: str, attr: str) -> str:
    """Evaluate a string attribute of a package, or "" if it is missing."""
    result = subprocess.run(
        [
            "nix",
            "eval",
            "--raw",
            "--apply",
            f'pkg: pkg.{attr} or ""',
            f".#packages.{SYSTEM}.{name}",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def compare_url(old_changelog: str, new_changelog: str) -> str | None:
    """GitHub compare URL between two release tag pages of one repository."""
    old = RELEASE_TAG_URL.fullmatch(old_changelog)
    new = RELEASE_TAG_URL.fullmatch(new_changelog)
    if not old or not new or old[1] != new[1]:
        return None
    return f"https://github.com/{new[1]}/compare/{old[2]}...{new[2]}"


def main() -> None:
    """Compute and emit the pull request metadata."""
    name = os.environ["NAME"]
    old_version = os.environ["OLD_VERSION"]
    old_changelog = os.environ.get("OLD_CHANGELOG", "")
    new_version = nix_eval(name, "version")
    new_changelog = nix_eval(name, "meta.changelog")

    lines = [
        "Automated update from .github/workflows/update-packages.yml.",
        "",
        f"- package: {name}",
    ]
    if new_changelog:
        lines.append(f"- release: {new_changelog}")
    diff = compare_url(old_changelog, new_changelog)
    if diff:
        lines.append(f"- diff: {diff}")

    write_output("title", f"{name}: {old_version} -> {new_version}")
    write_output("commit", f"chore({name}): update to {new_version}")
    write_output("body", "\n".join(lines))


if __name__ == "__main__":
    main()
