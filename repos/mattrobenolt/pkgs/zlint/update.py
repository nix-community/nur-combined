#!/usr/bin/env python3
"""Update zlint stable and unstable packages."""

import asyncio
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
STABLE_FILE = SCRIPT_DIR / "default.nix"
UNSTABLE_FILE = SCRIPT_DIR / "unstable.nix"

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
    """Fetch the latest zlint release version."""
    print(f"{GREEN}Fetching latest zlint release...{NC}")

    releases = await fetch_json("https://api.github.com/repos/DonIsaac/zlint/releases")

    if not releases:
        print(f"{RED}Error: No releases found{NC}", file=sys.stderr)
        sys.exit(1)

    latest = releases[0]
    version = latest["tag_name"].lstrip("v")

    print(f"{GREEN}Latest release: v{version}{NC}")
    return version


async def fetch_latest_commit():
    """Fetch the latest commit SHA from main branch."""
    print(f"{GREEN}Fetching latest commit from main...{NC}")

    loop = asyncio.get_event_loop()

    def run_git_ls_remote():
        result = subprocess.run(
            ["git", "ls-remote", "https://github.com/DonIsaac/zlint.git", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.split()[0]

    sha = await loop.run_in_executor(None, run_git_ls_remote)
    print(f"{GREEN}Latest commit: {sha[:8]}{NC}")
    return sha


async def generate_binary_hash(version, target):
    """Generate hash for a binary release."""
    print(f"{YELLOW}  Fetching hash for {target}...{NC}")

    url = f"https://github.com/DonIsaac/zlint/releases/download/v{version}/zlint-{target}"

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


async def generate_source_hash(rev):
    """Generate hash for source checkout."""
    print(f"{YELLOW}  Fetching source hash for {rev[:8]}...{NC}")

    loop = asyncio.get_event_loop()

    def run_prefetch():
        result = subprocess.run(
            [
                "nix-prefetch-url",
                "--unpack",
                f"https://github.com/DonIsaac/zlint/archive/{rev}.tar.gz"
            ],
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


async def update_stable(version):
    """Update stable zlint package."""
    print(f"{GREEN}Updating stable zlint to v{version}{NC}")

    targets = ["linux-x86_64", "linux-aarch64", "macos-x86_64", "macos-aarch64"]

    # Generate all hashes concurrently
    hashes_list = await asyncio.gather(*[
        generate_binary_hash(version, target)
        for target in targets
    ])

    hashes = dict(zip(targets, hashes_list))

    # Read current file
    content = STABLE_FILE.read_text()

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
    STABLE_FILE.write_text(content)

    print(f"{GREEN}Updated {STABLE_FILE}{NC}")


def extract_zig_version(zon_content):
    """Extract minimum_zig_version from build.zig.zon."""
    # Look for .minimum_zig_version = "X.Y.Z"
    match = re.search(r'\.minimum_zig_version\s*=\s*"([0-9]+\.[0-9]+)(?:\.[0-9]+)?"', zon_content)
    if match:
        version = match.group(1)
        # Convert "0.14" to "0_14" for Nix attribute name
        return version.replace(".", "_")
    return None


async def generate_zig_deps(sha):
    """Generate deps.nix from build.zig.zon using zon2nix."""
    print(f"{YELLOW}  Generating Zig dependencies with zon2nix...{NC}")

    deps_file = SCRIPT_DIR / "deps.nix"

    # Fetch build.zig.zon from the commit
    zon_url = f"https://raw.githubusercontent.com/DonIsaac/zlint/{sha}/build.zig.zon"

    loop = asyncio.get_event_loop()

    def fetch_zon():
        return urlopen(zon_url).read().decode('utf-8')

    def run_zon2nix(zon_content):
        import tempfile
        import os
        # Write to temp file since zon2nix expects a file path
        with tempfile.NamedTemporaryFile(mode='w', suffix='.zon', delete=False) as f:
            f.write(zon_content)
            temp_path = f.name

        try:
            result = subprocess.run(
                ["zon2nix", temp_path],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout
        finally:
            os.unlink(temp_path)

    try:
        zon_content = await loop.run_in_executor(None, fetch_zon)

        # Extract Zig version
        zig_version = extract_zig_version(zon_content)
        if zig_version:
            print(f"{GREEN}  Detected Zig version: {zig_version.replace('_', '.')}{NC}")

        deps_nix = await loop.run_in_executor(None, lambda: run_zon2nix(zon_content))

        # Write deps.nix
        deps_file.write_text(deps_nix)
        print(f"{GREEN}  Generated {deps_file}{NC}")

        return zig_version

    except subprocess.CalledProcessError as e:
        print(f"{RED}Error running zon2nix: {e}{NC}", file=sys.stderr)
        if e.stderr:
            print(f"{RED}stderr: {e.stderr}{NC}", file=sys.stderr)
        if e.stdout:
            print(f"{YELLOW}stdout: {e.stdout}{NC}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"{RED}Error fetching build.zig.zon: {e}{NC}", file=sys.stderr)
        sys.exit(1)


async def update_unstable(sha, source_hash):
    """Update unstable zlint package."""
    from datetime import datetime

    print(f"{GREEN}Updating unstable zlint to {sha[:8]}{NC}")

    # Generate deps.nix from build.zig.zon and get Zig version
    zig_version = await generate_zig_deps(sha)

    # Read current file
    content = UNSTABLE_FILE.read_text()

    # Update version with current date
    today = datetime.now().strftime("%Y-%m-%d")
    content = re.sub(
        r'version = "unstable-[\d-]+";',
        f'version = "unstable-{today}";',
        content
    )

    # Update rev
    content = re.sub(
        r'rev = "[0-9a-f]+";',
        f'rev = "{sha}";',
        content
    )

    # Update hash
    content = re.sub(
        r'hash = "sha256-[^"]+";',
        f'hash = "{source_hash}";',
        content
    )

    # Update Zig version if detected
    if zig_version:
        content = re.sub(
            r', zig_\d+_\d+',
            f', zig_{zig_version}',
            content
        )
        print(f"{GREEN}  Updated Zig version to zig_{zig_version}{NC}")

    # Write back
    UNSTABLE_FILE.write_text(content)

    print(f"{GREEN}Updated {UNSTABLE_FILE}{NC}")


async def main():
    """Main execution."""
    # Fetch versions
    version, sha = await asyncio.gather(
        fetch_latest_release(),
        fetch_latest_commit()
    )

    # Update stable package
    await update_stable(version)

    # Get source hash and update unstable
    source_hash = await generate_source_hash(sha)
    await update_unstable(sha, source_hash)

    print(f"{GREEN}All done!{NC}")
    print(f"{YELLOW}Updated files:{NC}")
    print(f"  - {STABLE_FILE} (v{version})")
    print(f"  - {UNSTABLE_FILE} ({sha[:8]})")
    print(f"  - {SCRIPT_DIR / 'deps.nix'} (Zig dependencies)")


if __name__ == "__main__":
    asyncio.run(main())
