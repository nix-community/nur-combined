#!/usr/bin/env bash

# https://github.com/NixOS/nixpkgs/tree/master/pkgs/servers/http/nginx

cd "$(dirname "$0")"

for f in *; do
  [ "$f" = "update.sh" ] && continue
  [ -d "$f" ] && continue
  git rm -f "$f" || rm -vf "$f"
done

owner=NixOS
repo=nixpkgs
ref=master
path=pkgs/servers/http/nginx

files=(
  $(curl -L https://api.github.com/repos/$owner/$repo/contents/$path?ref=$ref | jq -r '.[] | .name')
)

urls=()

for file in "${files[@]}"; do
  urls+=("https://github.com/$owner/$repo/raw/$ref/$path/$file")
done

wget -N "${urls[@]}"
