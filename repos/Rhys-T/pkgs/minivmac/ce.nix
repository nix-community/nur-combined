{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-06-22";
    hash = "sha256-7TZ1qfZkRNaH0YRkCQg6HbRP16W+PlEF/n7+KIirTLw=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        isCE = true;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "05129c767a61922ac6177c446373baf49da6e627";
            # Remove unfree disk and ROM images:
            sparseCheckout = [
                "/"
                "/extras/mydriver" # Not really used right now
                "/setup"
                "/src"
            ];
            inherit hash;
        };
        updateScript = unstableGitUpdater {
            tagConverter = writeShellScript "minivmac-ce-tag-converter" ''
                sed -E 's/$/-ce/'
            '';
        };
    });
in minivmac
