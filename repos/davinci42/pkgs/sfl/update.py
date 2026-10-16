import hashlib
import json
import os
import sys
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools import maintain


def latest_version() -> str:
    tag = maintain.run(
        ROOT,
        [
            "gh",
            "release",
            "list",
            "--repo",
            "SagerNet/sing-box",
            "--limit",
            "1",
            "--json",
            "tagName",
            "--jq",
            ".[0].tagName",
        ],
        capture=True,
    )
    version = tag.removeprefix("v")
    if not version:
        raise ValueError("Empty latest release tag")
    return version


def refresh() -> None:
    folder = Path(__file__).resolve().parent
    version = maintain.run(
        ROOT,
        ["nix", "eval", "-f", ".", "sfl.version", "--raw"],
        capture=True,
    )
    systems = cast(
        list[str],
        json.loads(
            maintain.run(
                ROOT,
                ["nix", "eval", "-f", ".", "sfl.meta.platforms", "--json"],
                capture=True,
            )
        ),
    )
    assets = cast(
        list[dict[str, str]],
        json.loads(
            maintain.run(
                ROOT,
                [
                    "gh",
                    "release",
                    "view",
                    "v" + version,
                    "--repo",
                    "SagerNet/sing-box",
                    "--json",
                    "assets",
                ],
                capture=True,
            )
        )["assets"],
    )
    digests = {
        asset["name"]: asset["digest"].removeprefix("sha256:")
        for asset in assets
        if asset.get("digest", "").startswith("sha256:")
    }
    for system in systems:
        source = cast(
            dict[str, str],
            json.loads(
                maintain.run(
                    ROOT,
                    [
                        "nix",
                        "eval",
                        "--impure",
                        "--json",
                        "--expr",
                        f'let pkgs = import <nixpkgs> {{ system = "{system}"; }}; src = (import ./. {{ inherit pkgs; }}).sfl.src; in {{ inherit (src) url outputHash; }}',
                    ],
                    capture=True,
                )
            ),
        )
        fetched = cast(
            dict[str, str],
            json.loads(
                maintain.run(
                    ROOT,
                    ["nix", "store", "prefetch-file", "--json", source["url"]],
                    capture=True,
                )
            ),
        )
        filename = source["url"].rsplit("/", 1)[-1]
        expected = digests.get(filename)
        if not expected:
            raise ValueError("Missing release digest: " + filename)
        with Path(fetched["storePath"]).open("rb") as archive:
            digest = hashlib.file_digest(archive, "sha256").hexdigest()
        if digest != expected:
            raise ValueError("Release checksum mismatch: " + filename)
        target = folder / "default.nix"
        content = target.read_text()
        if source["outputHash"] != fetched["hash"]:
            if content.count(source["outputHash"]) != 1:
                raise ValueError("Cannot uniquely locate source hash")
            _ = target.write_text(
                content.replace(source["outputHash"], fetched["hash"])
            )


def main() -> None:
    folder = Path(__file__).resolve().parent
    target = folder / "default.nix"
    saved = target.read_bytes()
    version = os.environ.get("NUR_TARGET_VERSION") or latest_version()
    command = [
        "nix-update",
        "-f",
        ".",
        "sfl",
        "--no-src",
        "--version=" + version,
        *sys.argv[1:],
    ]
    detecting = os.environ.get("NUR_DETECT_VERSION") == "1"
    if detecting:
        command.append("--src-only")
    try:
        _ = maintain.run(ROOT, command)
        if not detecting:
            refresh()
    except BaseException:
        _ = target.write_bytes(saved)
        raise


if __name__ == "__main__":
    main()
