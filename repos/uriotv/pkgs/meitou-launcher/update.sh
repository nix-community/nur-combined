#!/usr/bin/env bash
set -euo pipefail

# Launcher releases are distinct from the game's v* tags and prereleases.
latest=$(curl -fsSL 'https://api.github.com/repos/VlcekM/MeitouClient/releases?per_page=100' \
  | python3 -c 'import json,re,sys; releases=json.load(sys.stdin); versions=[x["tag_name"][len("launcher-v"):] for x in releases if not x["draft"] and not x["prerelease"] and re.fullmatch(r"launcher-v[0-9]+\.[0-9]+\.[0-9]+", x["tag_name"])]; print(max(versions, key=lambda s: tuple(map(int,s.split(".")))) if versions else "")')
[[ -n "$latest" ]] || { echo 'No stable launcher release found' >&2; exit 1; }
current=$(nix eval --raw --no-write-lock-file .#meitou-launcher.version)
if ! python3 -c 'import sys; sys.exit(0 if tuple(map(int,sys.argv[1].split("."))) > tuple(map(int,sys.argv[2].split("."))) else 1)' "$latest" "$current"; then
  echo "meitou-launcher is up to date (pinned $current, latest stable $latest)"
  exit 0
fi
nix-update --flake meitou-launcher --version "$latest"
fetch_deps=$(nix build --no-link --print-out-paths --no-write-lock-file .#meitou-launcher.fetch-deps)
"$fetch_deps" pkgs/meitou-launcher/deps.json
