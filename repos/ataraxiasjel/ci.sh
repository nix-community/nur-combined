#!/usr/bin/env bash
set -euo pipefail

args=(
  --accept-flake-config
  --gc-roots-dir gcroot
  --max-memory-size "12000"
  --option allow-import-from-derivation false
  --option restrict-eval true
  --show-trace
  --workers 4
  "$@"
)

exitCode=0
attrsWithError=()
for job in $(nix-eval-jobs "${args[@]}" 2>/dev/null | jq -r '. | @base64'); do
  job=$(echo "$job" | base64 -d)
  attr=$(echo "$job" | jq -r .attr)
  echo "### $attr"
  error=$(echo "$job" | jq -r .error)
  if [[ $error != null ]]; then
    echo "### ❌ $attr"
    echo
    echo "<details><summary>Eval error:</summary><pre>"
    echo "$error"
    echo "</pre></details>"
    attrsWithError+=($attr)
    exitCode=1
  else
    echo "### ✅ $attr"
  fi
done

if [[ $exitCode == 1 ]]; then
  echo "### ❌ Errors in: ${attrsWithError[*]}"
fi
exit $exitCode
