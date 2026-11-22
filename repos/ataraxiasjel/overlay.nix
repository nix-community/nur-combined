_final: prev:
let
  ci = import ./ci.nix { pkgs = prev; };
in
ci.notReserved
