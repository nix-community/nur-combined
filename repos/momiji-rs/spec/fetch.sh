#!/usr/bin/env bash
#
# fetch.sh — provision the OFFICIAL sass-spec suite into spec/sass-spec/.
#
# Modes:
#   (default)           Fetch the PINNED commit recorded in spec/SPEC_VERSION.txt.
#                       Reproducible — the conformance ratchet (check_baseline.py)
#                       always scores against this fixed case set, so the count in
#                       spec/BASELINE.json corresponds to an exact suite version.
#   --latest | --canary Fetch upstream master HEAD to detect drift. Does NOT change
#                       the pin; reports whether upstream has moved ahead so you can
#                       decide whether to re-pin.
#   --pin=<sha>         Fetch <sha> and re-write spec/SPEC_VERSION.txt to pin it.
#
# Shallow fetch (--depth 1) — we only score against one snapshot at a time. The
# upstream suite is large and .gitignore'd; everyone runs this before the harness.
#
# Usage:  bash spec/fetch.sh [--latest|--canary] [--pin=<sha>]
set -euo pipefail

REPO_URL="https://github.com/sass/sass-spec.git"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HERE}/sass-spec"
VERSION_FILE="${HERE}/SPEC_VERSION.txt"

mode="pinned"
pin_sha=""
for arg in "$@"; do
  case "$arg" in
    --latest | --canary) mode="latest" ;;
    --pin=*) mode="pin"; pin_sha="${arg#--pin=}" ;;
    -h | --help) sed -n '3,19p' "$0"; exit 0 ;;
    *) echo "fetch.sh: unknown argument '$arg' (try --help)" >&2; exit 2 ;;
  esac
done

pinned_sha=""
[ -f "$VERSION_FILE" ] && pinned_sha="$(awk '/^commit:/{print $2; exit}' "$VERSION_FILE")"

# Resolve the target commit for the SHA-targeted modes.
case "$mode" in
  pinned)
    if [ -z "$pinned_sha" ]; then
      echo "!! No pinned commit in $VERSION_FILE." >&2
      echo "!! Bootstrap one with:  bash spec/fetch.sh --latest  then  --pin=<sha>" >&2
      exit 1
    fi
    target="$pinned_sha" ;;
  pin) target="$pin_sha" ;;
  latest) target="" ;; # upstream HEAD, resolved after fetch
esac

# Already at the requested pinned commit? Leave it (cheap idempotent re-runs).
if [ "$mode" = "pinned" ] && [ -d "$DEST/.git" ] \
  && [ "$(git -C "$DEST" rev-parse HEAD 2>/dev/null || true)" = "$target" ]; then
  echo "==> sass-spec already at pinned ${target:0:12}; leaving in place."
  exit 0
fi

echo "==> Provisioning sass-spec (${mode}${target:+ @ ${target:0:12}}) into ${DEST}"
rm -rf "$DEST"
git init -q "$DEST"
git -C "$DEST" remote add origin "$REPO_URL"

fetch_ref="$target"
[ "$mode" = "latest" ] && fetch_ref="HEAD"
if ! git -C "$DEST" fetch -q --depth 1 origin "$fetch_ref" 2>clone.err; then
  echo "!! FETCH FAILED (no network, or unknown commit '${fetch_ref}'). stderr:" >&2
  sed 's/^/   /' clone.err >&2 || true
  echo "!! The harness still works against the tiny built-in sample:" >&2
  echo "!!   python3 spec/run_spec.py --suite spec/sample-spec" >&2
  rm -rf "$DEST" clone.err
  exit 1
fi
git -C "$DEST" checkout -q FETCH_HEAD
rm -f clone.err

SHA="$(git -C "$DEST" rev-parse HEAD)"
DATE="$(git -C "$DEST" log -1 --format=%cI)"

if [ "$mode" = "latest" ]; then
  echo "==> Fetched upstream HEAD: ${SHA} (${DATE})"
  if [ -n "$pinned_sha" ] && [ "$SHA" != "$pinned_sha" ]; then
    echo "==> DRIFT: pinned ${pinned_sha:0:12} != upstream ${SHA:0:12}."
    echo "    To adopt it:  bash spec/fetch.sh --pin=${SHA}"
    echo "    then re-run check_baseline.py and bump spec/BASELINE.json."
  else
    echo "==> No drift: upstream matches the pin."
  fi
  echo "==> (SPEC_VERSION.txt left unchanged in canary mode.)"
else
  # pinned / pin: SPEC_VERSION.txt IS the pin — record (idempotent for pinned).
  {
    echo "repo:   ${REPO_URL}"
    echo "commit: ${SHA}"
    echo "date:   ${DATE}"
    echo "fetched_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$VERSION_FILE"
  echo "==> Pinned version:"
  sed 's/^/    /' "$VERSION_FILE"
fi

N_DIR=$(find "${DEST}/spec" -type f \( -name 'input.scss' -o -name 'input.sass' \) 2>/dev/null | wc -l | tr -d ' ')
N_HRX=$(find "${DEST}/spec" -type f -name '*.hrx' 2>/dev/null | wc -l | tr -d ' ')
echo "==> Suite census: ${N_DIR} directory inputs, ${N_HRX} .hrx archives."
echo "==> Done."
