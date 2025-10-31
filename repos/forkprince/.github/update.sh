#!/usr/bin/env -S nix shell nixpkgs#curl nixpkgs#jq nixpkgs#nix nixpkgs#coreutils -c bash
set -euo pipefail

# Universal update script for various package types
# Usage: ./update.sh <info.json>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <info.json>"
  echo "Example: $0 modules/universal/system/pkgs/proton-em-bin/info.json"
  exit 1
fi

info="$1"

if [[ ! -f "$info" ]]; then
  echo "⚠️ Error: $info does not exist"
  exit 1
fi

config=$(cat "$info")
update_type=$(jq -r '.update_type // "github"' <<< "$config")
package_name=$(jq -r '.name // "package"' <<< "$config")

echo "📦 Updating $package_name using $info (type: $update_type)"

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: token $GITHUB_TOKEN")
  echo "🔑 Using GITHUB_TOKEN for authentication"
fi

update_github() {
  local repo query version oldVersion releases rawVersion

  repo=$(jq -r '.repo // empty' <<< "$config")
  query=$(jq -r '.query // empty' <<< "$config")
  oldVersion=$(jq -r '.version // empty' <<< "$config")

  if [[ -z "$repo" ]]; then
    echo "⚠️ Error: 'repo' must be set for GitHub updates"
    exit 1
  fi

  if [[ -z "$query" || "$query" == "null" ]]; then
    echo "⚠️ Error: 'query' must be set for GitHub updates"
    exit 1
  fi

  releases=$(curl -fsSL "${auth_header[@]}" "https://api.github.com/repos/${repo}/releases?per_page=100")
  rawVersion=$(jq -r "sort_by(.created_at) | reverse | $query" <<< "$releases")

  if [[ -z "$rawVersion" || "$rawVersion" == "null" ]]; then
    echo "⚠️ No version found using query: $query"
    exit 1
  fi

  version="${rawVersion#v}"

  if [[ "$oldVersion" == "$version" ]]; then
    echo "✅ Version is up to date ($version)"
    exit 0
  fi

  echo "⬇️ New version detected: $oldVersion → $version"

  if jq -e '.platforms' <<< "$config" > /dev/null; then
    update_github_multiplatform "$repo" "$rawVersion" "$version"
  else
    update_github_single "$repo" "$rawVersion" "$version"
  fi
}

update_github_single() {
  local repo="$1"
  local rawVersion="$2"
  local version="$3"
  local url_template unpack url tmp

  url_template=$(jq -r '.url_template // empty' <<< "$config")
  unpack=$(jq -r '.unpack // false' <<< "$config")

  if [[ -z "$url_template" ]]; then
    echo "⚠️ Error: 'url_template' must be set for single-file GitHub updates"
    exit 1
  fi

  url="${url_template//\{repo\}/$repo}"
  url="${url//\{version\}/$rawVersion}"
  url="${url//\{version_clean\}/$version}"

  echo "⬇️ Fetching $url"

  tmp=$(mktemp)
  prefetch_cmd=(nix store prefetch-file "$url" --json)
  
  if [[ "$unpack" == "true" ]]; then
    prefetch_cmd+=(--unpack)
  fi

  if "${prefetch_cmd[@]}" > "$tmp"; then
    jq --slurpfile ph "$tmp" --arg v "$version" '
      .hash = $ph[0].hash | .version = $v
    ' "$info" > "${info}.tmp"
    mv "${info}.tmp" "$info"
  else
    echo "⚠️ Failed to prefetch: $url"
    rm -f "$tmp"
    exit 1
  fi

  rm -f "$tmp"
  echo "✅ Updated version and hash"
}

update_github_multiplatform() {
  local repo="$1"
  local rawVersion="$2"
  local version="$3"
  local tmp newInfo

  tmp=$(mktemp)
  newInfo=$(mktemp)

  jq -c '.platforms | keys[]' <<< "$config" | while read -r platform; do
    platform=$(echo "$platform" | tr -d '"')
    file=$(jq -r --arg p "$platform" '.platforms[$p].file' <<< "$config")
    unpack=$(jq -r --arg p "$platform" '.platforms[$p].unpack // false' <<< "$config")

    if [[ -z "$file" || "$file" == "null" ]]; then
      echo "⚠️ Error: 'file' must be set for platform '$platform'"
      exit 1
    fi

    file="${file//\{version\}/$version}"

    url="https://github.com/${repo}/releases/download/${rawVersion}/${file}"
    echo "⬇️ Fetching $platform: $url"

    prefetch_cmd=(nix store prefetch-file "$url" --json)
    if [[ "$unpack" == "true" ]]; then
      prefetch_cmd+=(--unpack)
    fi

    if "${prefetch_cmd[@]}" > "$tmp"; then
      jq --arg p "$platform" --slurpfile ph "$tmp" '
        .platforms[$p].hash = $ph[0].hash
      ' "$info" > "$newInfo"
      mv "$newInfo" "$info"
    else
      echo "⚠️ Failed to prefetch: $url"
    fi
  done

  jq --arg v "$version" '.version = $v' "$info" > "$newInfo"
  mv "$newInfo" "$info"

  echo "✅ Updated version and hashes"
  rm -f "$tmp" "$newInfo"
}

update_api() {
  local api_url response newVersion newUrl oldVersion tmp newInfo hash

  api_url=$(jq -r '.api_url // empty' <<< "$config")
  
  if [[ -z "$api_url" ]]; then
    echo "⚠️ Error: 'api_url' must be set for API updates"
    exit 1
  fi

  response=$(curl -fsSL "$api_url")

  version_path=$(jq -r '.version_path // ".version"' <<< "$config")
  url_path=$(jq -r '.url_path // ".url"' <<< "$config")

  rawNewVersion=$(jq -r "$version_path" <<< "$response")
  newUrl=$(jq -r "$url_path" <<< "$response")

  if [[ -z "$rawNewVersion" || -z "$newUrl" || "$rawNewVersion" == "null" || "$newUrl" == "null" ]]; then
    echo "⚠️ Failed to fetch new version or URL from API"
    exit 1
  fi

  newVersion="${rawNewVersion#v}"

  oldVersion=$(jq -r '.version // empty' <<< "$config")

  if [[ "$newVersion" == "$oldVersion" ]]; then
    echo "✅ Version is up to date ($newVersion)"
    exit 0
  fi

  echo "⬇️ New version detected: $oldVersion → $newVersion"
  echo "🔗 Prefetching: $newUrl"

  tmp=$(mktemp)
  newInfo=$(mktemp)

  if nix store prefetch-file "$newUrl" --json > "$tmp"; then
    hash=$(jq -r '.hash' "$tmp")
  else
    echo "⚠️ Failed to prefetch $newUrl"
    rm -f "$tmp"
    exit 1
  fi

  jq \
    --arg version "$newVersion" \
    --arg url "$newUrl" \
    --arg hash "$hash" \
    '.version = $version | .src.url = $url | .src.hash = $hash' \
    "$info" > "$newInfo"

  mv "$newInfo" "$info"
  rm -f "$tmp"

  echo "✅ Updated to $package_name $newVersion"
}

case "$update_type" in
  "github")
    update_github
    ;;
  "api")
    update_api
    ;;
  *)
    echo "⚠️ Unknown update_type: $update_type"
    echo "Supported types: github, api"
    exit 1
    ;;
esac