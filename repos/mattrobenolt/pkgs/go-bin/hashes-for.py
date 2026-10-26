#!/usr/bin/env python3
"""Print Nix hashes for a Go release published at https://go.dev/dl/."""

import sys
from pathlib import Path
from typing import Any, cast

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, hex_to_sri

PLATFORMS = ("linux-amd64", "linux-arm64", "darwin-amd64", "darwin-arm64")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} VERSION")

    version = sys.argv[1].removeprefix("go")
    releases = cast(
        list[dict[str, Any]], fetch_json("https://go.dev/dl/?mode=json&include=all")
    )
    release = next((r for r in releases if r["version"] == f"go{version}"), None)
    if release is None:
        raise SystemExit(f"Go {version} is not published at https://go.dev/dl/")

    hashes = {
        f"{cast(str, file['os'])}-{cast(str, file['arch'])}": hex_to_sri(
            cast(str, file["sha256"])
        )
        for file in release["files"]
        if file.get("kind") == "archive"
    }

    print("pkgs.go-bin.fromGoRelease {")
    print(f'  version = "{version}";')
    print("  hashes = {")
    for platform in PLATFORMS:
        if platform in hashes:
            print(f'    "{platform}" = "{hashes[platform]}";')
    print("  };")
    print("}")


if __name__ == "__main__":
    main()
