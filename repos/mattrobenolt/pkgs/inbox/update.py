#!/usr/bin/env python3
"""Update inbox package to latest release."""

import asyncio
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
PACKAGE_FILE = SCRIPT_DIR / "default.nix"

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"


async def fetch_json(url):
    """Fetch JSON from URL."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, lambda: json.loads(urlopen(url).read()))


async def fetch_latest_release():
    """Fetch the latest inbox release version."""
    print(f"{GREEN}Fetching latest inbox release...{NC}")

    releases = await fetch_json("https://api.github.com/repos/mattrobenolt/inbox/releases")

    if not releases:
        print(f"{RED}Error: No releases found{NC}", file=sys.stderr)
        sys.exit(1)

    latest = releases[0]
    version = latest["tag_name"].lstrip("v")

    print(f"{GREEN}Latest release: v{version}{NC}")
    return version


async def fetch_checksums(version):
    """Fetch checksums.txt from GitHub release."""
    print(f"{YELLOW}Fetching checksums for v{version}...{NC}")

    url = f"https://github.com/mattrobenolt/inbox/releases/download/v{version}/checksums.txt"

    loop = asyncio.get_event_loop()

    def fetch_checksums_txt():
        return urlopen(url).read().decode('utf-8')

    checksums_txt = await loop.run_in_executor(None, fetch_checksums_txt)

    # Parse checksums.txt
    # Format: <sha256>  inbox_<version>_<target>.tar.gz
    checksums = {}
    for line in checksums_txt.strip().split('\n'):
        if not line:
            continue
        parts = line.split()
        if len(parts) != 2:
            continue
        sha256_hash, filename = parts
        # Extract target from filename (e.g., "darwin_arm64" from "inbox_0.0.1_darwin_arm64.tar.gz")
        match = re.search(r'inbox_[\d.]+_(.+)\.tar\.gz', filename)
        if match:
            target = match.group(1)
            checksums[target] = sha256_hash

    return checksums


async def convert_hash_to_sri(sha256_hash):
    """Convert SHA256 hash to SRI format."""
    loop = asyncio.get_event_loop()

    def convert():
        result = subprocess.run(
            ["nix", "hash", "convert", "--to", "sri", "--hash-algo", "sha256", sha256_hash],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()

    return await loop.run_in_executor(None, convert)


async def update_package(version, checksums):
    """Update package file with new version and hashes."""
    print(f"{GREEN}Updating inbox to v{version}{NC}")

    # Convert all checksums to SRI format concurrently
    targets = ["linux_amd64", "linux_arm64", "darwin_amd64", "darwin_arm64"]

    print(f"{YELLOW}Converting hashes to SRI format...{NC}")
    sri_hashes_list = await asyncio.gather(*[
        convert_hash_to_sri(checksums[target])
        for target in targets
    ])

    sri_hashes = dict(zip(targets, sri_hashes_list))

    # Read current file
    content = PACKAGE_FILE.read_text()

    # Update version
    old_version_match = re.search(r'version = "([\d.]+)";', content)
    old_version = old_version_match.group(1) if old_version_match else "unknown"

    content = re.sub(
        r'version = "[\d.]+";',
        f'version = "{version}";',
        content
    )

    # Update hashes
    for target, hash_value in sri_hashes.items():
        content = re.sub(
            f'"{target}" = "sha256-[^"]+";',
            f'"{target}" = "{hash_value}";',
            content
        )

    # Write back
    PACKAGE_FILE.write_text(content)

    print(f"{GREEN}Updated {PACKAGE_FILE}{NC}")
    print(f"{YELLOW}Version: {old_version} → {version}{NC}")


async def main():
    """Main execution."""
    # Fetch latest version
    version = await fetch_latest_release()

    # Fetch checksums from GitHub release
    checksums = await fetch_checksums(version)

    if not checksums:
        print(f"{RED}Error: No checksums found for v{version}{NC}", file=sys.stderr)
        sys.exit(1)

    # Update package file
    await update_package(version, checksums)

    print(f"{GREEN}All done!{NC}")
    print(f"{YELLOW}Updated: {PACKAGE_FILE} (v{version}){NC}")


if __name__ == "__main__":
    asyncio.run(main())
