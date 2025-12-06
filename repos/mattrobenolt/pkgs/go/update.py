#!/usr/bin/env python3
"""Update Go versions and hashes for the nixpkgs overlay."""

import asyncio
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
VERSIONS_FILE = SCRIPT_DIR / "versions.json"
HASHES_FILE = SCRIPT_DIR / "hashes.json"

# Only track Go versions >= this minimum
MIN_GO_VERSION = "1.24"

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"  # No Color


async def fetch_json(url):
    """Fetch JSON from URL (using sync urllib in thread pool)."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, lambda: json.loads(urlopen(url).read()))


async def fetch_latest_versions():
    """Fetch the latest Go versions from official go.dev API."""
    print(f"{GREEN}🔍 Fetching latest Go versions from go.dev...{NC}")

    # Fetch from official Go downloads JSON API
    releases = await fetch_json("https://go.dev/dl/?mode=json")

    # Extract version numbers (e.g., "go1.25.5" -> "1.25.5")
    all_versions = []
    for release in releases:
        version = release["version"]
        match = re.match(r"go(1\.\d+\.\d+)$", version)
        if match:
            all_versions.append(match.group(1))

    # Parse minimum version
    min_minor = int(MIN_GO_VERSION.split(".")[1])

    # Group by minor version and get the latest patch for each
    versions_by_minor = {}
    for version in all_versions:
        # Extract minor version (e.g., "1.25" from "1.25.5")
        match = re.match(r"1\.(\d+)\.(\d+)", version)
        if match:
            minor_num = int(match.group(1))
            minor = f"1.{minor_num}"

            # Only track versions >= MIN_GO_VERSION (compare as integers)
            if minor_num >= min_minor:
                # Keep the highest patch version for each minor version
                if minor not in versions_by_minor or version > versions_by_minor[minor]:
                    versions_by_minor[minor] = version

    if not versions_by_minor:
        print(f"{RED}Error: Could not find any Go versions{NC}", file=sys.stderr)
        sys.exit(1)

    print(f"{GREEN}Latest versions found:{NC}")
    for minor, version in sorted(versions_by_minor.items(), key=lambda x: int(x[0].split(".")[1]), reverse=True):
        print(f"  Go {minor}: {version}")
    print()

    # Write versions.json
    with open(VERSIONS_FILE, "w") as f:
        json.dump(versions_by_minor, f, indent=2, sort_keys=True)
        f.write("\n")

    return versions_by_minor


async def generate_hash(version, platform):
    """Generate hash for a specific version and platform."""
    print(f"{YELLOW}  Fetching hash for go{version}.{platform}.tar.gz...{NC}")

    url = f"https://go.dev/dl/go{version}.{platform}.tar.gz"

    loop = asyncio.get_event_loop()

    # Run nix-prefetch-url in thread pool
    def run_prefetch():
        result = subprocess.run(
            ["nix-prefetch-url", "--type", "sha256", url],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()

    def convert_hash(hash_value):
        result = subprocess.run(
            ["nix", "hash", "convert", "--hash-algo", "sha256", hash_value],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()

    try:
        hash_value = await loop.run_in_executor(None, run_prefetch)
        sri_hash = await loop.run_in_executor(None, lambda: convert_hash(hash_value))
        return sri_hash
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error fetching hash: {e}{NC}", file=sys.stderr)
        sys.exit(1)


async def update_version_hashes(version):
    """Update hashes for a specific version."""
    print(f"{GREEN}📦 Updating hashes for Go {version}{NC}")

    platforms = ["linux-amd64", "linux-arm64", "darwin-amd64", "darwin-arm64"]

    # Generate all hashes concurrently
    hashes_list = await asyncio.gather(*[
        generate_hash(version, platform)
        for platform in platforms
    ])

    # Create hashes dict
    hashes = dict(zip(platforms, hashes_list))

    # Read existing hashes or create empty dict
    if HASHES_FILE.exists():
        with open(HASHES_FILE) as f:
            all_hashes = json.load(f)
    else:
        all_hashes = {}

    # Update with new version
    all_hashes[version] = hashes

    # Write back to file
    with open(HASHES_FILE, "w") as f:
        json.dump(all_hashes, f, indent=2, sort_keys=True)
        f.write("\n")

    print(f"{GREEN}✅ Updated hashes for Go {version}{NC}")
    print()


async def main():
    """Main execution."""
    # Fetch latest versions
    versions = await fetch_latest_versions()

    # Update hashes for each version concurrently
    await asyncio.gather(*[
        update_version_hashes(version)
        for version in versions.values()
    ])

    # Read all hashes
    if HASHES_FILE.exists():
        with open(HASHES_FILE) as f:
            all_hashes = json.load(f)

        # Only keep hashes for versions we're tracking
        tracked_versions = set(versions.values())
        new_hashes = {v: h for v, h in all_hashes.items() if v in tracked_versions}

        # Write cleaned hashes back
        with open(HASHES_FILE, "w") as f:
            json.dump(new_hashes, f, indent=2, sort_keys=True)
            f.write("\n")

    print(f"{GREEN}✨ All done! Updated versions and hashes.{NC}")
    print(f"{YELLOW}📝 Updated files:{NC}")
    print(f"  - {VERSIONS_FILE}")
    print(f"  - {HASHES_FILE}")


if __name__ == "__main__":
    asyncio.run(main())
