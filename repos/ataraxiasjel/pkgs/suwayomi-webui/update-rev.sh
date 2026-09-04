#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused gnugrep
# Update the `revision` (Suwayomi commit count) after `nix-update-script`
# has already bumped `version` in default.nix.
#
# It is executed via passthru.updateScript sequence as a plain subprocess
# in the user's environment (with network), not inside a Nix build sandbox.
#
# Usage: update-rev.sh <package-dir>   (e.g. ./pkgs/suwayomi-webui)

set -euo pipefail

PKG_DIR="${1:?usage: update-rev.sh <package-dir>}"
FILE="$PKG_DIR/default.nix"

if [[ ! -f "$FILE" ]]; then
  echo "error: $FILE not found" >&2
  exit 1
fi

# Active version line in default.nix.
TAG="$(grep -oP '^\s*version = "\K[0-9.]+' "$FILE" | head -n 1 || true)"
if [[ -z "$TAG" ]]; then
  echo "error: could not parse version from $FILE" >&2
  exit 1
fi

CURL_ARGS=(-fsSL)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  CURL_ARGS+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

TAG_JSON="$(curl "${CURL_ARGS[@]}" "https://api.github.com/repos/Suwayomi/Suwayomi-WebUI/git/ref/tags/v$TAG")"
OBJ_TYPE="$(jq -r '.object.type // empty' <<<"$TAG_JSON")"
COMMIT_SHA="$(jq -r '.object.sha // empty' <<<"$TAG_JSON")"

# Annotated tags point at a tag object; peel it to the commit.
if [[ "$OBJ_TYPE" == "tag" ]]; then
  TAG_OBJ_URL="$(jq -r '.object.url // empty' <<<"$TAG_JSON")"
  if [[ -z "$TAG_OBJ_URL" ]]; then
    echo "error: annotated tag v$TAG has no object url: $TAG_JSON" >&2
    exit 1
  fi
  COMMIT_SHA="$(curl "${CURL_ARGS[@]}" "$TAG_OBJ_URL" | jq -r '.object.sha // empty')"
fi

if ! [[ "$COMMIT_SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "error: could not resolve tag v$TAG to a commit sha (got '$COMMIT_SHA')" >&2
  exit 1
fi

# Revision = total commit count reachable from the tag commit.
# With per_page=1 the "last" page number in the Link header equals that count.
LINK="$(curl -fsSI "${CURL_ARGS[@]}" "https://api.github.com/repos/Suwayomi/Suwayomi-WebUI/commits?per_page=1&sha=$COMMIT_SHA" | grep -i '^link:' | tr -d '\r' | head -n 1 || true)"
REVISION="$(grep -oP 'page=\K[0-9]+(?=>; rel="last")' <<<"$LINK" | head -n 1 || true)"

if ! [[ "$REVISION" =~ ^[0-9]+$ ]]; then
  echo "error: could not parse revision from Link header (got '$LINK')" >&2
  exit 1
fi

# Anchored to the version-controlled line only.
sed -i -E 's/^(\s*revision = ")[0-9]+(")/\1'"$REVISION"'\2/' "$FILE"

echo "suwayomi-webui: version $TAG -> revision $REVISION"
