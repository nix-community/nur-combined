#!/usr/bin/env bash
# Dispatches the updater workflows whose pull requests are still open after a push
# to main. Those PRs are now behind main (which must be up to date to merge), so the
# workflow that owns them rebuilds them on the new base:
#   auto-update/<package>   -> update.yml
#   auto-update-flake-lock  -> flake-update.yml
# Without open update PRs nothing is dispatched, so this cannot loop: a dispatched
# run only pushes to main through a PR that merges, and then that PR is closed.
#
# Requires GH_TOKEN (actions: write, pull-requests: read) and GH_REPO.
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GH_REPO:?GH_REPO is required}"
base=${UPDATE_PR_BASE:-main}

heads=$(gh pr list --state open --base "$base" --limit 200 \
  --json headRefName,isCrossRepository \
  --jq '.[] | select(.isCrossRepository | not) | .headRefName')

packages=0
lock=0
while IFS= read -r head; do
  case $head in
    auto-update/?*) packages=$((packages + 1)) ;;
    auto-update-flake-lock) lock=1 ;;
  esac
done <<< "$heads"

if (( packages == 0 && lock == 0 )); then
  echo 'No open update pull requests; nothing to refresh.'
  exit 0
fi
if (( packages > 0 )); then
  gh workflow run update.yml --ref "$base"
  echo "::notice::Dispatched update.yml to rebuild ${packages} open package update pull request(s) on ${base}."
fi
if (( lock == 1 )); then
  gh workflow run flake-update.yml --ref "$base"
  echo "::notice::Dispatched flake-update.yml to rebuild the open flake.lock pull request on ${base}."
fi
