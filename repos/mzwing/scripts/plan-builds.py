#!/usr/bin/env python3
"""Plan distributed package builds for .github/workflows/build.yml.

Reads ALL_TARGETS (a JSON array of {name, system, drvPath, outputName, outputPath})
from the environment, keeps only the 'out' outputs, probes the binary
caches for each remaining output path, validates .github/builders.json,
and writes these outputs to GITHUB_OUTPUT:

  targets     JSON array of targets not found in any binary cache
  builders    {"include": [...]} matrix for the builder job
  has_builds  "true" if any target needs building, otherwise "false"

Non-'out' outputs are excluded from planning on purpose: they are
realised by the same derivation build as 'out' and reach the builder
store cache through the post-build hook, but they are never pushed to
the public caches (their closures would drag the entire build-time
dependency graph into Cachix). Probing for them would therefore always
miss and schedule a perpetual no-op build.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from functools import partial
from pathlib import Path
from typing import Any

BUILDERS_JSON = Path(".github/builders.json")
HTTP_TIMEOUT_SECONDS = 15
ID_PREFIX_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
# Cachix (Cloudflare) blocks urllib's default User-Agent with a 403, so
# identify ourselves explicitly.
USER_AGENT = "nur-ci-plan-builds"


def cache_urls() -> list[str]:
    cache_name = os.environ["CACHE_NAME"]
    return [
        f"https://{cache_name}.cachix.org",
        "https://cache.nixos.org",
        "https://nix-community.cachix.org",
    ]


def store_hash(store_path: str) -> str:
    """Extract the hash part of /nix/store/<hash>-<name>."""
    return os.path.basename(store_path).split("-", maxsplit=1)[0]


def narinfo_status(store_path: str, cache: str) -> bool | None:
    """True: present; False: definitively absent; None: probe failed."""
    narinfo = f"{store_hash(store_path)}.narinfo"
    request = urllib.request.Request(
        f"{cache}/{narinfo}", method="HEAD", headers={"User-Agent": USER_AGENT}
    )
    try:
        with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT_SECONDS):
            return True
    except urllib.error.HTTPError as exc:
        if exc.code in (404, 410):
            return False
        return None
    except (urllib.error.URLError, TimeoutError):
        return None


def is_cached(store_path: str, caches: list[str]) -> bool:
    # Only a definitive 404 from every cache means missing. Cachix sits
    # behind Cloudflare, which intermittently 403/429s HEAD bursts from
    # runner IPs; treating such errors as "missing" schedules thousands of
    # already-cached derivations for a full rebuild. Retry, and if a probe
    # stays inconclusive assume cached: a wrong "cached" merely defers the
    # push until the next run (self-healing), while a wrong "missing"
    # wastes hours of builder time.
    for attempt in range(3):
        if attempt:
            time.sleep(2 * attempt)
        unknown = False
        for cache in caches:
            status = narinfo_status(store_path, cache)
            if status is True:
                return True
            if status is None:
                unknown = True
                break
        if not unknown:
            return False
    print(f"probe inconclusive, assuming cached: {store_path}", file=sys.stderr)
    return True


def load_builder_pools() -> list[dict[str, Any]]:
    """Load and validate .github/builders.json, exiting on invalid config."""
    pools = json.loads(BUILDERS_JSON.read_text(encoding="utf-8"))

    def fail(reason: str) -> None:
        sys.exit(f"Invalid {BUILDERS_JSON} configuration: {reason}")

    if not isinstance(pools, list) or not pools:
        fail("expected a non-empty array")

    for pool in pools:
        if not isinstance(pool.get("system"), str) or not pool["system"]:
            fail(f"pool entries need a non-empty string 'system': {pool!r}")
        id_prefix = pool.get("idPrefix")
        if not isinstance(id_prefix, str) or not ID_PREFIX_PATTERN.match(id_prefix):
            fail(f"'idPrefix' must match {ID_PREFIX_PATTERN.pattern}: {id_prefix!r}")
        if not isinstance(pool.get("runner"), str) or not pool["runner"]:
            fail(f"pool entries need a non-empty string 'runner': {pool!r}")
        for key in ("count", "maxJobs"):
            value = pool.get(key)
            if not isinstance(value, int) or isinstance(value, bool) or value <= 0:
                fail(f"'{key}' must be a positive integer, got {value!r}")

    id_prefixes = [pool["idPrefix"] for pool in pools]
    if len(id_prefixes) != len(set(id_prefixes)):
        fail(f"duplicate 'idPrefix' values: {id_prefixes}")

    return pools


def main() -> None:
    all_targets: list[dict[str, str]] = json.loads(os.environ["ALL_TARGETS"])
    pools = load_builder_pools()

    # See the module docstring: only 'out' outputs are planned.
    all_targets = [t for t in all_targets if t["outputName"] == "out"]

    probe = partial(is_cached, caches=cache_urls())
    with ThreadPoolExecutor() as executor:
        hits = executor.map(probe, (target["outputPath"] for target in all_targets))
        # Keep the same shape and key order the bash/jq version produced.
        targets = [
            {
                key: target[key]
                for key in ("name", "system", "drvPath", "outputName", "outputPath")
            }
            for target, hit in zip(all_targets, hits, strict=True)
            if not hit
        ]

    active_systems = sorted({target["system"] for target in targets})
    pool_systems = {pool["system"] for pool in pools}
    missing = [system for system in active_systems if system not in pool_systems]
    if missing:
        sys.exit(f"No builder pool configured for: {', '.join(missing)}")

    builders = {
        "include": [
            {
                "id": f"{pool['idPrefix']}-{index}",
                "runner": pool["runner"],
                "system": pool["system"],
                "maxJobs": pool["maxJobs"],
            }
            for pool in pools
            if pool["system"] in active_systems
            for index in range(1, pool["count"] + 1)
        ]
    }

    outputs = {
        "builders": json.dumps(builders, separators=(",", ":")),
        "has_builds": "true" if targets else "false",
        "targets": json.dumps(targets, separators=(",", ":")),
    }
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output_file:
        output_file.writelines(f"{key}={value}\n" for key, value in outputs.items())


if __name__ == "__main__":
    main()
