#! /usr/bin/env -S sd nix shell
#! nix-shell -p nixfmt-rfc-style

nixfmt -v $(find -type f -name '*.nix' )
