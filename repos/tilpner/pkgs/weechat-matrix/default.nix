{ pkgs }:

let
  inherit (pkgs.python3Packages) callPackage;
  self = rec {
    olm = callPackage ./olm.nix {};
    python-olm = callPackage ./python-olm.nix { inherit olm; };
    unpaddedbase64 = callPackage ./unpaddedbase64.nix {};
    matrix-nio = callPackage ./matrix-nio.nix { inherit python-olm unpaddedbase64; };
    weechat-matrix = callPackage ./weechat-matrix.nix { inherit matrix-nio; };
  };
in self
