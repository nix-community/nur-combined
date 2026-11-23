#!/usr/bin/env python3
"""Update launchy and its source-built Sparkle dependency.

`nix-update` moves the Launchy tag and source hash. Sparkle is pinned separately
because Launchy's manifest only gives a lower bound; keep the source tag and
fetchzip hash current with the latest compatible Sparkle release.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ATTR = "launchy"
PKG_REL = Path("by-name/la/launchy/package.nix")
MANIFEST_URL = "https://raw.githubusercontent.com/Punshnut/macos-launchy/v{version}/Package.swift"
SPARKLE_RELEASES_URL = "https://api.github.com/repos/sparkle-project/Sparkle/releases?per_page=100"
SPARKLE_TARBALL_URL = "https://github.com/sparkle-project/Sparkle/archive/refs/tags/{version}.tar.gz"
VERSION_RE = re.compile(r'(?m)^\s*version = "([^"]+)";')
SPARKLE_PACKAGE_RE = re.compile(
    r'\.package\(\s*url:\s*"https://github\.com/sparkle-project/Sparkle(?:\.git)?",\s*'
    r'(from|exact):\s*"([^"]+)"\s*\)'
)
SEMVER_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")


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
            "User-Agent": "nixpkgs-launchy-updater",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.read().decode("utf-8")
    except Exception as error:
        raise SystemExit(f"error: could not fetch {url}: {error}") from error


def fetch_manifest(version: str) -> str:
    url = MANIFEST_URL.format(version=urllib.parse.quote(version, safe=""))
    return http_text(url)


def sparkle_requirement(manifest: str) -> tuple[str, str]:
    match = SPARKLE_PACKAGE_RE.search(manifest)
    if match is None:
        raise SystemExit("error: Package.swift has no Sparkle dependency")
    return match.group(1), match.group(2)


def parse_semver(version: str) -> tuple[int, int, int]:
    match = SEMVER_RE.match(version)
    if match is None:
        raise SystemExit(f"error: invalid Sparkle version {version!r}")
    return tuple(int(part) for part in match.groups())


def sparkle_version(requirement: str, base: str) -> str:
    if requirement == "exact":
        return base

    major = parse_semver(base)[0]
    releases = json.loads(http_text(SPARKLE_RELEASES_URL))
    candidates: list[tuple[tuple[int, int, int], str]] = []
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue
        tag = release.get("tag_name", "")
        if tag.startswith("v"):
            tag = tag[1:]
        try:
            parts = parse_semver(tag)
        except SystemExit:
            continue
        if parts[0] == major:
            candidates.append((parts, tag))

    if not candidates:
        raise SystemExit(f"error: no compatible Sparkle {major}.x release found")
    return max(candidates)[1]


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
            raise SystemExit("error: could not find the launchy version")
        version = match.group(1)

        manifest = fetch_manifest(version)
        requirement, base = sparkle_requirement(manifest)
        sparkle = sparkle_version(requirement, base)

        hash_url = SPARKLE_TARBALL_URL.format(version=sparkle)
        sparkle_hash = sri_hash(hash_url, root)

        text = set_assignment(text, "sparkleVersion", sparkle)
        text = set_fetchzip_hash(text, "sparkle", sparkle_hash)

        if text != original:
            package.write_text(text, encoding="utf-8")
        print(f"launchy {version}: Sparkle {sparkle}")
    except BaseException:
        package.write_text(original, encoding="utf-8")
        raise

    return 0


if __name__ == "__main__":
    sys.exit(main())
