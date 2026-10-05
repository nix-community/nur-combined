#!/usr/bin/env python3
"""Print the update matrix for the scheduled update workflow.

Packages opt in by exposing passthru.updateScript (so rime-data-flypy is
skipped automatically), and flake.lock inputs are listed too. Writes
matrix and has-updates to GITHUB_OUTPUT.
"""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

# Only packages that expose an updater are candidates.
NIX_EXPR = """
pkgs:
builtins.listToAttrs
  (builtins.concatMap
    (name:
      let pkg = pkgs.${name}; in
      if pkg ? updateScript
      then [ { inherit name; value = pkg.version; } ]
      else [ ])
    (builtins.attrNames
      (builtins.removeAttrs pkgs [ "lib" "modules" "overlays" ])))
"""


def write_output(key: str, value: str) -> None:
    """Append a key=value pair to GITHUB_OUTPUT, or print it locally."""
    path = os.environ.get("GITHUB_OUTPUT")
    line = f"{key}={value}\n"
    if path:
        with open(path, "a") as handle:
            handle.write(line)
    else:
        print(line, end="")


def package_versions(system: str) -> dict[str, str]:
    """Map package name -> version for every package with an updateScript."""
    result = subprocess.run(
        [
            "nix",
            "eval",
            "--json",
            "--apply",
            NIX_EXPR,
            f".#legacyPackages.{system}",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def flake_inputs() -> list[str]:
    """Return the direct flake inputs declared in the lock file."""
    lock = json.loads(Path("flake.lock").read_text())
    root = lock["nodes"][lock["root"]]
    return sorted(root.get("inputs", {}))


def main() -> None:
    """Build and emit the update matrix."""
    packages_filter = os.environ.get("PACKAGES", "").split()
    inputs_filter = os.environ.get("INPUTS", "").split()
    system = os.environ.get("SYSTEM", "x86_64-linux")

    items = [
        {"type": "package", "name": name, "version": version}
        for name, version in sorted(package_versions(system).items())
        if not packages_filter or name in packages_filter
    ]
    items += [
        {"type": "flake-input", "name": name, "version": ""}
        for name in flake_inputs()
        if not inputs_filter or name in inputs_filter
    ]

    matrix = {"include": items}
    write_output("matrix", json.dumps(matrix, separators=(",", ":")))
    write_output("has-updates", str(bool(items)).lower())
    print(json.dumps(matrix, indent=2))


if __name__ == "__main__":
    main()
