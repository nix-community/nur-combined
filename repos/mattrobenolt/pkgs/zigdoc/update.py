#!/usr/bin/env python3
"""Update zigdoc package."""

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_github_latest_release, load_hashes, save_hashes, should_update

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"


def prefetch_source(version: str) -> str:
    url = f"https://github.com/rockorager/zigdoc/archive/v{version}.tar.gz"
    raw = subprocess.run(
        ["nix-prefetch-url", "--unpack", url],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    return subprocess.run(
        ["nix", "hash", "to-sri", "--type", "sha256", raw],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("rockorager", "zigdoc")
    print(f"Current: {current}, Latest: {latest}")
    if not should_update(current, latest):
        print("Already up to date")
        return
    save_hashes(HASHES_FILE, {"version": latest, "sourceHash": prefetch_source(latest)})
    print(f"Updated zigdoc to {latest}")


if __name__ == "__main__":
    main()
