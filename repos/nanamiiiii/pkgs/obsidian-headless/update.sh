#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -euo pipefail

owner="obsidianmd"
repo="obsidian-headless"

commit_info=$(curl -sf \
  "https://api.github.com/repos/$owner/$repo/commits/main")

latest_rev=$(echo "$commit_info" | jq -r '.sha')

if [ "$latest_rev" = "$UPDATE_NIX_OLD_VERSION_rev" ]; then
  echo "Already at latest commit"
  exit 0
fi

commit_date=$(echo "$commit_info" | jq -r '.commit.committer.date[:10]')

pkg_version=$(curl -sf \
  "https://raw.githubusercontent.com/$owner/$repo/$latest_rev/package.json" \
  | jq -r '.version')

new_version="$pkg_version-unstable-$commit_date"

echo '[
  { "attrPath": "version", "newValue": "'"$new_version"'" },
  { "attrPath": "rev",     "newValue": "'"$latest_rev"'" },
  { "attrPath": "src",     "newValue": "prefetch" },
  { "attrPath": "pnpmDeps","newValue": "prefetch" }
]'
