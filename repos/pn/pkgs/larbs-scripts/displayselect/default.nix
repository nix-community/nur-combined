{ callPackage }:
let
  wrapDS = callPackage ./wrapper.nix { };
  ds = callPackage ./displayselect.nix { };
in
  wrapDS ds { }
