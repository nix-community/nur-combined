#!/usr/bin/env bash
# Moves the `cache` branch to the current main commit, but only when every cache
# publication for that exact commit reported success. Consumers that add
# `github:urioTV/urio-nur/cache` therefore get a state whose binaries were all
# published (or nothing new). Never force-pushes: a non-fast-forward update fails.
#
# Requires GH_TOKEN (contents: write, statuses: read) and REPO (owner/name).
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${REPO:?REPO is required}"

# Must match the contexts posted by build.yml and kernel.yml. A missing context means
# the publication for this commit has not finished (or did not run): do nothing yet.
required=(
  cache/packages
  cache/kernel/linux-cachyos-latest-x86_64-v3
  cache/kernel/linux-cachyos-bore-x86_64-v3
)

sha=$(gh api "repos/${REPO}/git/ref/heads/main" --jq '.object.sha')
statuses=$(gh api "repos/${REPO}/commits/${sha}/status" \
  --jq '.statuses | map({(.context): .state}) | add // {}')

blocked=0
for context in "${required[@]}"; do
  state=$(jq -r --arg c "$context" '.[$c] // "missing"' <<< "$statuses")
  echo "${context}: ${state}"
  [[ $state == success ]] || blocked=1
done

if (( blocked )); then
  echo "::notice::cache branch not moved: ${sha} does not have all publications successful yet."
  exit 0
fi

if current=$(gh api "repos/${REPO}/git/ref/heads/cache" --jq '.object.sha' 2>/dev/null); then
  if [[ $current == "$sha" ]]; then
    echo "cache branch already at ${sha}"
    exit 0
  fi
  gh api --method PATCH "repos/${REPO}/git/refs/heads/cache" -f sha="$sha" -F force=false > /dev/null
  echo "cache branch fast-forwarded: ${current} -> ${sha}"
else
  gh api --method POST "repos/${REPO}/git/refs" -f ref=refs/heads/cache -f sha="$sha" > /dev/null
  echo "cache branch created at ${sha}"
fi
