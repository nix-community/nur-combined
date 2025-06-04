#!/usr/bin/env -S nix shell nixpkgs#fish nixpkgs#nix-update --command fish
# shellcheck disable=all
set SYSTEM $(nix eval --impure --raw --expr 'builtins.currentSystem')
set PKGS $(nix eval --raw .\#packages."$SYSTEM" --apply 'attrs: builtins.toString (builtins.attrNames attrs)')

set EXCLUDED_PKGS [ lyricer aya-prover-lsp dnsmasq-china-list_smartdns ]

for pkg in (string split ' ' $PKGS)
    if not contains $pkg $EXCLUDED_PKGS;
        echo "Updating" $pkg "..."
        set -a ARGS $(nix eval --raw .\#updateArgs --apply "attrs: attrs.$pkg or \"\"")
        eval nix-update $pkg $ARGS
        echo "Successfully updated" $pkg"."
    end
end
