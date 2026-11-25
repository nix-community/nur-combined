#!/usr/bin/env python3
"""Update xpipe_patched and both macOS portable DMG hashes."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import urllib.request
from pathlib import Path

PKG = Path("by-name/xp/xpipe_patched/package.nix")
RELEASE_API = "https://api.github.com/repos/xpipe-io/xpipe/releases/latest"
ASSET_URL = "https://github.com/xpipe-io/xpipe/releases/download/{version}/xpipe-portable-macos-{arch}.dmg"
SYSTEMS = {
    "aarch64-darwin": "arm64",
    "x86_64-darwin": "x86_64",
}


def run(cmd: list[str], cwd: Path) -> str:
    return subprocess.run(
        cmd,
        cwd=cwd,
        check=True,
        text=True,
        capture_output=True,
    ).stdout


def repo_root() -> Path:
    return Path(run(["git", "rev-parse", "--show-toplevel"], Path.cwd()).strip())


def latest_version() -> str:
    request = urllib.request.Request(
        RELEASE_API,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "nurpkgs-xpipe-updater",
        },
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        release = json.load(response)
    return release["tag_name"].removeprefix("v")


def sri_hash(url: str, root: Path) -> str:
    result = json.loads(run(["nix", "store", "prefetch-file", "--json", url], root))
    return result["hash"]


def set_version(text: str, version: str) -> str:
    updated, count = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        lambda match: f'{match.group(1)}"{version}";',
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit("error: could not update xpipe_patched version")
    return updated


def set_hash(text: str, system: str, hash_value: str) -> str:
    block = re.search(r"(?m)^  hash =\n    \{", text)
    if block is None:
        raise SystemExit("error: could not find xpipe_patched hash map")
    end = text.find("\n    };", block.end())
    if end < 0:
        raise SystemExit("error: unterminated xpipe_patched hash map")
    end += len("\n    };")

    start, stop = block.start(), end
    section = text[start:stop]
    section, count = re.subn(
        rf'(?m)^(\s*{re.escape(system)} = )"[^"]+";',
        lambda match: f'{match.group(1)}"{hash_value}";',
        section,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"error: could not update the {system} hash")
    return text[:start] + section + text[stop:]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", help="release version to pin instead of the latest release")
    args, unknown = parser.parse_known_args()
    if unknown:
        parser.error(f"unrecognized arguments: {' '.join(unknown)}")

    root = repo_root()
    package = root / PKG
    original = package.read_text(encoding="utf-8")
    version = args.version or latest_version()

    text = set_version(original, version)
    for system, arch in SYSTEMS.items():
        hash_value = sri_hash(ASSET_URL.format(version=version, arch=arch), root)
        text = set_hash(text, system, hash_value)
        print(f"{system}: {hash_value}")

    if text != original:
        package.write_text(text, encoding="utf-8")
    print(f"xpipe_patched: {version}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
