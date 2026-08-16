{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-08-15";
    hash = "sha256-vin+Vcj8NzPl9i2nZOCSozngleQQG/xvqr1kxpqudas=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        isCE = true;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "0638fb094a60a74688ab55cd8473c55411ec231f";
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
