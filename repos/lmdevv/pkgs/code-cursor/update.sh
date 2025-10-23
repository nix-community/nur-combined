#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq coreutils nix
set -eu -o pipefail

currentVersion=$(grep -E '^\s*version\s*=' default.nix | sed 's/.*version\s*=\s*"\([^"]*\)".*/\1/')

declare -A platforms=([x86_64-linux]='linux-x64' [x86_64-darwin]='darwin-x64' [aarch64-darwin]='darwin-arm64')
declare -A updates=()
first_version=""
failed_platforms=()

for platform in ${!platforms[@]}; do
  api_platform=${platforms[$platform]}
  result=$(curl -s "https://api2.cursor.sh/updates/api/download/stable/$api_platform/cursor")
  version=$(echo $result | jq -r '.version')
  if [[ "$version" == "$currentVersion" ]]; then
    echo "Already up to date: $version"
    exit 0
  fi
  if [[ -z "$first_version" ]]; then
    first_version=$version
    first_platform=$platform
  elif [[ "$version" != "$first_version" ]]; then
    >&2 echo "Multiple versions found: $first_version ($first_platform) and $version ($platform)"
    exit 1
  fi
  url=$(echo $result | jq -r '.downloadUrl')
  # Check if URL is downloadable
  if ! curl --output /dev/null --silent --head --fail "$url"; then
    echo "Warning: URL for $platform is not accessible: $url"
    failed_platforms+=("$platform")
    continue
  fi
  updates+=([$platform]="$result")
done

if [[ ${#failed_platforms[@]} -gt 0 ]]; then
  echo "The following platforms failed URL validation: ${failed_platforms[*]}"
  echo "Continuing with available platforms only..."
fi

if [[ ${#updates[@]} -eq 0 ]]; then
  echo "No platforms have valid URLs. Cannot update."
  exit 1
fi

echo "Updating from $currentVersion to $first_version"

# Update the default.nix file
for platform in ${!updates[@]}; do
  result=${updates[$platform]}
  version=$(echo $result | jq -r '.version')
  url=$(echo $result | jq -r '.downloadUrl')

  echo "Fetching hash for $platform..."
  raw_hash=$(nix-prefetch-url --type sha256 "$url")
  hash=$(nix hash to-sri --type sha256 "$raw_hash")

  # Update the version (only once)
  if [[ "$platform" == "x86_64-linux" ]]; then
    sed -i "s/version = \"[^\"]*\"/version = \"$version\"/" default.nix
  fi

  # Update the URL and hash for this specific platform
  case $platform in
    "x86_64-linux")
      sed -i "/x86_64-linux = fetchurl {/,/};/{
        s|url = \"https://downloads.cursor.com/production/[^\"]*\"|url = \"$url\"|
        s|hash = \"sha256-[^\"]*\"|hash = \"$hash\"|
      }" default.nix
      ;;
    "x86_64-darwin")
      sed -i "/x86_64-darwin = fetchurl {/,/};/{
        s|url = \"https://downloads.cursor.com/production/[^\"]*\"|url = \"$url\"|
        s|hash = \"sha256-[^\"]*\"|hash = \"$hash\"|
      }" default.nix
      ;;
    "aarch64-darwin")
      sed -i "/aarch64-darwin = fetchurl {/,/};/{
        s|url = \"https://downloads.cursor.com/production/[^\"]*\"|url = \"$url\"|
        s|hash = \"sha256-[^\"]*\"|hash = \"$hash\"|
      }" default.nix
      ;;
  esac
done

echo "Updated to version $first_version"
