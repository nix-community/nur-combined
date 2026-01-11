#!/usr/bin/env python3
"""Update zigdoc package to latest release."""

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
    """Fetch the latest zigdoc release version."""
    print(f"{GREEN}Fetching latest zigdoc release...{NC}")

    releases = await fetch_json("https://api.github.com/repos/rockorager/zigdoc/releases")

    if not releases:
        print(f"{RED}Error: No releases found{NC}", file=sys.stderr)
        sys.exit(1)

    latest = releases[0]
    version = latest["tag_name"].lstrip("v")

    print(f"{GREEN}Latest release: v{version}{NC}")
    return version


async def generate_source_hash(version):
    """Generate hash for source tarball."""
    print(f"{YELLOW}Fetching source hash for v{version}...{NC}")

    url = f"https://github.com/rockorager/zigdoc/archive/v{version}.tar.gz"

    loop = asyncio.get_event_loop()

    def run_prefetch():
        result = subprocess.run(
            ["nix-prefetch-url", "--unpack", url],
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
        print(f"{RED}Error fetching source hash: {e}{NC}", file=sys.stderr)
        sys.exit(1)


async def update_package(version, source_hash):
    """Update package file with new version and hash."""
    print(f"{GREEN}Updating zigdoc to v{version}{NC}")

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

    # Update rev
    content = re.sub(
        r'rev = "v[\d.]+";',
        f'rev = "v{version}";',
        content
    )

    # Update hash
    content = re.sub(
        r'hash = "sha256-[^"]+";',
        f'hash = "{source_hash}";',
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

    # Generate source hash
    source_hash = await generate_source_hash(version)

    # Update package file
    await update_package(version, source_hash)

    print(f"{GREEN}All done!{NC}")
    print(f"{YELLOW}Updated: {PACKAGE_FILE} (v{version}){NC}")


if __name__ == "__main__":
    asyncio.run(main())
