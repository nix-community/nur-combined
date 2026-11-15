"""Check or update fixed-output hashes for repository packages."""

import argparse
import hashlib
import json
import shlex
import subprocess
import sys
import tomllib
from pathlib import Path


def run(command: list[str]) -> None:
    print(f"$ {shlex.join(command)}", flush=True)
    subprocess.run(command, check=True)


def cache_key(targets: dict[str, dict[str, str]]) -> str:
    system = subprocess.check_output(
        ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"],
        text=True,
    )
    attributes = {name: target["attribute"] for name, target in targets.items()}
    fields = []
    for name, attribute in attributes.items():
        path = ".".join(json.dumps(part) for part in attribute.split("."))
        fields.append(f"{json.dumps(name)} = packages.{path}.drvPath;")
    output = subprocess.check_output(
        [
            "nix",
            "eval",
            "--json",
            "--no-write-lock-file",
            f".#packages.{system}",
            "--apply",
            "packages: { " + " ".join(fields) + " }",
        ],
        text=True,
    )
    # The store path of this script identifies the checker and the tools it runs.
    checker = str(Path(sys.argv[0]).resolve())
    inputs = json.dumps(
        {"system": system, "checker": checker, "drvs": json.loads(output)},
        sort_keys=True,
    )
    return hashlib.sha256(inputs.encode()).hexdigest()


def main() -> None:
    targets = tomllib.loads(Path("nix/hash-targets.toml").read_text())
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["check", "update", "key"])
    parser.add_argument(
        "packages", nargs="*", help="Packages to process (default: all)"
    )
    args = parser.parse_intermixed_args()
    names = args.packages or list(targets)
    unknown = set(names) - targets.keys()
    if unknown:
        parser.error(f"Unknown packages: {', '.join(sorted(unknown))}")

    try:
        if args.action == "key":
            print(cache_key({name: targets[name] for name in names}))
        elif args.action == "update":
            # nix-update reads the flake source from the store, which lazy trees
            # leave unmaterialized.
            run(["nix", "flake", "archive", "--no-write-lock-file"])
            for name in names:
                target = targets[name]
                run(
                    [
                        "nix-update",
                        "--flake",
                        "--version=skip",
                        "--no-src",
                        "--override-filename",
                        target["filename"],
                        target["attribute"],
                    ]
                )

        else:
            installables = [f".#{targets[name]['attribute']}" for name in names]
            command = ["nix", "build", "--no-link", "--no-write-lock-file"]
            # --rebuild requires valid outputs, including on a clean store.
            run([*command, *installables])
            run([*command, "--rebuild", *installables])
    except subprocess.CalledProcessError as error:
        parser.exit(1, f"Command failed with exit code {error.returncode}.\n")


if __name__ == "__main__":
    main()
