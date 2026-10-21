#!/usr/bin/env python3
"""Advance the pinned xddxdd/nix-cachyos-kernel revision in this package only.

Changes `rev` and `hash` in default.nix. Never touches flake.lock (nixpkgs or
any other input). Exits nonzero if the new pin cannot be fetched or evaluated.
"""
import json
from pathlib import Path
import re
import subprocess
import sys

REPO_URL = "https://github.com/xddxdd/nix-cachyos-kernel"
REF = "refs/heads/master"
PACKAGE = "linux-cachyos-latest-x86_64-v3"
PACKAGE_DIR = Path(__file__).resolve().parent
REPO_ROOT = PACKAGE_DIR.parents[1]
DEFAULT_NIX = PACKAGE_DIR / "default.nix"


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True, cwd=REPO_ROOT).stdout


def replace_once(text, pattern, replacement):
    new_text, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"expected exactly one match for {pattern!r}, found {count}")
    return new_text


def main():
    text = DEFAULT_NIX.read_text(encoding="utf-8")
    pinned_matches = re.findall(r'^\s*rev = "([0-9a-f]{40})";$', text, flags=re.MULTILINE)
    if len(pinned_matches) != 1:
        raise SystemExit("default.nix must contain exactly one 40-character rev")
    pinned = pinned_matches[0]

    latest = run("git", "ls-remote", REPO_URL, REF).split()[0]
    if not re.fullmatch(r"[0-9a-f]{40}", latest):
        raise SystemExit(f"unexpected ls-remote result: {latest!r}")
    if latest == pinned:
        print(f"{PACKAGE} is up to date ({pinned})")
        return 0

    # SRI hash of the unpacked GitHub archive, the same value fetchFromGitHub checks.
    prefetch = json.loads(run(
        "nix", "store", "prefetch-file", "--unpack", "--hash-type", "sha256", "--json",
        f"{REPO_URL}/archive/{latest}.tar.gz",
    ))
    new_hash = prefetch["hash"]

    updated = replace_once(text, r'^(\s*)rev = "[0-9a-f]{40}";$', rf'\1rev = "{latest}";')
    updated = replace_once(updated, r'^(\s*)hash = "sha256-[^"]+";$', rf'\1hash = "{new_hash}";')
    DEFAULT_NIX.write_text(updated, encoding="utf-8")

    # Evaluation proves the new pin imports and exposes the package; nothing is built here.
    version = run(
        "nix", "eval", "--raw", "--no-write-lock-file",
        f".#packages.x86_64-linux.{PACKAGE}.version",
    ).strip()
    print(f"{PACKAGE}: {pinned} -> {latest} (version {version})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
