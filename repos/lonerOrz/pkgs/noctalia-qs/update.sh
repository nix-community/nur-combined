#!/usr/bin/env bash
set -euo pipefail

pname="noctalia-qs"
owner="noctalia-dev"
repo="noctalia-qs"
branch="master"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"
workdir="$(mktemp -d)"
build_log="$workdir/build.log"

DUMMY_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

backup="$(mktemp)"
cp "$package_file" "$backup"

rollback() {
  echo "Update failed, rolling back"
  cp "$backup" "$package_file"
}
trap rollback EXIT

echo "Checking latest version"
latest_version=$(curl -sL "https://api.github.com/repos/quickshell-mirror/quickshell/releases/latest" | jq -r '.tag_name')
latest_version="${latest_version#v}"
if [[ -z "$latest_version" ]]; then
  echo "ERROR: Cannot fetch latest version"
  exit 1
fi
echo "Latest version: $latest_version"

echo "Checking latest revision"
latest_rev="$(git ls-remote "https://github.com/${owner}/${repo}.git" "${branch}" | cut -f1)"

if [[ -z "$latest_rev" ]]; then
  echo "ERROR: Cannot fetch latest commit"
  exit 1
fi

current_rev="$(grep -oP 'rev\s*=\s*"\K[^"]+' "$package_file" || true)"
current_version="$(grep -oP 'version\s*=\s*"\K[^"]+' "$package_file" || true)"

echo "Current: rev=$current_rev, version=$current_version"
echo "Latest:  rev=$latest_rev, version=$latest_version"

if [[ "$latest_rev" == "$current_rev" && "$latest_version" == "$current_version" ]]; then
  echo "Already up-to-date"
  trap - EXIT
  rm -f "$backup"
  rm -rf "$workdir"
  exit 0
fi

echo "Update detected"

sed -i -E "s|(version\s*=\s*\")[^\"]*|\1${latest_version}|" "$package_file"
sed -i -E "s|(rev\s*=\s*\")[^\"]*|\1${latest_rev}|" "$package_file"

echo "Updating hash"
sed -i -E "s|(hash\s*=\s*\")[^\"]*|\1${DUMMY_HASH}|" "$package_file"

echo "Building to get hash..."
if nix build "$script_dir/../..#${pname}" 2>"$build_log"; then
  echo "ERROR: Expected build to fail but it succeeded"
  exit 1
fi

new_hash="$(grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$build_log" | head -n1 || true)"

if [[ -z "$new_hash" ]]; then
  echo "ERROR: Cannot extract hash"
  tail -n20 "$build_log"
  exit 1
fi

echo "New hash: $new_hash"
sed -i -E "s|(hash\s*=\s*\")${DUMMY_HASH}|\1${new_hash}|" "$package_file"

# echo "Final build verification"
# nix build "$script_dir/../..#${pname}"

trap - EXIT
rm -f "$backup"
rm -rf "$workdir"

echo "Update completed! version=$latest_version, rev=$latest_rev"
