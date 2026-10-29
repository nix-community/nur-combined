#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  upstream_nix="$repo_root/by-name/cl/claude-desktop/upstream.nix"
elif [[ -f "$script_dir/upstream.nix" ]]; then
  upstream_nix="$script_dir/upstream.nix"
elif [[ -f "$script_dir/../claude-desktop/upstream.nix" ]]; then
  upstream_nix="$script_dir/../claude-desktop/upstream.nix"
else
  echo "Error: Could not locate upstream.nix" >&2
  exit 1
fi

current_tag="$(sed -nE 's/^[[:space:]]*(tag|rev)[[:space:]]*=[[:space:]]*"([^"]+)";/\2/p' "$upstream_nix")"
if [[ -z "$current_tag" ]]; then
  echo "Error: Could not determine current tag from $upstream_nix" >&2
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

archive_url="https://github.com/aaddrick/claude-desktop-debian/archive/refs/tags/${target_tag}.tar.gz"
raw_hash="$(nix-prefetch-url --unpack "$archive_url")"
new_hash="$(nix hash convert --hash-algo sha256 --to sri "$raw_hash")"

cat <<EOF > "$upstream_nix"
{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "aaddrick";
  repo = "claude-desktop-debian";
  tag = "${target_tag}";
  hash = "${new_hash}";
}
EOF

echo "Successfully updated claude-desktop to ${target_tag} (${new_hash})"
