#!/usr/bin/env python3
"""Advance the pinned xddxdd/nix-cachyos-kernel revision in this package only.

The pin moves only when upstream's `linux-cachyos` kernel version becomes newer.
Upstream commits flake.lock (nixpkgs) bumps almost daily; each of them changes the
kernel derivation and would force a from-scratch rebuild, so they are ignored
until the next kernel release.

Changes `rev` and `hash` in default.nix. Never touches flake.lock. Exits nonzero
if the new pin cannot be fetched, evaluated or does not have the expected version.
"""
import json
from pathlib import Path
import re
import subprocess
import sys

REPO_URL = "https://github.com/xddxdd/nix-cachyos-kernel"
RAW_URL = "https://raw.githubusercontent.com/xddxdd/nix-cachyos-kernel"
REF = "refs/heads/master"
VERSION_KEY = "linux-cachyos"
PACKAGE = "linux-cachyos-latest-x86_64-v3"
PACKAGE_DIR = Path(__file__).resolve().parent
REPO_ROOT = PACKAGE_DIR.parents[1]
DEFAULT_NIX = PACKAGE_DIR / "default.nix"


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True, cwd=REPO_ROOT).stdout


def version_at(rev):
    data = json.loads(run("curl", "--fail", "--silent", "--show-error", "--retry", "3",
                          f"{RAW_URL}/{rev}/kernel-cachyos/version.json"))
    version = data[VERSION_KEY]["version"]
    if not re.fullmatch(r"\d+(\.\d+)*", version):
        raise SystemExit(f"unexpected upstream version: {version!r}")
    return version


def version_key(version):
    return tuple(int(part) for part in version.split("."))


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

    current_version = version_at(pinned)
    latest_version = version_at(latest)
    if version_key(latest_version) <= version_key(current_version):
        print(f"{PACKAGE} is up to date (kernel {current_version}; upstream {latest[:12]} "
              f"has {latest_version}, only non-kernel changes ignored)")
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

    # Evaluation proves the new pin imports and has the expected version; nothing is built.
    evaluated = run(
        "nix", "eval", "--raw", "--no-write-lock-file",
        f".#packages.x86_64-linux.{PACKAGE}.version",
    ).strip()
    if evaluated != latest_version:
        raise SystemExit(f"evaluated version {evaluated!r} != upstream {latest_version!r}")
    print(f"{PACKAGE}: {current_version} -> {latest_version} ({pinned[:12]} -> {latest[:12]})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
