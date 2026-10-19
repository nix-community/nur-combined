# Standalone nixpkgs overlay, without the NUR namespace.
_final: prev:
let
  nur = import ./default.nix { pkgs = prev; };
in
builtins.removeAttrs nur [ "overlays" ]
