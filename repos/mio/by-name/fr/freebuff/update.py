#!/usr/bin/env python3
"""Update freebuff to the version published on npm (the `npx freebuff` release).

The npm wrapper version (0.2.x) is not one of the GitHub tags of
CodebuffAI/freebuff (those track the underlying Codebuff CLI and stop at
v1.0.679). What does identify the source of a release is
`freebuff/cli/release/package.json`: the release workflow bumps it to the npm
version, so the commit that sets it to a given version is the source snapshot
that release was cut from. This script resolves that commit, prefetches the
source, recomputes the per-platform Bun workspace dependency hashes and
rewrites package.nix.
"""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request

OWNER = "CodebuffAI"
REPO = "freebuff"
VERSION_FILE = "freebuff/cli/release/package.json"
NPM_LATEST_URL = "https://registry.npmjs.org/freebuff/latest"
GITHUB_API = "https://api.github.com"
RAW_GITHUB = "https://raw.githubusercontent.com"

# platform attrs used in package.nix -> (bun --os, bun --cpu)
PLATFORMS = {
    "x86_64-linux": ("linux", "x64"),
    "aarch64-darwin": ("darwin", "arm64"),
}

# Packages missing from the public snapshot's lockfile; kept in sync with
# package.nix. `--no-save` adds them without touching bun.lock.
EXTRA_PACKAGES = ["@opentelemetry/api@1.10.0", "picocolors@1.1.1"]


def request(url: str) -> urllib.request.Request:
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "nurpkgs3-freebuff-updater")
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith(GITHUB_API):
        req.add_header("Authorization", f"Bearer {token}")
    return req


def get_json(url: str):
    with urllib.request.urlopen(request(url), timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def get_text(url: str) -> str:
    with urllib.request.urlopen(request(url), timeout=30) as resp:
        return resp.read().decode("utf-8")


def run(args: list[str], **kwargs) -> str:
    return subprocess.check_output(args, text=True, **kwargs).strip()


def npm_latest_version() -> str:
    version = get_json(NPM_LATEST_URL).get("version")
    if not version:
        raise RuntimeError(f"no version in {NPM_LATEST_URL}")
    return version


def release_source_commit(target_version: str) -> str:
    """The commit that set the npm wrapper version to `target_version`."""
    print(f"Looking up the source commit for freebuff {target_version}...")
    for page in range(1, 6):
        commits = get_json(
            f"{GITHUB_API}/repos/{OWNER}/{REPO}/commits"
            f"?path={VERSION_FILE}&per_page=100&page={page}"
        )
        if not commits:
            break
        for commit in commits:
            sha = commit["sha"]
            raw = get_text(f"{RAW_GITHUB}/{OWNER}/{REPO}/{sha}/{VERSION_FILE}")
            try:
                version = json.loads(raw).get("version")
            except json.JSONDecodeError:
                continue
            if version == target_version:
                return sha
    raise RuntimeError(
        f"could not find a {REPO} commit whose {VERSION_FILE} is "
        f"{target_version}; is the npm release published?"
    )


def sri_hash(base32: str) -> str:
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32]
    )


def prefetch_source(rev: str) -> tuple[str, str]:
    print(f"Prefetching {OWNER}/{REPO} at {rev}...")
    output = run(
        [
            "nix-prefetch-url",
            "--unpack",
            "--print-path",
            "--type",
            "sha256",
            f"https://github.com/{OWNER}/{REPO}/archive/{rev}.tar.gz",
        ]
    ).splitlines()
    return sri_hash(output[0]), output[-1]


