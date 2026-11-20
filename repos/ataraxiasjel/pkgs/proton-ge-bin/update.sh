attr="${UPDATE_NIX_ATTR_PATH:?run this through maintainers/scripts/update.nix}"
oldVersion="${UPDATE_NIX_OLD_VERSION:?run this through maintainers/scripts/update.nix}"

version="$(curl -fsSL "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases" \
  | jq -er 'map(select(.prerelease == false)) | .[0].tag_name')"

if [[ -z "$version" || "$version" == null ]]; then
  echo "$attr: could not determine the latest version" >&2
  exit 1
fi
if [[ "$version" == "$oldVersion" ]]; then
  echo "$attr: already at the latest version $version" >&2
  exit 0
fi

update-source-version "pkgsCross.gnu64.proton-ge-bin" "$version" --ignore-same-version
update-source-version "pkgsCross.aarch64-multiplatform.proton-ge-bin" "$version" --ignore-same-version
