#!/usr/bin/env python3
"""Update dsh-nu to the latest GitHub release and verify the package builds."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from update_lib import (  # noqa: E402 - the path above must run first
    is_newer,
    latest_github_release,
    nix_build,
    nix_prefetch_file,
    read_json,
    write_json,
)

PKG_DIR = Path(__file__).resolve().parent
HASHES_FILE = PKG_DIR / "hashes.json"
FLAKE_ATTR = ".#dsh-nu"
OWNER, REPO = "ryan4yin", "dsh-nu"


def tarball_url(version: str) -> str:
    """Return the GitHub release asset URL for a dsh-nu version."""
    return (
        f"https://github.com/{OWNER}/{REPO}/releases/download/"
        f"v{version}/dsh-nu-{version}.tgz"
    )


def main() -> None:
    """Update hashes.json when GitHub has a newer release, then build the package."""
    current = read_json(HASHES_FILE)
    latest = latest_github_release(OWNER, REPO)
    print(f"current: {current['version']}, latest: {latest}")
    if not is_newer(latest, current["version"]):
        print("already up to date")
        return

    data = {
        "version": latest,
        "sourceHash": nix_prefetch_file(tarball_url(latest)),
    }
    write_json(HASHES_FILE, data)
    print(f"updated to {latest}")

    print("verifying build...")
    result = nix_build(FLAKE_ATTR)
    if result.returncode != 0:
        write_json(HASHES_FILE, current)
        raise SystemExit("build failed, restored hashes.json:\n" + result.stdout + result.stderr)
    print("build ok")


if __name__ == "__main__":
    main()
