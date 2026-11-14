#!/usr/bin/env python3
"""Update zigdoc package."""

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_release,
    load_hashes,
    save_if_changed,
    should_update,
)

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

    version = latest if should_update(current, latest) else current
    payload = {"version": version, "sourceHash": prefetch_source(version)}

    if not save_if_changed(HASHES_FILE, payload):
        print("Already up to date")
        return

    if version != current:
        print(f"Updated zigdoc to {version}")
    else:
        print(f"Repaired drifted hashes for zigdoc {version}")


if __name__ == "__main__":
    main()
