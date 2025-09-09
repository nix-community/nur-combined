{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2025-05-21";
    hash = "sha256-FNGlHOEbJhgPOCQkzTYFd604Ypk+8F8SyHPsCY/nVt0=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "bd5cd855f97568697169474ff1ed779a00bd796d";
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
