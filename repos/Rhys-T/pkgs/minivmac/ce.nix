{ callPackage, fetchFromGitHub, unstableGitUpdater, writeShellScript, ... }@args: let
    version = "37.03-ce-unstable-2026-04-23";
    hash = "sha256-W0rJuvHOaHUc5ZhkzXvWfBsbZp/x6/7k30Q/aho5xBs=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = fetchFromGitHub {
            owner = "minivmac";
            repo = "minivmac";
            rev = "9c498eaac63250f0a754b92d5dc5cf47d34d009c";
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