def workspace_deps_hash(source_path: str, os_name: str, cpu: str) -> str:
    print(f"Computing workspace dependency hash for {os_name}-{cpu}...")
    with tempfile.TemporaryDirectory(prefix="freebuff-deps-") as tmp:
        tree = os.path.join(tmp, "src")
        shutil.copytree(source_path, tree, symlinks=True)
        # The prefetched tree comes from the read-only Nix store.
        subprocess.run(["chmod", "-R", "u+w", tree], check=True)
        env = dict(os.environ)
        env["HOME"] = os.path.join(tmp, "home")
        os.makedirs(env["HOME"], exist_ok=True)
        # A previous platform's node_modules would otherwise be reused.
        shutil.rmtree(os.path.join(tree, "node_modules"), ignore_errors=True)

        common = ["bun", "install", "--ignore-scripts", f"--os={os_name}", f"--cpu={cpu}"]
        subprocess.run(
            common + ["--frozen-lockfile"],
            cwd=tree,
            env=env,
            check=True,
            stdout=subprocess.DEVNULL,
        )
        subprocess.run(
            common + ["--no-save", *EXTRA_PACKAGES],
            cwd=tree,
            env=env,
            check=True,
            stdout=subprocess.DEVNULL,
        )
        return run(["nix", "hash", "path", os.path.join(tree, "node_modules")])


def dist_version(rev: str) -> str:
    """Version recorded in the prefetched source, for a sanity check."""
    raw = get_text(f"{RAW_GITHUB}/{OWNER}/{REPO}/{rev}/{VERSION_FILE}")
    return json.loads(raw).get("version", "")


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    try:
        repo_root = Path(
            run(["git", "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL)
        )
        pkg_nix = repo_root / "by-name/fr/freebuff/package.nix"
    except Exception:
        pkg_nix = script_dir / "package.nix"

    if not pkg_nix.is_file():
        print(f"Error: could not find package.nix at {pkg_nix}", file=sys.stderr)
        return 1

    content = pkg_nix.read_text(encoding="utf-8")
    version_match = re.search(r'(?m)^  version = "([^"]+)";', content)
    rev_match = re.search(
        r'(?ms)^  src = fetchFromGitHub \{.*?^\s*rev = "([^"]+)";', content
    )
    if not version_match or not rev_match:
        print("Error: could not parse version/src.rev from package.nix", file=sys.stderr)
        return 1
    current_version = version_match.group(1)
    current_rev = rev_match.group(1)

    target_version = None
    for arg in sys.argv[1:]:
        if arg in ("-h", "--help"):
            print("Usage: update.py [VERSION] (defaults to the npm `latest` release)")
            return 0
        if arg.startswith("--version="):
            target_version = arg.split("=", 1)[1]
        elif not arg.startswith("-"):
            target_version = arg
    if not target_version:
        target_version = npm_latest_version()

    print(f"Current version: {current_version} ({current_rev[:12]})")
    print(f"Target version:  {target_version}")

    rev = release_source_commit(target_version)
    if current_version == target_version and current_rev == rev:
        print(f"freebuff is already up to date ({current_version}).")
        return 0
    print(f"Release source commit: {rev}")

    src_version = dist_version(rev)
    if src_version != target_version:
        print(
            f"Error: {rev} declares {src_version!r}, expected {target_version!r}",
            file=sys.stderr,
        )
        return 1

    src_hash, src_path = prefetch_source(rev)
    print(f"Source hash: {src_hash}")

    dep_hashes = {
        platform: workspace_deps_hash(src_path, os_name, cpu)
        for platform, (os_name, cpu) in PLATFORMS.items()
    }
    for platform, hash_ in dep_hashes.items():
        print(f"{platform} workspace deps hash: {hash_}")

    content = re.sub(
        r'(?m)^  version = "[^"]+";',
        f'  version = "{target_version}";',
        content,
        count=1,
    )
    content = re.sub(
        r'(?ms)(^  src = fetchFromGitHub \{.*?^\s*rev = ")[^"]+(";)',
        rf"\g<1>{rev}\g<2>",
        content,
        count=1,
    )
    content = re.sub(
        r'(?ms)(^  src = fetchFromGitHub \{.*?^\s*hash = ")[^"]+(";)',
        rf"\g<1>{src_hash}\g<2>",
        content,
        count=1,
    )
    for platform, hash_ in dep_hashes.items():
        content = re.sub(
            rf'(?m)^(\s*{re.escape(platform)} = ")[^"]+(";)',
            rf"\g<1>{hash_}\g<2>",
            content,
            count=1,
        )

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Updated freebuff to {target_version} ({rev}) in {pkg_nix}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
