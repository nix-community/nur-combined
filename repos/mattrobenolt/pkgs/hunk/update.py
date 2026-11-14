#!/usr/bin/env python3
"""Update hunk package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_release,
    load_hashes,
    release_asset_hashes,
    save_if_changed,
    should_update,
)

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
OWNER = "modem-dev"
REPO = "hunk"
ASSETS = {
    "x86_64-linux": "hunkdiff-linux-x64.tar.gz",
    "aarch64-linux": "hunkdiff-linux-arm64.tar.gz",
    "x86_64-darwin": "hunkdiff-darwin-x64.tar.gz",
    "aarch64-darwin": "hunkdiff-darwin-arm64.tar.gz",
}


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_release(OWNER, REPO)["tag_name"].lstrip("v")
    print(f"Current: {current}, Latest: {latest}")

    version = latest if should_update(current, latest) else current
    release = fetch_release(OWNER, REPO, f"v{version}")
    hashes = release_asset_hashes(release, ASSETS)

    if not save_if_changed(HASHES_FILE, {"version": version, "hashes": hashes}):
        print("Already up to date")
        return

    if version != current:
        print(f"Updated hunk to {version}")
    else:
        print(f"Repaired drifted hashes for hunk {version}")


if __name__ == "__main__":
    main()
