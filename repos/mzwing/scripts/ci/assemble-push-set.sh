#!/usr/bin/env bash
# Publish realized `out` outputs only; auxiliary crate outputs retain the full build graph.
set -euo pipefail

jq -r '.[].drvPath' <<<"${TARGETS}" | sort --unique >/tmp/active-drvs.txt
jq -r '.[] | select(.outputName == "out") | .outputPath' <<<"${TARGETS}" >/tmp/out-targets.txt
grep '^/nix/store/' /tmp/built-outputs.txt 2>/dev/null |
  grep -Fxf /tmp/out-targets.txt >/tmp/push-outputs.txt || true

printf 'Publishing %s of %s realised outputs to Cachix.\n' \
  "$(wc -l </tmp/push-outputs.txt)" "$(wc -l </tmp/out-targets.txt)"
