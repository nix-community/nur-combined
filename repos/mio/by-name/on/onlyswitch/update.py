#!/usr/bin/env python3
"""Update OnlySwitch and its source-built Sparkle dependency.

`nix-update` moves the release tag, source hash, and SwiftPM cache hash.
OnlySwitch also pins Sparkle exactly, so fetch that version from the matching
upstream manifest and refresh the source-built Sparkle tarball hash too.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ATTR = "onlyswitch"
PKG_REL = Path("by-name/on/onlyswitch/package.nix")
MANIFEST_URL = "https://raw.githubusercontent.com/jacklandrin/OnlySwitch/release_{version}/Modules/Package.swift"
SPARKLE_TARBALL_URL = "https://github.com/sparkle-project/Sparkle/archive/refs/tags/{version}.tar.gz"
VERSION_RE = re.compile(r'(?m)^\s*version = "([^"]+)";')
SPARKLE_PACKAGE_RE = re.compile(
    r'\.package\(\s*url:\s*"https://github\.com/sparkle-project/Sparkle(?:\.git)?",\s*'
    r'(?:exact|from):\s*"([^"]+)"\s*\)'
)


def run(cmd: list[str], cwd: Path, *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, check=check)


def repo_root() -> Path:
    result = run(["git", "rev-parse", "--show-toplevel"], Path.cwd(), check=False)
    if result.returncode != 0:
        raise SystemExit(f"error: not in a git checkout:\n{result.stderr}")
    return Path(result.stdout.strip())


def http_text(url: str) -> str:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "nixpkgs-onlyswitch-updater",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.read().decode("utf-8")
    except Exception as error:
        raise SystemExit(f"error: could not fetch {url}: {error}") from error


def sparkle_version(manifest: str) -> str:
    match = SPARKLE_PACKAGE_RE.search(manifest)
    if match is None:
        raise SystemExit("error: Package.swift has no Sparkle dependency")
    return match.group(1)


def sri_hash(url: str, root: Path) -> str:
    prefetch = run(["nix-prefetch-url", "--unpack", url], root)
    raw = prefetch.stdout.strip().splitlines()[-1]
    convert = run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw],
        root,
    )
    return convert.stdout.strip()


def set_assignment(text: str, name: str, value: str) -> str:
    pattern = re.compile(rf'(?m)^(\s*{re.escape(name)}\s*=\s*)"[^"]+";')
    updated, count = pattern.subn(
        lambda match: f'{match.group(1)}"{value}";',
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"error: could not update {name} in package.nix")
    return updated


def set_fetchzip_hash(text: str, name: str, value: str) -> str:
    start = re.search(rf'(?m)^([ \t]*){re.escape(name)} = fetchzip \{{', text)
    if start is None:
        raise SystemExit(f"error: could not find the {name} fetchzip block")
    indent = start.group(1)
    end_marker = f"\n{indent}}};"
    end = text.find(end_marker, start.end())
    if end < 0:
        raise SystemExit(f"error: unterminated {name} fetchzip block")
    end += len(end_marker)

    block = text[start.start() : end]
    updated, count = re.subn(
        r'(?m)^(\s*hash = )"[^"]+";',
        lambda match: f'{match.group(1)}"{value}";',
        block,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"error: could not update the {name} hash")
    return text[: start.start()] + updated + text[end:]


def main() -> int:
    root = repo_root()
    package = root / PKG_REL
    original = package.read_text(encoding="utf-8")

    status = subprocess.run(
        [
            "nix-update",
            "--use-github-releases",
            "--version-regex",
            r"release_(.*)",
            "--subpackage",
            "spmDeps",
            os.environ.get("UPDATE_NIX_ATTR_PATH", ATTR),
            *sys.argv[1:],
        ],
        cwd=root,
        check=False,
    ).returncode
    if status != 0:
        return status

    try:
        text = package.read_text(encoding="utf-8")
        match = VERSION_RE.search(text)
        if match is None:
            raise SystemExit("error: could not find the onlyswitch version")
        version = match.group(1)

        manifest_url = MANIFEST_URL.format(version=urllib.parse.quote(version, safe=""))
        sparkle = sparkle_version(http_text(manifest_url))
        sparkle_hash = sri_hash(SPARKLE_TARBALL_URL.format(version=sparkle), root)

        text = set_assignment(text, "sparkleVersion", sparkle)
        text = set_fetchzip_hash(text, "sparkleSrc", sparkle_hash)

        if text != original:
            package.write_text(text, encoding="utf-8")
        print(f"onlyswitch {version}: Sparkle {sparkle}")
    except BaseException:
        package.write_text(original, encoding="utf-8")
        raise

    return 0


if __name__ == "__main__":
    sys.exit(main())
