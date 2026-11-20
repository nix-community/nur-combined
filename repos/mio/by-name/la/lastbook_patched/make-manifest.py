#!/usr/bin/env python3
"""Write manifest-v1.json for lastbook_patched: upstream's manifest plus the
Australian region maps from the review release PR #38 links to.

Usage: make-manifest.py <AUSTRALIA-STATE-REVIEW-BUILD.json>

Those maps are GitHub release assets, which is why this variant also carries
0002-review-download-hosts.patch. Every file is still verified against the
SHA-256 recorded here, and the upstream packs/models/state maps are untouched.
"""

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parents[0] / "lastbook" / "manifest-v1.json"
OUT = HERE / "manifest-v1.json"
RELEASE = (
    "https://github.com/pilkster/lastbook/releases/download/"
    "australia-state-maps-review-2026-11-17"
)
TITLES = {
    "au-act": "Australian Capital Territory",
    "au-nsw": "New South Wales",
    "au-nt": "Northern Territory",
    "au-qld": "Queensland",
    "au-sa": "South Australia",
    "au-tas": "Tasmania",
    "au-vic": "Victoria",
    "au-wa": "Western Australia",
}
INCLUDES = "Local streets, buildings, water and mapped help points"


def main(review_path):
    base = json.loads(BASE.read_text(encoding="utf-8"))
    review = json.loads(Path(review_path).read_text(encoding="utf-8"))

    maps = [m for m in base["maps"] if not str(m["id"]).startswith("au-")]
    for m in review["maps"]:
        code = m["code"]
        maps.append(
            {
                "id": code,
                "title": TITLES[code],
                "kind": "region",
                "country": "Australia",
                "includes": INCLUDES,
                "installed_bytes": m["installed_bytes"],
                "available": True,
                "files": [
                    {
                        "name": m["zip"],
                        "url": f"{RELEASE}/{m['zip']}",
                        "size": m["zip_bytes"],
                        "sha256": m["sha256"],
                        "kind": "zip",
                    }
                ],
            }
        )

    base["maps"] = maps
    if review.get("built"):
        base["published"] = review["built"][:10]
    OUT.write_text(json.dumps(base, indent=1) + "\n", encoding="utf-8")
    print(f"wrote {OUT.name}: {len(base['packs'])} packs, {len(maps)} maps")


if __name__ == "__main__":
    main(sys.argv[1])
