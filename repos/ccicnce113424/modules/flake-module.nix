{ ... }:
let
  modules = import ./module-list.nix;
in
{
  flake = {
    inherit (modules) nixosModules;
  };
}
