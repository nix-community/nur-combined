#!/usr/bin/env -S nix shell nixpkgs#curl nixpkgs#jq nixpkgs#nix nixpkgs#coreutils -c bash
set -euo pipefail

# Universal package version updater
# Supports GitHub releases and custom API endpoints
# Usage: ./update.sh [--force] <version.json>

force_hash=false
if [[ "${1:-}" == "--force" ]]; then
  force_hash=true
  shift
fi

if [[ $# -ne 1 ]]; then
  cat <<EOF
Usage: $0 [--force] <version.json>

Options:
  --force    Re-fetch hash even if version is up-to-date

Example:
  $0 pkgs/proton-em-bin/version.json
  $0 --force pkgs/beeper-nightly/version.json
EOF
  exit 1
fi

version_file="$1"

if [[ ! -f "$version_file" ]]; then
  echo "⚠️ Error: File not found: $version_file" >&2
  exit 1
fi

config=$(cat "$version_file")

if [[ "$force_hash" == "false" ]]; then
  json_force=$(jq -r '.force_hash // false' <<< "$config")
  if [[ "$json_force" == "true" ]]; then
    force_hash=true
  fi
fi

source_type=$(jq -r '.source.type // "github-release"' <<< "$config")
package_name=$(jq -r '.name // "package"' <<< "$config")

echo "📦 Updating $package_name (type: $source_type)"

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: token $GITHUB_TOKEN")
  echo "🔑 Using GITHUB_TOKEN for authentication"
fi

update_github_release() {
  local repo query oldVersion releases rawVersion version

  repo=$(jq -r '.source.repo // empty' <<< "$config")
  query=$(jq -r '.source.query // empty' <<< "$config")
  oldVersion=$(jq -r '.version // empty' <<< "$config")

  if [[ -z "$query" || "$query" == "null" ]]; then
    echo "⚠️ Error: 'source.query' is required" >&2
    exit 1
  fi

  if jq -e '.platforms' <<< "$config" > /dev/null && [[ -z "$repo" ]]; then
    local first_platform_repo
    first_platform_repo=$(jq -r '.platforms[.platforms | keys[0]].repo' <<< "$config")

    if [[ -z "$first_platform_repo" || "$first_platform_repo" == "null" ]]; then
      echo "⚠️ Error: Either 'source.repo' or per-platform 'repo' is required" >&2
      exit 1
    fi

    echo "🔍 Fetching version from $first_platform_repo..."
    if ! releases=$(curl -fsSL "${auth_header[@]}" "https://api.github.com/repos/${first_platform_repo}/releases?per_page=100"); then
      echo "⚠️ Error: Failed to fetch releases from GitHub API" >&2
      exit 1
    fi

    rawVersion=$(jq -r "sort_by(.created_at) | reverse | $query" <<< "$releases")
    repo=""
  else
    if [[ -z "$repo" ]]; then
      echo "⚠️ Error: 'source.repo' is required" >&2
      exit 1
    fi

    echo "🔍 Fetching releases from $repo..."
    if ! releases=$(curl -fsSL "${auth_header[@]}" "https://api.github.com/repos/${repo}/releases?per_page=100"); then
      echo "⚠️ Error: Failed to fetch releases from GitHub API" >&2
      exit 1
    fi

    rawVersion=$(jq -r "sort_by(.created_at) | reverse | $query" <<< "$releases")
  fi

  if [[ -z "$rawVersion" || "$rawVersion" == "null" ]]; then
    echo "⚠️ Error: No version found using query: $query" >&2
    exit 1
  fi

  version="${rawVersion#v}"
  echo "📌 Latest version: $version"

  if [[ "$oldVersion" == "$version" ]]; then
    if [[ "$force_hash" == "false" ]]; then
      echo "✅ Version is up to date"
      exit 0
    else
      echo "🔄 Forcing hash update"
    fi
  else
    echo "⬆️ Update: $oldVersion → $version"
  fi

  if jq -e '.variants' <<< "$config" > /dev/null; then
    update_variants "$repo" "$rawVersion" "$version"
  elif jq -e '.platforms' <<< "$config" > /dev/null; then
    update_platforms "$repo" "$rawVersion" "$version"
  else
    update_single "$repo" "$rawVersion" "$version"
  fi
}

update_single() {
  local repo="$1"
  local rawVersion="$2"
  local version="$3"
  local url unpack tmp hash

  url=$(jq -r '.asset.url // empty' <<< "$config")
  unpack=$(jq -r '.asset.unpack // false' <<< "$config")

  if [[ -z "$url" ]]; then
    echo "⚠️ Error: 'asset.url' is required" >&2
    exit 1
  fi

  url="${url//\{repo\}/$repo}"
  url="${url//\{version\}/$rawVersion}"

  echo "⬇️  Downloading $url"

  tmp=$(mktemp)
  local prefetch_cmd=(nix store prefetch-file "$url" --json)

  if [[ "$unpack" == "true" ]]; then
    prefetch_cmd+=(--unpack)
  fi

  if ! "${prefetch_cmd[@]}" > "$tmp"; then
    echo "⚠️ Error: Failed to prefetch file" >&2
    rm -f "$tmp"
    exit 1
  fi

  hash=$(jq -r '.hash' "$tmp")
  rm -f "$tmp"

  jq --arg v "$version" --arg h "$hash" '
    .version = $v | .hash = $h
  ' "$version_file" > "${version_file}.tmp"
  mv "${version_file}.tmp" "$version_file"

  echo "✅ Updated to version $version"
}

update_platforms() {
  local default_repo="$1"
  local rawVersion="$2"
  local version="$3"
  local tmp platform file unpack url hash platform_repo platform_raw_version

  tmp=$(mktemp)
  echo "🔄 Processing platforms..."

  local platforms=()
  while IFS= read -r platform; do
    platforms+=("$platform")
  done < <(jq -r '.platforms | keys[]' <<< "$config")

  for platform in "${platforms[@]}"; do
    platform_repo=$(jq -r --arg p "$platform" '.platforms[$p].repo // empty' <<< "$config")

    if [[ -z "$platform_repo" ]]; then
      platform_repo="$default_repo"
      platform_raw_version="$rawVersion"
    else
      echo "   [$platform] Using repo: $platform_repo"
      local platform_releases
      if ! platform_releases=$(curl -fsSL "${auth_header[@]}" "https://api.github.com/repos/${platform_repo}/releases?per_page=100"); then
        echo "⚠️ Error: Failed to fetch releases from $platform_repo" >&2
        continue
      fi

      local query
      query=$(jq -r '.source.query // ".[0].tag_name"' <<< "$config")
      platform_raw_version=$(jq -r "sort_by(.created_at) | reverse | $query" <<< "$platform_releases")

      if [[ -z "$platform_raw_version" || "$platform_raw_version" == "null" ]]; then
        echo "⚠️ Error: No version found for $platform_repo" >&2
        continue
      fi
    fi

    file=$(jq -r --arg p "$platform" '.platforms[$p].file' <<< "$config")
    unpack=$(jq -r --arg p "$platform" '.platforms[$p].unpack // false' <<< "$config")

    if [[ -z "$file" || "$file" == "null" ]]; then
      echo "⚠️ Error: 'file' required for platform '$platform'" >&2
      exit 1
    fi

    file="${file//\{version\}/$version}"
    url="https://github.com/${platform_repo}/releases/download/${platform_raw_version}/${file}"

    echo "   [$platform] $file"

    local prefetch_cmd=(nix store prefetch-file "$url" --json)
    if [[ "$unpack" == "true" ]]; then
      prefetch_cmd+=(--unpack)
    fi

    if ! "${prefetch_cmd[@]}" > "$tmp"; then
      echo "⚠️ Error: Failed to prefetch $platform" >&2
      continue
    fi

    hash=$(jq -r '.hash' "$tmp")

    jq --arg p "$platform" --arg h "$hash" '.platforms[$p].hash = $h' "$version_file" > "${version_file}.tmp"
    mv "${version_file}.tmp" "$version_file"
  done

  jq --arg v "$version" '.version = $v' "$version_file" > "${version_file}.tmp"
  mv "${version_file}.tmp" "$version_file"

  rm -f "$tmp"
  echo "✅ Updated ${#platforms[@]} platforms to version $version"
}

update_variants() {
  local repo="$1"
  local rawVersion="$2"
  local version="$3"
  local tmp url_template variant url hash

  tmp=$(mktemp)
  url_template=$(jq -r '.asset.url_template // empty' <<< "$config")

  if [[ -z "$url_template" ]]; then
    echo "⚠️ Error: 'asset.url_template' required for variants" >&2
    exit 1
  fi

  echo "🔄 Processing variants..."

  local variants=()
  while IFS= read -r variant; do
    variants+=("$variant")
  done < <(jq -r '.variants | keys[]' <<< "$config")

  for variant in "${variants[@]}"; do
    local substitutions
    substitutions=$(jq -r --arg v "$variant" '.variants[$v].substitutions // []' <<< "$config")

    url="${url_template//\{repo\}/$repo}"
    url="${url//\{version\}/$rawVersion}"

    local i=0
    while IFS= read -r sub; do
      url="${url//\{$i\}/$sub}"
      i=$((i + 1))
    done < <(jq -r --arg v "$variant" '.variants[$v].substitutions[]' <<< "$config")

    echo "   [$variant] $(jq -r --arg v "$variant" '.variants[$v].substitutions | join(", ")' <<< "$config")"

    unpack=$(jq -r '.asset.unpack // false' <<< "$config")
    local prefetch_cmd=(nix store prefetch-file "$url" --json)
    if [[ "$unpack" == "true" ]]; then
      prefetch_cmd+=(--unpack)
    fi

    if ! "${prefetch_cmd[@]}" > "$tmp"; then
      echo "⚠️ Error: Failed to prefetch $variant" >&2
      continue
    fi

    hash=$(jq -r '.hash' "$tmp")

    jq --arg v "$variant" --arg h "$hash" '
      .variants[$v].hash = $h
    ' "$version_file" > "${version_file}.tmp"
    mv "${version_file}.tmp" "$version_file"
  done

  jq --arg v "$version" '.version = $v' "$version_file" > "${version_file}.tmp"
  mv "${version_file}.tmp" "$version_file"

  rm -f "$tmp"
  echo "✅ Updated ${#variants[@]} variants to version $version"
}

update_api() {
  local api_url response version_path url_path rawVersion newVersion newUrl oldVersion tmp hash

  api_url=$(jq -r '.source.url // empty' <<< "$config")
  
  if [[ -z "$api_url" ]]; then
    echo "⚠️ Error: 'source.url' is required for API updates" >&2
    exit 1
  fi

  echo "🔍 Fetching from API..."
  if ! response=$(curl -fsSL "$api_url"); then
    echo "⚠️ Error: Failed to fetch from API endpoint" >&2
    exit 1
  fi

  version_path=$(jq -r '.source.version_path // ".version"' <<< "$config")
  url_path=$(jq -r '.source.url_path // ".url"' <<< "$config")

  rawVersion=$(jq -r "$version_path" <<< "$response")
  newUrl=$(jq -r "$url_path" <<< "$response")

  if [[ -z "$rawVersion" || -z "$newUrl" || "$rawVersion" == "null" || "$newUrl" == "null" ]]; then
    echo "⚠️ Error: Failed to extract version or URL from API response" >&2
    exit 1
  fi

  newVersion="${rawVersion#v}"
  oldVersion=$(jq -r '.version // empty' <<< "$config")

  echo "📌 Latest version: $newVersion"

  if [[ "$newVersion" == "$oldVersion" ]]; then
    if [[ "$force_hash" == "false" ]]; then
      echo "✅ Version is up to date"
      exit 0
    else
      echo "🔄 Forcing hash update"
    fi
  else
    echo "⬆️ Update: $oldVersion → $newVersion"
  fi

  echo "⬇️  Downloading $newUrl"

  tmp=$(mktemp)
  if ! nix store prefetch-file "$newUrl" --json > "$tmp"; then
    echo "⚠️ Error: Failed to prefetch file" >&2
    rm -f "$tmp"
    exit 1
  fi

  hash=$(jq -r '.hash' "$tmp")
  rm -f "$tmp"

  jq \
    --arg version "$newVersion" \
    --arg url "$newUrl" \
    --arg hash "$hash" \
    '.version = $version | .asset.url = $url | .asset.hash = $hash' \
    "$version_file" > "${version_file}.tmp"

  mv "${version_file}.tmp" "$version_file"
  echo "✅ Updated to version $newVersion"
}

case "$source_type" in
  github-release)
    update_github_release
    ;;
  api)
    update_api
    ;;
  *)
    echo "⚠️ Error: Unknown source type: $source_type" >&2
    echo "Supported types: github-release, api" >&2
    exit 1
    ;;
esac