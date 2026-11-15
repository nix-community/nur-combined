"""Check or update fixed-output hashes for repository packages.

Targets are read from nix/hash-targets.toml, in the config format of
merrkry/fod-hash-check: each table has an `installable` and the `file` that
declares its hash.
"""

import argparse
import shlex
import subprocess
import tomllib
from pathlib import Path


def run(command: list[str]) -> None:
    print(f"$ {shlex.join(command)}", flush=True)
    subprocess.run(command, check=True)


def main() -> None:
    targets = tomllib.loads(Path("nix/hash-targets.toml").read_text())
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["check", "update"])
    parser.add_argument(
        "packages", nargs="*", help="Packages to process (default: all)"
    )
    args = parser.parse_intermixed_args()
    names = args.packages or list(targets)
    unknown = set(names) - targets.keys()
    if unknown:
        parser.error(f"Unknown packages: {', '.join(sorted(unknown))}")

    try:
        if args.action == "update":
            attributes = {}
            for name in names:
                installable = targets[name]["installable"]
                # nix-update takes an attribute of the flake in the working
                # directory.
                if not installable.startswith(".#"):
                    parser.error(
                        f"{name}: update needs an installable of the form .#<attribute>"
                    )
                attributes[name] = installable.removeprefix(".#")
            # nix-update reads the flake source from the store, which lazy trees
            # leave unmaterialized.
            run(["nix", "flake", "archive", "--no-write-lock-file"])
            for name in names:
                run(
                    [
                        "nix-update",
                        "--flake",
                        "--version=skip",
                        "--no-src",
                        "--override-filename",
                        targets[name]["file"],
                        attributes[name],
                    ]
                )

        else:
            installables = [targets[name]["installable"] for name in names]
            command = ["nix", "build", "--no-link", "--no-write-lock-file"]
            # --rebuild requires valid outputs, including on a clean store.
            run([*command, *installables])
            run([*command, "--rebuild", *installables])
    except subprocess.CalledProcessError as error:
        parser.exit(1, f"Command failed with exit code {error.returncode}.\n")


if __name__ == "__main__":
    main()
