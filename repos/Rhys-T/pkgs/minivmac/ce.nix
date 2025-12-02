{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2025-12-02";
    hash = "sha256-izcX5VkiQcDpootlLLPNuAk/06+PO17cg6+dyws223Y=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "c8e7e3c752d8328bcda2fbaacd35f58a0388f248";
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
