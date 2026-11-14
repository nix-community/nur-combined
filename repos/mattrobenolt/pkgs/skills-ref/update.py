#!/usr/bin/env python3
"""Update skills-ref package."""

import subprocess
import sys
import tomllib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json, fetch_text, load_hashes, save_if_changed

SCRIPT_DIR = Path(__file__).parent
HASHES_FILE = SCRIPT_DIR / "hashes.json"
REPO = "agentskills/agentskills"
SUBDIR = "skills-ref"


def fetch_latest() -> tuple[str, str]:
    commit = fetch_json(f"https://api.github.com/repos/{REPO}/commits/main")
    rev = commit["sha"]
    date = commit["commit"]["committer"]["date"][:10]
    pyproject = fetch_text(
        f"https://raw.githubusercontent.com/{REPO}/{rev}/{SUBDIR}/pyproject.toml"
    )
    version = tomllib.loads(pyproject)["project"]["version"]
    return f"{version}-unstable-{date}", rev


def prefetch_source(rev: str) -> str:
    url = f"https://github.com/{REPO}/archive/{rev}.tar.gz"
    raw = subprocess.run(
        ["nix-prefetch-url", "--unpack", url],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    return subprocess.run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()


def main() -> None:
    data = load_hashes(HASHES_FILE)
    latest_version, latest_rev = fetch_latest()
    print(
        f"Current: {data['version']} ({data['rev']}), "
        f"Latest: {latest_version} ({latest_rev})"
    )

    if data["rev"] == latest_rev:
        version, rev = data["version"], latest_rev
    else:
        version, rev = latest_version, latest_rev
    payload = {"version": version, "rev": rev, "sourceHash": prefetch_source(rev)}

    if not save_if_changed(HASHES_FILE, payload):
        print("Already up to date")
        return

    if rev != data["rev"]:
        print(f"Updated skills-ref to {version}")
    else:
        print(f"Repaired drifted hashes for skills-ref {version}")


if __name__ == "__main__":
    main()
