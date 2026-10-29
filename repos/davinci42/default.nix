{
  pkgs ? import <nixpkgs> { },
}:
{
  basic-memory = pkgs.callPackage ./pkgs/basic-memory { };
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  magpie = pkgs.callPackage ./pkgs/magpie { };
  mnamer-rs = pkgs.callPackage ./pkgs/mnamer-rs { };
  nixosModules = {
    fluxdown = ./modules/fluxdown.nix;
    magpie = ./modules/magpie-nixos.nix;
  };
  darwinModules = {
    magpie = ./modules/magpie-darwin.nix;
  };
}
