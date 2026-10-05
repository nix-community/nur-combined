#!/usr/bin/env python3
"""Update the dsh npm package: version, source hash, lockfile, npmDepsHash."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path
from urllib.request import urlretrieve

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from update_lib import (  # noqa: E402 - the path above must run first
    DUMMY_SHA256_HASH,
    extract_hash_from_build_error,
    is_newer,
    nix_build,
    nix_prefetch_file,
    npm_latest_version,
    read_json,
    write_json,
)

PKG_DIR = Path(__file__).resolve().parent
PACKAGE = "@deepseek-ai/dsh"
FLAKE_ATTR = ".#dsh"


def tarball_url(version: str) -> str:
    """Return the registry tarball URL for a dsh version."""
    return f"https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-{version}.tgz"


def regenerate_lockfile(url: str) -> None:
    """Regenerate package-lock.json the way the derivation expects.

    The published tarball ships no lockfile, and its devDependencies point at
    unpublished workspace packages, so generate one with those removed.
    """
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        tarball = tmp_path / "package.tgz"
        urlretrieve(url, tarball)
        with tarfile.open(tarball, "r:gz") as archive:
            archive.extractall(tmp_path, filter="data")

        package_dir = tmp_path / "package"
        manifest_path = package_dir / "package.json"
        manifest = json.loads(manifest_path.read_text())
        manifest.pop("devDependencies", None)
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

        subprocess.run(
            ["npm", "install", "--package-lock-only", "--ignore-scripts"],
            cwd=package_dir,
            check=True,
        )
        shutil.copyfile(package_dir / "package-lock.json", PKG_DIR / "package-lock.json")
    print("regenerated package-lock.json")


def main() -> None:
    """Update hashes.json when a newer dsh release exists on npm."""
    hashes_file = PKG_DIR / "hashes.json"
    data = read_json(hashes_file)
    current = data["version"]
    latest = npm_latest_version(PACKAGE)
    print(f"current: {current}, latest: {latest}")
    if not is_newer(latest, current):
        print("already up to date")
        return

    url = tarball_url(latest)
    print(f"hashing {url}")
    source_hash = nix_prefetch_file(url)
    regenerate_lockfile(url)

    # Stage a placeholder npmDepsHash so the build fails and reports the real
    # one; this tracks npmDepsFetcherVersion automatically.
    write_json(
        hashes_file,
        {"version": latest, "sourceHash": source_hash, "npmDepsHash": DUMMY_SHA256_HASH},
    )
    print("calculating npmDepsHash (expected build failure)...")
    result = nix_build(FLAKE_ATTR)
    real_hash = extract_hash_from_build_error(result.stdout + result.stderr)
    if not real_hash:
        write_json(hashes_file, data)
        raise SystemExit(
            "could not extract npmDepsHash from build output:\n"
            + result.stdout
            + result.stderr
        )

    write_json(
        hashes_file,
        {"version": latest, "sourceHash": source_hash, "npmDepsHash": real_hash},
    )

    print("verifying build...")
    subprocess.run(["nix", "build", "--no-link", FLAKE_ATTR], check=True)
    print(f"updated to {latest}")


if __name__ == "__main__":
    main()
