#!/usr/bin/env bash
# Fetch latest commit hash (rev) from GitHub with proper rate limit handling
# Usage: github-rev-fetch.sh <owner/repo> [branch]
# Example: github-rev-fetch.sh vicinaehq/vicinae main
#          github-rev-fetch.sh vicinaehq/vicinae master

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <owner/repo> [branch]" >&2
  echo "Example: $0 vicinaehq/vicinae main" >&2
  echo "         $0 vicinaehq/vicinae master" >&2
  exit 1
fi

REPO="$1"
BRANCH="${2:-main}"  # Default to 'main' if not specified
REPO_URL="https://github.com/${REPO}"

# Build auth header if GITHUB_TOKEN is available
AUTH_HEADER=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

# Try GitHub API first (authenticated requests have higher rate limits)
LATEST_REV=$(curl -sS -L --fail --retry 3 --retry-delay 2 --retry-connrefused \
  "${AUTH_HEADER[@]}" \
  "https://api.github.com/repos/${REPO}/branches/${BRANCH}" 2>/dev/null | jq -r '.commit.sha' 2>/dev/null || echo "")

# Fallback: use git ls-remote if API fails
if [ "$LATEST_REV" = "null" ] || [ -z "$LATEST_REV" ]; then
  echo "⚠️ GitHub API failed, using git ls-remote..." >&2
  LATEST_REV=$(git ls-remote "$REPO_URL" "refs/heads/${BRANCH}" 2>/dev/null | cut -f1 || echo "")
fi

# Validate result
if [ -z "$LATEST_REV" ]; then
  echo "❌ Failed to fetch latest commit for ${REPO}@${BRANCH}" >&2
  exit 1
fi

echo "$LATEST_REV"
