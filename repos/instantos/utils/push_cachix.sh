#!/usr/bin/env bash

main() {
   token="${1:-$(pass Development/instantOScachixToken)}"
   export CACHIX_SIGNING_KEY="$token"
   [ ! -z "$1" ] && shift

    nix-env -q cachix ||
        nix-env -iA cachix -f https://cachix.org/api/v1/install
    cachix authtoken "$token"
    nix-build "$@" |
        cachix push instantos
}

if [ "$0" = "$BASH_SOURCE" ]; then
    main "$@"
fi

