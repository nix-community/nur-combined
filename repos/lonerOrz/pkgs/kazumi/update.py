#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 jq curl nix-prefetch-git yq-go python3Packages.requests

import json
import subprocess
import sys
from pathlib import Path
import tarfile
import io
import requests
import re

PKG_DIR = Path(__file__).parent.resolve()
DEFAULT_NIX = PKG_DIR / "default.nix"
GITHUB_OWNER = "Predidit"
GITHUB_REPO = "Kazumi"
PUBSPEC_LOCK = PKG_DIR / "pubspec.lock.json"
GIT_HASHES = PKG_DIR / "gitHashes.json"


def fetch_latest_version() -> str:
    url = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.json()["tag_name"]


def read_current_version() -> str | None:
    content = DEFAULT_NIX.read_text()
    m = re.search(r'version\s*=\s*"(.*?)"', content)
    return m.group(1) if m else None


def fetch_tarball_and_compute_hash(tag: str):
    repo_url = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}.git"
    print(f"[INFO] Fetching GitHub release {tag} via nix-prefetch-git")
    result = subprocess.check_output(
        ["nix-prefetch-git", "--url", repo_url, "--rev", tag]
    ).decode()
    data = json.loads(result)
    tarball_hash = data["hash"]
    print(f"[INFO] Tarball hash: {tarball_hash}")
    tarball_url = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/archive/refs/tags/{tag}.tar.gz"
    return tarball_hash, tarball_url


def generate_pubspec_lock_from_tarball(tarball_url: str) -> dict:
    print(f"[INFO] Generating pubspec.lock.json in memory from tarball")
    resp = requests.get(tarball_url)
    resp.raise_for_status()
    with tarfile.open(fileobj=io.BytesIO(resp.content), mode="r:gz") as tf:
        pubspec_file = next(
            (m for m in tf.getmembers() if m.name.endswith("pubspec.lock")), None
        )
        if not pubspec_file:
            print("[ERROR] pubspec.lock not found in tarball")
            sys.exit(1)
        f = tf.extractfile(pubspec_file)
        assert f is not None, "Failed to extract pubspec.lock from tarball"
        raw_text = f.read()
    result = subprocess.check_output(
        ["yq", "eval", "--output-format=json", "--prettyPrint", "-"], input=raw_text
    )
    PUBSPEC_LOCK.write_bytes(result)
    print(f"[OK] {PUBSPEC_LOCK} generated")
    return json.loads(result)


def update_git_hashes(pubspec_data: dict):
    output = {}
    git_cache: dict[str, str] = {}
    packages = pubspec_data.get("packages", {})
    for name, info in packages.items():
        if info.get("source") != "git":
            continue
        desc = info.get("description")
        if not isinstance(desc, dict):
            continue
        url = desc.get("url")
        rev = desc.get("resolved-ref")
        if not (isinstance(url, str) and isinstance(rev, str)):
            continue
        if url in git_cache:
            output[name] = git_cache[url]
            continue
        try:
            raw = subprocess.check_output(
                ["nix-prefetch-git", "--url", url, "--rev", rev]
            )
            h = json.loads(raw)["hash"]
            output[name] = h
            git_cache[url] = h
        except subprocess.CalledProcessError:
            print(f"[WARN] Failed to fetch {name} hash")
            continue
    GIT_HASHES.write_text(json.dumps(output, indent=2))
    print(f"[OK] {GIT_HASHES} updated")


def update_default_nix(tag: str, tarball_hash: str):
    content = DEFAULT_NIX.read_text()
    content = re.sub(r'version\s*=\s*".*?"', f'version = "{tag}"', content)
    content = re.sub(r'hash\s*=\s*".*?"', f'hash = "{tarball_hash}"', content)
    DEFAULT_NIX.write_text(content)
    print(f"[OK] default.nix updated with version={tag} and new hash")


def main():
    try:
        latest_tag = fetch_latest_version()
        current_version = read_current_version()
        if current_version == latest_tag:
            print(f"[SKIP] already latest version {latest_tag}")
            return
        tarball_hash, tarball_url = fetch_tarball_and_compute_hash(latest_tag)
        pubspec_data = generate_pubspec_lock_from_tarball(tarball_url)
        update_git_hashes(pubspec_data)
        update_default_nix(latest_tag, tarball_hash)
    except Exception as e:
        print(f"[ERROR] {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
