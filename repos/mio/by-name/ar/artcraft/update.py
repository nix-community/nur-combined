#!/usr/bin/env python3
import os
from pathlib import Path
import re
import subprocess
import sys


def parse_version(v: str):
    return [int(x) for x in v.split(".") if x.isdigit()]


def get_latest_tag() -> str:
    print("Fetching latest tags from storytold/artcraft...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    tags_out = subprocess.check_output(
        ["git", "ls-remote", "--tags", "https://github.com/storytold/artcraft.git"],
        text=True,
        env=env,
    )
    versions = []
    for line in tags_out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("refs/tags/"):
            tag = parts[1][len("refs/tags/") :]
            if not tag.endswith("^{}") and tag.startswith("artcraft-v"):
                ver = tag[len("artcraft-v") :]
                if re.match(r"^[0-9]+(\.[0-9]+)+$", ver):
                    versions.append(ver)
    if not versions:
        raise RuntimeError("No valid release tags found in storytold/artcraft")
    versions.sort(key=parse_version)
    return versions[-1]


def prefetch_src(version: str) -> tuple[str, str]:
    url = f"https://github.com/storytold/artcraft/archive/refs/tags/artcraft-v{version}.tar.gz"
    print(f"Prefetching {url}...")
    proc = subprocess.run(
        ["nix-prefetch-url", "--unpack", "--print-path", url],
        capture_output=True,
        text=True,
        check=True,
    )
    lines = proc.stdout.strip().splitlines()
    raw_hash = lines[0].strip()
    store_path = lines[1].strip() if len(lines) > 1 else ""
    sri_hash = subprocess.check_output(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw_hash],
        text=True,
    ).strip()
    return sri_hash, store_path


