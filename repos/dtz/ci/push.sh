#!/usr/bin/env bash

set -euo pipefail

CACHIX_CACHE=${CACHIX_CACHE:-allvm}

function push_paths () {
  echo "realizing paths..."
  nix build $@ --no-link
  local drvs=$(nix-store -q --deriver $@)
  echo "derivers: "
  echo "$drvs" | sed -e 's/^/  /'
  echo "realizing...."
  echo $drvs | xargs nix-store -r 2>&1 | sed -e 's/^/  /'
  echo "computing closure (including outputs....)"
  local closure=$(echo $drvs | xargs nix-store -qR --include-outputs)
  echo "closure size: $(echo "$closure" | wc -l)"
  echo "pushing..."
  echo $closure | cachix push ${CACHIX_CACHE} 2>&1 | sed -e 's/^/  /'
  echo "done!"
}

# If triggered by cron, ensure build closure is pushed too
if [[ $TRAVIS_EVENT_TYPE == "cron" ]]; then

  echo "Pushing build (and runtime) closures..."
  push_paths $@

else
  echo "Pushing runtime closures..."
  cachix push ${CACHIX_CACHE} $@
fi
