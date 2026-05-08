#!/usr/bin/env python3
"""Update hunk package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, hex_to_sri, load_hashes, save_hashes, should_update

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
RELEASE_URL = "https://api.github.com/repos/modem-dev/hunk/releases/latest"
TARGETS = {
    "x86_64-linux": "linux-x64",
    "aarch64-linux": "linux-arm64",
    "x86_64-darwin": "darwin-x64",
    "aarch64-darwin": "darwin-arm64",
}


def fetch_latest_release() -> tuple[str, dict[str, str]]:
    release = fetch_json(RELEASE_URL)
    version = release["tag_name"].lstrip("v")
    assets = {asset["name"]: asset for asset in release["assets"]}

    hashes: dict[str, str] = {}
    for system, target in TARGETS.items():
        name = f"hunkdiff-{target}.tar.gz"
        asset = assets.get(name)
        if asset is None:
            raise ValueError(f"Missing hunk release asset: {name}")

        digest = asset.get("digest", "")
        if not digest.startswith("sha256:"):
            raise ValueError(f"Missing sha256 digest for hunk release asset: {name}")

        hashes[system] = hex_to_sri(digest.removeprefix("sha256:"))

    return version, hashes


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest, hashes = fetch_latest_release()
    print(f"Current: {current}, Latest: {latest}")
    if not should_update(current, latest):
        print("Already up to date")
        return
    save_hashes(HASHES_FILE, {"version": latest, "hashes": hashes})
    print(f"Updated hunk to {latest}")


if __name__ == "__main__":
    main()
