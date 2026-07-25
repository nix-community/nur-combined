#!/usr/bin/env python3
"""Update qmd source and dependency hashes."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, fetch_text, load_hashes, save_hashes, should_update

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
TARGETS = {
    "aarch64-darwin": ("darwin", "arm64"),
    "aarch64-linux": ("linux", "arm64"),
    "x86_64-linux": ("linux", "x64"),
}


def latest_version_commit() -> tuple[str, str]:
    commits = fetch_json(
        "https://api.github.com/repos/tobi/qmd/commits?path=package.json&per_page=1"
    )
    rev = commits[0]["sha"]
    package = json.loads(
        fetch_text(f"https://raw.githubusercontent.com/tobi/qmd/{rev}/package.json")
    )
    return package["version"], rev


def prefetch_source(rev: str) -> tuple[str, Path]:
    result = subprocess.run(
        [
            "nix",
            "store",
            "prefetch-file",
            "--json",
            "--unpack",
            f"https://github.com/tobi/qmd/archive/{rev}.tar.gz",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    data = json.loads(result.stdout)
    return data["hash"], Path(data["storePath"])


def node_modules_hash(src: Path, os_name: str, cpu: str) -> str:
    with tempfile.TemporaryDirectory() as tmp_name:
        tmp = Path(tmp_name)
        shutil.copy(src / "package.json", tmp)
        shutil.copy(src / "bun.lock", tmp)

        env = os.environ.copy()
        env["HOME"] = str(tmp / "home")
        subprocess.run(
            [
                "bun",
                "install",
                "--backend",
                "copyfile",
                "--frozen-lockfile",
                "--ignore-scripts",
                "--no-progress",
                "--production",
                "--os",
                os_name,
                "--cpu",
                cpu,
            ],
            cwd=tmp,
            env=env,
            check=True,
        )

        output = tmp / "output"
        output.mkdir()
        shutil.move(tmp / "node_modules", output / "node_modules")
        return subprocess.run(
            ["nix", "hash", "path", str(output)],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()


def main() -> None:
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest, rev = latest_version_commit()
    print(f"Current: {current}, Latest: {latest}")

    force = "--force" in sys.argv[1:]
    if not force and not should_update(current, latest):
        print("Already up to date")
        return

    source_hash, src = prefetch_source(rev)
    node_modules_hashes = {
        system: node_modules_hash(src, os_name, cpu)
        for system, (os_name, cpu) in TARGETS.items()
    }
    save_hashes(
        HASHES_FILE,
        {
            "version": latest,
            "rev": rev,
            "sourceHash": source_hash,
            "nodeModulesHashes": node_modules_hashes,
        },
    )
    print(f"Updated qmd to {latest} ({rev[:7]})")


if __name__ == "__main__":
    main()
