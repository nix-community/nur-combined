#!/usr/bin/env python3
"""Update ziglint package."""

import asyncio
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
DEFAULT_FILE = SCRIPT_DIR / "default.nix"

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
    """Fetch the latest ziglint release version."""
    print(f"{GREEN}Fetching latest ziglint release...{NC}")

    releases = await fetch_json("https://api.github.com/repos/rockorager/ziglint/releases")

    if not releases:
        print(f"{RED}Error: No releases found{NC}", file=sys.stderr)
        sys.exit(1)

    latest = releases[0]
    version = latest["tag_name"].lstrip("v")

    print(f"{GREEN}Latest release: v{version}{NC}")
    return version


async def generate_binary_hash(version, target):
    """Generate hash for a binary release tarball."""
    print(f"{YELLOW}  Fetching hash for {target}...{NC}")

    url = f"https://github.com/rockorager/ziglint/releases/download/v{version}/ziglint-{target}.tar.gz"

    loop = asyncio.get_event_loop()

    def run_prefetch():
        result = subprocess.run(
            ["nix-prefetch-url", url],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()

    def convert_hash(hash_value):
        result = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", hash_value],
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
        print(f"{RED}Error fetching hash for {target}: {e}{NC}", file=sys.stderr)
        sys.exit(1)


async def update_package(version):
    """Update ziglint package."""
    print(f"{GREEN}Updating ziglint to v{version}{NC}")

    targets = ["x86_64-linux", "aarch64-linux", "aarch64-macos"]

    # Generate all hashes concurrently
    hashes_list = await asyncio.gather(*[
        generate_binary_hash(version, target)
        for target in targets
    ])

    hashes = dict(zip(targets, hashes_list))

    # Read current file
    content = DEFAULT_FILE.read_text()

    # Update version
    content = re.sub(
        r'version = "[\d.]+";',
        f'version = "{version}";',
        content
    )

    # Update hashes
    for target, hash_value in hashes.items():
        content = re.sub(
            f'"{target}" = "sha256-[^"]+";',
            f'"{target}" = "{hash_value}";',
            content
        )

    # Write back
    DEFAULT_FILE.write_text(content)

    print(f"{GREEN}Updated {DEFAULT_FILE}{NC}")


async def main():
    """Main execution."""
    version = await fetch_latest_release()
    await update_package(version)

    print(f"{GREEN}All done!{NC}")
    print(f"{YELLOW}Updated files:{NC}")
    print(f"  - {DEFAULT_FILE} (v{version})")


if __name__ == "__main__":
    asyncio.run(main())
