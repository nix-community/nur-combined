#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix nix-update python3
# shellcheck shell=bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
nix-update "$UPDATE_NIX_ATTR_PATH" --version branch --src-only
nix build ".#${UPDATE_NIX_ATTR_PATH}.src" --no-link
SOURCE=$(nix eval --raw ".#${UPDATE_NIX_ATTR_PATH}.src")
python3 - "$SOURCE" "$SCRIPT_DIR/artifacts.json" <<'PY'
import json
from pathlib import Path
import runpy
import subprocess
import sys

entries = runpy.run_path(str(Path(sys.argv[1]) / "firmware/fetch_artifacts.py"))["INPUTS"]
for entry in entries:
    result = subprocess.check_output(["nix", "store", "prefetch-file", "--json", entry["url"]])
    entry["sha256"] = json.loads(result)["hash"]
Path(sys.argv[2]).write_text(json.dumps(entries, indent=2) + "\n")
PY
nix build ".#${UPDATE_NIX_ATTR_PATH}.firmware" --no-link
