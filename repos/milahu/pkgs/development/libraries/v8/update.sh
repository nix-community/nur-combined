#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq gclient2nix

# https://v8.dev/docs/release-process
CHANNEL=Stable
PLATFORM=Linux
VERSION_OVERVIEW="https://chromiumdash.appspot.com/fetch_releases?channel=$CHANNEL&platform=$PLATFORM"

v8_git_url=https://chromium.googlesource.com/v8/v8.git

gclient2nix_root=src # default

force_update=0
force_update=1

set -eo pipefail

cd "$(dirname "$0")"

# set -x # debug

if [ -n "$1" ]; then
  v8_version="$1"
  shift
else
  echo "fetching v8_commit from $VERSION_OVERVIEW"
  v8_commit=$(curl -s "$VERSION_OVERVIEW" | jq -r '.[0].hashes.v8')
  echo "v8_commit: $v8_commit"
  v8_version=$(
    git ls-remote --tags https://chromium.googlesource.com/v8/v8 |
    grep "$v8_commit" | head -n1 | cut -c52-
  )
fi

echo "v8_version: $v8_version"

if [ -e info.json ]; then
  v8_version_old=$(jq -r ".src.args.tag // empty" <info.json)
else
  v8_version_old=
fi

if [ "$force_update" = 0 ] && [ "$v8_version_old" = "$v8_version" ]; then
  echo "already up-to-date"
  exit
fi

echo "updating from $v8_version_old to $v8_version"

args=(gclient2nix generate)

if [ -n "$gclient2nix_root" ]; then
  args+=(--root "$gclient2nix_root")
fi

args+=("$v8_git_url@$v8_version")

info_json="$("${args[@]}")"

# fix:
# copying /buildtools...
# cp: cannot create directory '/buildtools': Permission denied
# a: /buildtools
# b: src/buildtools
info_json="$(echo "$info_json" | sed -E 's|^(    ")/|\1'"$gclient2nix_root"/'|')"

echo "$info_json" >info.json
echo done $(readlink -f info.json)
