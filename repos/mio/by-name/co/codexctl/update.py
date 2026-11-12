#!/usr/bin/env python3
"""Update codexctl.

Upstream tags are Unix timestamps rather than semantic versions, so nix-update
would write the raw timestamp into `version`. Keep the upstream base version
and use the standard `<base>-unstable-<date>` form instead.
"""
import datetime
from pathlib import Path
import re
import subprocess
import sys

UPSTREAM = "https://github.com/Jayy001/codexctl"


def repo_root() -> Path:
    return Path(
        subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    )


def latest_tag() -> str:
    out = subprocess.check_output(
        ["git", "ls-remote", "--tags", f"{UPSTREAM}.git"],
        text=True,
    )
    tags = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 2 or not parts[1].startswith("refs/tags/"):
            continue
        tag = parts[1][len("refs/tags/") :]
        if tag.isdigit():
            tags.append(tag)
    if not tags:
        raise RuntimeError("No timestamp tags found in Jayy001/codexctl")
    return max(tags, key=int)


def base_version(tag: str) -> str:
    pyproject = subprocess.check_output(
        ["curl", "-fsSL", f"{UPSTREAM.replace('https://github.com', 'https://raw.githubusercontent.com')}/{tag}/pyproject.toml"],
        text=True,
    )
    m = re.search(r'(?m)^version = "([^"]+)"', pyproject)
    if not m:
        raise RuntimeError("Could not find the version in upstream pyproject.toml")
    return m.group(1)


def src_hash(tag: str) -> str:
    url = f"{UPSTREAM}/archive/refs/tags/{tag}.tar.gz"
    raw = subprocess.check_output(
        ["nix-prefetch-url", "--unpack", url], text=True
    ).strip()
    return subprocess.check_output(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw],
        text=True,
    ).strip()


def main() -> int:
    package = repo_root() / "by-name/co/codexctl/package.nix"
    content = package.read_text(encoding="utf-8")

    current = re.search(r'(?m)^\s*tag = "([^"]+)";', content)
    if not current:
        print("Error: could not find the src tag in package.nix", file=sys.stderr)
        return 1
    current_tag = current.group(1)

    tag = sys.argv[1].lstrip("v") if len(sys.argv) > 1 else latest_tag()
    print(f"Current tag: {current_tag}")
    print(f"Target tag:  {tag}")

    if tag == current_tag:
        print("codexctl is already up to date.")
        return 0

    version = base_version(tag)
    date = datetime.datetime.fromtimestamp(
        int(tag), datetime.timezone.utc
    ).strftime("%Y-%m-%d")

    content, n_ver = re.subn(
        r'(?m)^(  version = )"[^"]+";', rf'\g<1>"{version}-unstable-{date}";', content, count=1
    )
    content, n_tag = re.subn(
        r'(?m)^(\s*tag = )"[^"]+";', rf'\g<1>"{tag}";', content, count=1
    )
    content, n_hash = re.subn(
        r'(?m)^(\s*hash = )"[^"]+";', rf'\g<1>"{src_hash(tag)}";', content, count=1
    )
    if (n_ver, n_tag, n_hash) != (1, 1, 1):
        raise RuntimeError(
            f"Failed to update attributes in {package} "
            f"(version={n_ver}, tag={n_tag}, hash={n_hash})"
        )

    package.write_text(content, encoding="utf-8")
    print(f"Updated codexctl to {tag} ({version}-unstable-{date})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
