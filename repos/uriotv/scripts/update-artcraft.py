#!/usr/bin/env python3
"""Update one official ArtCraft Linux binary release, atomically and fail closed."""
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = {"wordcraft", "gridcraft", "deckcraft", "pdfcraft", "photocraft", "filmcraft", "soundcraft"}
VERSION = re.compile(r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\Z")


class SameOriginRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if not newurl.startswith("https://api.github.com/"):
            raise ValueError("refusing GitHub API redirect to another origin")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def latest(name):
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "urio-nur-artcraft-updater"}
    if token := os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(f"https://api.github.com/repos/storytold/{name}/releases/latest", headers=headers)
    with urllib.request.build_opener(SameOriginRedirect()).open(request, timeout=30) as response:
        release = json.load(response)
    tag = release.get("tag_name", "")
    version = tag.removeprefix("v")
    if not tag.startswith("v") or not VERSION.fullmatch(version) or release.get("draft") or release.get("prerelease"):
        raise ValueError("latest release is not a stable vX.Y.Z release")
    filename = f"{name}-{version}-linux-x86_64.tar.gz"
    assets = [a for a in release.get("assets", []) if a.get("name") == filename]
    expected_url = f"https://github.com/storytold/{name}/releases/download/{tag}/{filename}"
    if len(assets) != 1 or assets[0].get("browser_download_url") != expected_url:
        raise ValueError(f"missing, duplicated or unexpected asset {filename}")
    digest = assets[0].get("digest") or ""
    if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
        raise ValueError(f"missing or invalid SHA-256 digest for {filename}")
    return version, expected_url, "sha256-" + base64.b64encode(bytes.fromhex(digest[7:])).decode()


def update(name):
    if name not in PACKAGES:
        raise ValueError("unknown ArtCraft package")
    path = ROOT / "pkgs" / name / "source.json"
    original = path.read_bytes()
    current = json.loads(original)
    if set(current) != {"version", "hash"} or not VERSION.fullmatch(current["version"]):
        raise ValueError("invalid pinned source metadata")
    version, url, sha = latest(name)
    old_key = tuple(map(int, current["version"].split(".")))
    new_key = tuple(map(int, version.split(".")))
    if new_key <= old_key:
        if new_key == old_key and sha != current["hash"]:
            raise ValueError("upstream asset digest changed without a version change")
        print(f"{name}: unchanged (pinned {current['version']}, latest {version})")
        return
    result = subprocess.run(["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url],
                            check=True, capture_output=True, text=True)
    if json.loads(result.stdout).get("hash") != sha:
        raise ValueError("download hash does not match GitHub's release digest")
    temporary = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as file:
            temporary = Path(file.name)
            file.write(json.dumps({"version": version, "hash": sha}, indent=2) + "\n")
            file.flush()
            os.fchmod(file.fileno(), path.stat().st_mode & 0o777)
        os.replace(temporary, path)
        temporary = None
        actual = subprocess.run(["nix", "eval", "--raw", "--no-write-lock-file", f".#{name}.version"],
                                cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip()
        if actual != version:
            raise ValueError(f"evaluated version {actual!r} does not match {version!r}")
    except BaseException:
        path.write_bytes(original)
        raise
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(f"{name}: updated {current['version']} -> {version}")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("expected one package name")
        update(sys.argv[1])
    except Exception as exc:
        print(f"ArtCraft updater: {exc}", file=sys.stderr)
        sys.exit(1)
