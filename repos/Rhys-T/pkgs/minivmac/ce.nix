{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-09-17";
    hash = "sha256-hudeEtAZC/8DLANLzO9NE+pRYMNd71rAKCGjG3AEypA=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        isCE = true;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "6860a9a7f372c461b25dc42974b191a453ebcfb2";
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
