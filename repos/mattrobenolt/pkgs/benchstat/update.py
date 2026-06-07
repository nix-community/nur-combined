#!/usr/bin/env python3
"""Update benchstat package."""

import re
import subprocess
import sys
from pathlib import Path
from typing import NoReturn

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from updater import fetch_json

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
PACKAGE_FILE = SCRIPT_DIR / "package.nix"
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
OWNER = "golang"
REPO = "perf"
BRANCH = "master"


def die(message: str) -> NoReturn:
    raise SystemExit(message)


def run(command: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=check,
    )


def prefetch_source(rev: str) -> str:
    url = f"https://github.com/{OWNER}/{REPO}/archive/{rev}.tar.gz"
    raw = run(["nix-prefetch-url", "--unpack", url]).stdout.strip()
    return run(["nix", "hash", "to-sri", "--type", "sha256", raw]).stdout.strip()


def latest_commit() -> tuple[str, str]:
    commit = fetch_json(f"https://api.github.com/repos/{OWNER}/{REPO}/commits/{BRANCH}")
    rev = commit["sha"]
    date = commit["commit"]["committer"]["date"][:10]
    return rev, date


def replace_attr(text: str, attr: str, value: str) -> str:
    pattern = rf'({attr} = )"[^"]+";'
    new_text, count = re.subn(pattern, rf'\1"{value}";', text, count=1)
    if count != 1:
        die(f"Could not replace {attr} in {PACKAGE_FILE}")
    return new_text


def replace_vendor_hash(text: str, value: str) -> str:
    new_text, count = re.subn(
        r'(vendorHash = )(?:"[^"]+"|lib\.fakeHash);',
        rf'\1"{value}";',
        text,
        count=1,
    )
    if count != 1:
        die(f"Could not replace vendorHash in {PACKAGE_FILE}")
    return new_text


def vendor_hash_from_build() -> str:
    result = run(["nix", "build", ".#benchstat"], check=False)
    output = result.stdout + result.stderr
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", output)
    if not match:
        print(output, file=sys.stderr)
        die("Could not find vendorHash in nix build output")
    return match.group(1)


def main() -> None:
    latest_rev, latest_date = latest_commit()
    text = PACKAGE_FILE.read_text()
    current_rev_match = re.search(r'rev = "([^"]+)";', text)
    if not current_rev_match:
        die(f"Could not find rev in {PACKAGE_FILE}")
    current_rev = current_rev_match.group(1)

    print(f"Current: {current_rev}")
    print(f"Latest:  {latest_rev}")
    if current_rev == latest_rev:
        print("Already up to date")
        return

    source_hash = prefetch_source(latest_rev)
    text = replace_attr(text, "version", f"unstable-{latest_date}")
    text = replace_attr(text, "rev", latest_rev)
    text = replace_attr(text, "hash", source_hash)
    text = replace_vendor_hash(text, FAKE_HASH)
    PACKAGE_FILE.write_text(text)

    vendor_hash = vendor_hash_from_build()
    PACKAGE_FILE.write_text(replace_vendor_hash(PACKAGE_FILE.read_text(), vendor_hash))
    print(f"Updated benchstat to {latest_rev} ({latest_date})")


if __name__ == "__main__":
    main()
