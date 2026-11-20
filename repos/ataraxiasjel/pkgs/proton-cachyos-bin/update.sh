attr="${UPDATE_NIX_ATTR_PATH:?run this through maintainers/scripts/update.nix}"
oldVersion="${UPDATE_NIX_OLD_VERSION:?run this through maintainers/scripts/update.nix}"

version="$(curl -fsSL "https://api.github.com/repos/CachyOS/proton-cachyos/releases" \
  | jq -er 'map(select(.prerelease == false and (.tag_name | startswith("cachyos-") and endswith("-slr"))))
    | .[0].tag_name | ltrimstr("cachyos-") | rtrimstr("-slr")')"

if [[ -z "$version" || "$version" == null ]]; then
  echo "$attr: could not determine the latest version" >&2
  exit 1
fi
if [[ "$version" == "$oldVersion" ]]; then
  echo "$attr: already at the latest version $version" >&2
  exit 0
fi

# The default package owns the x86_64 and arm64 sources; the v3 package
# owns the x86_64-v3 source. update-source-version patches both the
# version and the matching hash in this file.
update-source-version "pkgsCross.gnu64.proton-cachyos-bin" "$version" --ignore-same-version
update-source-version "pkgsCross.aarch64-multiplatform.proton-cachyos-bin" "$version" --ignore-same-version
update-source-version "pkgsCross.gnu64.proton-cachyos-bin-v3" "$version" --ignore-same-version
