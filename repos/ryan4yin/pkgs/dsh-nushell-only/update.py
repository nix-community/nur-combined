#!/usr/bin/env python3
"""Update dsh-nushell-only to the latest commit on the fork's develop branch."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from urllib.request import Request, urlopen

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from update_lib import nix_build, read_json, run, write_json  # noqa: E402

PKG_DIR = Path(__file__).resolve().parent
HASHES_FILE = PKG_DIR / "hashes.json"
FLAKE_ATTR = ".#dsh-nushell-only"
REPOSITORY = "https://github.com/ryan4yin/dsh-nushell-only.git"
BRANCH = "develop"
RAW_ROOT = "https://raw.githubusercontent.com/ryan4yin/dsh-nushell-only"


def latest_rev() -> str:
    """Return the head commit of the plugin's develop branch."""
    result = run(
        ["git", "ls-remote", REPOSITORY, f"refs/heads/{BRANCH}"],
        capture_output=True,
        check=True,
    )
    return result.stdout.split()[0]


def manifest_version(rev: str) -> str:
    """Read package.json at a specific commit."""
    request = Request(
        f"{RAW_ROOT}/{rev}/package.json",
        headers={"User-Agent": "nur-packages-updater"},
    )
    with urlopen(request, timeout=60) as response:
        return json.load(response)["version"]


def source_hash(rev: str) -> str:
    """Return the fetchFromGitHub hash for a commit."""
    result = run(
        ["nix", "flake", "prefetch", "--json", f"github:ryan4yin/dsh-nushell-only/{rev}"],
        capture_output=True,
        check=True,
    )
    return json.loads(result.stdout)["hash"]


def main() -> None:
    """Update hashes.json when develop moves, then verify the package builds."""
    current = read_json(HASHES_FILE)
    rev = latest_rev()
    if rev == current["rev"]:
        print("already up to date")
        return

    data = {
        "version": manifest_version(rev),
        "rev": rev,
        "sourceHash": source_hash(rev),
    }
    print(f"current: {current['rev']} -> {rev}")
    write_json(HASHES_FILE, data)
    print(f"updated to {data['version']} ({rev})")

    print("verifying build...")
    result = nix_build(FLAKE_ATTR)
    if result.returncode != 0:
        write_json(HASHES_FILE, current)
        raise SystemExit("build failed, restored hashes.json:\n" + result.stdout + result.stderr)
    print("build ok")


if __name__ == "__main__":
    main()
