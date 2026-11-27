#!/usr/bin/env python3
"""Pick the newest stable Engram release from the GitHub releases JSON on stdin.

Prints the version without the leading `v`. Upstream also publishes unrelated
`pi-v*` tags on the same repository, so the tag must be a plain `vX.Y.Z` and the
release must not be a draft or prerelease; anything else is ignored rather than
guessed at. Exits nonzero when no such release exists.
"""

import json
import re
import sys

RELEASE_TAG = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")


def latest_stable_version(releases):
    candidates = []
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue

        match = RELEASE_TAG.fullmatch(release.get("tag_name", ""))
        if match is not None:
            candidates.append((tuple(map(int, match.groups())), ".".join(match.groups())))

    if not candidates:
        raise ValueError("No stable Engram release has a vX.Y.Z tag")

    return max(candidates)[1]


def main():
    try:
        print(latest_stable_version(json.load(sys.stdin)))
    except (json.JSONDecodeError, ValueError) as error:
        print(f"engram: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
