#!/bin/bash

eval_output=$(nix-eval-jobs --gc-roots-dir gcroot --argstr nixosVersion "${CHANNEL_BRANCH}" --check-cache-status all-unbroken.nix)

while IFS= read -r line; do
    is_cached=$(echo "$line" | jq '.isCached')
    drv_path=$(echo "$line" | jq '.drvPath' | tr -d '"')
    if [[ "$is_cached" == "false" ]]; then
        result+=("$drv_path")
    fi
done <<< "$eval_output"

if [[ ${#result[@]} -ne 0 ]]; then
    echo "Building the folling derivations: ${result[*]}"
    echo cachix watch-exec "${CACHIX_CACHE}" -- nix-build --argstr nixosVersion "${CHANNEL_BRANCH}" ${result[*]} --show-trace
    cachix watch-exec "${CACHIX_CACHE}" -- nix-build --argstr nixosVersion "${CHANNEL_BRANCH}" ${result[*]} --show-trace
fi
rm -rf gcroot

remaining=$(nix-build --dry-run --argstr nixosVersion all-unbroken.nix 2>&1 | awk '/^these.*derivations will be built/,/^these.*paths will be fetched/' | sed '1d;$d')
count=$(echo $remaining | wc -l)
if [ $c -gt 0 ]; then
    echo "There remains $count derivations to be built:"
    echo $remaining
    exit 1
else
    echo "No new derivations to build, everything is up-to-date."
fi
