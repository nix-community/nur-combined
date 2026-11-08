#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" && [[ -f "$repo_root/by-name/br/brave-origin-bin/upstream.nix" ]]; then
  upstream_nix="$repo_root/by-name/br/brave-origin-bin/upstream.nix"
elif [[ -f "$script_dir/upstream.nix" ]]; then
  upstream_nix="$script_dir/upstream.nix"
elif [[ -f "$script_dir/../brave-origin-bin/upstream.nix" ]]; then
  upstream_nix="$script_dir/../brave-origin-bin/upstream.nix"
elif [[ -f "by-name/br/brave-origin-bin/upstream.nix" ]]; then
  upstream_nix="$(pwd)/by-name/br/brave-origin-bin/upstream.nix"
else
  echo "Error: Could not locate upstream.nix" >&2
  exit 1
fi

current_rev="$(sed -nE 's/^[[:space:]]*(tag|rev)[[:space:]]*=[[:space:]]*"([^"]+)";/\2/p' "$upstream_nix")"
if [[ -z "$current_rev" ]]; then
  echo "Error: Could not determine current rev from $upstream_nix" >&2
  exit 1
fi

target_rev="${1:-}"

if [[ -z "$target_rev" ]]; then
  echo "Fetching latest upstream commit for buckley310/brave-browser-nix on codeberg.org..."
  target_rev="$(
    git ls-remote https://codeberg.org/buckley310/brave-browser-nix.git refs/heads/main \
      | awk '{print $1}'
  )"
fi

if [[ -z "$target_rev" ]]; then
  echo "Error: Could not determine latest rev" >&2
  exit 1
fi

echo "Current rev: $current_rev"
echo "Target rev:  $target_rev"

if [[ "$current_rev" == "$target_rev" ]]; then
  echo "brave-origin-bin is already up to date ($current_rev)."
  exit 0
fi

echo "Updating brave-origin-bin from $current_rev to $target_rev..."

archive_url="https://codeberg.org/buckley310/brave-browser-nix/archive/${target_rev}.tar.gz"
raw_hash="$(nix-prefetch-url --unpack "$archive_url")"
new_hash="$(nix hash convert --hash-algo sha256 --to sri "$raw_hash")"

cat <<EOF > "$upstream_nix"
{ fetchFromGitea }:

fetchFromGitea {
  domain = "codeberg.org";
  owner = "buckley310";
  repo = "brave-browser-nix";
  rev = "${target_rev}";
  hash = "${new_hash}";
}
EOF

echo "Successfully updated brave-origin-bin to ${target_rev} (${new_hash})"
