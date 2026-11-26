#!/usr/bin/env python3
"""Update vphone-cli's rolling source pin and generated SwiftPM cache hash."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ATTR = "vphone-cli"
REPO = "https://github.com/Lakr233/vphone-cli.git"
PKG_REL = Path("by-name/vp/vphone-cli/package.nix")


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True, check=check)


def git(*args: str) -> str:
    return run(["git", *args]).stdout.strip()


def latest_revision() -> tuple[str, str]:
    with tempfile.TemporaryDirectory() as directory:
        git("init", "-q", directory)
        git("-C", directory, "remote", "add", "origin", REPO)
        git("-C", directory, "fetch", "-q", "--depth=1", "origin", "main")
        revision = git("-C", directory, "rev-parse", "FETCH_HEAD")
        date = git("-C", directory, "log", "-1", "--format=%cs", "FETCH_HEAD")
    return revision, date


def sri_hash(url: str) -> str:
    raw = run(["nix-prefetch-url", "--unpack", url]).stdout.strip().splitlines()[-1]
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw]
    ).stdout.strip()


def current_system() -> str:
    return run(
        ["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]
    ).stdout.strip()


def replace_once(pattern: str, replacement: str, text: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.M | re.S)
    if count != 1:
        raise SystemExit(f"error: could not update {label} in package.nix")
    return updated


def refresh_spm_hash(package: Path) -> str:
    text = package.read_text(encoding="utf-8")
    text = replace_once(
        r'(?m)^(\s*outputHash = )"[^"]+";',
        r'\g<1>lib.fakeHash;',
        text,
        "spmDeps outputHash",
    )
    package.write_text(text, encoding="utf-8")

    result = run(
        [
            "nix",
            "build",
            f".#legacyPackages.{current_system()}.{ATTR}.spmDeps",
            "--no-link",
        ],
        check=False,
    )
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr)
    if match is None:
        raise SystemExit(
            "error: could not determine the SwiftPM cache hash:\n"
            + result.stderr[-4000:]
        )

    return match.group(1)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--rev", help="revision to pin instead of upstream main")
    args = parser.parse_args()

    root = Path(git("rev-parse", "--show-toplevel"))
    package = root / PKG_REL
    original = package.read_text(encoding="utf-8")

    if args.rev:
        revision = args.rev
        date = git("show", "-s", "--format=%cs", revision)
    else:
        revision, date = latest_revision()
    version = f"0-unstable-{date}"

    print(f"vphone-cli: {version} ({revision})")
    try:
        source_hash = sri_hash(
            f"https://github.com/Lakr233/vphone-cli/archive/{revision}.tar.gz"
        )
        text = replace_once(
            r'(?m)^(\s*version = )"[^"]+";',
            rf'\g<1>"{version}";',
            original,
            "version",
        )
        text = replace_once(
            r'(?m)^(\s*rev = )"[^"]+";',
            rf'\g<1>"{revision}";',
            text,
            "revision",
        )
        text = replace_once(
            r'(?ms)^(  src = fetchFromGitHub \{\n.*?^\s*hash = )"[^"]+";',
            rf'\g<1>"{source_hash}";',
            text,
            "source hash",
        )
        package.write_text(text, encoding="utf-8")

        spm_hash = refresh_spm_hash(package)
        text = package.read_text(encoding="utf-8").replace("lib.fakeHash", f'"{spm_hash}"')
        package.write_text(text, encoding="utf-8")
        print(f"Source hash: {source_hash}")
        print(f"SwiftPM cache hash: {spm_hash}")

        build = run(
            ["nix", "build", f".#legacyPackages.{current_system()}.{ATTR}", "--no-link"],
            check=False,
        )
        if build.returncode != 0:
            package.write_text(original, encoding="utf-8")
            raise SystemExit(
                "error: updated source does not build; keeping the previous pin\n"
                + build.stderr[-4000:]
            )
    except BaseException:
        if package.read_text(encoding="utf-8") != original:
            package.write_text(original, encoding="utf-8")
        raise

    print(f"vphone-cli {version} builds; package.nix updated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
