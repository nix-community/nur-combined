#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 jq curl nix-prefetch-git yq-go python3Packages.requests

import base64
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

import requests

PKG_DIR = Path(__file__).parent.resolve()

DEFAULT_NIX = PKG_DIR / "default.nix"
PUBSPEC_LOCK = PKG_DIR / "pubspec.lock.json"
GIT_HASHES = PKG_DIR / "gitHashes.json"
ECH_HTTP_DEPS = PKG_DIR / "ech-http-deps.json"

GITHUB_OWNER = "Predidit"
GITHUB_REPO = "Kazumi"
GITHUB_URL = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}"

ECH_HTTP_PACKAGE = "ech_http"
ECH_HTTP_MANIFEST = "lib/src/build_support/dependencies.json"
ECH_HTTP_TARGETS = ("linux-arm64", "linux-x64")


def log(level: str, message: str) -> None:
    print(f"[{level}] {message}")


def http_get(url: str) -> requests.Response:
    resp = requests.get(url)
    resp.raise_for_status()
    return resp


def read_tarball_member(tarball: bytes, suffix: str) -> bytes:
    with tarfile.open(fileobj=io.BytesIO(tarball), mode="r:gz") as tf:
        member = next((m for m in tf.getmembers() if m.name.endswith(suffix)), None)
        if member is None:
            log("ERROR", f"{suffix} not found in tarball")
            sys.exit(1)
        f = tf.extractfile(member)
        assert f is not None, f"Failed to extract {suffix} from tarball"
        return f.read()


def fetch_latest_version() -> str:
    url = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"
    return http_get(url).json()["tag_name"]


def read_current_version() -> str | None:
    m = re.search(r'version\s*=\s*"(.*?)"', DEFAULT_NIX.read_text())
    return m.group(1) if m else None


def fetch_release_tarball(tag: str) -> tuple[str, bytes]:
    log("INFO", f"Fetching GitHub release {tag} via nix-prefetch-git")
    result = subprocess.check_output(
        ["nix-prefetch-git", "--url", f"{GITHUB_URL}.git", "--rev", tag]
    ).decode()
    tarball_hash = json.loads(result)["hash"]
    log("INFO", f"Tarball hash: {tarball_hash}")
    tarball = http_get(f"{GITHUB_URL}/archive/refs/tags/{tag}.tar.gz").content
    return tarball_hash, tarball


def update_pubspec_lock(tarball: bytes) -> dict:
    log("INFO", "Generating pubspec.lock.json in memory from tarball")
    raw = read_tarball_member(tarball, "pubspec.lock")
    data = subprocess.check_output(
        ["yq", "eval", "--output-format=json", "--prettyPrint", "-"], input=raw
    )
    PUBSPEC_LOCK.write_bytes(data)
    log("OK", f"{PUBSPEC_LOCK} generated")
    return json.loads(data)


def update_git_hashes(pubspec_data: dict) -> None:
    hashes: dict[str, str] = {}
    cache: dict[str, str] = {}
    for name, info in pubspec_data.get("packages", {}).items():
        if info.get("source") != "git":
            continue
        desc = info.get("description")
        if not isinstance(desc, dict):
            continue
        url = desc.get("url")
        rev = desc.get("resolved-ref")
        if not (isinstance(url, str) and isinstance(rev, str)):
            continue
        if url not in cache:
            try:
                result = subprocess.check_output(
                    ["nix-prefetch-git", "--url", url, "--rev", rev]
                )
                cache[url] = json.loads(result)["hash"]
            except subprocess.CalledProcessError:
                log("WARN", f"Failed to fetch {name} hash")
                continue
        hashes[name] = cache[url]
    GIT_HASHES.write_text(json.dumps(hashes, indent=2))
    log("OK", f"{GIT_HASHES} updated")


def update_ech_http_deps(pubspec_data: dict) -> None:
    version = pubspec_data.get("packages", {}).get(ECH_HTTP_PACKAGE, {}).get("version")
    if not version:
        log(
            "WARN",
            f"{ECH_HTTP_PACKAGE} not found in pubspec.lock, skipping {ECH_HTTP_DEPS.name} update",
        )
        return

    archive_url = f"https://pub.dev/api/archives/{ECH_HTTP_PACKAGE}-{version}.tar.gz"
    log("INFO", f"Fetching {ECH_HTTP_PACKAGE} {version} manifest from pub.dev")
    tarball = http_get(archive_url).content
    manifest = json.loads(read_tarball_member(tarball, ECH_HTTP_MANIFEST))

    deps = {}
    for target in ECH_HTTP_TARGETS:
        entry = manifest["targets"][target]
        digest = bytes.fromhex(entry["sha256"])
        deps[target] = {
            "url": entry["url"],
            "hash": f"sha256-{base64.b64encode(digest).decode()}",
        }

    ECH_HTTP_DEPS.write_text(json.dumps(deps, indent=2) + "\n")
    log("OK", f"{ECH_HTTP_DEPS} updated")


def update_default_nix(tag: str, tarball_hash: str) -> None:
    content = DEFAULT_NIX.read_text()
    content = re.sub(r'version\s*=\s*".*?"', f'version = "{tag}"', content)
    content = re.sub(r'hash\s*=\s*".*?"', f'hash = "{tarball_hash}"', content)
    DEFAULT_NIX.write_text(content)
    log("OK", f"default.nix updated with version={tag} and new hash")


def main() -> None:
    try:
        latest_tag = fetch_latest_version()
        current_version = read_current_version()
        if current_version == latest_tag:
            log("SKIP", f"already latest version {latest_tag}")
            return
        tarball_hash, tarball = fetch_release_tarball(latest_tag)
        pubspec_data = update_pubspec_lock(tarball)
        update_git_hashes(pubspec_data)
        update_ech_http_deps(pubspec_data)
        update_default_nix(latest_tag, tarball_hash)
    except Exception as e:
        log("ERROR", str(e))
        sys.exit(1)


if __name__ == "__main__":
    main()
