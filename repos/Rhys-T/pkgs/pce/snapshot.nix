{callPackage, fetchurl, lib, ...}@args: let
    thruArgs = removeAttrs args ["callPackage" "fetchurl"];
    version = "0.2.2-unstable-2025-04-20";
    gitRev = "cc0c583cfdd3e77f1d9a698838ec658ba11f5cfd";
    version' = "${builtins.concatStringsSep "" (lib.drop 2 (lib.strings.splitString "-" version))}-${builtins.substring 0 8 gitRev}";
in callPackage ./generic.nix (thruArgs // {
    inherit version gitRev;
    includesUnfreeROMs = false;
    src = fetchurl {
        url = "http://www.hampa.ch/pub/pce/pre/pce-${version'}/pce-${version'}.tar.gz";
        hash = "sha256-MqN/Abucq6qcxbXg9yJodV8yEUMMV/g4cdpnxa7dcRc=";
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
