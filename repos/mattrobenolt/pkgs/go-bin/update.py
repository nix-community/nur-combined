#!/usr/bin/env python3
"""Update tracked Go versions and hashes."""

import re
import subprocess
import sys
from pathlib import Path
from typing import Any, cast

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, hex_to_sri, load_json, save_json

SCRIPT_DIR = Path(__file__).parent
VERSIONS_FILE = SCRIPT_DIR / "versions.json"
HASHES_FILE = SCRIPT_DIR / "hashes.json"
MIN_GO_VERSION = "1.24"
PLATFORMS = ("linux-amd64", "linux-arm64", "darwin-amd64", "darwin-arm64")


def minor_version(version: str) -> str | None:
    match = re.match(r"^(1\.\d+)", version)
    return match.group(1) if match else None


def minor_number(minor: str) -> int:
    return int(minor.split(".")[1])


def fetch_releases() -> list[dict[str, Any]]:
    data = fetch_json("https://go.dev/dl/?mode=json&include=all")
    if not isinstance(data, list):
        raise TypeError(f"Expected list from Go API, got {type(data)}")
    return cast(list[dict[str, Any]], data)


def latest_stable_versions(releases: list[dict[str, Any]]) -> dict[str, str]:
    versions: dict[str, str] = {}
    min_minor = minor_number(MIN_GO_VERSION)
    for release in releases:
        version = cast(str, release["version"]).removeprefix("go")
        if not release.get("stable", False):
            continue
        minor = minor_version(version)
        if minor is None or minor_number(minor) < min_minor:
            continue
        versions.setdefault(minor, version)
    return versions


def latest_prerelease(after_minor: str) -> str | None:
    result = subprocess.run(
        ["git", "ls-remote", "--tags", "https://github.com/golang/go.git"],
        capture_output=True,
        text=True,
        check=True,
    )
    prereleases: list[str] = []
    pattern = re.compile(r"refs/tags/go(1\.(\d+)(?:rc|beta)\d+)$")
    for line in result.stdout.splitlines():
        match = pattern.search(line)
        if match and int(match.group(2)) > minor_number(after_minor):
            prereleases.append(match.group(1))
    return sorted(prereleases, reverse=True)[0] if prereleases else None


def release_by_version(releases: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {
        cast(str, release["version"]).removeprefix("go"): release
        for release in releases
    }


def extract_hashes(release: dict[str, Any]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for file in release["files"]:
        if file.get("kind") != "archive":
            continue
        platform = f"{file['os']}-{file['arch']}"
        if platform in PLATFORMS:
            hashes[platform] = hex_to_sri(cast(str, file["sha256"]))
    missing = set(PLATFORMS) - set(hashes)
    if missing:
        raise ValueError(
            f"Missing hashes for {cast(str, release['version'])}: {sorted(missing)}"
        )
    return hashes


def main() -> None:
    releases = fetch_releases()
    versions = latest_stable_versions(releases)

    latest_stable_minor = max(versions, key=minor_number)
    try:
        next_version = latest_prerelease(latest_stable_minor)
    except subprocess.CalledProcessError as error:
        print(f"Could not fetch Go prerelease tags: {error}")
        next_version = None
    if next_version:
        versions["next"] = next_version

    existing_versions = load_json(VERSIONS_FILE)
    for key, value in existing_versions.items():
        if key != "next" and key not in versions:
            print(f"Preserving pinned Go {key}: {value}")
            versions[key] = cast(str, value)

    releases_by_version = release_by_version(releases)
    existing_hashes = load_json(HASHES_FILE)
    hashes: dict[str, Any] = {}
    for version in sorted(set(versions.values())):
        if version in existing_hashes:
            hashes[version] = existing_hashes[version]
            continue
        release = releases_by_version.get(version)
        if release is None:
            raise ValueError(f"Go API did not include release data for {version}")
        print(f"Extracting hashes for Go {version}")
        hashes[version] = extract_hashes(release)

    save_json(VERSIONS_FILE, versions)
    save_json(HASHES_FILE, hashes)
    print("Updated Go versions and hashes")


if __name__ == "__main__":
    main()
