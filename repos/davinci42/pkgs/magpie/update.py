import hashlib
import json
import os
import sys
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools import maintain


def refresh() -> None:
    folder = Path(__file__).resolve().parent
    version = maintain.run(
        ROOT,
        ["nix", "eval", "-f", ".", "magpie.version", "--raw"],
        capture=True,
    )
    systems = cast(
        list[str],
        json.loads(
            maintain.run(
                ROOT,
                ["nix", "eval", "-f", ".", "magpie.meta.platforms", "--json"],
                capture=True,
            )
        ),
    )
    release = cast(
        dict[str, object],
        json.loads(
            maintain.run(
                ROOT,
                [
                    "gh",
                    "release",
                    "view",
                    "v" + version,
                    "--repo",
                    "yetone/magpie-releases",
                    "--json",
                    "assets",
                ],
                capture=True,
            )
        ),
    )
    digests = {
        cast(str, item["name"]): cast(str, item.get("digest", "")).removeprefix(
            "sha256:"
        )
        for item in cast(list[dict[str, object]], release["assets"])
        if isinstance(item.get("name"), str)
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
                        f'let pkgs = import <nixpkgs> {{ system = "{system}"; }}; src = (import ./. {{ inherit pkgs; }}).magpie.src; in {{ inherit (src) url outputHash; }}',
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
        if expected:
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
    target_file = Path(__file__).resolve().parent / "default.nix"
    saved = target_file.read_bytes()
    command = [
        "nix-update",
        "-f",
        ".",
        "magpie",
        "--use-github-releases",
        "--no-src",
    ]
    target = os.environ.get("NUR_TARGET_VERSION")
    if target:
        command.append("--version=" + target)
    command.extend(sys.argv[1:])
    detecting = os.environ.get("NUR_DETECT_VERSION") == "1"
    if detecting:
        command.append("--src-only")
    try:
        _ = maintain.run(ROOT, command)
        if not detecting:
            refresh()
    except BaseException:
        _ = target_file.write_bytes(saved)
        raise


if __name__ == "__main__":
    main()
