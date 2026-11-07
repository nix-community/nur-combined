#!/usr/bin/env python3
"""Print the update matrix for the scheduled update workflow.

Packages opt in by exposing passthru.updateScript (so rime-data-flypy is
skipped automatically), and flake.lock inputs are listed too. The optional
TYPES environment variable restricts which kinds are emitted (for example
TYPES=package). Writes matrix and has-updates to GITHUB_OUTPUT.
"""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

from update_lib import write_output

# Only packages that expose an updater are candidates. The changelog is
# recorded before updating so the PR can link a diff from the old release.
NIX_EXPR = """
pkgs:
builtins.listToAttrs
  (builtins.concatMap
    (name:
      let pkg = pkgs.${name}; in
      if pkg ? updateScript
      then [ {
        inherit name;
        value = {
          inherit (pkg) version;
          changelog = pkg.meta.changelog or "";
        };
      } ]
      else [ ])
    (builtins.attrNames
      (builtins.removeAttrs pkgs [ "lib" "modules" "overlays" ])))
"""


def package_versions(system: str) -> dict[str, dict[str, str]]:
    """Map package name -> {version, changelog} for every updatable package."""
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
    types_filter = os.environ.get("TYPES", "").split()
    system = os.environ.get("SYSTEM", "x86_64-linux")

    def wanted(kind: str) -> bool:
        """Whether kind survives the optional TYPES filter."""
        return not types_filter or kind in types_filter

    items: list[dict[str, str]] = []
    if wanted("package"):
        items += [
            {"type": "package", "name": name, **info}
            for name, info in sorted(package_versions(system).items())
            if not packages_filter or name in packages_filter
        ]
    if wanted("flake-input"):
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
