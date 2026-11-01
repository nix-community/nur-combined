#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix
import json
import pathlib
import subprocess
import urllib.request
import xml.etree.ElementTree as ET

path = pathlib.Path(__file__).with_name("sources.json")
sources = json.loads(path.read_text())
with urllib.request.urlopen(
    "https://github.com/chthollyphile/folia-major/releases.atom"
) as response:
    entry = ET.parse(response).find("{http://www.w3.org/2005/Atom}entry")
tag = entry.find("{http://www.w3.org/2005/Atom}link").attrib["href"].rsplit("/", 1)[1]
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
