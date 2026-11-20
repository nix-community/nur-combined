attr="${UPDATE_NIX_ATTR_PATH:?run this through maintainers/scripts/update.nix}"
oldVersion="${UPDATE_NIX_OLD_VERSION:?run this through maintainers/scripts/update.nix}"

version="$(curl -fsSL "https://dawn.wine/api/v1/repos/dawn-winery/dwproton/tags?page=1&limit=1" | jq -r .[0].name)"

if [[ -z "$version" || "$version" == null ]]; then
  echo "$attr: could not determine the latest version" >&2
  exit 1
fi
if [[ "$version" == "$oldVersion" ]]; then
  echo "$attr: already at the latest version $version" >&2
  exit 0
fi

update-source-version "pkgsCross.gnu64.dwproton-bin" "$version" --ignore-same-version
