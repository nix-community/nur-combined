#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
flake_file="$repo_root/flake.nix"
elif [[ -f "$script_dir/../../../flake.nix" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
  flake_file="$repo_root/flake.nix"
else
  echo "Error: Could not locate flake.nix" >&2
  exit 1
fi

current_tag="$(sed -nE 's#^[[:space:]]*url = "github:aaddrick/claude-desktop-debian/([^"]+)";#\1#p' "$flake_file")"
if [[ -z "$current_tag" ]]; then
  echo "Error: Could not determine current tag from $flake_file" >&2
  exit 1
fi

target_tag="${1:-}"

if [[ -z "$target_tag" ]]; then
  echo "Fetching latest upstream tags for aaddrick/claude-desktop-debian..."
  target_tag="$(
    git ls-remote --tags https://github.com/aaddrick/claude-desktop-debian.git \
      | awk '{print $2}' \
      | sed 's#^refs/tags/##' \
      | grep -v '\^{}' \
      | grep -v -E -- '-(dev|rc|alpha|beta)' \
      | sort -V \
      | tail -n 1
  )"
fi

if [[ -z "$target_tag" ]]; then
  echo "Error: Could not determine latest tag" >&2
  exit 1
fi

echo "Current tag: $current_tag"
echo "Target tag:  $target_tag"

if [[ "$current_tag" == "$target_tag" ]]; then
  echo "claude-desktop is already up to date ($current_tag)."
  exit 0
fi

echo "Updating claude-desktop from $current_tag to $target_tag..."

sed -i -E \
  "s#(url = \"github:aaddrick/claude-desktop-debian/)[^\"]+(\";)#\\1${target_tag}\\2#" \
  "$flake_file"

(cd "$repo_root" && nix flake lock --update-input claude-desktop-src)

echo "Successfully updated claude-desktop to ${target_tag}"
