#!/usr/bin/env python3
"""Discover the Linux x86_64 APT release and update its Nix source pin."""

import argparse
import gzip
import json
import re
import subprocess
from email.parser import Parser
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.request import Request, urlopen

from components import COMPONENTS, extract_components

# APT release discovery:
# https://github.com/NixOS/nixpkgs/pull/551713/files
REPOSITORY = "https://persistent.oaistatic.com/codex-app-prod/linux/deb"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dpkg-deb", required=True)
    parser.add_argument("--source-file", type=Path, required=True)
    arguments = parser.parse_args()

    request = Request(
        f"{REPOSITORY}/dists/stable/main/binary-amd64/Packages.gz",
        headers={"User-Agent": "chatgpt-nix-updater"},
    )
    with urlopen(request, timeout=60) as response:
        index = gzip.decompress(response.read()).decode()

    packages = [Parser().parsestr(record) for record in index.strip().split("\n\n")]
    releases = [
        package
        for package in packages
        if package["Package"] == "chatgpt" and package["Architecture"] == "amd64"
    ]
    if len(releases) != 1:
        raise ValueError(f"Expected one chatgpt amd64 release, found {len(releases)}")

    release = releases[0]
    version = release["Version"]
    filename = release["Filename"]
    digest = release["SHA256"]
    if not version or not filename or not digest:
        raise ValueError("APT metadata is missing Version, Filename or SHA256")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        raise ValueError(f"Unexpected version: {version}")
    if filename != f"pool/main/c/chatgpt/chatgpt_{version}_amd64.deb":
        raise ValueError(f"Unexpected package filename: {filename}")
    if not re.fullmatch(r"[0-9a-f]{64}", digest):
        raise ValueError(f"Invalid SHA256: {digest}")

    # Verify the archive before updating the pin; the build reuses the store copy.
    prefetch = subprocess.run(
        [
            "nix",
            "--extra-experimental-features",
            "nix-command",
            "store",
            "prefetch-file",
            "--json",
            "--expected-hash",
            digest,
            f"{REPOSITORY}/{filename}",
        ],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    archive = json.loads(prefetch.stdout)

    with TemporaryDirectory() as directory:
        destination = Path(directory)
        extract_components(
            Path(archive["storePath"]), destination, COMPONENTS, arguments.dpkg_deb
        )
        hashes = {}
        for component in COMPONENTS:
            hashes[component] = subprocess.check_output(
                [
                    "nix",
                    "--extra-experimental-features",
                    "nix-command",
                    "hash",
                    "path",
                    str(destination / component),
                ],
                text=True,
            ).strip()

    # Write only after the archive and every component have been verified.
    component_pins = "\n".join(
        f'    {component} = "{hashes[component]}";' for component in COMPONENTS
    )
    source = f'''{{ fetchurl }}:

rec {{
  version = "{version}";
  src = fetchurl {{
    url = "{REPOSITORY}/pool/main/c/chatgpt/chatgpt_${{version}}_amd64.deb";
    hash = "{archive["hash"]}";
  }};

  componentHashes = {{
{component_pins}
  }};
}}
'''
    arguments.source_file.write_text(source)


if __name__ == "__main__":
    main()
