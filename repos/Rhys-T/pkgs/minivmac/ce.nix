{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-09-16";
    hash = "sha256-Y91MIju+hO67UGkRCmxOD6Ooj0vNiEwnVAD2KgHHR/k=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        isCE = true;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "3bf43efd8a53a9ffb99240d101ca895f120c704a";
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
