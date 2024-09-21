{callPackage, fetchurl, lib, ...}@args: let
    thruArgs = removeAttrs args ["callPackage" "fetchurl"];
    version = "0.2.2-unstable-2024-01-22";
    version' = "20240122-5a67b2a9";
in callPackage ./generic.nix (thruArgs // rec {
    inherit version;
    includesUnfreeROMs = false;
    src = fetchurl {
        url = http://www.hampa.ch/pub/pce/pre + "/pce-${version'}/pce-${version'}.tar.gz";
        hash = "sha256-9a6F2/DrjGby7f0IGOT1oEpeLuNdiedBgtVtZiiR8zQ=";
    };
    supportsSDL2 = true;
})
