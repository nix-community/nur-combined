#!/usr/bin/env python3
"""Update Eglantine from the newest daily release and refresh its CPM manifest."""

from __future__ import annotations

import json
import re
import subprocess
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path


REPO = "Eglantine-Community/Eglantine"
REPO_URL = f"https://github.com/{REPO}.git"
RELEASES_URL = f"https://github.com/{REPO}/releases.atom"
PACKAGE = Path("by-name/eg/eglantine/package.nix")
CPMFILE = Path("by-name/eg/eglantine/cpmfile.json")
ATOM = {"atom": "http://www.w3.org/2005/Atom"}


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True).strip()


def latest_daily() -> str:
    with urllib.request.urlopen(RELEASES_URL, timeout=60) as response:
        feed = ET.fromstring(response.read())
    for entry in feed.findall("atom:entry", ATOM):
        link = entry.find("atom:link", ATOM)
        if link is None:
            continue
        href = link.get("href", "")
        tag = href.rsplit("/", 1)[-1]
        if tag.startswith("daily-"):
            return tag
    raise SystemExit("error: no Eglantine daily release found")


def revision_for(tag: str) -> str:
    output = run("git", "ls-remote", "--tags", REPO_URL)
    fallback = None
    for line in output.splitlines():
        if f"refs/tags/{tag}^{{}}" in line:
            return line[:40]
        if f"refs/tags/{tag}" in line:
            fallback = line[:40]
    if fallback is not None:
        return fallback
    raise SystemExit(f"error: could not resolve Eglantine tag {tag}")


def sri_hash(url: str) -> str:
    base32 = run("nix-prefetch-url", "--unpack", url).splitlines()[-1]
    return run("nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32)


def replace_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"error: could not update {label}")
    return updated


def main() -> None:
    root = Path(run("git", "rev-parse", "--show-toplevel"))
    package_path = root / PACKAGE
    cpmfile_path = root / CPMFILE

    tag = latest_daily()
    revision = revision_for(tag)
    compact_date = tag.removeprefix("daily-")
    if not re.fullmatch(r"20[0-9]{2}[0-9]{2}[0-9]{2}", compact_date):
        raise SystemExit(f"error: unexpected Eglantine daily tag {tag}")
    date = f"{compact_date[:4]}-{compact_date[4:6]}-{compact_date[6:]}"
    if not re.fullmatch(r"20[0-9]{2}-[0-9]{2}-[0-9]{2}", date):
        raise SystemExit(f"error: invalid Eglantine daily date {compact_date}")

    text = package_path.read_text()
    version_match = re.search(r'(?m)^  version = "([^"]+)-unstable-[^"]+";', text)
    if version_match is None:
        raise SystemExit("error: could not determine the Eglantine version base")
    base_version = version_match.group(1)
    version = f"{base_version}-unstable-{date}"
    source_hash = sri_hash(f"https://github.com/{REPO}/archive/{revision}.tar.gz")

    text = replace_once(
        text,
        r'(?m)^  version = "[^"]+";',
        f'  version = "{version}";',
        "version",
    )
    text = replace_once(
        text,
        r'(?m)^    rev = "([0-9a-f]{40})";',
        f'    rev = "{revision}";',
        "source revision",
    )
    text = replace_once(
        text,
        r'(?m)^    hash = "[^"]+";',
        f'    hash = "{source_hash}";',
        "source hash",
    )
    package_path.write_text(text)

    with urllib.request.urlopen(
        f"https://raw.githubusercontent.com/{REPO}/{revision}/cpmfile.json", timeout=60
    ) as response:
        manifest_text = response.read().decode()
    json.loads(manifest_text)
    cpmfile_path.write_text(manifest_text)

    print(f"eglantine: {version} ({revision})")
    print(f"source hash: {source_hash}")


if __name__ == "__main__":
    main()
