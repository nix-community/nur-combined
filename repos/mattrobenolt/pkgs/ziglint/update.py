#!/usr/bin/env python3
"""Update ziglint package."""

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_github_latest_release, load_hashes, save_hashes, should_update

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
TARGETS = ("x86_64-linux", "aarch64-linux", "aarch64-macos")


def prefetch_url(url: str) -> str:
    raw = subprocess.run(
        ["nix-prefetch-url", url], capture_output=True, text=True, check=True
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
    latest = fetch_github_latest_release("rockorager", "ziglint")
    print(f"Current: {current}, Latest: {latest}")
    if not should_update(current, latest):
        print("Already up to date")
        return
    hashes = {
        target: prefetch_url(
            f"https://github.com/rockorager/ziglint/releases/download/v{latest}/ziglint-{target}.tar.gz"
        )
        for target in TARGETS
    }
    save_hashes(HASHES_FILE, {"version": latest, "hashes": hashes})
    print(f"Updated ziglint to {latest}")


if __name__ == "__main__":
    main()
