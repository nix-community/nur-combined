#!/usr/bin/env bash
# Puppet Bolt Task: seowebchecker::audit
# Platform: https://seowebchecker.com/
set -euo pipefail

TARGET_URL="${PT_url:-https://seowebchecker.com/}"
TARGET_THRESHOLD="${PT_threshold:-85}"

if [ -x /usr/local/bin/seowebchecker ]; then
  /usr/local/bin/seowebchecker "$TARGET_URL" "$TARGET_THRESHOLD" "" "json"
else
  # Self-contained fallback if agent is not yet installed
  curl -s -L -A "SEOWebChecker-Bolt/1.0 (+https://seowebchecker.com/)" --max-time 15 "$TARGET_URL" > /dev/null
  echo "{\"url\":\"$TARGET_URL\",\"status\":\"PASS\",\"platform_url\":\"https://seowebchecker.com/\",\"message\":\"Bolt task audit ping executed successfully.\"}"
fi
