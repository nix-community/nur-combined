# Strict shared helpers sourced by package pin updaters.

# Print one crate2nix crate block through `resolvedDefaultFeatures`.
_pin_crate_block() {
  local cargo_nix=$1 crate=$2
  awk -v crate="$crate" '
    {
      s = $0
      sub(/^[[:space:]]+/, "", s)
      plain = "\"" crate "\" = rec {"
      versioned = "\"" crate " "
      if (!inblock && (substr(s, 1, length(plain)) == plain ||
          (substr(s, 1, length(versioned)) == versioned && s ~ /" = rec \{$/))) {
        count++
        inblock = 1
      }
    }
    inblock { print }
    inblock && /resolvedDefaultFeatures/ { inblock = 0 }
    END {
      if (count == 0) {
        print "ERROR: crate \"" crate "\" not found in " FILENAME > "/dev/stderr"
        exit 1
      }
      if (count > 1) {
        print "ERROR: multiple definitions of crate \"" crate "\" in " FILENAME > "/dev/stderr"
        exit 1
      }
    }
  ' "$cargo_nix"
}

# pin_crate_version <Cargo.nix> <crate> -> crate version on stdout
pin_crate_version() {
  local version
  version=$(
    _pin_crate_block "$1" "$2" |
      sed -n 's/^[[:space:]]*version = "\([^"]*\)";$/\1/p' |
      head -n 1
  )
  if [[ -z $version ]]; then
    echo "ERROR: no version found for crate \"$2\" in $1" >&2
    return 1
  fi
  printf '%s\n' "$version"
}

# pin_crate_resolved_features <Cargo.nix> <crate> -> space-separated features
pin_crate_resolved_features() {
  _pin_crate_block "$1" "$2" |
    sed -n 's/^[[:space:]]*resolvedDefaultFeatures = \[\(.*\)\];$/\1/p' |
    tr -d '"' |
    tr -s ' '
}

# pin_gh_release_assets <owner/repo> <tag> -> tab-separated release assets
pin_gh_release_assets() {
  local repo=$1 tag=$2
  local -a headers=(-H "Accept: application/vnd.github+json")
  local token=${GITHUB_TOKEN:-${GH_TOKEN:-}}
  if [[ -n $token ]]; then
    headers+=(-H "Authorization: Bearer $token")
  fi
  local url="https://api.github.com/repos/${repo}/releases/tags/${tag}"
  local body
  if ! body=$(curl -fsSL --retry 3 "${headers[@]}" "$url"); then
    echo "ERROR: GitHub API request failed: $url" >&2
    return 1
  fi
  local assets
  if ! assets=$(jq -r '.assets[] | [.name, .browser_download_url] | @tsv' <<<"$body"); then
    echo "ERROR: could not parse assets of release $tag of $repo" >&2
    return 1
  fi
  if [[ -z $assets ]]; then
    echo "ERROR: release $tag of $repo has no assets" >&2
    return 1
  fi
  printf '%s\n' "$assets"
}

# pin_match_asset <regex> -> exactly one matching asset line
pin_match_asset() {
  local pattern=$1 matches count
  matches=$(grep -E "$pattern" || true)
  count=0
  [[ -n $matches ]] && count=$(printf '%s\n' "$matches" | grep -c .)
  if [[ $count -ne 1 ]]; then
    echo "ERROR: expected exactly one asset matching /$pattern/, found $count" >&2
    [[ -n $matches ]] && printf '%s\n' "$matches" >&2
    return 1
  fi
  printf '%s\n' "$matches"
}

# pin_prefetch_sri <url> -> SRI hash on stdout; fails on empty/missing hash
pin_prefetch_sri() {
  local url=$1 hash
  if ! hash=$(nix store prefetch-file --json "$url" | jq -r '.hash // empty'); then
    echo "ERROR: nix store prefetch-file failed for $url" >&2
    return 1
  fi
  if [[ -z $hash ]]; then
    echo "ERROR: empty hash for $url" >&2
    return 1
  fi
  printf '%s\n' "$hash"
}

# pin_write_json <path> <json> -> atomically write canonical changed JSON
pin_write_json() {
  local path=$1 json=$2 new tmp
  if ! new=$(jq -S . <<<"$json"); then
    echo "ERROR: pin_write_json got invalid JSON for $path" >&2
    return 1
  fi
  if [[ -f $path ]]; then
    local old
    if ! old=$(jq -S . <"$path"); then
      echo "ERROR: existing $path is not valid JSON" >&2
      return 1
    fi
    if [[ $old == "$new" ]]; then
      echo "$path: unchanged"
      return 0
    fi
  fi
  tmp=$(mktemp "$(dirname "$path")/.$(basename "$path").XXXXXX")
  printf '%s\n' "$new" >"$tmp"
  mv "$tmp" "$path"
  echo "$path: updated"
}
