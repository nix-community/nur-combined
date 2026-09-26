#!/usr/bin/env bash
# Asks NUR to re-sync this repo now instead of waiting for its own poll.
#
# The endpoint rate-limits, and GitHub's shared runner IPs hit that limit
# often enough that a bare `curl --fail` turned "Notify NUR" red on the
# 2026-09-09 and 2026-09-26 merges with HTTP 429. So: retry transient
# failures (curl's --retry covers 408/429/5xx and honours Retry-After), and
# if NUR is *still* rate-limiting afterwards, warn rather than fail. A
# missed ping only delays the update until NUR's next scheduled poll; it
# never loses it. Anything else (a 4xx other than 429, persistent 5xx,
# no connection at all) still fails, since that may mean the endpoint or
# repo name changed and the ping has stopped working for good.
set -uo pipefail

url="https://nur-update.nix-community.org/update?repo=msaxena"

status=$(curl -sS -X POST -o /dev/null -w '%{http_code}' \
  --retry 5 --retry-max-time 180 "$url")
curl_exit=$?

if [ "$curl_exit" -eq 0 ] && [[ $status == 2* ]]; then
  echo "NUR re-sync requested (HTTP $status)."
elif [ "$status" = "429" ]; then
  echo "::warning::NUR's update endpoint is still rate-limiting (HTTP 429) after retries; the change will be picked up on NUR's next scheduled poll instead."
else
  echo "::error::NUR re-sync request failed (curl exit $curl_exit, HTTP ${status:-none})."
  exit 1
fi
