#!/usr/bin/env python3
"""Update archivetune and the core/lyrics submodule pins recorded in package.nix.

`nix-update` handles the app version and source hash; the two submodules are not
reachable as flake attributes, so their commits are read from the tagged tree on
GitHub and written back here.
"""

import json
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

# The script is copied into the Nix store, so resolve package.nix from the work tree.
PKG = Path.cwd() / "by-name" / "ar" / "archivetune" / "package.nix"
SUBMODULES = {"coreSrc": "core", "lyricsSrc": "lyrics"}


def run(*args):
    return subprocess.run(args, check=True, text=True, capture_output=True).stdout


def sri_hash(url):
    base32 = run("nix-prefetch-url", "--unpack", url).strip().splitlines()[-1]
    return run(
        "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32
    ).strip()


def commit_for(tag, path):
    url = f"https://api.github.com/repos/rukamori/ArchiveTune/contents/{path}?ref={tag}"
    with urllib.request.urlopen(url) as response:
        return json.load(response)["sha"]


def main():
    # UPDATE_NIX_ATTR_PATH (set by the wrapper) names the attribute to update.
    if not os.environ.get("ARCHIVETUNE_SKIP_NIX_UPDATE"):
        subprocess.run(["nix-update", "--flake", *sys.argv[1:]], check=True)

    text = PKG.read_text()
    version = re.search(r'\n\s*version = "([^"]+)";', text).group(1)
    tag = f"v{version}"

    for attr, path in SUBMODULES.items():
        block = re.search(rf"{attr} = fetchFromGitHub \{{.*?\n  \}};", text, re.S).group(0)
        old_rev = re.search(r'rev = "([^"]+)";', block).group(1)
        sha = commit_for(tag, path)
        if sha == old_rev:
            continue
        url = f"https://github.com/rukamori/{path}/archive/{sha}.tar.gz"
        new_block = re.sub(r'rev = "[^"]+";', f'rev = "{sha}";', block)
        new_block = re.sub(r'hash = "[^"]+";', f'hash = "{sri_hash(url)}";', new_block)
        text = text.replace(block, new_block)
        print(f"{attr}: {old_rev} -> {sha}")

    PKG.write_text(text)


if __name__ == "__main__":
    main()
