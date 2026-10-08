#!/usr/bin/env python3
"""Pin the newest successfully published NixBox release and its Cargo lock."""
import argparse
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import tomllib
import urllib.parse
import urllib.request
import urllib.error

UPSTREAM = "SINGH-RAJVEER/nixbox"
ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / "pkgs" / "nixbox"


def api(path):
    request = urllib.request.Request(
        "https://api.github.com/repos/" + UPSTREAM + "/" + path,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "rajveer-nur-release-updater",
            **({"Authorization": "Bearer " + os.environ["GH_TOKEN"]} if os.getenv("GH_TOKEN") else {}),
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def version_key(version):
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError("Expected a stable semantic version: " + version)
    return tuple(int(part) for part in version.split("."))


def release():
    # A tag is created before publishing finishes upstream. Require a green
    # publish run as well, so a partial crates.io release is never selected.
    runs = api("actions/workflows/publish.yml/runs?branch=master&event=push&status=success&per_page=100")["workflow_runs"]
    for run in runs:
        revision = run["head_sha"]
        content = api("contents/Cargo.toml?ref=" + revision)
        version = tomllib.loads(base64.b64decode(content["content"]).decode())["workspace"]["package"]["version"]
        if not re.fullmatch(r"\d+\.\d+\.\d+", version):
            continue
        try:
            tag = api("git/ref/tags/" + urllib.parse.quote("v" + version, safe=""))["object"]
        except urllib.error.HTTPError as error:
            if error.code == 404:
                continue
            raise
        while tag["type"] == "tag":
            tag = api("git/tags/" + tag["sha"])["object"]
        if tag["type"] == "commit" and tag["sha"] == revision:
            return version, revision
    raise RuntimeError("No successful publish run with a matching release tag was found")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Report the release without downloading or writing it")
    args = parser.parse_args()
    version, revision = release()
    current = json.loads((PACKAGE / "source.json").read_text())
    if version_key(version) < version_key(current["version"]):
        raise RuntimeError("Refusing to downgrade from " + current["version"] + " to " + version)
    if version == current["version"] and revision != current["rev"]:
        raise RuntimeError("Release tag changed for an already packaged version")
    if revision == current["rev"]:
        print("NixBox " + version + " is already packaged")
        return
    print("Updating NixBox " + current["version"] + " to " + version + " (" + revision + ")")
    if args.dry_run:
        return
    archive = "https://github.com/" + UPSTREAM + "/archive/" + revision + ".tar.gz"
    fetched = json.loads(subprocess.check_output([
        "nix", "--extra-experimental-features", "nix-command", "store", "prefetch-file",
        "--unpack", "--json", "--name", "source", archive,
    ], text=True))
    source = Path(fetched["storePath"])
    manifest = tomllib.loads((source / "Cargo.toml").read_text())
    if manifest["workspace"]["package"]["version"] != version:
        raise RuntimeError("Fetched source version does not match the release")
    lock_bytes = (source / "Cargo.lock").read_bytes()
    lock = tomllib.loads(lock_bytes.decode())
    if any(p.get("source", "").startswith("git+") for p in lock["package"]):
        raise RuntimeError("New Git dependencies require explicit cargoLock.outputHashes; update packaging before proceeding")
    updated = {"version": version, "rev": revision, "hash": fetched["hash"]}
    (PACKAGE / "Cargo.lock").write_bytes(lock_bytes)
    (PACKAGE / "source.json").write_text(json.dumps(updated, indent=2) + "\n")


if __name__ == "__main__":
    main()
