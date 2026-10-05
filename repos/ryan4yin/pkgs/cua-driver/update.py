#!/usr/bin/env python3
"""Update the cua-driver prebuilt release tarball and its hash."""

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
OWNER, REPO = "trycua", "cua"
# cua publishes several components; only this release line is relevant.
TAG_PREFIX = "cua-driver-rs-v"


def main() -> None:
    """Update hashes.json when a newer cua-driver release exists."""
    hashes_file = PKG_DIR / "hashes.json"
    current = read_json(hashes_file)["version"]
    latest = latest_github_release(OWNER, REPO, tag_prefix=TAG_PREFIX)
    print(f"current: {current}, latest: {latest}")
    if not is_newer(latest, current):
        print("already up to date")
        return

    url = (
        f"https://github.com/{OWNER}/{REPO}/releases/download/"
        f"{TAG_PREFIX}{latest}/cua-driver-rs-{latest}-linux-x86_64-binary.tar.gz"
    )
    print(f"hashing {url}")
    digest = nix_prefetch_file(url)

    write_json(hashes_file, {"version": latest, "hash": digest})
    print(f"updated to {latest}")


if __name__ == "__main__":
    main()
