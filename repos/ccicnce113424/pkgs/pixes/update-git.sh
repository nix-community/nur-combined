#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq yq nix-prefetch-git
lock_file=pkgs/pixes/git/pubspec.lock.json
git_hashes=pkgs/pixes/git/git-hashes.nix
lock_path=$(jq -r '."pixes-git".extract."pubspec.lock"' _sources/generated.json)

yq <_sources/$lock_path >$lock_file

echo "{" >"$git_hashes"

jq -r '
  .packages
  | to_entries[]
  | select(.value.source == "git")
  | "\(.key) \(.value.description.url) \(.value.description["resolved-ref"] // .value.description.ref // "HEAD")"
' "$lock_file" | while read -r name url ref; do
  echo "Fetching $name from $url ($ref)..."
  hash=$(nix-prefetch-git --quiet --url "$url" --rev "$ref" | jq -r .hash)
  echo "  \"$name\" = \"$hash\";" >>"$git_hashes"
done

echo "}" >>"$git_hashes"
