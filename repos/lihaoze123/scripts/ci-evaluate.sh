#!/usr/bin/env bash
set -euo pipefail

# Keep successful evaluations even if another package fails.
eval_status=0
nix-eval-jobs --workers 2 --max-memory-size 2048 \
  --flake '.#ciMetadata.x86_64-linux.buildJobPackages' \
  > ci-evaluation.jsonl || eval_status=$?
EVAL_EXIT_CODE="$eval_status" python3 scripts/ci-plan.py ci-evaluation.jsonl
