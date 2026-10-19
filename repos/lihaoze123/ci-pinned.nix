let
  flake = builtins.getFlake (toString ./.);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
in
import ./ci.nix { inherit pkgs; nurAttrs = flake.packages.x86_64-linux; }
