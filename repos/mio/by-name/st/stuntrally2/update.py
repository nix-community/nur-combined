#!/usr/bin/env python3
"""Update Stunt Rally 2 and its tracks checkout to the same 2.x release."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

REMOTE = "https://github.com/stuntrally/stuntrally.git"
PKG_REL = Path("by-name/st/stuntrally2/package.nix")
VERSION_RE = re.compile(r'(?m)^(\s*version = )"([^"]+)";')


def run(cmd: list[str], cwd: Path) -> str:
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0", GIT_CONFIG_COUNT="0")
    return subprocess.check_output(cmd, cwd=cwd, env=env, text=True).strip()


def repo_root() -> Path:
    return Path(run(["git", "rev-parse", "--show-toplevel"], Path.cwd()))


def latest_2x_tag(root: Path) -> str:
    tags = run(["git", "ls-remote", "--tags", REMOTE], root)
    versions: list[tuple[tuple[int, ...], str]] = []
    for line in tags.splitlines():
        ref = line.partition("refs/tags/")[2]
        tag = ref.removesuffix("^{}")
        if ref.endswith("^{}") or not re.fullmatch(r"v?2(?:\.\d+)+", tag):
            continue
        version = tag.removeprefix("v")
        versions.append((tuple(int(part) for part in version.split(".")), version))
    if not versions:
        raise SystemExit("error: no Stunt Rally 2.x tags found")
    return max(versions)[1]


def sri_hash(root: Path, repo: str, version: str) -> str:
    url = f"https://github.com/stuntrally/{repo}/archive/refs/tags/{version}.tar.gz"
    raw = run(["nix-prefetch-url", "--unpack", url], root).splitlines()[-1]
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw],
        root,
    )


def set_fetch_hash(text: str, attribute: str, value: str) -> str:
    start = re.search(rf'(?m)^  {re.escape(attribute)} = fetchFromGitHub \{{', text)
    if start is None:
        raise SystemExit(f"error: could not find the {attribute} source block")
    end = text.find("\n  };", start.end())
    if end < 0:
        raise SystemExit(f"error: unterminated {attribute} source block")
    end += len("\n  };")

    block = text[start.start() : end]
    updated, count = re.subn(
        r'(?m)^(\s*hash = )"[^"]+";',
        lambda match: f'{match.group(1)}"{value}";',
        block,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"error: could not update the {attribute} source hash")
    return text[: start.start()] + updated + text[end:]


def target_version(root: Path, package: Path, args: list[str]) -> str:
    current = VERSION_RE.search(package.read_text(encoding="utf-8"))
    if current is None:
        raise SystemExit("error: could not find the current version")

    target = None
    for arg in args:
        if arg in ("-h", "--help"):
            print("Usage: update.py [VERSION]")
            raise SystemExit(0)
        if arg.startswith("--version="):
            arg = arg.split("=", 1)[1]
        elif arg.startswith("-"):
            continue
        if arg == "stable":
            continue
        target = arg.removeprefix("v")

    return target or latest_2x_tag(root)


def main() -> int:
    root = repo_root()
    package = root / PKG_REL
    original = package.read_text(encoding="utf-8")
    current = VERSION_RE.search(original)
    if current is None:
        raise SystemExit("error: could not find the current version")

    version = target_version(root, package, sys.argv[1:])
    if not re.fullmatch(r"2(?:\.\d+)+", version):
        raise SystemExit(f"error: {version} is not a Stunt Rally 2.x release")
    if version == current.group(2):
        print(f"stuntrally2 is already up to date ({version}).")
        return 0

    text, version_count = VERSION_RE.subn(
        lambda match: f'{match.group(1)}"{version}";',
        original,
        count=1,
    )
    if version_count != 1:
        raise SystemExit("error: could not update the package version")

    text = set_fetch_hash(text, "src", sri_hash(root, "stuntrally", version))
    text = set_fetch_hash(text, "tracks", sri_hash(root, "tracks", version))
    package.write_text(text, encoding="utf-8")
    print(f"Updated stuntrally2 to {version}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
