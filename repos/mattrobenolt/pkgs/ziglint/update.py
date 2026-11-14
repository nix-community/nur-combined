#!/usr/bin/env python3
"""Update ziglint package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_release,
    fetch_release,
    load_hashes,
    release_asset_hashes,
    save_if_changed,
    should_update,
)

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
OWNER = "rockorager"
REPO = "ziglint"
ASSETS = {
    "x86_64-linux": "ziglint-x86_64-linux.tar.gz",
    "aarch64-linux": "ziglint-aarch64-linux.tar.gz",
    "aarch64-macos": "ziglint-aarch64-macos.tar.gz",
}


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release(OWNER, REPO)
    print(f"Current: {current}, Latest: {latest}")

    version = latest if should_update(current, latest) else current
    release = fetch_release(OWNER, REPO, f"v{version}")
    hashes = release_asset_hashes(release, ASSETS)

    if not save_if_changed(HASHES_FILE, {"version": version, "hashes": hashes}):
        print("Already up to date")
        return

    if version != current:
        print(f"Updated ziglint to {version}")
    else:
        print(f"Repaired drifted hashes for ziglint {version}")


if __name__ == "__main__":
    main()
