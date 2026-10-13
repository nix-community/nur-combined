#!/usr/bin/env bash
set -euo pipefail

pname="rea-agents"
pkg_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nix_file="$pkg_dir/default.nix"

for command in curl jq nix perl; do
  if ! command -v "$command" >/dev/null; then
    echo "Required command not found: $command" >&2
    exit 1
  fi
done

curl_args=(--fail --location --retry 3 --silent --show-error)

current="$(perl -ne 'print $1 if /^  version = "([^"]+)";/' "$nix_file")"
latest="$(
  curl "${curl_args[@]}" "https://registry.npmjs.org/$pname/latest" \
    | jq --raw-output --exit-status '.version'
)"

if [[ ! "$latest" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid upstream version: $latest" >&2
  exit 1
fi

if [[ "$latest" == "$current" ]]; then
  echo "$pname is up to date ($current)"
  exit 0
fi

tarball_url="https://registry.npmjs.org/$pname/-/$pname-$latest.tgz"
lock_url="https://raw.githubusercontent.com/morluto/rea/$pname-$latest/package-lock.json"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# The npm tarball has no lockfile; the matching release tag must provide one.
curl "${curl_args[@]}" --output "$work_dir/package-lock.json" "$lock_url"

src_hash="$(nix store prefetch-file --json "$tarball_url" | jq --raw-output --exit-status '.hash')"
lock_hash="$(nix store prefetch-file --json "$lock_url" | jq --raw-output --exit-status '.hash')"
deps_hash="$(
  nix shell nixpkgs#prefetch-npm-deps --command \
    prefetch-npm-deps "$work_dir/package-lock.json" 2>/dev/null | tail -n 1
)"

for hash in "$src_hash" "$lock_hash" "$deps_hash"; do
  if [[ ! "$hash" =~ ^sha256-[A-Za-z0-9+/=]+$ ]]; then
    echo "Invalid hash: $hash" >&2
    exit 1
  fi
done

perl -0pi -e 's/(\n  version = ")[^"]+(";)/${1}'"$latest"'${2}/' "$nix_file"
perl -0pi -e 's|(\.tgz";\n    sha256 = ")[^"]+(";)|${1}'"$src_hash"'${2}|' "$nix_file"
perl -0pi -e 's|(package-lock\.json";\n    sha256 = ")[^"]+(";)|${1}'"$lock_hash"'${2}|' "$nix_file"
perl -0pi -e 's|(npmDepsHash = ")[^"]+(";)|${1}'"$deps_hash"'${2}|' "$nix_file"

echo "Updated $pname $current -> $latest"
