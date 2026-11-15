#!/usr/bin/env bash
set -euo pipefail

# Authenticate GitHub API calls when CI provides a token: the anonymous limit is
# 60 requests per hour for the whole runner address.
api_auth=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  api_auth=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi
# Launcher releases are distinct from the game's v* tags and prereleases.
latest=$(curl -fsSL --retry 4 --retry-max-time 60 --max-time 30 "${api_auth[@]}" 'https://api.github.com/repos/VlcekM/MeitouClient/releases?per_page=100' \
  | python3 -c 'import json,re,sys; releases=json.load(sys.stdin); versions=[x["tag_name"][len("launcher-v"):] for x in releases if not x["draft"] and not x["prerelease"] and re.fullmatch(r"launcher-v[0-9]+\.[0-9]+\.[0-9]+", x["tag_name"])]; print(max(versions, key=lambda s: tuple(map(int,s.split(".")))) if versions else "")')
[[ -n "$latest" ]] || { echo 'No stable launcher release found' >&2; exit 1; }
current=$(nix eval --raw --no-write-lock-file .#meitou-launcher.version)
if ! python3 -c 'import sys; sys.exit(0 if tuple(map(int,sys.argv[1].split("."))) > tuple(map(int,sys.argv[2].split("."))) else 1)' "$latest" "$current"; then
  echo "meitou-launcher is up to date (pinned $current, latest stable $latest)"
  exit 0
fi

# The package wraps upstream's prebuilt AppImage: only the version and its hash move.
nix-update --flake meitou-launcher --version "$latest"
