with builtins;
let
  flake = getFlake (toString ./.);
in
flake.outputs
