{
  pkgs ? import <nixpkgs> { },
}:
{
  basic-memory = pkgs.callPackage ./pkgs/basic-memory { };
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  mnamer-rs = pkgs.callPackage ./pkgs/mnamer-rs { };
  rsshub = pkgs.callPackage ./pkgs/rsshub { };
  nixosModules = {
    fluxdown = ./modules/fluxdown.nix;
  };
  darwinModules.nh = ./modules/nh-darwin;
}
