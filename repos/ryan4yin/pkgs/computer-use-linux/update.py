#!/usr/bin/env python3
"""Update computer-use-linux prebuilt release binaries and their hashes."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from update_lib import (  # noqa: E402 - the path above must run first
    is_newer,
    latest_github_release,
    nix_prefetch_file,
    read_json,
    write_json,
)

PKG_DIR = Path(__file__).resolve().parent
OWNER, REPO = "agent-sh", "computer-use-linux"
# nixpkgs system -> upstream release asset target triple.
TARGETS = {
    "x86_64-linux": "x86_64-unknown-linux-gnu",
    "aarch64-linux": "aarch64-unknown-linux-gnu",
}


def main() -> None:
    """Update hashes.json when a newer release exists."""
    hashes_file = PKG_DIR / "hashes.json"
    current = read_json(hashes_file)["version"]
    latest = latest_github_release(OWNER, REPO)
    print(f"current: {current}, latest: {latest}")
    if not is_newer(latest, current):
        print("already up to date")
        return

    hashes = {}
    for target in TARGETS.values():
        url = (
            f"https://github.com/{OWNER}/{REPO}/releases/download/"
            f"v{latest}/computer-use-linux-{target}"
        )
        print(f"hashing {url}")
        hashes[target] = nix_prefetch_file(url)

    write_json(hashes_file, {"version": latest, "hashes": hashes})
    print(f"updated to {latest}")


if __name__ == "__main__":
    main()
