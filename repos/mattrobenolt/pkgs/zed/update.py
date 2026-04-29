#!/usr/bin/env python3
"""Update Zed versions and hashes for both stable and preview channels."""

import asyncio
import json
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
VERSIONS_FILE = SCRIPT_DIR / "versions.json"
HASHES_FILE = SCRIPT_DIR / "hashes.json"

GITHUB_API = "https://api.github.com/repos/zed-industries/zed/releases"

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"


async def fetch_json(url):
    """Fetch JSON from URL."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, lambda: json.loads(urlopen(url).read()))


async def fetch_latest_versions():
    """Fetch the latest stable and preview versions from GitHub releases."""
    print(f"{GREEN}Fetching latest Zed releases from GitHub...{NC}")

    releases = await fetch_json(f"{GITHUB_API}?per_page=20")

    stable = None
    preview = None

    for release in releases:
        tag = release["tag_name"]
        is_pre = release["prerelease"]

        if not is_pre and stable is None:
            stable = tag.lstrip("v")
        elif is_pre and preview is None and tag.endswith("-pre"):
            preview = tag.lstrip("v")

        if stable and preview:
            break

    if not stable:
        print(f"{RED}Error: could not find stable release{NC}", file=sys.stderr)
        sys.exit(1)
    if not preview:
        print(f"{RED}Error: could not find preview release{NC}", file=sys.stderr)
        sys.exit(1)

    print(f"  stable:  {stable}")
    print(f"  preview: {preview}")
    print()
    return {"stable": stable, "preview": preview}


async def nix_prefetch(url):
    """Return the SRI SHA256 hash of a URL using nix-prefetch-url."""
    loop = asyncio.get_event_loop()

    def run():
        r = subprocess.run(
            ["nix-prefetch-url", url],
            capture_output=True,
            text=True,
            check=True,
        )
        return r.stdout.strip()

    def convert(raw):
        r = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", raw],
            capture_output=True,
            text=True,
            check=True,
        )
        return r.stdout.strip()

    try:
        raw = await loop.run_in_executor(None, run)
        return await loop.run_in_executor(None, lambda: convert(raw))
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error fetching {url}: {e}{NC}", file=sys.stderr)
        sys.exit(1)


async def fetch_hashes(version):
    """Fetch hashes for both Linux architectures for a given version."""
    print(f"{YELLOW}  Fetching hashes for {version}...{NC}")

    arches = ["x86_64", "aarch64"]
    nix_systems = ["x86_64-linux", "aarch64-linux"]

    urls = [
        f"https://github.com/zed-industries/zed/releases/download/v{version}/zed-linux-{arch}.tar.gz"
        for arch in arches
    ]

    hashes = await asyncio.gather(*[nix_prefetch(url) for url in urls])
    return dict(zip(nix_systems, hashes))


async def main():
    """Main execution."""
    versions = await fetch_latest_versions()

    # Read existing hashes
    if HASHES_FILE.exists():
        with open(HASHES_FILE) as f:
            all_hashes = json.load(f)
    else:
        all_hashes = {}

    # Fetch hashes for any version we don't already have
    new_versions = [v for v in versions.values() if v not in all_hashes]
    if new_versions:
        print(f"{GREEN}Fetching hashes for new versions...{NC}")
        results = await asyncio.gather(*[fetch_hashes(v) for v in new_versions])
        for v, h in zip(new_versions, results):
            all_hashes[v] = h
    else:
        print(f"{GREEN}All hashes already up to date.{NC}")

    # Prune hashes no longer referenced
    tracked = set(versions.values())
    all_hashes = {v: h for v, h in all_hashes.items() if v in tracked}

    # Write versions.json
    with open(VERSIONS_FILE, "w") as f:
        json.dump(versions, f, indent=2, sort_keys=True)
        f.write("\n")

    # Write hashes.json
    with open(HASHES_FILE, "w") as f:
        json.dump(all_hashes, f, indent=2, sort_keys=True)
        f.write("\n")

    print(f"\n{GREEN}Done!{NC}")
    print(f"{YELLOW}Updated: {VERSIONS_FILE}{NC}")
    print(f"{YELLOW}Updated: {HASHES_FILE}{NC}")


if __name__ == "__main__":
    asyncio.run(main())
