#!/usr/bin/env python3
"""Update splash and the SwiftPM packages its app vendors.

`nix-update` moves the app tag and source hash. `postPatch` vendors the exact
Sparkle and SwiftTerm versions declared in app/Package.swift, so those pins
must move with the app too. Read them from the updated tag, prefetch both
archives, and rewrite the version/hash pairs in package.nix.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ATTR = "splash"
PKG_REL = Path("by-name/sp/splash/package.nix")
MANIFEST_URL = "https://raw.githubusercontent.com/incoai/splash/{version}/app/Package.swift"
SPARKLE_URL = (
    "https://github.com/sparkle-project/Sparkle/releases/download/"
    "{version}/Sparkle-for-Swift-Package-Manager.zip"
)
SWIFTTERM_URL = (
    "https://github.com/migueldeicaza/SwiftTerm/archive/refs/tags/v{version}.tar.gz"
)
VERSION_RE = re.compile(r'(?m)^\s*version = "([^"]+)";')


def run(cmd: list[str], cwd: Path, *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, check=check)


def repo_root() -> Path:
    result = run(["git", "rev-parse", "--show-toplevel"], Path.cwd(), check=False)
    if result.returncode != 0:
        raise SystemExit(f"error: not in a git checkout:\n{result.stderr}")
    return Path(result.stdout.strip())


def fetch_manifest(version: str) -> str:
    url = MANIFEST_URL.format(version=urllib.parse.quote(version, safe=""))
    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            return response.read().decode("utf-8")
    except Exception as error:
        raise SystemExit(f"error: could not fetch {url}: {error}") from error


def dependency_version(manifest: str, repository: str) -> str:
    pattern = re.compile(
        rf'\.package\(\s*url:\s*"https://github\.com/{re.escape(repository)}(?:\.git)?",\s*'
        rf'exact:\s*"([^"]+)"\s*\)'
    )
    match = pattern.search(manifest)
    if match is None:
        raise SystemExit(f"error: app/Package.swift has no exact pin for {repository}")
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
        ["nix-update", os.environ.get("UPDATE_NIX_ATTR_PATH", ATTR), *sys.argv[1:]],
        cwd=root,
        check=False,
    ).returncode
    if status != 0:
        return status

    try:
        text = package.read_text(encoding="utf-8")
        match = VERSION_RE.search(text)
        if match is None:
            raise SystemExit("error: could not find the splash version")
        version = match.group(1)

        manifest = fetch_manifest(version)
        sparkle_version = dependency_version(manifest, "sparkle-project/Sparkle")
        swiftterm_version = dependency_version(manifest, "migueldeicaza/SwiftTerm")

        sparkle_hash = sri_hash(SPARKLE_URL.format(version=sparkle_version), root)
        swiftterm_hash = sri_hash(SWIFTTERM_URL.format(version=swiftterm_version), root)

        text = set_assignment(text, "sparkleVersion", sparkle_version)
        text = set_assignment(text, "swiftTermVersion", swiftterm_version)
        text = set_fetchzip_hash(text, "sparkle", sparkle_hash)
        text = set_fetchzip_hash(text, "swiftTerm", swiftterm_hash)

        if text != original:
            package.write_text(text, encoding="utf-8")
        print(
            f"splash {version}: Sparkle {sparkle_version}, "
            f"SwiftTerm {swiftterm_version}"
        )
    except BaseException:
        package.write_text(original, encoding="utf-8")
        raise

    return 0


if __name__ == "__main__":
    sys.exit(main())
