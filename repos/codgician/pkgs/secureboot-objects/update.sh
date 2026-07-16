#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl git jq nix

set -euo pipefail

repo="microsoft/secureboot_objects"
nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/secureboot-objects/default.nix"

releases="$(curl --fail --silent --show-error "https://api.github.com/repos/$repo/releases?per_page=100")"
tag="$(
  jq -r '
    [ .[]
      | select(.draft | not)
      | select(.prerelease | not)
      | select(.tag_name | test("^v[0-9]+(\\.[0-9]+)*-signed$"))
    ]
    | sort_by(.published_at)
    | last
    | .tag_name // empty
  ' <<< "$releases"
)"

if [[ -z "$tag" ]]; then
  echo "No stable signed release found for $repo" >&2
  exit 1
fi

version="${tag#v}"
version="${version%-signed}"

asset_url() {
  jq -r --arg tag "$tag" --arg name "$1" '
    .[]
    | select(.tag_name == $tag)
    | .assets[]
    | select(.name == $name)
    | .browser_download_url
  ' <<< "$releases"
}

signed_url="$(asset_url "edk2-2011-signed-secureboot-binaries.tar.gz")"
optional_url="$(asset_url "edk2-2011-optional-signed-secureboot-binaries.tar.gz")"

if [[ -z "$signed_url" || -z "$optional_url" ]]; then
  echo "Signed release $tag is missing a required tarball" >&2
  exit 1
fi

prefetch() {
  env -u DENDRO_API_KEY nix store prefetch-file --json "$1" | jq -r '.hash'
}

signed_hash="$(prefetch "$signed_url")"
optional_hash="$(prefetch "$optional_url")"
old_version="$(sed -nE 's/^[[:space:]]*version = "([^"]+)";$/\1/p' "$path")"
old_signed_hash="$(sed -nE '/signed = \{/,/\};/s/^[[:space:]]*hash = "([^"]+)";$/\1/p' "$path")"
old_optional_hash="$(sed -nE '/optional = \{/,/\};/s/^[[:space:]]*hash = "([^"]+)";$/\1/p' "$path")"

if [[ "$version" == "$old_version" && "$signed_hash" == "$old_signed_hash" && "$optional_hash" == "$old_optional_hash" ]]; then
  echo "secureboot-objects is up to date at $version"
  exit 0
fi

sed -i -E \
  -e "s|version = \"$old_version\";|version = \"$version\";|" \
  -e "/signed = \{/,/\};/s|hash = \"sha256-[^\"]+\";|hash = \"$signed_hash\";|" \
  -e "/optional = \{/,/\};/s|hash = \"sha256-[^\"]+\";|hash = \"$optional_hash\";|" \
  "$path"

echo "Updated secureboot-objects: $old_version -> $version"
