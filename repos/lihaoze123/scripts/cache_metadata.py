#!/usr/bin/env python3
"""Read Attic metadata without exposing credentials in command arguments."""

import base64
import json
import os
from pathlib import Path
import subprocess
import time
import urllib.error
import urllib.request


def read_token():
    token_file = os.environ.get("ATTIC_TOKEN_FILE")
    return Path(token_file).read_text().strip() if token_file else os.environ.get("ATTIC_TOKEN", "")


def fetch_metadata(store_path, token=None):
    cache_url = os.environ.get("ATTIC_CACHE_URL", "https://cache.chumeng.xyz/nur").rstrip("/")
    store_name = Path(store_path).name
    store_hash = store_name.split("-", 1)[0]
    request = urllib.request.Request(f"{cache_url}/{store_hash}.narinfo")
    token = read_token() if token is None else token
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                fields = {}
                for line in response.read().decode().splitlines():
                    key, separator, value = line.partition(": ")
                    if separator:
                        fields[key] = value
            if fields.get("StorePath") != store_path:
                raise ValueError(f"Cache returned a different store path for {store_path}")
            return fields
        except urllib.error.HTTPError as error:
            if error.code == 404:
                return None
            if error.code < 500 or attempt == 2:
                raise
        except urllib.error.URLError:
            if attempt == 2:
                raise
        time.sleep(attempt + 1)
    raise RuntimeError("Unreachable")


def normalize_hash(value):
    if value.startswith("sha256:"):
        return "sha256-" + base64.b64encode(bytes.fromhex(value[7:])).decode()
    return value


def validate_metadata(store_path, local, remote):
    if remote is None:
        raise ValueError(f"Missing from private cache: {store_path}")
    expected = {
        "StorePath": store_path,
        "NarHash": normalize_hash(local["narHash"]),
        "NarSize": str(local["narSize"]),
        "References": sorted(Path(path).name for path in local["references"]),
    }
    actual = {
        "StorePath": remote["StorePath"],
        "NarHash": normalize_hash(remote["NarHash"]),
        "NarSize": remote["NarSize"],
        "References": sorted(remote.get("References", "").split()),
    }
    if expected != actual:
        raise ValueError(f"Cache metadata differs from the built output: {store_path}")


def verify_paths(paths):
    result = subprocess.check_output(["nix", "path-info", "--json", "--json-format", "1", *paths], text=True)
    metadata = json.loads(result)
    if isinstance(metadata, list):
        metadata = {entry["path"]: entry for entry in metadata}
    for path in paths:
        validate_metadata(path, metadata[path], fetch_metadata(path))
        print(f"Verified private cache metadata: {path}", flush=True)


if __name__ == "__main__":
    import sys

    paths = [line.strip() for line in Path(sys.argv[1]).read_text().splitlines() if line.strip()]
    verify_paths(paths)
