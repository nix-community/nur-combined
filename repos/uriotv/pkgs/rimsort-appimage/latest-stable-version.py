#!/usr/bin/env python3
"""Select the newest stable RimSort release that actually ships an AppImage."""

import json
import re
import sys


RELEASE_TAG = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)$")
ASSET_TEMPLATE = "RimSort-v{version}-x86_64.AppImage"


def latest_stable_version(releases):
    candidates = []
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue

        match = RELEASE_TAG.fullmatch(release.get("tag_name", ""))
        if match is None:
            continue

        version = ".".join(match.groups())
        assets = {asset.get("name") for asset in release.get("assets", [])}
        if ASSET_TEMPLATE.format(version=version) in assets:
            candidates.append((tuple(map(int, match.groups())), version))

    if not candidates:
        raise ValueError("No stable RimSort release with the x86_64 AppImage asset was found")

    return max(candidates)[1]


def main():
    try:
        print(latest_stable_version(json.load(sys.stdin)))
    except (json.JSONDecodeError, ValueError) as error:
        print(f"rimsort-appimage: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
