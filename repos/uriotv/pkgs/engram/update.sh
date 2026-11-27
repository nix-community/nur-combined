#!/usr/bin/env bash
set -euo pipefail

pkg_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$pkg_dir/../.." && pwd)"

for command in curl python3; do
  command -v "$command" >/dev/null || { echo "Required command not found: $command" >&2; exit 1; }
done

curl_args=(--fail --silent --show-error --location --retry 3
  --header 'Accept: application/vnd.github+json')
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi

# Upstream tags unrelated release lines (e.g. pi-v0.8.0) on the same repository,
# so the version is chosen explicitly instead of taking "the latest tag".
version="$(curl "${curl_args[@]}" \
  'https://api.github.com/repos/Gentleman-Programming/engram/releases?per_page=100' \
  | python3 -B "$pkg_dir/latest-release.py")"

current="$(nix eval --raw --no-write-lock-file "path:$repo_root#engram.version")"
if [[ "$version" == "$current" ]]; then
  echo "engram is up to date ($current)"
  exit 0
fi
if ! python3 -c 'import sys; sys.exit(0 if tuple(map(int, sys.argv[1].split("."))) > tuple(map(int, sys.argv[2].split("."))) else 1)' \
  "$version" "$current"; then
  echo "engram: upstream release $version is not newer than $current; not downgrading" >&2
  exit 1
fi

cd "$repo_root"
# Builds from the tag's source: nix-update refreshes the source hash and the
# vendor hash together, so both stay consistent with the version.
nix-update --flake engram --version "$version"
