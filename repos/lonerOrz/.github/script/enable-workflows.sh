#!/usr/bin/env bash
# Enable every workflow in the upstream build repo. A disabled workflow makes
# review-dispatch fail with 422 "Cannot trigger a 'workflow_dispatch' on a disabled workflow".
#
# Usage: enable-workflows.sh [owner/repo]   (default: lonerOrz/nixpkgs-review-gha)
#
# stdout: exactly one JSON line
#   {"repo":..,"total":n,"updated":n,"skipped":n,"failed":n,
#    "workflows":[{"workflow":..,"state_before":..,"status":..,"detail":..}]}
#   status: updated (just enabled) | skipped (already active) | failed
# stderr: human-readable log
set -euo pipefail

REPO="lonerOrz/nixpkgs-review-gha"
[[ $# -gt 0 && "$1" != -* ]] && REPO="$1"

log() { printf '%s\n' "$*" >&2; }

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

# Still emit a parsable JSON line on failure.
emit_failed() {
  log "Error: $1"
  printf '{"repo":"%s","total":0,"updated":0,"skipped":0,"failed":1,"workflows":[{"workflow":"","state_before":"","status":"failed","detail":"%s"}]}\n' \
    "$(json_escape "$REPO")" "$(json_escape "$1")"
  exit 1
}

command -v gh >/dev/null || emit_failed "gh is required"

BASE="repos/${REPO}/actions/workflows"

if ! RAW=$(gh api "$BASE" --jq '.workflows[] | "\(.path)|\(.state)"' 2>&1); then
  emit_failed "${RAW%%gh:*}"
fi
[[ -n "${RAW//$'\n'/}" ]] || emit_failed "no workflows found in ${REPO}"
mapfile -t WORKFLOWS <<< "${RAW%$'\n'}"

ENTRIES=()
UPDATED=0
SKIPPED=0
FAILED=0

log "Workflows in ${REPO}:"

for entry in "${WORKFLOWS[@]}"; do
  file="${entry%%|*}"
  state="${entry##*|}"
  name="$(basename "$file")"

  if [[ "$state" == "active" ]]; then
    status="skipped"; detail="already active"
    log "  = ${name} (active)"
    SKIPPED=$((SKIPPED + 1))
  elif gh workflow enable "$name" --repo "$REPO" 2>/dev/null; then
    status="updated"; detail="enabled (was ${state})"
    log "  + ${name} (was ${state}) -> enabled"
    UPDATED=$((UPDATED + 1))
  else
    status="failed"; detail="could not enable (was ${state})"
    log "  ! ${name} (was ${state}) -> FAILED"
    FAILED=$((FAILED + 1))
  fi

  ENTRIES+=("{\"workflow\":\"$(json_escape "$file")\",\"state_before\":\"$(json_escape "$state")\",\"status\":\"${status}\",\"detail\":\"$(json_escape "$detail")\"}")
done

JOINED=$(IFS=,; printf '%s' "${ENTRIES[*]}")
log "Summary: ${UPDATED} enabled / ${SKIPPED} already active / ${FAILED} failed"

printf '{"repo":"%s","total":%d,"updated":%d,"skipped":%d,"failed":%d,"workflows":[%s]}\n' \
  "$(json_escape "$REPO")" "${#WORKFLOWS[@]}" "$UPDATED" "$SKIPPED" "$FAILED" "$JOINED"

(( FAILED == 0 ))
