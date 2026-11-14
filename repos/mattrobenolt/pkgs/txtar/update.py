#!/usr/bin/env python3
"""Update txtar package."""

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import (
    fetch_github_latest_release,
    fetch_text,
    hex_to_sri,
    load_hashes,
    save_if_changed,
    should_update,
)

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
TARGETS = ("linux_amd64", "linux_arm64", "darwin_arm64")


def fetch_checksums(version: str) -> dict[str, str]:
    text = fetch_text(
        f"https://github.com/mattrobenolt/txtar/releases/download/v{version}/checksums.txt"
    )
    checksums: dict[str, str] = {}
    for line in text.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        sha256_hash, filename = parts
        match = re.search(r"txtar_[\d.]+_(.+)\.tar\.gz", filename)
        if match:
            checksums[match.group(1)] = hex_to_sri(sha256_hash)
    missing = set(TARGETS) - set(checksums)
    if missing:
        raise ValueError(f"Missing txtar checksums for {sorted(missing)}")
    return {target: checksums[target] for target in TARGETS}


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("mattrobenolt", "txtar")
    print(f"Current: {current}, Latest: {latest}")

    version = latest if should_update(current, latest) else current
    hashes = fetch_checksums(version)

    if not save_if_changed(HASHES_FILE, {"version": version, "hashes": hashes}):
        print("Already up to date")
        return

    if version != current:
        print(f"Updated txtar to {version}")
    else:
        print(f"Repaired drifted hashes for txtar {version}")


if __name__ == "__main__":
    main()
