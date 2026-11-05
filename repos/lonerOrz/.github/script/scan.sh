#!/usr/bin/env bash
# Generates a JSON map of package names to per-system derivation paths.
# Usage: ./scan.sh [target] [--impure]
# Default target: current flake
# Output: JSON to stdout, shaped { pkg: { system: drvPath, ... }, ... }
#   (a package absent on a given system is omitted from that system's map)
#
# Systems are discovered from the flake itself: we scan every system the
# flake declares `packages.<system>` for, so a package is only fingerprinted
# on the systems it can actually be built on (meta.platforms ∩ flake systems).
# A system the target flake does not support (e.g. aarch64-darwin on an
# older base branch) is simply absent from the output rather than erroring.

set -euo pipefail

# scan.sh lives at <repo>/.github/script/scan.sh, so the repo root is two
# levels up. Resolve it absolutely so builtins.getFlake has a stable base.
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

NIX_FLAGS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --impure) NIX_FLAGS="--impure"; export NIXPKGS_ALLOW_UNFREE=1; shift;;
    --) shift; break;;
    *) shift;;
  esac
done

# Unquoted heredoc: bash expands ${REPO_ROOT}, while nix's ${sys}/${n} are
# written as \${...} so they survive literally into the Nix expression.
FILTER_EXPR="$(cat <<NIX
  let
    f = builtins.getFlake "${REPO_ROOT}" ;
    systems = builtins.attrNames (f.packages or {}) ;
    drvOf = sys: pkgs: builtins.mapAttrs
      (n: v: if (v.type or null) == "derivation" then v.drvPath else null) pkgs ;
    perSystem = sys: drvOf sys (f.packages.\${sys} or {}) ;
  in
    builtins.foldl'
      (acc: sys:
        builtins.mapAttrs
          (n: drv: (acc.\${n} or {}) // { "\${sys}" = drv; })
          (perSystem sys))
      {}
      systems
NIX
)"

if [[ "${DEBUG:-}" == "1" ]]; then
  nix eval $NIX_FLAGS --json --expr "$FILTER_EXPR"
else
  nix eval $NIX_FLAGS --json --expr "$FILTER_EXPR" 2>/dev/null
fi
