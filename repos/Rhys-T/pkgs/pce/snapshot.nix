{callPackage, fetchurl, lib, ...}@args: let
    thruArgs = removeAttrs args ["callPackage" "fetchurl"];
    version = "0.2.2-unstable-2024-01-22";
    gitRev = "5a67b2a9e1e3e3d5be767ecf7f8bf2a2265ae0d9";
    version' = "${builtins.concatStringsSep "" (lib.drop 2 (lib.strings.splitString "-" version))}-${builtins.substring 0 8 gitRev}";
in callPackage ./generic.nix (thruArgs // {
    inherit version gitRev;
    includesUnfreeROMs = false;
    src = fetchurl {
        url = "http://www.hampa.ch/pub/pce/pre/pce-${version'}/pce-${version'}.tar.gz";
        hash = "sha256-9a6F2/DrjGby7f0IGOT1oEpeLuNdiedBgtVtZiiR8zQ=";
    };
    supportsSDL2 = true;
})
