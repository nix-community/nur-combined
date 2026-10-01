{
  pkgs ? import <nixpkgs> { },
}:
{
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  nixosModules.fluxdown = ./modules/fluxdown.nix;
}
