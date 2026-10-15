#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nix-update gnused gawk coreutils curl
# shellcheck shell=bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
package=redrix-coreboot
path="pkgs/$package/default.nix"

# Keep the source and payload pins together, including when fetching fails.
backup=$(mktemp)
cp "$path" "$backup"
cleanup() {
  status=$?
  if (( status != 0 )); then
    cp "$backup" "$path"
    echo "Update failed; restored the original coreboot and EDK2 pins." >&2
  fi
  rm -f "$backup"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

nix-update --flake --version=branch=my --src-only "$package"
revision=$(nix eval --raw ".#$package.src.rev")
version=$(bash tasks/firmware-version.sh "$package" "$revision")
sed -i -E "s/^  version = \"[^\"]+\";/  version = \"$version\";/" "$path"
echo "Updated $package to $version"
source=$(nix build --no-link --print-out-paths ".#$package.src")

# Redrix normally inherits MrChromebox's default. Honor an explicit board pin
# as well; read the selected reference from the immutable coreboot source.
selector=$(sed -nE 's/^CONFIG_EDK2_TAG_OR_REV="([^"]+)"$/\1/p' \
  "$source/configs/adl/config.redrix.uefi")
if [[ -z "$selector" ]]; then
  selector=$(sed -nE '/^config EDK2_TAG_OR_REV$/,/^config /{
    s/^[[:space:]]*default "([^"]+)" if EDK2_REPO_MRCHROMEBOX$/\1/p
  }' "$source/payloads/external/edk2/Kconfig")
fi

# Tags can remain readable fetcher pins. Coreboot also accepts branch names
# prefixed by origin; resolve those through GitHub and pin the immutable commit
# because fetchFromGitHub cannot safely fetch a moving branch reference.
if [[ "$selector" =~ ^origin/([[:alnum:]_.-]+(/[[:alnum:]_.-]+)*)$ ]]; then
  branch=${BASH_REMATCH[1]}
  pin=$(curl -fsSL "https://api.github.com/repos/MrChromebox/edk2/branches/$branch" \
    | sed -nE 's/^[[:space:]]*"sha":[[:space:]]*"([[:xdigit:]]{40})",?$/\1/p' \
    | head -n1)
  if [[ ! "$pin" =~ ^[[:xdigit:]]{40}$ ]]; then
    echo "Cannot resolve EDK2 branch $branch to a commit" >&2
    exit 1
  fi
  kind=rev
elif [[ "$selector" =~ ^[[:xdigit:]]{40}$ ]]; then
  pin=$selector
  kind=rev
elif [[ "$selector" =~ ^[[:alnum:]][[:alnum:]._-]*$ ]]; then
  pin=$selector
  kind=tag
else
  echo "Cannot determine a single EDK2 tag or branch from coreboot: $selector" >&2
  exit 1
fi

old_pin=$(sed -nE "/edk2 = fetchFromGitHub/,/^  };/s/^[[:space:]]*(tag|rev) = \"([^\"]+)\";/\2/p" "$path")
old_kind=$(sed -nE "/edk2 = fetchFromGitHub/,/^  };/s/^[[:space:]]*(tag|rev) = \"[^\"]+\";/\1/p" "$path")
if [[ "$pin" != "$old_pin" || "$kind" != "$old_kind" ]]; then
  sed -i -E "/edk2 = fetchFromGitHub/,/^  };/s/^[[:space:]]*(tag|rev) = \"[^\"]+\";/    $kind = \"$pin\";/" "$path"
  nix-update --flake --version=skip --no-src --custom-dep edk2 "$package"
  echo "Updated EDK2 $kind: $old_pin -> $pin"
else
  echo "EDK2 is up to date at $pin ($kind)"
fi
old_selector=$(sed -nE 's/^  edk2Selector = "([^"]+)";$/\1/p' "$path")
if [[ "$selector" != "$old_selector" ]]; then
  sed -i -E "s|^  edk2Selector = \"[^\"]+\";|  edk2Selector = \"$selector\";|" "$path"
  echo "Updated EDK2 configuration reference: $old_selector -> $selector"
fi
