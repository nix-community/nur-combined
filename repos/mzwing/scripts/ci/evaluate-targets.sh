#!/usr/bin/env bash
# Every package this repository can cache, for mzwing/nix-actions' distributed-build workflow.
set -euo pipefail

# Assign first: a command substitution that fails inside printf's argument list leaves the step green and hands an empty `targets` to the next one.
targets="$(nix eval --json --impure --file ci/targets.nix)"
printf 'targets=%s\n' "${targets}" >>"${GITHUB_OUTPUT}"
