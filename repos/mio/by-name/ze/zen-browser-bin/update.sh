#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  upstream_nix="$repo_root/by-name/ze/zen-browser-bin/upstream.nix"
elif [[ -f "$script_dir/upstream.nix" ]]; then
  upstream_nix="$script_dir/upstream.nix"
elif [[ -f "$script_dir/../zen-browser-bin/upstream.nix" ]]; then
  upstream_nix="$script_dir/../zen-browser-bin/upstream.nix"
else
  echo "Error: Could not locate upstream.nix" >&2
  exit 1
fi

current_rev="$(sed -nE 's/^[[:space:]]*(rev|tag)[[:space:]]*=[[:space:]]*"([^"]+)";/\2/p' "$upstream_nix")"
if [[ -z "$current_rev" ]]; then
  echo "Error: Could not determine current rev from $upstream_nix" >&2
  exit 1
fi

target_rev="${1:-}"

if [[ -z "$target_rev" ]]; then
  echo "Fetching latest upstream commit for 0xc000022070/zen-browser-flake..."
  target_rev="$(
    git ls-remote https://github.com/0xc000022070/zen-browser-flake.git refs/heads/beta \
      | awk '{print $1}'
  )"
  if [[ -z "$target_rev" ]]; then
    target_rev="$(
      git ls-remote https://github.com/0xc000022070/zen-browser-flake.git HEAD \
        | awk '{print $1}'
    )"
  fi
fi

if [[ -z "$target_rev" ]]; then
  echo "Error: Could not determine latest rev" >&2
  exit 1
fi

echo "Current rev: $current_rev"
echo "Target rev:  $target_rev"

if [[ "$current_rev" == "$target_rev" ]]; then
  echo "zen-browser-bin is already up to date ($current_rev)."
  exit 0
fi

echo "Updating zen-browser-bin from $current_rev to $target_rev..."

archive_url="https://github.com/0xc000022070/zen-browser-flake/archive/${target_rev}.tar.gz"
raw_hash="$(nix-prefetch-url --unpack "$archive_url")"
new_hash="$(nix hash convert --hash-algo sha256 --to sri "$raw_hash")"

cat <<EOF > "$upstream_nix"
{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "0xc000022070";
  repo = "zen-browser-flake";
  rev = "${target_rev}";
  hash = "${new_hash}";
}
EOF

echo "Successfully updated zen-browser-bin to ${target_rev} (${new_hash})"
