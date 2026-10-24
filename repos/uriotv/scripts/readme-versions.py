#!/usr/bin/env python3
"""Keep the Version column of the README package table in sync with the registry.

Usage:
  readme-versions.py --write [--manifest FILE] [--readme FILE]
  readme-versions.py --check [--manifest FILE] [--readme FILE]

Versions come from the CI manifest JSON (`.#ci.x86_64-linux.manifest`, a list of
{name, version}) when --manifest is given, otherwise from a Nix evaluation of the
x86_64-linux package registry. Every registry package must have exactly one row,
and every row must name a registry package; drift in either direction is an error.
"""

import argparse
import json
from pathlib import Path
import subprocess
import sys

REPO_ROOT = Path(__file__).resolve().parents[1]
HEADER = "| Package | Version | Description | Public cache |"
SEPARATOR = "|---|---|---|---|"
VERSIONS_EXPR = "builtins.mapAttrs (_: p: p.version or null)"


class ReadmeError(Exception):
    pass


def load_versions(manifest: Path | None) -> dict[str, str]:
    if manifest is None:
        result = subprocess.run(
            [
                "nix", "eval", "--json", "--no-write-lock-file",
                f"{REPO_ROOT}#ci.x86_64-linux.packages", "--apply", VERSIONS_EXPR,
            ],
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            raise ReadmeError(f"nix eval failed:\n{result.stderr}")
        data = json.loads(result.stdout)
    else:
        data = json.loads(manifest.read_text())
    if isinstance(data, list):
        data = {entry["name"]: entry.get("version") for entry in data}
    if not isinstance(data, dict) or not data:
        raise ReadmeError("package version data is empty or malformed")
    versions = {}
    for name, version in data.items():
        if not isinstance(version, str) or not version or version == "unknown":
            raise ReadmeError(f"{name}: package has no version")
        versions[name] = version
    return versions


def split_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def render(readme: str, versions: dict[str, str]) -> str:
    lines = readme.split("\n")
    try:
        start = lines.index(HEADER)
    except ValueError:
        raise ReadmeError(f"package table header not found: {HEADER}") from None
    if start + 1 >= len(lines) or lines[start + 1] != SEPARATOR:
        raise ReadmeError("package table separator missing or malformed")

    seen = set()
    index = start + 2
    while index < len(lines) and lines[index].startswith("|"):
        cells = split_row(lines[index])
        if len(cells) != 4:
            raise ReadmeError(f"malformed package row: {lines[index]}")
        name = cells[0].strip("`")
        if name not in versions:
            raise ReadmeError(f"{name}: listed in README but not in the package registry")
        if name in seen:
            raise ReadmeError(f"{name}: listed more than once in README")
        seen.add(name)
        cells[1] = f"`{versions[name]}`"
        lines[index] = "| " + " | ".join(cells) + " |"
        index += 1

    missing = sorted(set(versions) - seen)
    if missing:
        raise ReadmeError("missing from the README package table: " + ", ".join(missing))
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="update README in place")
    mode.add_argument("--check", action="store_true", help="fail if README is stale")
    parser.add_argument("--manifest", type=Path, help="CI manifest or name->version JSON")
    parser.add_argument("--readme", type=Path, default=REPO_ROOT / "README.md")
    args = parser.parse_args()

    try:
        current = args.readme.read_text()
        updated = render(current, load_versions(args.manifest))
    except (ReadmeError, OSError, json.JSONDecodeError, KeyError) as error:
        print(f"::error::README versions: {error}", file=sys.stderr)
        return 1

    if args.check:
        if updated != current:
            print(
                "::error::README package versions are stale; "
                "run scripts/readme-versions.py --write",
                file=sys.stderr,
            )
            return 1
        print("README package versions are current.")
    elif updated != current:
        args.readme.write_text(updated)
        print(f"Updated package versions in {args.readme}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
