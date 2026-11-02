#!/usr/bin/env python3
import os
from pathlib import Path
import re
import subprocess
import sys


def parse_version(v: str):
    return [int(x) for x in v.split(".") if x.isdigit()]


def get_latest_tag() -> str:
    print("Fetching latest tags from gorhill/uBlock...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    tags_out = subprocess.check_output(
        ["git", "ls-remote", "--tags", "https://github.com/gorhill/uBlock.git"],
        text=True,
        env=env,
    )
    versions = []
    for line in tags_out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("refs/tags/"):
            tag = parts[1][len("refs/tags/") :]
            if not tag.endswith("^{}") and re.match(r"^[0-9]+(\.[0-9]+)+$", tag):
                versions.append(tag)
    if not versions:
        raise RuntimeError("No valid release tags found in gorhill/uBlock")
    versions.sort(key=parse_version)
    return versions[-1]


def get_uassets_rev(branch: str) -> str:
    print(f"Fetching latest {branch} commit from uBlockOrigin/uAssets...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    out = subprocess.check_output(
        [
            "git",
            "ls-remote",
            "https://github.com/uBlockOrigin/uAssets.git",
            f"refs/heads/{branch}",
        ],
        text=True,
        env=env,
    )
    for line in out.splitlines():
        parts = line.split()
        if parts and re.match(r"^[0-9a-f]{40}$", parts[0]):
            return parts[0]
    raise RuntimeError(f"Could not resolve {branch} commit from uBlockOrigin/uAssets")


def prefetch_github_archive(owner: str, repo: str, rev: str) -> str:
    url = f"https://github.com/{owner}/{repo}/archive/{rev}.tar.gz"
    print(f"Prefetching {url}...")
    raw_hash = subprocess.check_output(
        ["nix-prefetch-url", "--unpack", url],
        text=True,
    ).strip()
    sri_hash = subprocess.check_output(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw_hash],
        text=True,
    ).strip()
    return sri_hash


def main() -> int:
    try:
        repo_root = Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
        pkg_nix = repo_root / "by-name/ub/ublock-origin-firefox/package.nix"
    except Exception:
        pkg_nix = Path(__file__).resolve().parent / "package.nix"

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
            target_version = arg.split("=", 1)[1].lstrip("v")
        elif not arg.startswith("-"):
            target_version = arg.lstrip("v")

    if not target_version:
        target_version = get_latest_tag()

    print(f"Current version: {current_version}")
    print(f"Target version:  {target_version}")

    src_hash = prefetch_github_archive("gorhill", "uBlock", target_version)
    print(f"New source hash: {src_hash}")

    uassets_main_rev = get_uassets_rev("master")
    uassets_main_hash = prefetch_github_archive(
        "uBlockOrigin", "uAssets", uassets_main_rev
    )
    print(f"New uAssetsMain: rev={uassets_main_rev} hash={uassets_main_hash}")

    uassets_prod_rev = get_uassets_rev("gh-pages")
    uassets_prod_hash = prefetch_github_archive(
        "uBlockOrigin", "uAssets", uassets_prod_rev
    )
    print(f"New uAssetsProd: rev={uassets_prod_rev} hash={uassets_prod_hash}")

    content, n_ver = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        rf'\g<1>"{target_version}";',
        content,
        count=1,
    )
    content, n_src = re.subn(
        r'(src = fetchFromGitHub \{\s*owner = "gorhill";\s*repo = "uBlock";\s*rev = [^;]+;\s*hash = ")[^"]+(";)',
        rf"\g<1>{src_hash}\g<2>",
        content,
        count=1,
    )
    content, n_main_rev = re.subn(
        r'(uAssetsMain = fetchFromGitHub \{\s*owner = "uBlockOrigin";\s*repo = "uAssets";\s*rev = ")[^"]+(";)',
        rf"\g<1>{uassets_main_rev}\g<2>",
        content,
        count=1,
    )
    content, n_main_hash = re.subn(
        r'(uAssetsMain = fetchFromGitHub \{\s*owner = "uBlockOrigin";\s*repo = "uAssets";\s*rev = "[^"]+";\s*hash = ")[^"]+(";)',
        rf"\g<1>{uassets_main_hash}\g<2>",
        content,
        count=1,
    )
    content, n_prod_rev = re.subn(
        r'(uAssetsProd = fetchFromGitHub \{\s*owner = "uBlockOrigin";\s*repo = "uAssets";\s*rev = ")[^"]+(";)',
        rf"\g<1>{uassets_prod_rev}\g<2>",
        content,
        count=1,
    )
    content, n_prod_hash = re.subn(
        r'(uAssetsProd = fetchFromGitHub \{\s*owner = "uBlockOrigin";\s*repo = "uAssets";\s*rev = "[^"]+";\s*hash = ")[^"]+(";)',
        rf"\g<1>{uassets_prod_hash}\g<2>",
        content,
        count=1,
    )

    if (
        n_ver != 1
        or n_src != 1
        or n_main_rev != 1
        or n_main_hash != 1
        or n_prod_rev != 1
        or n_prod_hash != 1
    ):
        raise RuntimeError(
            f"Failed to update all attributes in {pkg_nix} (ver={n_ver}, src={n_src}, main_rev={n_main_rev}, main_hash={n_main_hash}, prod_rev={n_prod_rev}, prod_hash={n_prod_hash})"
        )

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Successfully updated ublock-origin-firefox to {target_version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
