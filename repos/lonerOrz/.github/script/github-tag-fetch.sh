#!/usr/bin/env bash
# Fetch latest release tag from GitHub with proper rate limit handling
# Usage: github-tag-fetch.sh <owner/repo>
# Example: github-tag-fetch.sh vicinaehq/vicinae

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <owner/repo>" >&2
  echo "Example: $0 vicinaehq/vicinae" >&2
  exit 1
fi

REPO="$1"
REPO_URL="https://github.com/${REPO}"

# Build auth header if GITHUB_TOKEN is available
AUTH_HEADER=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

# Try GitHub API first (authenticated requests have higher rate limits)
LATEST_TAG=$(curl -sS -L --fail --retry 3 --retry-delay 2 --retry-connrefused \
  "${AUTH_HEADER[@]}" \
  "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | jq -r .tag_name 2>/dev/null || echo "")

# Fallback: use git ls-remote if API fails or returns null
if [ "$LATEST_TAG" = "null" ] || [ -z "$LATEST_TAG" ]; then
  echo "⚠️ GitHub API failed or no release found, using git ls-remote..." >&2
  LATEST_TAG=$(git ls-remote --tags --sort='v:refname' "$REPO_URL" 2>/dev/null | tail -1 | cut -f2 | sed 's|refs/tags/||' || echo "")
fi

# Validate result
if [ -z "$LATEST_TAG" ]; then
  echo "❌ Failed to fetch latest tag for ${REPO}" >&2
  exit 1
fi

echo "$LATEST_TAG"
