#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl gawk git gnugrep gnused jq nix nix-prefetch-git
# shellcheck shell=bash

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
package=redrix-ec
path="pkgs/$package/default.nix"

backup=$(mktemp)
cp "$path" "$backup"
cleanup() {
  status=$?
  if (( status != 0 )); then
    cp "$backup" "$path"
    echo "Update failed; restored the original EC source and version." >&2
  fi
  rm -f "$backup"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# nix-update 1.16's flake source-hash prefetch evaluates a generated
# builtins.getFlake store path that is missing under Nix 2.35. Resolve the
# branch and prefetch its immutable revision directly instead.
revision=$(curl --fail --silent --show-error \
  https://api.github.com/repos/codgician/redrix-ec/branches/my \
  | jq -er '.commit.sha | select(test("^[0-9a-f]{40}$"))')
prefetch=$(nix-prefetch-git \
  --url https://github.com/codgician/redrix-ec \
  --rev "$revision" \
  --quiet)
hash=$(jq -er '.hash | select(test("^sha256-[A-Za-z0-9+/]{43}=$"))' <<< "$prefetch")
version=$(bash tasks/firmware-version.sh "$package" "$revision")
[[ "$version" =~ ^[0-9A-Za-z.+-]+$ ]]

# Keep the independent cryptoc pin untouched; change only fetchFromGitHub.
source_fields=$(sed -n '/src = fetchFromGitHub/,/^  };$/p' "$path")
test "$(grep -Ec '^  version = "[^"]+";$' "$path")" = 1
test "$(grep -Ec '^    rev = "[0-9a-f]{40}";$' <<< "$source_fields")" = 1
test "$(grep -Ec '^    hash = "sha256-[^"]+";$' <<< "$source_fields")" = 1
sed -i -E \
  -e "s|^(  version = )\"[^\"]+\";|\1\"$version\";|" \
  -e '/src = fetchFromGitHub/,/^  };$/ { s|^(    rev = )\"[0-9a-f]{40}\";|\1\"'"$revision"'\";|; s|^(    hash = )\"sha256-[^\"]+\";|\1\"'"$hash"'\";|; }' \
  "$path"
echo "Updated $package to $version ($revision)"
