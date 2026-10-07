"""Select a GitHub release and let nix-update update the package source pins."""

import argparse
import os
import subprocess

from .github import release_version


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--owner", required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--attribute", required=True)
    parser.add_argument("--tag-pattern", required=True)
    parser.add_argument("--prerelease", action="store_true")
    parser.add_argument(
        "extra_args", nargs=argparse.REMAINDER, help="Arguments for nix-update after --"
    )
    args = parser.parse_args()

    version = release_version(
        args.owner, args.repo, args.tag_pattern, prerelease=args.prerelease
    )
    attribute = os.environ.get("UPDATE_NIX_ATTR_PATH", args.attribute)
    extra_args = args.extra_args
    if extra_args and extra_args[0] == "--":
        extra_args = extra_args[1:]
    command = ["nix-update", attribute, f"--version={version}", *extra_args]
    subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
