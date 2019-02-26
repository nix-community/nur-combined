{ pkgs }:

let
  inherit (pkgs.python2Packages) callPackage;
  self = rec {
    python-olm = callPackage ./python-olm.nix {};
    unpaddedbase64 = callPackage ./unpaddedbase64.nix {};
    matrix-nio = callPackage ./matrix-nio.nix { inherit python-olm unpaddedbase64; };
    weechat-matrix = callPackage ./weechat-matrix.nix { };
  };
in self
