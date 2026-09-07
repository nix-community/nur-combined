{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-09-03";
    hash = "sha256-hudeEtAZC/8DLANLzO9NE+pRYMNd71rAKCGjG3AEypA=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        isCE = true;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "f4d08ef0a978c03fef0122708b56857cbd368bba";
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
