#!/usr/bin/env python3
"""Update the version and flat SHA256 of the repository's binary packages."""

import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
import time
import urllib.error
import urllib.request


FULL_CHECK_INTERVAL = 7 * 24 * 60 * 60
VERSION = re.compile(r'(?m)^(\s*version\s*=\s*")([^"]+)(";)')
HASH = re.compile(r'(?m)^(\s*hash\s*=\s*")([^"]+)(";)')


def read_cache(path, url, now):
    try:
        cache = json.loads(path.read_text())
        digest = base64.b64decode(cache["hash"].removeprefix("sha256-"), validate=True)
        if (
            cache["url"] != url
            or not cache["hash"].startswith("sha256-")
            or len(digest) != 32
            or not 0 <= now - cache["verified_at"] < FULL_CHECK_INTERVAL
            or not all(isinstance(cache.get(key, ""), str) for key in ("etag", "last_modified"))
        ):
            return None
        return cache
    except (OSError, ValueError, KeyError, TypeError, AttributeError):
        return None


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        temporary = Path(file.name)
        try:
            file.write(text)
            file.close()
            if path.exists():
                temporary.chmod(path.stat().st_mode)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def update_source(package_file, version, url, cache_dir, *, force=False, now=None):
    now = time.time() if now is None else now
    text = package_file.read_text()
    versions, hashes = list(VERSION.finditer(text)), list(HASH.finditer(text))
    if len(versions) != 1 or len(hashes) != 1:
        raise ValueError(f"Expected one version and one source hash in {package_file}")
    old_version, old_hash = versions[0][2], hashes[0][2]
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+", version):
        raise ValueError(f"Invalid upstream version: {version}")
    if tuple(map(int, version.split("."))) < tuple(map(int, old_version.split("."))):
        raise ValueError(f"Refusing to downgrade from {old_version} to {version}")
    if url.endswith(".zip"):
        magic = b"PK\x03\x04"
    elif url.endswith(".deb"):
        magic = b"!<arch>\n"
    else:
        raise ValueError(f"Unsupported archive URL: {url}")

    cache_file = cache_dir / (hashlib.sha256(url.encode()).hexdigest() + ".json")
    cache = read_cache(cache_file, url, now)
    # Always revalidate with the server, including its CDN; do not trust a fresh HTTP cache.
    headers = {"Accept-Encoding": "identity", "Cache-Control": "no-cache"}
    if cache and not force and version == old_version:
        etag = cache.get("etag", "")
        if etag.startswith('"') and etag.endswith('"'):
            headers["If-None-Match"] = etag
        elif cache.get("last_modified"):
            headers["If-Modified-Since"] = cache["last_modified"]

    conditional = "If-None-Match" in headers or "If-Modified-Since" in headers
    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            if response.status != 200:
                raise ValueError(f"Expected HTTP 200, got {response.status}")
            digest = hashlib.sha256()
            size = 0
            prefix = b""
            while chunk := response.read(1024 * 1024):
                if not prefix:
                    prefix = chunk[:len(magic)]
                digest.update(chunk)
                size += len(chunk)
            if not prefix.startswith(magic):
                raise ValueError(f"Response is not the expected archive: {url}")
            length = response.headers.get("Content-Length")
            if length is not None and size != int(length):
                raise ValueError(f"Incomplete download: expected {length} bytes, got {size}")
            cache = {
                "url": url,
                "hash": "sha256-" + base64.b64encode(digest.digest()).decode(),
                "etag": response.headers.get("ETag", ""),
                "last_modified": response.headers.get("Last-Modified", ""),
                "verified_at": now,
            }
            print(f"Downloaded {size} bytes; calculated {cache['hash']}")
    except urllib.error.HTTPError as error:
        if error.code != 304 or not conditional:
            raise
        error.close()
        # Keep the full-download timestamp: daily 304 responses must not postpone verification.
        print("HTTP 304: source unchanged; reused cached SHA256 (no archive download)")

    new_hash = cache["hash"]
    updated = VERSION.sub(lambda match: match[1] + version + match[3], text)
    updated = HASH.sub(lambda match: match[1] + new_hash + match[3], updated)
    if updated != text:
        atomic_write(package_file, updated)
        print(f"Updated {package_file}: {old_version} -> {version}; {old_hash} -> {new_hash}")
    else:
        print(f"{package_file.parent.name}: version and source hash unchanged")
    atomic_write(cache_file, json.dumps(cache, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package_file", type=Path)
    parser.add_argument("version")
    parser.add_argument("url")
    args = parser.parse_args()
    cache_root = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    cache_dir = Path(os.environ.get("UPDATE_CACHE_DIR", cache_root / "nur-package-updates"))
    update_source(
        args.package_file,
        args.version,
        args.url,
        cache_dir,
        force=os.environ.get("UPDATE_FORCE_HASH") == "1",
    )


if __name__ == "__main__":
    main()
