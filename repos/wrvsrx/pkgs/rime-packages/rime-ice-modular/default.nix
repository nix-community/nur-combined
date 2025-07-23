{ callPackage, source }:
let
  rime-ice-modular-src = callPackage ./rime-ice-modular-src.nix { inherit source; };
  components = import ./components.nix { inherit rime-ice-modular-src callPackage; };
in
components
