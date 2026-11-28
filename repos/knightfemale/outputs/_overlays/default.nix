final: prev:
let
  inherit (prev) lib;

  overlays = [
    (import ./deviceTrees.nix)
    (import ./lib.nix)
    (import ./packages.nix)
    (import ./python314Packages.nix)
  ];
in
lib.composeManyExtensions overlays final prev
