#!/usr/bin/env python3
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import urllib.request


def parse_zen_version(v: str):
    """Sort key for Zen versions, e.g. 1.23.4b, 1.23b, 1.24."""
    is_beta = v.endswith("b")
    num_part = v[:-1] if is_beta else v
    nums = [int(x) for x in num_part.split(".") if x.isdigit()]
    return (nums, 0 if is_beta else 1)


def get_latest_tag() -> str:
    print("Fetching latest tags from zen-browser/desktop...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    tags_out = subprocess.check_output(
        ["git", "ls-remote", "--tags", "https://github.com/zen-browser/desktop.git"],
        text=True,
        env=env,
    )
    tags = []
    for line in tags_out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("refs/tags/"):
            tag = parts[1][len("refs/tags/") :]
            if not tag.endswith("^{}") and re.match(r"^[0-9]+(\.[0-9]+)+b?$", tag):
                tags.append(tag)
    if not tags:
        raise RuntimeError("No valid release tags found in zen-browser/desktop")
    tags.sort(key=parse_zen_version)
    return tags[-1]


def get_firefox_version(zen_version: str) -> str:
    surfer_url = f"https://raw.githubusercontent.com/zen-browser/desktop/{zen_version}/surfer.json"
    req = urllib.request.Request(surfer_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    ver = data.get("version", {}).get("version")
    if not ver:
        ver = data.get("version", {}).get("candidate")
    if not ver:
        raise RuntimeError(f"Could not determine firefox version from {surfer_url}")
    return ver


def get_firefox_hash(firefox_version: str) -> str:
    # Fetch SHA256SUMS from Mozilla
    sums_url = f"https://archive.mozilla.org/pub/firefox/releases/{firefox_version}/SHA256SUMS"
    req = urllib.request.Request(sums_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=15) as resp:
        sums_text = resp.read().decode("utf-8")

    ff_hex = None
    target_name = f"source/firefox-{firefox_version}.source.tar.xz"
    for line in sums_text.splitlines():
        if target_name in line:
            ff_hex = line.split()[0]
            break

    if not ff_hex:
        raise RuntimeError(f"Could not find hash for {target_name} in {sums_url}")

    return "sha256-" + base64.b64encode(bytes.fromhex(ff_hex)).decode("ascii")


def prefetch_desktop_git(tag: str) -> tuple[str, str]:
    print(f"Prefetching zen-browser/desktop tag {tag}...")
    output = subprocess.check_output(
        [
            "nix-prefetch-git",
            "https://github.com/zen-browser/desktop.git",
            "--rev",
            f"refs/tags/{tag}",
            "--fetch-submodules",
            "--quiet",
        ],
        text=True,
    )
    data = json.loads(output)
    return data["hash"], data.get("path", "")


def get_npm_deps_hash(lock_path: str) -> str:
    print(f"Computing npmDepsHash for {lock_path}...")
    output = subprocess.check_output(
        ["prefetch-npm-deps", lock_path],
        text=True,
    )
    return output.strip()


def main() -> int:
    script_dir = Path(__file__).resolve().parent

    try:
        repo_root = Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
        pkg_nix = repo_root / "by-name/ze/zen-browser/package.nix"
    except Exception:
        pkg_nix = script_dir / "package.nix"

    if not pkg_nix.is_file():
        print(f"Error: Could not find package.nix at {pkg_nix}", file=sys.stderr)
        return 1

    content = pkg_nix.read_text(encoding="utf-8")
    m_ver = re.search(r'(?m)^  version = "([^"]+)";', content)
    if not m_ver:
        print("Error: Could not find current version in package.nix", file=sys.stderr)
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

    if not target_version:
        target_version = get_latest_tag()

    print(f"Current version: {current_version}")
    print(f"Target version:  {target_version}")

    if current_version == target_version:
        print(f"zen-browser is already up to date ({current_version}).")
        return 0

    firefox_version = get_firefox_version(target_version)
    print(f"Firefox base version: {firefox_version}")

    firefox_hash = get_firefox_hash(firefox_version)
    print(f"Firefox source hash: {firefox_hash}")

    desktop_hash, desktop_path = prefetch_desktop_git(target_version)
    print(f"Desktop repo hash: {desktop_hash}")

    npm_deps_hash = None
    lock_file = os.path.join(desktop_path, "package-lock.json") if desktop_path else ""
    if os.path.isfile(lock_file):
        npm_deps_hash = get_npm_deps_hash(lock_file)
        print(f"npmDepsHash: {npm_deps_hash}")

    # Replace version
    content = re.sub(
        r'(?m)^  version = "[^"]+";',
        f'  version = "{target_version}";',
        content,
        count=1,
    )

    # Replace firefoxVersion
    content = re.sub(
        r'(?m)^  firefoxVersion = "[^"]+";',
        f'  firefoxVersion = "{firefox_version}";',
        content,
        count=1,
    )

    # Replace firefoxSrc hash
    content = re.sub(
        r'(firefoxSrc = fetchurl \{.+?hash = ")[^"]+(";)',
        rf"\g<1>{firefox_hash}\g<2>",
        content,
        flags=re.DOTALL,
    )

    # Update patchedSrc block
    patched_src_match = re.search(
        r"patchedSrc = buildNpmPackage \(finalAttrs: \{(.+?)\n  \}\);",
        content,
        re.DOTALL,
    )
    if not patched_src_match:
        print("Error: Could not find patchedSrc block in package.nix", file=sys.stderr)
        return 1

    block = patched_src_match.group(1)
    new_block = re.sub(
        r'(src = fetchFromGitHub \{[^}]*?hash = ")[^"]+(";)',
        rf"\g<1>{desktop_hash}\g<2>",
        block,
        flags=re.DOTALL,
    )
    if npm_deps_hash:
        new_block = re.sub(
            r'(npmDepsHash = ")[^"]+(";)',
            rf"\g<1>{npm_deps_hash}\g<2>",
            new_block,
        )

    content = (
        content[: patched_src_match.start(1)]
        + new_block
        + content[patched_src_match.end(1) :]
    )

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Successfully updated zen-browser to {target_version} (Firefox {firefox_version})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
