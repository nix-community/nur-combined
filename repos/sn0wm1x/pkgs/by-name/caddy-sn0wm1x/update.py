#!/usr/bin/env python3
"""Update plugin pins and source hashes."""

import argparse
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import time
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


def fetch(url, *, github=False):
    headers = {"User-Agent": "caddy-sn0wm1x-update"}
    if github and os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = "Bearer " + os.environ["GITHUB_TOKEN"]
    for attempt in range(3):
        try:
            with urlopen(Request(url, headers=headers), timeout=30) as response:
                return response.read()
        except HTTPError as error:
            if error.code not in (429, 500, 502, 503, 504) or attempt == 2:
                raise
        except (URLError, TimeoutError):
            if attempt == 2:
                raise
        time.sleep(attempt + 1)


def github(repo, endpoint):
    return json.loads(fetch(f"https://api.github.com/repos/{repo}/{endpoint}", github=True))


def latest_ref(repo):
    """Prefer stable releases/tags; use HEAD for repositories without tags."""
    try:
        release = github(repo, "releases/latest")
        return release["tag_name"]
    except HTTPError as error:
        if error.code != 404:
            raise
    tags = github(repo, "tags?per_page=100")
    stable = [
        tag["name"] for tag in tags
        if re.fullmatch(r"v?\d+\.\d+\.\d+(?:-naive)?", tag["name"])
    ]
    if stable:
        return max(stable, key=lambda tag: tuple(map(int, re.findall(r"\d+", tag))))
    return github(repo, "commits?per_page=1")[0]["sha"]


def module_version(module, ref):
    escaped = "".join("!" + char.lower() if char.isupper() else char for char in module)
    data = fetch(f"https://proxy.golang.org/{escaped}/@v/{quote(ref, safe='')}.info")
    return json.loads(data)["Version"]


def refresh(versions):
    for name, plugin in versions["plugins"].items():
        ref = latest_ref(plugin["repo"])
        if name == "forwardproxy":
            # This fork retains the upstream Go module name. Resolve the commit
            # rather than its v2 tag, which does not match the module's path.
            revision = github(plugin["repo"], f"commits/{quote(ref, safe='')}")["sha"]
            versions["forwardproxyRevision"] = revision
            ref = revision
        new_version = module_version(plugin.get("replacement", plugin["module"]), ref)
        print(f"{name}: {plugin['version']} -> {new_version}", flush=True)
        plugin["version"] = new_version


def write_versions(path, versions):
    temporary = path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(versions, indent=2) + "\n")
    temporary.replace(path)


def prefetch_hash(target):
    result = subprocess.run(
        ["nix", "build", "--no-link", target],
        capture_output=True, text=True,
    )
    hashes = re.findall(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr)
    if result.returncode == 0 or len(hashes) != 1:
        raise RuntimeError(f"Could not determine hash for {target}:\n" + result.stderr)
    return hashes[0]


def update(root, *, hash_only=False):
    path = root / "pkgs/by-name/caddy-sn0wm1x/versions.json"
    original = path.read_bytes()
    versions = json.loads(original)
    try:
        if not hash_only:
            refresh(versions)
        # Let Nixpkgs normalize the patch before hashing it; the hash of the
        # raw download is not the hash expected by fetchpatch2.
        versions["patchHash"] = FAKE_HASH
        write_versions(path, versions)
        # path: includes newly added/untracked package files during development.
        target = f"path:{root}#caddy-sn0wm1x"
        print("Prefetching normalized QUIC patch...", flush=True)
        versions["patchHash"] = prefetch_hash(target + ".quicPatch")
        versions["hash"] = FAKE_HASH
        write_versions(path, versions)
        print("Building vendored source to determine its hash...", flush=True)
        versions["hash"] = prefetch_hash(target + ".src")
        write_versions(path, versions)
        print(f"Source hash: {versions['hash']}", flush=True)
    except BaseException:
        path.write_bytes(original)
        raise
    print("Updated caddy-sn0wm1x pins and source hashes", flush=True)


def main():
    def interrupted(signum, frame):
        raise KeyboardInterrupt(f"Interrupted by signal {signum}")

    signal.signal(signal.SIGTERM, interrupted)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--hash-only", action="store_true", help="Keep plugin pins; refresh source hashes")
    args = parser.parse_args()
    update(args.root.resolve(), hash_only=args.hash_only)


if __name__ == "__main__":
    main()
