#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p nix-prefetch 'python3.withPackages(ps: with ps; [ requests packaging ])'

import json
import subprocess
from collections import defaultdict
import os

import requests
from packaging import version


OUTPUT_FILE='versions.json'
CACHE_FILE='cache'

ARCHITECTURE_MAP = {
    "aarch64-darwin": "darwin-arm64",
    "aarch64-linux": "linux-arm64",
    "armv7l-linux": "linux-arm",
    "i686-linux": "linux-386",
    "x86_64-darwin": "darwin-amd64",
    "x86_64-linux": "linux-amd64",
}

def load_file(filename):
    try:
        with open(filename, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}

def get_hashes_for_version(version_str):
    hashes = {}
    for nix_arch, url_suffix in ARCHITECTURE_MAP.items():
        print(f"Getting hash for {nix_arch}")
        url = f"https://github.com/owncloud/ocis/releases/download/v{version_str}/ocis-{version_str}-{url_suffix}"
        derivation = f"""{{ stdenv, fetchurl }}:
stdenv.mkDerivation rec {{
  pname = "ocis";
  version = "{version_str}";
  src = fetchurl {{ url = "{url}"; }};
}}"""
        try:
            proc = subprocess.run(
                ["nix-prefetch", derivation.encode()],
                capture_output=True,
                check=True,
            )
            hashes[nix_arch] = proc.stdout.decode().strip()
        except subprocess.CalledProcessError as e:
            raise RuntimeError(
                f"Failed to get hash for {nix_arch} {version_str}: {e.stderr.decode()}"
            ) from e
    return hashes


def main():
    # Fetch releases from GitHub API
    existing_data = load_file(OUTPUT_FILE)
    result = existing_data.copy()

    if os.path.isfile(CACHE_FILE):
        releases = load_file(CACHE_FILE)
    else:
        response = requests.get("https://api.github.com/repos/owncloud/ocis/releases?per_page=50")
        response.raise_for_status()
        releases = response.json()
        with open(CACHE_FILE, "w") as f:
            json.dump(releases, f)

    # Process releases and group by major version
    major_groups = defaultdict(list)
    for release in releases:
        if release["prerelease"]:
            continue

        tag = release["tag_name"]
        if not tag.startswith("v"):
            continue

        try:
            ver = version.parse(tag[1:])
        except:
            continue

        major_groups[ver.major].append(ver)

    # Find latest version for each major
    result = {}
    for major, versions in major_groups.items():
        latest_version = max(versions)
        version_str = str(latest_version)
        major_key = str(major)

        existing_entry = existing_data.get(major_key, {})
        if existing_entry.get("version") == version_str:
            print(f"Reusing existing entry for major {major_key} ({version_str})")
            result[major_key] = existing_entry
            continue

        print(f"Processing new version for major {major_key}: {version_str}")
        try:
            hashes = get_hashes_for_version(version_str)
        except Exception as e:
            print(f"Skipping major {major} due to error: {str(e)}")
            continue

        result[major_key] = {
            "version": version_str,
            "hashes": hashes,
        }

    # Write output to JSON file
    with open(OUTPUT_FILE, "w") as f:
        json.dump(result, f, indent=4)


if __name__ == "__main__":
    main()