def compute_mismatch_hash(cmd: list[str]) -> str:
    proc = subprocess.run(
        cmd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    m = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", proc.stdout)
    if not m:
        # Also check for 'specified: ... \n got: ...' or hash mismatch formatting
        m = re.search(r"got:\s*([a-z0-9+/=]+)", proc.stdout)
    if not m:
        print(proc.stdout, file=sys.stderr)
        raise RuntimeError(f"Failed to extract hash from output of {' '.join(cmd)}")
    hash_val = m.group(1)
    if not hash_val.startswith("sha256-"):
        hash_val = subprocess.check_output(
            ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", hash_val],
            text=True,
        ).strip()
    return hash_val


def main() -> int:
    try:
        repo_root = Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
        pkg_nix = repo_root / "by-name/ar/artcraft/package.nix"
        lock_file = repo_root / "by-name/ar/artcraft/frontend-package-lock.json"
    except Exception:
        pkg_nix = Path(__file__).resolve().parent / "package.nix"
        lock_file = Path(__file__).resolve().parent / "frontend-package-lock.json"
        repo_root = pkg_nix.parent.parent.parent.parent

    if not pkg_nix.is_file():
        print(f"Error: Could not find package.nix at {pkg_nix}", file=sys.stderr)
        return 1

    content = pkg_nix.read_text(encoding="utf-8")
    m_ver = re.search(r'(?m)^\s*version = "([^"]+)";', content)
    if not m_ver:
        print("Error: Could not find version in package.nix", file=sys.stderr)
        return 1
    current_version = m_ver.group(1)

    target_version = None
    for arg in sys.argv[1:]:
        if arg in ("-h", "--help"):
            print("Usage: update.py [TARGET_VERSION]")
            return 0
        if arg.startswith("--version="):
            target_version = arg.split("=", 1)[1]
        elif not arg.startswith("-"):
            target_version = arg

    if target_version:
        target_version = target_version.removeprefix("artcraft-v").removeprefix("v")

    if not target_version:
        target_version = get_latest_tag()

    print(f"Current version: {current_version}")
    print(f"Target version:  {target_version}")

    if current_version == target_version:
        print(f"artcraft is already up to date ({current_version}).")
        return 0

    src_hash, store_path = prefetch_src(target_version)
    print(f"New source hash: {src_hash}")

    # Update frontend-package-lock.json
    lock_updated = False
    if store_path and (Path(store_path) / "frontend/package-lock.json").is_file():
        upstream_lock = (Path(store_path) / "frontend/package-lock.json").read_text(encoding="utf-8")
        lock_file.write_text(upstream_lock, encoding="utf-8")
        lock_updated = True
        print(f"Updated {lock_file} from unpacked store path.")
    else:
        lock_url = f"https://raw.githubusercontent.com/storytold/artcraft/artcraft-v{target_version}/frontend/package-lock.json"
        try:
            import urllib.request
            with urllib.request.urlopen(lock_url) as resp:
                lock_file.write_bytes(resp.read())
            lock_updated = True
            print(f"Updated {lock_file} from {lock_url}.")
        except Exception as e:
            print(f"Warning: Failed to fetch upstream lockfile: {e}", file=sys.stderr)

    # 1. Update version and src hash in package.nix
    content, n_ver = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        rf'\g<1>"{target_version}";',
        content,
        count=1,
    )
    content, n_src = re.subn(
        r'(tag = "artcraft-v\$\{version\}";\s*hash = ")[^"]+(";)',
        rf"\g<1>{src_hash}\g<2>",
        content,
        count=1,
    )
    if n_ver != 1 or n_src != 1:
        raise RuntimeError(f"Failed to update version/src hash in {pkg_nix} (ver={n_ver}, src={n_src})")

    # Set dummy hash for npmDeps
    dummy_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    content, n_npm = re.subn(
        r'(npmDeps = fetchNpmDeps \{\s*src = frontendSrc;\s*hash = ")[^"]+(";)',
        rf"\g<1>{dummy_hash}\g<2>",
        content,
        count=1,
    )
    if n_npm != 1:
        raise RuntimeError(f"Failed to set dummy npmDeps hash in {pkg_nix}")

    pkg_nix.write_text(content, encoding="utf-8")

    # Compute new npmDeps hash
    print("Computing new npmDeps hash...")
    new_npm_hash = compute_mismatch_hash(
        ["nix-build", "--no-out-link", str(repo_root), "-A", "artcraft.npmDeps"]
    )
    print(f"New npmDeps hash: {new_npm_hash}")

    content = pkg_nix.read_text(encoding="utf-8")
    content, n_npm_real = re.subn(
        r'(npmDeps = fetchNpmDeps \{\s*src = frontendSrc;\s*hash = ")[^"]+(";)',
        rf"\g<1>{new_npm_hash}\g<2>",
        content,
        count=1,
    )
    # Set dummy cargoHash
    content, n_cargo = re.subn(
        r'(?m)^(\s*cargoHash = )"[^"]+";',
        rf'\g<1>"{dummy_hash}";',
        content,
        count=1,
    )
    if n_npm_real != 1 or n_cargo != 1:
        raise RuntimeError(f"Failed to write real npmDeps and dummy cargoHash in {pkg_nix}")

    pkg_nix.write_text(content, encoding="utf-8")

    # Compute new cargoHash
    print("Computing new cargoHash...")
    new_cargo_hash = compute_mismatch_hash(
        ["nix-build", "--no-out-link", str(repo_root), "-A", "artcraft.cargoDeps"]
    )
    print(f"New cargoHash: {new_cargo_hash}")

    content = pkg_nix.read_text(encoding="utf-8")
    content, n_cargo_real = re.subn(
        r'(?m)^(\s*cargoHash = )"[^"]+";',
        rf'\g<1>"{new_cargo_hash}";',
        content,
        count=1,
    )
    if n_cargo_real != 1:
        raise RuntimeError(f"Failed to write real cargoHash in {pkg_nix}")

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Successfully updated artcraft to {target_version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
