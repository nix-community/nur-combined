#!/usr/bin/env bash
# Records one commit status for the commit this run checked out (GITHUB_SHA).
# Usage: publication-status.sh <context> <outcome>...
# The status is "success" only when every outcome is exactly "success"; any other
# value (failure, cancelled, skipped, empty) records "failure". Callers pass the
# step outcomes of publication verification; the cache branch is promoted only from
# success.
set -euo pipefail

if (( $# < 2 )); then
  echo 'usage: publication-status.sh <context> <outcome>...' >&2
  exit 2
fi
context=$1
shift

state=success
description='All required publication checks succeeded for this commit.'
for outcome in "$@"; do
  if [[ $outcome != success ]]; then
    state=failure
    description="A publication check did not succeed (outcome: ${outcome:-empty})."
    break
  fi
done

: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"

gh api --method POST "repos/${GITHUB_REPOSITORY}/statuses/${GITHUB_SHA}" \
  -f state="$state" \
  -f context="$context" \
  -f description="$description" > /dev/null

echo "${context} = ${state} for ${GITHUB_SHA}"
