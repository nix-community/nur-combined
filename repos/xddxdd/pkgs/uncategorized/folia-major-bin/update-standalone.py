#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix git
import json
import pathlib
import re
import subprocess

path = pathlib.Path(__file__).with_name("sources.json")
sources = json.loads(path.read_text())
tags = subprocess.check_output(
    [
        "git",
        "ls-remote",
        "--tags",
        "--refs",
        "https://github.com/chthollyphile/folia-major",
    ],
    text=True,
)
tag = max(
    re.findall(r"refs/tags/(v[0-9]+\.[0-9]+\.[0-9]+)$", tags, re.MULTILINE),
    key=lambda tag: tuple(map(int, tag[1:].split("."))),
)
version = tag.removeprefix("v")
for system, arch in {"aarch64-linux": "arm64", "x86_64-linux": "x64"}.items():
    url = (
        f"https://github.com/chthollyphile/folia-major/releases/download/{tag}/"
        f"folia-major-{version}-linux-{arch}.tar.gz"
    )
    result = json.loads(
        subprocess.check_output(["nix", "store", "prefetch-file", "--json", url])
    )
    sources[system] = {"version": version, "url": url, "hash": result["hash"]}
path.write_text(json.dumps(sources, indent=2) + "\n")
for system in sources:
    subprocess.run(
        [
            "nix",
            "build",
            "--builders",
            "",
            "--no-link",
            "--impure",
            "--expr",
            (
                "let flake = builtins.getFlake (toString ./.); "
                f'pkgs = import flake.inputs.nixpkgs {{ system = "{system}"; }}; '
                f"in (pkgs.callPackage {path.parent}/default.nix {{ }}).src"
            ),
        ],
        check=True,
    )
