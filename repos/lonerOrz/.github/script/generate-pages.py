#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent

DIST_DIR = ROOT / "dist"

DIST_DIR.mkdir(exist_ok=True)

NIX_EXPR = r"""
let
  pkgs = import <nixpkgs> {};

  nur = import ./. { inherit pkgs; };

  names = builtins.attrNames nur;

  safe = x:
    if builtins.isString x then x
    else if builtins.isBool x then x
    else if builtins.isInt x then x
    else if builtins.isFloat x then x
    else if builtins.isList x then map safe x
    else if builtins.isAttrs x then
      builtins.mapAttrs (_: safe) x
    else
      builtins.toString x;

in

map
  (name:
    let
      drv = nur.${name};
    in {
      inherit name;

      pname =
        drv.pname or name;

      version =
        drv.version or "unknown";

      description =
        drv.meta.description or "";

      homepage =
        drv.meta.homepage or "";

      license =
        safe (drv.meta.license or "");

      platforms =
        safe (drv.meta.platforms or []);
    })
  names
"""

print("Evaluating Nix packages...")

result = subprocess.check_output(
    [
        "nix",
        "eval",
        "--json",
        "--impure",
        "--expr",
        NIX_EXPR,
    ],
    cwd=ROOT,
)

packages = json.loads(result)

packages.sort(
    key=lambda pkg: pkg["name"].lower()
)

packages_json = DIST_DIR / "packages.json"

with open(packages_json, "w") as f:
    json.dump(
        packages,
        f,
        indent=2,
        ensure_ascii=False,
    )

print()
print(f"Generated {len(packages)} packages")
print(f"Wrote: {packages_json}")
