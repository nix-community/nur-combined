{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-01-31";
    hash = "sha256-9GpLCi/KJiarw5MxpLfGtZCJJRs5JCTN2/dP4E44i5I=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "fa6dda82bcd53d3172962172a2bcecf53d1d85d9";
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
