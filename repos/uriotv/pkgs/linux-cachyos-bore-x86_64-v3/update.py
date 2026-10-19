#!/usr/bin/env python3
"""Update the upstream source and its matching nixpkgs as one atomic pin."""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import urllib.request

REPOSITORY = "xddxdd/nix-cachyos-kernel"
VENDORED_FILES = (
    "LICENSE", "helpers.nix", "kernel-cachyos/default.nix",
    "kernel-cachyos/mkCachyKernel.nix", "kernel-cachyos/cachySettings.nix",
    "kernel-cachyos/version.json",
)


def request_bytes(url):
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "urio-nur-kernel-updater"}
    if os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = "Bearer " + os.environ["GITHUB_TOKEN"]
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=60) as response:
        return response.read()


def request_json(url):
    return json.loads(request_bytes(url))


def validate_pin(pin):
    for rev in (pin["rev"], pin["nixpkgs"]["rev"]):
        if not re.fullmatch(r"[0-9a-f]{40}", rev):
            raise ValueError("Expected immutable 40-character Git revisions")
    for hash_ in (pin["hash"], pin["nixpkgs"]["narHash"]):
        if not re.fullmatch(r"sha256-[A-Za-z0-9+/]{43}=", hash_):
            raise ValueError("Expected sha256 SRI hashes")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", pin["version"]):
        raise ValueError("Expected a stable kernel version")
    return pin


def main():
    destination = Path(__file__).with_name("upstream")
    current = json.loads((destination / "source.json").read_text())
    rev = request_json(f"https://api.github.com/repos/{REPOSITORY}/commits/master")["sha"]
    if rev == current["rev"]:
        print("CachyOS source is already current")
        return
    # All metadata comes from the SAME immutable commit, never separate moving HEADs.
    base = f"https://raw.githubusercontent.com/{REPOSITORY}/{rev}"
    versions = request_json(base + "/kernel-cachyos/version.json")
    lock = request_json(base + "/flake.lock")
    kernel = versions["linux-cachyos-bore"]
    nixpkgs_node = lock["nodes"][lock["nodes"]["root"]["inputs"]["nixpkgs"]]["locked"]
    if (nixpkgs_node.get("owner"), nixpkgs_node.get("repo")) != ("NixOS", "nixpkgs"):
        raise ValueError("Unexpected upstream nixpkgs repository")
    prefetch = subprocess.run(
        ["nix", "store", "prefetch-file", "--json", "--unpack",
         f"https://github.com/{REPOSITORY}/archive/{rev}.tar.gz"],
        text=True, capture_output=True, check=True,
    )
    pin = validate_pin({
        "rev": rev,
        "hash": json.loads(prefetch.stdout)["hash"],
        "version": kernel["version"],
        "nixpkgs": {"rev": nixpkgs_node["rev"], "narHash": nixpkgs_node["narHash"]},
    })
    # Download the complete immutable snapshot before touching tracked files.
    with tempfile.TemporaryDirectory(dir=destination.parent) as temporary:
        stage = Path(temporary) / "snapshot"
        for filename in VENDORED_FILES:
            output = stage / filename
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(request_bytes(base + "/" + filename))
        (stage / "source.json").write_text(json.dumps(pin, indent=2) + "\n")
        backup = Path(temporary) / "previous"
        destination.rename(backup)
        try:
            stage.rename(destination)
        except BaseException:
            backup.rename(destination)
            raise
        shutil.rmtree(backup)
    print(f"Updated CachyOS {current['version']} -> {pin['version']} ({rev})")


if __name__ == "__main__":
    main()
