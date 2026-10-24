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
import sys

manifest, = (Path(sys.argv[1]) / "firmware").glob("artifacts-*.json")
entries = json.loads(manifest.read_text())["source_artifacts"]
Path(sys.argv[2]).write_text(json.dumps([entries[0], entries[2]], indent=2) + "\n")
PY
nix build ".#${UPDATE_NIX_ATTR_PATH}.firmware" --no-link
