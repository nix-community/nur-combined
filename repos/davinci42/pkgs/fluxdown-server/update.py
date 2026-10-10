import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools import maintain


def refresh() -> None:
    folder = Path(__file__).resolve().parent
    version = maintain.run(
        ROOT,
        ["nix", "eval", "-f", ".", "fluxdown-server.version", "--raw"],
        capture=True,
    )
    systems = cast(
        list[str],
        json.loads(
            maintain.run(
                ROOT,
                ["nix", "eval", "-f", ".", "fluxdown-server.meta.platforms", "--json"],
                capture=True,
            )
        ),
    )
    with tempfile.TemporaryDirectory(prefix="fluxdown-release-") as temporary:
        _ = maintain.run(
            ROOT,
            [
                "gh",
                "release",
                "download",
                "v" + version,
                "--repo",
                "zerx-lab/FluxDown",
                "--pattern",
                "SHA256SUMS-server.txt",
                "--dir",
                temporary,
            ],
        )
        manifest = (Path(temporary) / "SHA256SUMS-server.txt").read_text()
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
                            f'let pkgs = import <nixpkgs> {{ system = "{system}"; }}; src = (import ./. {{ inherit pkgs; }}).fluxdown-server.src; in {{ inherit (src) url outputHash; }}',
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
            expected = next(
                (
                    line.split()[0]
                    for line in manifest.splitlines()
                    if len(line.split()) == 2
                    and line.split()[-1].lstrip("*") == filename
                ),
                None,
            )
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
    schema = folder / "settings-schema.json"
    before = cast(dict[str, object], json.loads(schema.read_text()))
    _ = subprocess.run(
        [sys.executable, str(folder / "update-settings.py")], cwd=ROOT, check=True
    )
    after = cast(dict[str, object], json.loads(schema.read_text()))
    _ = before.pop("version", None)
    _ = after.pop("version", None)
    if before != after and os.environ.get("NUR_ACCEPT_CONTRACT") != "1":
        raise ValueError(
            "FluxDown contract changed; review and run just update-reviewed fluxdown-server "
            + version
        )


def main() -> None:
    folder = Path(__file__).resolve().parent
    saved = {
        name: (folder / name).read_bytes()
        for name in ("default.nix", "settings-schema.json")
    }
    command = [
        "nix-update",
        "-f",
        ".",
        "fluxdown-server",
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
        for name, content in saved.items():
            _ = (folder / name).write_bytes(content)
        raise


if __name__ == "__main__":
    main()
