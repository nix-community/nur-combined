{ system ? builtins.currentSystem }:

# Use flake.nix devshell, similar to "nix develop"
(builtins.getFlake (toString ./.)).devShells.${system}.default

