#!/usr/bin/env python3
"""Update Zed versions and hashes for both stable and preview channels."""

import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, release_asset_hashes, save_if_changed

SCRIPT_DIR = Path(__file__).parent
VERSIONS_FILE = SCRIPT_DIR / "versions.json"
HASHES_FILE = SCRIPT_DIR / "hashes.json"

OWNER = "zed-industries"
REPO = "zed"
ASSETS = {
    "x86_64-linux": "zed-linux-x86_64.tar.gz",
    "aarch64-linux": "zed-linux-aarch64.tar.gz",
}


def latest_channels(releases: list[dict[str, Any]]) -> dict[str, str]:
    stable: str | None = None
    preview: str | None = None
    for release in releases:
        tag = release["tag_name"]
        if release["prerelease"] and preview is None and tag.endswith("-pre"):
            preview = tag.lstrip("v")
        elif not release["prerelease"] and stable is None:
            stable = tag.lstrip("v")
        if stable and preview:
            break

    if not stable:
        raise SystemExit("Could not find a stable release")
    if not preview:
        raise SystemExit("Could not find a preview release")
    return {"stable": stable, "preview": preview}


def main() -> None:
    releases = fetch_json(
        f"https://api.github.com/repos/{OWNER}/{REPO}/releases?per_page=20"
    )
    versions = latest_channels(releases)
    print(f"Stable: {versions['stable']}, Preview: {versions['preview']}")

    by_version = {release["tag_name"].lstrip("v"): release for release in releases}
    hashes = {
        version: release_asset_hashes(by_version[version], ASSETS)
        for version in versions.values()
    }

    changed = save_if_changed(VERSIONS_FILE, versions)
    changed |= save_if_changed(HASHES_FILE, hashes)
    print(
        f"Updated {VERSIONS_FILE.name} and {HASHES_FILE.name}"
        if changed
        else "Already up to date"
    )


if __name__ == "__main__":
    main()
