#!/usr/bin/env -S nix shell -L nixpkgs#python3 -c bash
# shellcheck shell=bash
set -euo pipefail

# Drop artifacts in _sources/ that generated.json no longer references.
#
# Filtered nvfetcher runs need --keep-old so the extract files of unselected
# sources survive; the flag also keeps superseded artifacts of the selected
# source forever. Mirror the cleanup an unfiltered run performs (delete every
# top-level entry except generated.nix/generated.json and the live references)
# without refetching anything.
#
# Usage: prune-sources.sh [sources-dir]   # defaults to _sources

sources_dir=${1:-_sources}
if [[ ! -d $sources_dir ]]; then
  exit 0
fi

python3 - "$sources_dir" <<'PY'
import json
import os
import shutil
import sys

root = sys.argv[1]
generated = os.path.join(root, "generated.json")
if not os.path.exists(generated):
    sys.exit(0)

keep = {"generated.json", "generated.nix"}
with open(generated) as f:
    for entry in json.load(f).values():
        for path in (entry.get("extract") or {}).values():
            keep.add(path.split("/", 1)[0])
        for lock in (entry.get("cargoLock") or {}).values():
            keep.add(lock[0].split("/", 1)[0])

removed = []
for name in os.listdir(root):
    if name in keep:
        continue
    path = os.path.join(root, name)
    if os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path)
    else:
        os.remove(path)
    removed.append(name)

if removed:
    print(f"Pruned {len(removed)} stale source artifact(s) from {root}: {' '.join(sorted(removed))}")
PY
