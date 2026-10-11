#!/usr/bin/env -S nix shell -L nixpkgs#python3 -c bash
# shellcheck shell=bash
set -euo pipefail

# Refresh update units: for each unit run its nvfetcher sources first, then its
# passthru.updateScript. This is the per-package CI entry point and the local
# one-stop updater.
#
# Usage:
#   run-update-scripts.sh [--list] [attr ...]   # no attrs = all units
#
# --list prints the selected unit names as a JSON array (for GitHub Actions matrices).
#
# Mirrors the nixpkgs maintainers/scripts/update.nix contract: the command comes from
# `updateScript.command or updateScript`, scripts receive UPDATE_NIX_NAME/PNAME/
# OLD_VERSION/ATTR_PATH, and the executor is the update.py of the same pinned nixpkgs.
# Evaluation root is pkgs/: nested nix-update and `nix-build -A` resolve ./default.nix.

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)
cd "$REPO_ROOT"

list_only=false
if [[ ${1-} == "--list" ]]; then
  list_only=true
  shift
fi

NIXPKGS=$(nix eval --raw .#nixpkgs)
export NIX_PATH="nixpkgs=$NIXPKGS"

select='['
for attr in "$@"; do
  select+=" \"$attr\""
done
select+=']'

# Like update.nix's packagesJson, writeText's string context builds every derivation the
# scripts reference (gitUpdater's writeScript, the nix-update binary, ...).
units_json=$(
  nix-build --no-out-link \
    --arg select "$select" \
    -E '{ select }: with import <nixpkgs> { }; writeText "update-units.json" (builtins.toJSON (import ./_scripts/update-scripts.nix { inherit pkgs; inherit select; }))'
)

if $list_only; then
  python3 -c 'import json, sys; print(json.dumps([u["name"] for u in json.load(open(sys.argv[1]))]))' "$units_json"
  exit 0
fi

plan_dir=$(mktemp -d)
# gitUpdater-style scripts write update-git-commits.txt and failure logs into the cwd.
trap 'rm -rf "$plan_dir"; cd "$REPO_ROOT/pkgs" && rm -f update-git-commits.txt ./*.log' EXIT

python3 - "$units_json" "$plan_dir" <<'PY'
import json, sys

units = json.load(open(sys.argv[1]))
out = sys.argv[2]
json.dump([u["update"] for u in units if u["update"] is not None], open(f"{out}/records.json", "w"))
sources = sorted({s for u in units for s in u["sources"]})
open(f"{out}/sources.txt", "w").write("\n".join(sources))
PY

if [[ -s $plan_dir/sources.txt ]]; then
  filter=$(paste -sd'|' "$plan_dir/sources.txt")
  # A filtered run must not drop the extract files of unselected sources; a full run
  # (no selection) keeps today's `just up` semantics, including old-file cleanup.
  keep_old=()
  if [[ $# -gt 0 ]]; then
    keep_old=(--keep-old)
  fi
  nix run -L .#nvfetcher-bin -- "${keep_old[@]}" --filter "^($filter)$"
fi

if [[ $(python3 -c 'import json, sys; print(len(json.load(open(sys.argv[1]))))' "$plan_dir/records.json") != 0 ]]; then
  # Script evaluation root is pkgs/.
  cd "$REPO_ROOT/pkgs"
  python3 "$NIXPKGS/maintainers/scripts/update.py" "$plan_dir/records.json" --skip-prompt --max-workers 1
fi
