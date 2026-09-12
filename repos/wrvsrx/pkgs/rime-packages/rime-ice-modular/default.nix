{ callPackage }:
let
  rime-ice-modular-src = callPackage ./rime-ice-modular-src.nix { };
  components = import ./components.nix { inherit rime-ice-modular-src callPackage; };
in
components
