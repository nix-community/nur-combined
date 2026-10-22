#!/usr/bin/env bash
# NUR throttles all repositories globally for five minutes after a refresh:
# https://github.com/nix-community/nur-update/blob/main/nur_update/__init__.py
# A 429 is a deferred notification, NOT a failed package build or accepted POST.
set -euo pipefail

repo=${1:?Usage: notify-nur.sh REPOSITORY}
[[ "$repo" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { echo '::error::Invalid NUR repository name'; exit 1; }
trusted_event=false
if [[ "${GITHUB_EVENT_NAME:-}" =~ ^(push|workflow_dispatch|schedule)$ ]] ||
   [[ "${GITHUB_EVENT_NAME:-}" == workflow_run && "${CI_TRUSTED_UPDATE_COMPLETION:-false}" == true ]]; then
  trusted_event=true
fi
if [[ "${GITHUB_REF:-}" != refs/heads/main || "$trusted_event" != true ]]; then
  echo 'Read-only CI: no NUR notification for this event/ref'
  exit 0
fi

summary() {
  echo "$1"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    printf '\n### NUR notification\n\n%s\n' "$1" >> "$GITHUB_STEP_SUMMARY"
  fi
}

last='transport error'
for attempt in 1 2 3; do
  if status=$(curl --silent --show-error --connect-timeout 10 --max-time 30 \
      --output /dev/null --write-out '%{http_code}' -X POST \
      "https://nur-update.nix-community.org/update?repo=$repo"); then
    case "$status" in
      2[0-9][0-9])
        summary "NUR accepted the refresh request (HTTP $status)."
        exit 0
        ;;
      429)
        echo '::warning::NUR is rate-limiting refreshes (HTTP 429). Notification deferred; package builds and cache publication succeeded.'
        summary 'NUR notification deferred (HTTP 429): no refresh was accepted by this request. NUR also performs its own periodic repository updates.'
        exit 0
        ;;
      500|502|503|504) last="HTTP $status" ;;
      *) echo "::error::NUR rejected the refresh request (HTTP $status)"; exit 1 ;;
    esac
  else
    last='transport error'
  fi
  if [[ "$attempt" != 3 ]]; then sleep "$attempt"; fi
done

echo "::error::NUR notification failed after three attempts: $last"
exit 1
