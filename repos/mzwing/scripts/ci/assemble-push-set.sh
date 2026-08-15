#!/usr/bin/env bash
# Work out which realised outputs go to Cachix, and which derivations reconciliation should treat as this run's active set.
# Only 'out' outputs are published: auxiliary outputs like crate2nix's '-lib' reference the whole crate graph through nix-support/propagated-build-inputs, so `cachix push` would upload that entire build-time closure as "runtime dependencies".
set -euo pipefail

jq -r '.[].drvPath' <<<"${TARGETS}" | sort --unique >/tmp/active-drvs.txt
jq -r '.[] | select(.outputName == "out") | .outputPath' <<<"${TARGETS}" >/tmp/out-targets.txt
grep '^/nix/store/' /tmp/built-outputs.txt 2>/dev/null |
  grep -Fxf /tmp/out-targets.txt >/tmp/push-outputs.txt || true

printf 'Publishing %s of %s realised outputs to Cachix.\n' \
  "$(wc -l </tmp/push-outputs.txt)" "$(wc -l </tmp/out-targets.txt)"
