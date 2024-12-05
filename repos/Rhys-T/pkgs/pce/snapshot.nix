{callPackage, fetchurl, lib, ...}@args: let
    thruArgs = removeAttrs args ["callPackage" "fetchurl"];
    version = "0.2.2-unstable-2024-10-18";
    gitRev = "86b4a1a05e6614f8d4b6ff8ed033114985e3c5a5";
    version' = "${builtins.concatStringsSep "" (lib.drop 2 (lib.strings.splitString "-" version))}-${builtins.substring 0 8 gitRev}";
in callPackage ./generic.nix (thruArgs // {
    inherit version gitRev;
    includesUnfreeROMs = false;
    src = fetchurl {
        url = "http://www.hampa.ch/pub/pce/pre/pce-${version'}/pce-${version'}.tar.gz";
        hash = "sha256-6YmA4xoh+LycLPQ1AZS7yjz5RgPBR4tfc01z7gMkcRY=";
    };
    supportsSDL2 = true;
    appNames = [
        "aym"
        "pce-atarist"
        "pce-cpm80"
        "pce-dos"
        "pce-ibmpc"
        "pce-img"
        "pce-macplus"
        "pce-rc759"
        "pce-sim405"
        "pce-simarm"
        "pce-sims32"
        "pce-spectrum"
        "pce-vic20"
        "pfi"
        "pri"
        "psi"
        "pti"
    ];
})
