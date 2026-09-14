#!/usr/bin/env nix
#! nix shell --inputs-from .# nixpkgs#python3 --command python3
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2024 Numtide
"""Update claude-desktop from Anthropic's APT index.

Anthropic publish Claude Desktop as prebuilt Debian packages through an APT
repository; there is no source tree and no GitHub releases. This script reads
the per-architecture Packages index, picks the highest version for each arch,
and records the download URLs and SRI hashes in hashes.json. The two arches may
sit at different versions when one lags behind, so each arch is handled on its
own and the top-level version follows x86_64-linux.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_text, load_hashes, save_hashes, should_update
from updater.hash import hex_to_sri

APT_BASE = "https://downloads.claude.ai/claude-desktop/apt/stable"
DIST_BASE = APT_BASE + "/dists/stable/main"
PLATFORMS = {"x86_64-linux": "amd64", "aarch64-linux": "arm64"}

HASHES_FILE = Path(__file__).parent / "hashes.json"


def parse_version(version: str) -> tuple[int, ...]:
    """Turn a dotted version into an int tuple for sorting (non-numeric -> 0)."""
    parts = []
    for part in version.split("."):
        try:
            parts.append(int(part))
        except ValueError:
            parts.append(0)
    return tuple(parts)


def latest_for_arch(arch: str) -> tuple[str, str, str]:
    """Return (version, filename, sha256_hex) of the newest release for arch.

    The Packages index holds one RFC822-style stanza per published version,
    separated by blank lines.
    """
    text = fetch_text(f"{DIST_BASE}/binary-{arch}/Packages")

    candidates = []
    for stanza in text.split("\n\n"):
        fields = {}
        for line in stanza.splitlines():
            if ": " in line:
                key, value = line.split(": ", 1)
                fields[key] = value
        version = fields.get("Version")
        filename = fields.get("Filename")
        sha256 = fields.get("SHA256")
        if version and filename and sha256:
            candidates.append((version, filename, sha256))

    if not candidates:
        msg = f"No package stanza found for arch {arch}"
        raise RuntimeError(msg)

    candidates.sort(key=lambda entry: parse_version(entry[0]))
    return candidates[-1]


def main() -> None:
    """Refresh hashes.json when a newer release is available for any arch."""
    current = load_hashes(HASHES_FILE)

    urls = {}
    hashes = {}
    versions = {}
    for platform, arch in PLATFORMS.items():
        version, filename, sha256_hex = latest_for_arch(arch)
        versions[platform] = version
        urls[platform] = f"{APT_BASE}/{filename}"
        hashes[platform] = hex_to_sri(sha256_hex)

    new_version = versions["x86_64-linux"]

    # Also catch an arm64-only bump while amd64 stays put.
    changed = (
        should_update(current.get("version", ""), new_version)
        or urls != current.get("urls", {})
        or hashes != current.get("hashes", {})
    )

    if not changed:
        print("claude-desktop: already up to date")
        return

    save_hashes(
        HASHES_FILE,
        {"version": new_version, "urls": urls, "hashes": hashes},
    )
    print(f"Updated to {new_version}")


if __name__ == "__main__":
    main()

