#/usr/bin/env bash

set -x
store=$1; shift
drvs=$@

set -x
nix copy --from $store --derivation $drvs
nix build -L --no-link --extra-substituters $store $drvs
#nix build -L --no-link --substituters $store $drvs
nix copy --to $store --no-check-sigs $drvs
